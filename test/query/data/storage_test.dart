import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
// ignore: always_use_package_imports
import 'package:e1547/query/data/storage.drift.dart';
import 'package:e1547/query/query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase sqlite;
  late QueryStorageRepository repository;
  late DriftQueryStorage storage;

  StoredQuery entry(
    String key,
    Object? data, {
    Duration? duration = const Duration(days: 1),
    DateTime? createdAt,
  }) => StoredQuery(
    key: key,
    data: data,
    createdAt: createdAt ?? DateTime.now(),
    storageDuration: duration,
  );

  /// [put] is fire and forget, so writes are drained through a read.
  Future<void> settle() => storage.get('drain');

  setUp(() {
    sqlite = AppDatabase(NativeDatabase.memory());
    repository = QueryStorageRepository(database: sqlite);
    storage = DriftQueryStorage(repository: repository, maxEntries: 3);
  });

  tearDown(() => sqlite.close());

  group('DriftQueryStorage', () {
    test('restores what it stored', () async {
      storage.put(entry('["ident",1,"posts",5]', {'id': 5, 'name': 'tester'}));
      await settle();

      final stored = await storage.get('["ident",1,"posts",5]');
      expect(stored, isNotNull);
      expect(stored!.data, {'id': 5, 'name': 'tester'});
      expect(stored.storageDuration, const Duration(days: 1));
    });

    test('restores paged id lists', () async {
      final pages = InfiniteQueryData<List<int>, int>(
        pages: [
          [1, 2],
          [3],
        ],
        args: [1, 2],
      );
      storage.put(entry('["ident",1,"posts"]', pages));
      await settle();

      final restored = pagedIdConfig().storageDeserializer!(
        (await storage.get('["ident",1,"posts"]'))!.data,
      );
      expect(restored.pages, [
        [1, 2],
        [3],
      ]);
      expect(restored.args, [1, 2]);
    });

    test('reports a missing key as null', () async {
      expect(await storage.get('["ident",1,"posts",404]'), isNull);
    });

    test('replaces an existing key instead of duplicating it', () async {
      storage.put(entry('["ident",1,"posts",5]', {'score': 1}));
      storage.put(entry('["ident",1,"posts",5]', {'score': 2}));
      await settle();

      expect((await storage.get('["ident",1,"posts",5]'))!.data, {'score': 2});
      expect(await repository.count(), 1);
    });

    test('drops the least recent entries past the cap', () async {
      final now = DateTime.now();
      for (int i = 0; i < 5; i++) {
        storage.put(
          entry('["ident",1,"posts",$i]', {
            'id': i,
          }, createdAt: now.subtract(Duration(minutes: 5 - i))),
        );
      }
      await settle();

      expect(await repository.count(), 3);
      expect(await storage.get('["ident",1,"posts",0]'), isNull);
      expect(await storage.get('["ident",1,"posts",1]'), isNull);
      expect(await storage.get('["ident",1,"posts",4]'), isNotNull);
    });

    test('sweeps expired entries when the cap is reached', () async {
      storage.put(
        entry(
          '["ident",1,"posts",0]',
          {'id': 0},
          duration: const Duration(milliseconds: 1),
          createdAt: DateTime(2020),
        ),
      );
      for (int i = 1; i < 4; i++) {
        storage.put(entry('["ident",1,"posts",$i]', {'id': i}));
      }
      await settle();

      expect(await storage.get('["ident",1,"posts",0]'), isNull);
    });

    test('removes only the queries of one identity', () async {
      storage.put(entry('["ident",1,"posts",5]', {'id': 5}));
      storage.put(entry('["ident",2,"posts",5]', {'id': 5}));
      await settle();

      await repository.removeIdentity(1);

      expect(await storage.get('["ident",1,"posts",5]'), isNull);
      expect(await storage.get('["ident",2,"posts",5]'), isNotNull);
    });

    test('deleteAll empties the store', () async {
      storage.put(entry('["ident",1,"posts",5]', {'id': 5}));
      await settle();

      storage.deleteAll();
      await settle();

      expect(await repository.count(), 0);
    });
  });

  group('DriftQueryStorage write coalescing', () {
    DriftQueryStorage wide() =>
        DriftQueryStorage(repository: repository, maxEntries: 100);

    test('commits a whole burst of puts as one flush', () async {
      final storage = wide();
      for (int i = 0; i < 5; i++) {
        storage.put(entry('["ident",1,"posts",$i]', {'id': i}));
      }
      await storage.get('drain');

      for (int i = 0; i < 5; i++) {
        expect(await storage.get('["ident",1,"posts",$i]'), isNotNull);
      }
      expect(storage.flushes, 1);
    });

    test('collapses rewrites of one key into one commit', () async {
      final storage = wide();
      storage.put(entry('["ident",1,"posts",5]', {'score': 1}));
      storage.put(entry('["ident",1,"posts",5]', {'score': 2}));
      await storage.get('drain');

      expect((await storage.get('["ident",1,"posts",5]'))!.data, {'score': 2});
      expect(storage.flushes, 1);
    });

    test('a delete staged after its put wins the flush', () async {
      final storage = wide();
      storage.put(entry('["ident",1,"posts",5]', {'id': 5}));
      storage.delete('["ident",1,"posts",5]');
      await storage.get('drain');

      expect(await storage.get('["ident",1,"posts",5]'), isNull);
    });

    test('a put staged after deleteAll survives it', () async {
      final storage = wide();
      storage.put(entry('["ident",1,"posts",5]', {'id': 5}));
      await storage.get('drain');

      storage.deleteAll();
      storage.put(entry('["ident",1,"posts",6]', {'id': 6}));
      await storage.get('drain');

      expect(await storage.get('["ident",1,"posts",5]'), isNull);
      expect((await storage.get('["ident",1,"posts",6]'))!.data, {'id': 6});
    });

    test('keeps committing after a failed flush', () async {
      // One failed write or commit must not kill the queue: the pending
      // slot is released exactly once per turn, so later bursts keep
      // committing (the failed burst's writes are dropped fire-and-forget
      // like the old per-write queue dropped them).
      final sqlite = AppDatabase(NativeDatabase.memory());
      final flaky = _FlakyRepository(database: sqlite);
      final storage = DriftQueryStorage(repository: flaky);
      addTearDown(() => sqlite.close());

      storage.put(entry('["ident",1,"posts",1]', {'id': 1}));
      await storage.get('drain'); // the flush fails; the burst is dropped

      storage.put(entry('["ident",1,"posts",2]', {'id': 2}));
      await storage.get('drain');

      expect((await storage.get('["ident",1,"posts",2]'))?.data, {'id': 2});
      expect(storage.flushes, 2);
    });

    test('commits separately again once a flush has landed', () async {
      final storage = wide();
      storage.put(entry('["ident",1,"posts",5]', {'id': 5}));
      await storage.get('drain');
      storage.put(entry('["ident",1,"posts",6]', {'id': 6}));
      await storage.get('drain');

      expect(await storage.get('["ident",1,"posts",6]'), isNotNull);
      expect(storage.flushes, 2);
    });
  });
}

class _FlakyRepository extends QueryStorageRepository {
  _FlakyRepository({required super.database});

  /// How many leading writeAll calls fail; a transient sqlite error.
  int failures = 1;

  int _failed = 0;

  @override
  Future<void> writeAll(
    List<QueryStorageTableData> entries, {
    List<String>? removeKeys,
  }) async {
    if (_failed < failures) {
      _failed++;
      throw Exception('simulated transient sqlite failure');
    }
    return super.writeAll(entries, removeKeys: removeKeys);
  }
}
