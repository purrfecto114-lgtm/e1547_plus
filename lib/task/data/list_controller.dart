import 'dart:async';

import 'package:e1547/app/app.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/task/task.dart';
import 'package:flutter/foundation.dart';

/// How many finished tasks one page of the task history holds.
const int taskHistoryPageSize = 80;

/// Serves the task page: the always-small list of active tasks as one live
/// query, and the task history in pages.
///
/// Active tasks are shown immediately and in full, while history is only
/// queried a page at a time, so opening the task page does not read and
/// rebuild a whole task table that may hold thousands of entries. Every
/// loaded page stays a live query, so history entries keep updating as
/// their tasks settle.
class TasksListController extends ChangeNotifier {
  TasksListController({required this.repository, required this.identity}) {
    _listen();
  }

  final TaskRepository repository;
  final int identity;

  /// The statuses that make up the task history, as opposed to the active
  /// tasks.
  static const Set<TaskStatus> _historyStatuses = {
    TaskStatus.completed,
    TaskStatus.failed,
    TaskStatus.canceled,
  };

  StreamSubscription<List<Task>>? _activeSub;
  final Map<int, StreamSubscription<List<Task>>> _historySubs = {};

  bool _disposed = false;

  List<Task>? _active;

  /// The active tasks, or null while they are still loading.
  List<Task>? get activeTasks => _active;

  /// The active tasks followed by every loaded history page, or null while
  /// the first load is still pending.
  List<Task>? get items => _items;
  List<Task>? _items;

  Object? _error;
  Object? get error => _error;

  /// Whether the next history page is being loaded.
  bool _loadingNextPage = false;

  /// Whether [fetchNextPage] has been called at least once. Until then the
  /// history stays at its first page and reports no next page, so a caller
  /// that is not wired to this controller sees a stable list instead of an
  /// endless loading spinner.
  bool _pagingEnabled = false;

  /// The loaded history pages, in order; the page at index 0 is page 1.
  final List<List<Task>> _historyPages = <List<Task>>[];

  PagingState<int, Task> get state {
    if (_active == null) return PagingState();
    // The same id-based deduplication _rebuildItems applies: a task that
    // settled between the live query and a history page must not show up
    // in both, or the paged list renders one row twice while the
    // selection works on the flattened items.
    final Set<int> seen = _active!.map((task) => task.id).toSet();
    return PagingState(
      pages: [
        _active!,
        for (final List<Task> page in _historyPages)
          [for (final Task task in page) if (seen.add(task.id)) task],
      ],
      keys: [
        for (int i = 0; i <= _historyPages.length; i++) i,
      ],
      error: _error,
      hasNextPage: _pagingEnabled && _hasNextHistoryPage,
      isLoading: (_active == null && _error == null) || _loadingNextPage,
    );
  }

  /// Whether another history page is likely to exist: the last loaded page
  /// was full.
  bool get _hasNextHistoryPage {
    if (_historyPages.isEmpty) return false;
    return _historyPages.last.length >= taskHistoryPageSize;
  }

  void _listen() {
    _activeSub = repository
        .active(identity: identity)
        .stream
        .listen(
          (tasks) {
            _active = tasks;
            _error = null;
            _rebuildItems();
            notifyListeners();
          },
          onError: (Object error) {
            _error = error;
            notifyListeners();
          },
        );
    unawaited(_loadHistoryPage(1));
  }

  /// Loads the next page of task history and opts the controller into
  /// reporting that a next page exists.
  ///
  /// Each loaded page stays a live query, so history entries update as
  /// their tasks settle without reloading everything before them.
  Future<void> fetchNextPage() async {
    _pagingEnabled = true;
    if (_loadingNextPage) return;
    await _loadHistoryPage(_historyPages.length + 1);
  }

  Future<void> _loadHistoryPage(int page) async {
    if (_disposed) return;
    if (_historySubs.containsKey(page)) return;
    final StreamFuture<List<Task>> query = repository.page(
      page: page,
      limit: taskHistoryPageSize,
      identity: identity,
      statuses: _historyStatuses,
    );
    _historySubs[page] = query.stream.listen(
      (tasks) {
        if (_historyPages.length < page) {
          _historyPages.add(tasks);
        } else {
          _historyPages[page - 1] = tasks;
        }
        _error = null;
        _rebuildItems();
        notifyListeners();
      },
      onError: (Object error) {
        _failHistoryPage(page);
        _error = error;
        notifyListeners();
      },
    );
    if (page > 1) {
      // the first emission of a new page is its load; page 1 loads as part
      // of the initial load
      _loadingNextPage = true;
      notifyListeners();
      try {
        await query;
      } on Object catch (error) {
        // the subscription reports this as well; keeping it here makes the
        // awaiting caller end in the same error state
        _failHistoryPage(page);
        _error = error;
      }
      _loadingNextPage = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Drops a history page whose query failed.
  ///
  /// A failed query leaves a dead subscription behind: dropping its key
  /// lets a later [fetchNextPage] load the page again instead of silently
  /// doing nothing. Both error paths — the stream's and the awaiting
  /// caller's — run through here, whichever fires first, so the cleanup
  /// is safe to run twice for the same failure.
  void _failHistoryPage(int page) {
    _historySubs.remove(page)?.cancel();
  }

  /// Flattens the active tasks and the loaded history pages into one list,
  /// deduplicated by id: a task moving between the live queries can be in
  /// two page caches for a moment.
  void _rebuildItems() {
    final List<Task>? active = _active;
    if (active == null) {
      _items = null;
      return;
    }
    if (_historyPages.isEmpty) {
      _items = List<Task>.of(active);
      return;
    }
    final Set<int> seen = active.map((task) => task.id).toSet();
    _items = [
      ...active,
      for (final List<Task> page in _historyPages)
        for (final Task task in page)
          if (seen.add(task.id)) task,
    ];
  }

  /// Re-subscribes to the task streams, e.g. after a database failure
  /// left the list in an error state.
  void retry() {
    _activeSub?.cancel();
    for (final StreamSubscription<List<Task>> subscription
        in _historySubs.values) {
      subscription.cancel();
    }
    _historySubs.clear();
    _historyPages.clear();
    _active = null;
    _items = null;
    _loadingNextPage = false;
    _error = null;
    notifyListeners();
    _listen();
  }

  @override
  void dispose() {
    _disposed = true;
    _activeSub?.cancel();
    for (final StreamSubscription<List<Task>> subscription
        in _historySubs.values) {
      subscription.cancel();
    }
    _historySubs.clear();
    super.dispose();
  }
}

class TasksListProvider
    extends
        SubChangeNotifierProvider2<
          AppStorage,
          IdentityClient,
          TasksListController
        > {
  TasksListProvider({super.child, super.builder})
    : super(
        create: (context, storage, identity) => TasksListController(
          repository: TaskRepository(database: storage.sqlite),
          identity: identity.identity.id,
        ),
      );
}
