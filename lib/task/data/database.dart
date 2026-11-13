import 'package:drift/drift.dart';
import 'package:e1547/identity/data/database.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/task/task.dart';

@UseRowClass(Task, generateInsertable: true)
class TasksTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => textEnum<TaskAction>()();
  IntColumn get postId => integer()();
  TextColumn get status => textEnum<TaskStatus>()();
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get metadata => text()
      .map(
        JsonSqlConverter<TaskMetadata>(
          decode: (value) =>
              TaskMetadata.fromJson(value as Map<String, dynamic>),
        ),
      )
      .nullable()();
}

@DataClassName('TaskIdentity')
class TasksIdentitiesTable extends Table {
  IntColumn get identity => integer().references(
    IdentitiesTable,
    #id,
    onDelete: KeyAction.noAction,
    onUpdate: KeyAction.noAction,
  )();
  IntColumn get task => integer().references(
    TasksTable,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();

  @override
  Set<Column> get primaryKey => {identity, task};
}

@DriftAccessor(tables: [TasksTable, TasksIdentitiesTable, IdentitiesTable])
class TaskRepository extends DatabaseAccessor<GeneratedDatabase>
    with $TaskRepositoryMixin {
  TaskRepository({required GeneratedDatabase database}) : super(database);

  /// Failed tasks are retained by age instead of count: they stay
  /// available for retry until [failedRetention] has passed since they
  /// finished, with no limit on how many pile up within that window.
  static const Duration failedRetention = Duration(days: 7);

  StreamFuture<Task> get(int id) => (select(
    tasksTable,
  )..where((tbl) => tbl.id.equals(id))).watchSingle().future;

  Expression<bool> _identityQuery($TasksTableTable tbl, int? identity) {
    final subQuery = tasksIdentitiesTable.selectOnly()
      ..addColumns([tasksIdentitiesTable.task]);
    if (identity != null) {
      // A plain equality lets SQLite use the association table's composite
      // primary key, whose identity column comes first; the previous
      // "argument null or identity equal" shape could only scan the whole
      // table. A null identity still matches every associated task.
      subQuery.where(tasksIdentitiesTable.identity.equals(identity));
    }

    return tbl.id.isInQuery(subQuery);
  }

  SimpleSelectStatement<TasksTable, Task> _querySelect({
    int? limit,
    int? offset,
    int? identity,
    Set<TaskAction>? actions,
    Set<TaskStatus>? statuses,
  }) {
    final selectable = select(tasksTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..where((tbl) => _identityQuery(tbl, identity));
    if (actions != null) {
      selectable.where((tbl) => tbl.action.isIn(actions.map((e) => e.name)));
    }
    if (statuses != null) {
      selectable.where((tbl) => tbl.status.isIn(statuses.map((e) => e.name)));
    }
    assert(
      offset == null || limit != null,
      'Cannot specify offset without limit!',
    );
    if (limit != null) {
      selectable.limit(limit, offset: offset);
    }
    return selectable;
  }

  StreamFuture<List<Task>> page({
    int? page,
    int? limit,
    int? identity,
    Set<TaskAction>? actions,
    Set<TaskStatus>? statuses,
  }) {
    page ??= 1;
    limit ??= 80;
    final int offset = (page < 1 ? 0 : page - 1) * limit;
    return _querySelect(
      limit: limit,
      offset: offset,
      identity: identity,
      actions: actions,
      statuses: statuses,
    ).watch().future;
  }

  StreamFuture<List<Task>> all({int? identity}) =>
      _querySelect(identity: identity).watch().future;

  StreamFuture<List<Task>> active({int? identity}) => _querySelect(
    identity: identity,
    statuses: {TaskStatus.pending, TaskStatus.running},
  ).watch().future;

  StreamFuture<int> length({
    int? identity,
    Set<TaskAction>? actions,
    Set<TaskStatus>? statuses,
  }) {
    final Expression<int> count = tasksTable.id.count();
    final selectable = selectOnly(tasksTable)
      ..where(_identityQuery(tasksTable, identity))
      ..addColumns([count]);
    if (actions != null) {
      selectable.where(tasksTable.action.isIn(actions.map((e) => e.name)));
    }
    if (statuses != null) {
      selectable.where(tasksTable.status.isIn(statuses.map((e) => e.name)));
    }
    return selectable.map((row) => row.read(count)!).watchSingle().future;
  }

  /// Returns the tasks with the given ids.
  Future<List<Task>> getAll(List<int> ids) =>
      (select(tasksTable)..where((tbl) => tbl.id.isIn(ids))).get();

  /// Returns the active task that [request] would duplicate, if any.
  ///
  /// A duplicate shares the identity, action and post of the request. For
  /// downloads the file url must match as well, so a post whose file was
  /// replaced can be downloaded again. Tasks that already reached a
  /// terminal state never block a fresh request.
  Future<Task?> _findActiveDuplicate(TaskRequest request, int identity) async {
    final List<Task> candidates =
        await (select(tasksTable)
              ..where((tbl) => _identityQuery(tbl, identity))
              ..where((tbl) => tbl.action.equals(request.action.name))
              ..where((tbl) => tbl.postId.equals(request.postId))
              ..where(
                (tbl) => tbl.status.isIn(
                  [TaskStatus.pending, TaskStatus.running].map((e) => e.name),
                ),
              ))
            .get();
    for (final Task candidate in candidates) {
      if (request.action == TaskAction.download &&
          candidate.metadata?.fileUrl != request.metadata?.fileUrl) {
        continue;
      }
      return candidate;
    }
    return null;
  }

  /// Inserts a task, unless an identical one is already queued or running.
  ///
  /// A duplicate request merges into that task, which is returned instead
  /// of a newly created one, so no worker or byte of bandwidth is spent
  /// twice on the same goal.
  Future<Task> add(TaskRequest item, int identity) => transaction(() async {
    final Task? duplicate = await _findActiveDuplicate(item, identity);
    if (duplicate != null) return duplicate;
    final Task task = await into(tasksTable).insertReturning(
      TaskCompanion(
        action: Value(item.action),
        postId: Value(item.postId),
        status: const Value(TaskStatus.pending),
        createdAt: Value(DateTime.now()),
        metadata: Value(item.metadata),
      ),
    );
    await into(tasksIdentitiesTable).insert(
      TaskIdentityCompanion(identity: Value(identity), task: Value(task.id)),
    );
    return task;
  });

  /// Inserts a batch of tasks, merging requests that duplicate an already
  /// active task instead of inserting a second copy of it.
  ///
  /// Returns which tasks were newly created and which already active tasks
  /// absorbed a duplicate request; requests within one batch also dedupe
  /// against the tasks inserted just before them. The whole pass is one
  /// transaction, so a concurrent enqueue either sees none or all of it.
  Future<({List<Task> created, List<Task> merged})> addAll(
    Iterable<TaskRequest> items,
    int identity,
  ) => transaction(() async {
    final DateTime now = DateTime.now();
    final List<Task> created = [];
    final List<Task> merged = [];
    final Set<int> reportedIds = {};
    for (final item in items) {
      final Task? duplicate = await _findActiveDuplicate(item, identity);
      if (duplicate != null) {
        if (reportedIds.add(duplicate.id)) {
          merged.add(duplicate);
        }
        continue;
      }
      final Task task = await into(tasksTable).insertReturning(
        TaskCompanion(
          action: Value(item.action),
          postId: Value(item.postId),
          status: const Value(TaskStatus.pending),
          createdAt: Value(now),
          metadata: Value(item.metadata),
        ),
      );
      created.add(task);
      reportedIds.add(task.id);
    }
    await batch((b) {
      b.insertAll(
        tasksIdentitiesTable,
        created
            .map(
              (task) => TaskIdentityCompanion(
                identity: Value(identity),
                task: Value(task.id),
              ),
            )
            .toList(),
      );
    });
    return (created: created, merged: merged);
  });

  Future<Task?> claimNext({int? identity, Set<TaskAction>? actions}) async =>
      transaction(() async {
        final query = select(tasksTable)
          ..where((tbl) => _identityQuery(tbl, identity))
          ..where((tbl) => tbl.status.equals(TaskStatus.pending.name));
        if (actions != null) {
          query.where((tbl) => tbl.action.isIn(actions.map((e) => e.name)));
        }
        query
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt),
            (t) => OrderingTerm(expression: t.id),
          ])
          ..limit(1);
        final Task? next = await query.getSingleOrNull();
        if (next == null) return null;
        return (update(tasksTable)..where((tbl) => tbl.id.equals(next.id)))
            .writeReturning(
              const TaskCompanion(status: Value(TaskStatus.running)),
            )
            .then((rows) => rows.single);
      });

  Future<void> markCompleted(int id) =>
      (update(tasksTable)..where((tbl) => tbl.id.equals(id))).write(
        TaskCompanion(
          status: const Value(TaskStatus.completed),
          error: const Value(null),
          completedAt: Value(DateTime.now()),
        ),
      );

  Future<void> markFailed(int id, String error) =>
      (update(tasksTable)..where((tbl) => tbl.id.equals(id))).write(
        TaskCompanion(
          status: const Value(TaskStatus.failed),
          error: Value(error),
          completedAt: Value(DateTime.now()),
        ),
      );

  /// Cancels a task unless it already reached a terminal state.
  ///
  /// Returns the status the task had before: pending tasks never reach a
  /// worker, so their caller counts the canceled outcome itself, while
  /// running tasks are aborted and reported by the worker that owns them.
  Future<TaskStatus?> markCanceled(int id) => transaction(() async {
    final TaskStatus? status = await readStatus(id);
    if (status == null || status.isTerminal) return status;
    await (update(tasksTable)..where((tbl) => tbl.id.equals(id))).write(
      TaskCompanion(
        status: const Value(TaskStatus.canceled),
        error: const Value(null),
        completedAt: Value(DateTime.now()),
      ),
    );
    return status;
  });

  /// Returns a claimed running task to the pending queue, e.g. when the
  /// controller that claimed it is disposed. Tasks that were canceled or
  /// already finished in the meantime keep their status.
  Future<void> release(int id) =>
      (update(tasksTable)
            ..where((tbl) => tbl.id.equals(id))
            ..where((tbl) => tbl.status.equals(TaskStatus.running.name)))
          .write(const TaskCompanion(status: Value(TaskStatus.pending)));

  /// Cancels the given tasks, or every active task of [identity] when
  /// [ids] is null, in a single database write.
  ///
  /// The tasks are returned with the status they had before cancellation:
  /// those that were still pending never reach a worker, so their caller
  /// counts their outcome from the returned statuses itself, while running
  /// ones are aborted and classified by their workers. The read and the
  /// write share one transaction, so a task cannot be claimed in between.
  Future<List<Task>> cancelTasks({List<int>? ids, int? identity}) =>
      transaction(() async {
        final query = select(tasksTable)
          ..where(
            (tbl) => tbl.status.isIn(
              [TaskStatus.pending, TaskStatus.running].map((e) => e.name),
            ),
          );
        if (ids != null) {
          query.where((tbl) => tbl.id.isIn(ids));
        } else {
          query.where((tbl) => _identityQuery(tbl, identity));
        }
        final List<Task> active = await query.get();
        if (active.isEmpty) return const <Task>[];
        await (update(
          tasksTable,
        )..where((tbl) => tbl.id.isIn(active.map((e) => e.id)))).write(
          TaskCompanion(
            status: const Value(TaskStatus.canceled),
            error: const Value(null),
            completedAt: Value(DateTime.now()),
          ),
        );
        return active;
      });

  Future<int> clear({required Set<TaskStatus> statuses, int? identity}) =>
      (delete(tasksTable)
            ..where((tbl) => _identityQuery(tbl, identity))
            ..where((tbl) => tbl.status.isIn(statuses.map((e) => e.name))))
          .go();

  Future<TaskStatus?> readStatus(int id) async {
    final task = await (select(
      tasksTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return task?.status;
  }

  Future<void> resetRunning({int? identity}) =>
      (update(tasksTable)
            ..where((tbl) => _identityQuery(tbl, identity))
            ..where((tbl) => tbl.status.equals(TaskStatus.running.name)))
          .write(const TaskCompanion(status: Value(TaskStatus.pending)));

  Future<void> remove(int id) => removeAll([id]);

  Future<void> removeAll(List<int>? ids, {int? identity}) {
    final query = delete(tasksTable)
      ..where((tbl) => _identityQuery(tbl, identity));
    if (ids != null) {
      query.where((tbl) => tbl.id.isIn(ids));
    }
    return query.go();
  }

  Future<int> sweep({
    required TaskAction action,
    required TaskStatus status,
    required Duration maxAge,
  }) {
    final threshold = DateTime.now().subtract(maxAge);
    return (delete(tasksTable)
          ..where((tbl) => tbl.action.equals(action.name))
          ..where((tbl) => tbl.status.equals(status.name))
          ..where((tbl) => tbl.completedAt.isSmallerThanValue(threshold)))
        .go();
  }
}
