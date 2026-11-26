import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';

import 'package:flutter/foundation.dart';

// ignore: always_use_package_imports
import 'storage.drift.dart';

class QueryStorageTable extends Table {
  TextColumn get key => text()();
  TextColumn get data => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get duration => integer().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftAccessor(tables: [QueryStorageTable])
class QueryStorageRepository extends DatabaseAccessor<GeneratedDatabase>
    with $QueryStorageRepositoryMixin {
  QueryStorageRepository({required GeneratedDatabase database})
    : super(database);

  Future<QueryStorageTableData?> get(String key) => (select(
    queryStorageTable,
  )..where((tbl) => tbl.key.equals(key))).getSingleOrNull();

  Future<void> put(QueryStorageTableData entry) =>
      into(queryStorageTable).insertOnConflictUpdate(entry);

  /// Commits [entries] and removes [removeKeys] in one transaction, or
  /// empties the whole table when [removeKeys] is null.
  ///
  /// A saved page of posts writes one row per post; batching those into a
  /// single drift [Batch] commits the whole burst as one transaction
  /// instead of one per row.
  Future<void> writeAll(
    List<QueryStorageTableData> entries, {
    List<String>? removeKeys,
  }) async {
    await batch((batch) {
      if (removeKeys == null) {
        batch.deleteAll(queryStorageTable);
      }
      for (final entry in entries) {
        batch.insert(
          queryStorageTable,
          entry,
          onConflict: DoUpdate((old) => entry),
        );
      }
      for (final key in removeKeys ?? const <String>[]) {
        batch.deleteWhere(queryStorageTable, (tbl) => tbl.key.equals(key));
      }
    });
  }

  Future<void> remove(String key) =>
      (delete(queryStorageTable)..where((tbl) => tbl.key.equals(key))).go();

  Future<void> removeAll() => delete(queryStorageTable).go();

  Future<int> count() async {
    final Expression<int> amount = queryStorageTable.key.count();
    final query = selectOnly(queryStorageTable)..addColumns([amount]);
    return await query.map((row) => row.read(amount)).getSingle() ?? 0;
  }

  Future<void> removeIdentity(int identity) => (delete(
    queryStorageTable,
  )..where((tbl) => tbl.key.like('["$identityKeyTag",$identity,%'))).go();

  Future<void> removeExpired(DateTime now) => (delete(
    queryStorageTable,
  )..where((tbl) => tbl.expiresAt.isSmallerThanValue(now))).go();

  Future<void> trim({required int maxAmount}) async {
    final oldest = selectOnly(queryStorageTable)
      ..addColumns([queryStorageTable.key])
      ..orderBy([
        OrderingTerm(
          expression: queryStorageTable.createdAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(-1, offset: maxAmount);

    await (delete(
      queryStorageTable,
    )..where((tbl) => tbl.key.isInQuery(oldest))).go();
  }
}

class DriftQueryStorage extends StorageInterface {
  DriftQueryStorage({required this.repository, this.maxEntries = 5000});

  final QueryStorageRepository repository;

  final int maxEntries;

  int? _estimatedEntries;

  /// Writes staged for the next commit, keyed by row: a later write of the
  /// same key replaces an earlier one, and a delete stages null.
  final Map<String, QueryStorageTableData?> _staged = {};

  /// The single queue of write turns, in call order. Every write — put,
  /// delete, deleteAll — is a turn that first stages its change; the
  /// commit runs after the last queued turn of a burst, so a page of puts
  /// lands as one transaction. A deleteAll turn is its own burst boundary:
  /// it commits immediately at its turn's end, so puts queued after it
  /// commit after the wipe, never inside it.
  Future<void> _writes = Future.value();

  /// Turns queued but not yet staged.
  int _pending = 0;

  /// Number of committed write batches, visible for testing.
  @visibleForTesting
  int flushes = 0;

  /// A deleteAll marker: it wipes the database and everything staged
  /// before its turn.
  static const String _wipeSentinel = '\u0000wipe';

  Future<void> _evict() async {
    _estimatedEntries ??= await repository.count();
    if (_estimatedEntries! <= maxEntries) return;
    await repository.removeExpired(DateTime.now());
    await repository.trim(maxAmount: maxEntries);
    _estimatedEntries = await repository.count();
  }

  void _enqueue(Future<void> Function() write, {bool boundary = false}) {
    _pending++;
    // The pending slot is released exactly once per turn — write and
    // commit outcomes alike — through whenComplete. A counter that
    // double-decrements on a failure would drift negative and every
    // later burst would stage forever without committing; one that
    // never decrements on failure stalls the queue the other way.
    _writes = _writes
        .then((_) => write())
        .then((_) async {
          // A boundary turn (deleteAll) commits on its own: the wipe must
          // not swallow a put queued after it, so the burst ends here.
          // Otherwise, only the last turn of a burst commits: while more
          // turns are queued, their writes belong in this same transaction.
          if (boundary || _pending == 1) {
            await _commitStaged();
          }
        })
        .catchError((_) {
          // A database error in this turn's write or commit is
          // swallowed — fire and forget like the writes themselves —
          // and the queue stays alive for later bursts. A failed commit
          // drops its staged writes; the next burst re-stages what it
          // still holds, and a fetch re-stores whatever the app needs.
        })
        .whenComplete(() {
          _pending--;
        });
  }

  @override
  Future<StoredQuery?> get(String key) async {
    // Writes are fire and forget, so a read has to wait for them.
    await _writes;
    final entry = await repository.get(key);
    if (entry == null) return null;
    return StoredQuery(
      key: entry.key,
      data: jsonDecode(entry.data),
      createdAt: entry.createdAt,
      storageDuration: entry.duration == null
          ? null
          : Duration(milliseconds: entry.duration!),
    );
  }

  @override
  void put(StoredQuery query) => _enqueue(() async {
    _staged[query.key] = QueryStorageTableData(
      key: query.key,
      data: jsonEncode(query.data),
      createdAt: query.createdAt,
      duration: query.storageDuration?.inMilliseconds,
      expiresAt: query.expiry,
    );
  });

  @override
  void delete(String key) => _enqueue(() async {
    _staged[key] = null;
  });

  @override
  void deleteAll() => _enqueue(() async {
    _staged[_wipeSentinel] = null;
  }, boundary: true);

  Future<void> _commitStaged() async {
    if (_staged.isEmpty) return;
    flushes++;
    final wipe = _staged.containsKey(_wipeSentinel);
    final puts = [
      for (final MapEntry(:key, :value) in _staged.entries)
        if (value != null && key != _wipeSentinel) value,
    ];
    final removes = [
      for (final MapEntry(:key, :value) in _staged.entries)
        if (value == null && key != _wipeSentinel) key,
    ];
    _staged.clear();
    await repository.writeAll(
      wipe ? const [] : puts,
      removeKeys: wipe ? null : removes,
    );
    if (wipe) {
      _estimatedEntries = 0;
    } else if (puts.isNotEmpty) {
      // One flush upserts many rows: the estimate tracks them all, or
      // the eviction trigger lags by (rows-per-flush - 1) per flush.
      _estimatedEntries =
          (_estimatedEntries ?? await repository.count()) + puts.length;
      await _evict();
    }
  }

  @override
  void close() {}
}

Future<void> removeIdentityQueries({
  required CachedQuery cache,
  required GeneratedDatabase database,
  required int identity,
}) async {
  cache.deleteCache(
    filterFn: (unencoded, _) =>
        unencoded is List &&
        unencoded.length >= 2 &&
        unencoded[0] == identityKeyTag &&
        unencoded[1] == identity,
  );
  await QueryStorageRepository(database: database).removeIdentity(identity);
}
