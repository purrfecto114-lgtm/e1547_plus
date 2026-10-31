import 'dart:io';

import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/files/files.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late AppDatabase sqlite;
  late DriftFileCacheStorage repository;

  CacheObject object(String key, {DateTime? touched, String? path}) =>
      CacheObject(
        'https://example.test/data/$key.jpg',
        key: key,
        relativePath: path ?? '$key.jpg',
        validTill: DateTime(2030),
        eTag: '"$key"',
        length: 1024,
        touched: touched,
      );

  setUp(() async {
    sqlite = AppDatabase(NativeDatabase.memory());
    repository = DriftFileCacheStorage(
      repository: FileCacheRepository(database: sqlite),
      cache: fileCacheKey,
      flushDelay: const Duration(milliseconds: 10),
    );
    await repository.open();
  });

  tearDown(() async {
    await repository.close();
    await sqlite.close();
  });

  group('DriftFileCacheStorage', () {
    test('returns what it inserted, with an id', () async {
      final inserted = await repository.insert(object('a'));
      expect(inserted.id, isNotNull);

      final stored = await repository.get('a');
      expect(stored?.id, inserted.id);
      expect(stored?.relativePath, 'a.jpg');
      expect(stored?.eTag, '"a"');
      expect(stored?.length, 1024);
    });

    test('assigns its own id, ignoring any the caller sends', () async {
      final first = await repository.insert(object('a'));
      final second = await repository.insert(
        object('b').copyWith(id: first.id),
      );

      expect(second.id, isNot(first.id));
      expect((await repository.getAllObjects()).map((e) => e.key), ['a', 'b']);
    });

    test('a deferred update is visible before it is written', () async {
      final inserted = await repository.insert(object('a'));
      await repository.update(inserted.copyWith(relativePath: 'moved.jpg'));

      expect((await repository.get('a'))?.relativePath, 'moved.jpg');
    });

    test('a re-download keeps its new path and etag once written', () async {
      final inserted = await repository.insert(object('a'));
      await repository.update(
        inserted.copyWith(relativePath: 'moved.jpg', eTag: '"new"'),
      );
      await repository.getAllObjects();

      final stored = await repository.get('a');
      expect(stored?.relativePath, 'moved.jpg');
      expect(stored?.eTag, '"new"');
    });

    test('over capacity gives up the least recently touched', () async {
      var when = DateTime(2021);
      for (final key in ['old', 'middle', 'new']) {
        await repository.insert(
          object(key, touched: when),
          setTouchedToNow: false,
        );
        when = when.add(const Duration(days: 1));
      }

      final over = await repository.getObjectsOverCapacity(2);
      expect(over.map((e) => e.key), ['old']);
    });

    test('old objects are the ones nothing touched', () async {
      await repository.insert(
        object('stale', touched: DateTime(2020)),
        setTouchedToNow: false,
      );
      await repository.insert(object('fresh'));
      await repository.getAllObjects();

      final old = await repository.getOldObjects(const Duration(days: 1));
      expect(old.map((e) => e.key), ['stale']);
    });

    test('deleting drops the row and any buffered write for it', () async {
      final inserted = await repository.insert(object('a'));
      await repository.update(inserted.copyWith(relativePath: 'moved.jpg'));

      expect(await repository.delete(inserted.id!), 1);
      expect(await repository.get('a'), isNull);
      expect(await repository.getAllObjects(), isEmpty);
    });

    test('only reports rows belonging to its own cache', () async {
      await repository.insert(object('a'));

      final other = DriftFileCacheStorage(
        repository: FileCacheRepository(database: sqlite),
        cache: 'somethingElse',
      );
      await other.open();
      addTearDown(other.close);

      expect(await other.get('a'), isNull);
      expect(await other.exists(), isFalse);
      expect(await repository.exists(), isTrue);
    });

    test(
      'degrades sqlite failures arriving from the background isolate',
      () async {
        // The production database runs on a background isolate, where sqlite
        // failures arrive wrapped as DriftRemoteException (the identity login
        // flow matches on exactly that shape). A second connection holding an
        // exclusive lock makes the next write fail, reproducing the storage
        // pressure of issue #178: the failure must degrade into a cache miss
        // instead of crashing the caller.
        final temp = await Directory.systemTemp.createTemp(
          'file-cache-isolate',
        );
        addTearDown(() => temp.delete(recursive: true));
        final file = File('${temp.path}/cache.db');
        final isolatedDb = AppDatabase(NativeDatabase.createInBackground(file));
        final storage = DriftFileCacheStorage(
          repository: FileCacheRepository(database: isolatedDb),
          cache: fileCacheKey,
          flushDelay: const Duration(milliseconds: 10),
        );
        await storage.open();
        addTearDown(isolatedDb.close);
        addTearDown(storage.close);

        await storage.insert(object('a'));

        final blocker = sqlite3.open(file.path);
        addTearDown(blocker.close);
        blocker.execute('BEGIN EXCLUSIVE');

        final stored = await storage.insert(object('b'));
        expect(stored.key, 'b'); // degraded to the fallback, not thrown
        expect(stored.id, isNull); // never received a database id
      },
    );
  });
}
