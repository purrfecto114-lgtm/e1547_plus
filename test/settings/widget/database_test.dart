import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('classifyImportSchemaVersion', () {
    test('the current schema imports', () {
      expect(
        classifyImportSchemaVersion(supportedSchemaVersion),
        ImportSchemaGate.ok,
      );
    });

    test('older schemas import, migration upgrades them', () {
      expect(classifyImportSchemaVersion(1), ImportSchemaGate.ok);
    });

    test('a newer schema is rejected as too new', () {
      expect(
        classifyImportSchemaVersion(supportedSchemaVersion + 1),
        ImportSchemaGate.tooNew,
      );
    });

    test('a file without a schema version is not an e1547 export', () {
      // sqlite reports user_version 0 for a file it treats as brand new;
      // opening it would run onCreate, create every app table itself, and
      // let a 0-byte file pass the table check — destroying the user's
      // data once the import completes.
      expect(classifyImportSchemaVersion(0), ImportSchemaGate.empty);
    });

    test('a file that is no sqlite database at all is rejected', () {
      expect(classifyImportSchemaVersion(null), ImportSchemaGate.empty);
    });
  });

  group('schemaMismatches', () {
    test('a real database matches the expected columns', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      expect(await schemaMismatches(db), isEmpty);
    });

    test('a table with the right name but wrong columns is caught', () async {
      final dir = await Directory.systemTemp.createTemp('e1547_schema');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}${Platform.pathSeparator}app.db';

      final db = AppDatabase(NativeDatabase(File(path)));
      await db.customSelect('SELECT 1').get();
      await db.close();

      // Rebuild one table with only its id column, the way a synthetic
      // file passes the table name check but fails every real query.
      final sqlite = sqlite3.open(path);
      sqlite.execute('ALTER TABLE histories_table RENAME TO histories_old');
      sqlite.execute(
        'CREATE TABLE histories_table (id INTEGER NOT NULL PRIMARY KEY)',
      );
      sqlite.execute('DROP TABLE histories_old');
      sqlite.close();

      final mangled = AppDatabase(NativeDatabase(File(path)));
      addTearDown(mangled.close);
      final problems = await schemaMismatches(mangled);
      expect(problems, hasLength(1));
      expect(problems.single, contains('histories_table'));
    });
  });

  group('staged import markers', () {
    late Directory dir;
    late String candidatePath;
    late String markerPath;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('e1547_marker');
      candidatePath = '${dir.path}${Platform.pathSeparator}app.db.new';
      markerPath = '${dir.path}${Platform.pathSeparator}app.db.new.ok';
    });
    tearDown(() => dir.delete(recursive: true));

    test('a stamped candidate verifies', () async {
      await File(candidatePath).writeAsString('candidate', flush: true);
      await stampStagedImport(candidatePath, markerPath);
      expect(await stagedImportVerified(candidatePath, markerPath), isTrue);
    });

    test('a modified candidate fails the marker check', () async {
      await File(candidatePath).writeAsString('candidate', flush: true);
      await stampStagedImport(candidatePath, markerPath);
      await File(candidatePath).writeAsString('tampered', flush: true);
      expect(await stagedImportVerified(candidatePath, markerPath), isFalse);
    });

    test('a missing or empty marker fails the check', () async {
      await File(candidatePath).writeAsString('candidate', flush: true);
      expect(await stagedImportVerified(candidatePath, markerPath), isFalse);

      await File(markerPath).writeAsString('', flush: true);
      expect(await stagedImportVerified(candidatePath, markerPath), isFalse);
    });

    test('a validated candidate alone does not count as confirmed', () async {
      await File(candidatePath).writeAsString('candidate', flush: true);
      await stampStagedImport(candidatePath, markerPath);
      expect(
        await stagedImportConfirmed(
          candidatePath,
          markerPath,
          '$candidatePath.confirmed',
        ),
        isFalse,
      );
    });

    test('a confirmed candidate installs', () async {
      await File(candidatePath).writeAsString('candidate', flush: true);
      await stampStagedImport(candidatePath, markerPath);
      await confirmStagedImport(candidatePath, '$candidatePath.confirmed');
      expect(
        await stagedImportConfirmed(
          candidatePath,
          markerPath,
          '$candidatePath.confirmed',
        ),
        isTrue,
      );
    });

    test(
      'a candidate modified after its confirmation does not install',
      () async {
        await File(candidatePath).writeAsString('candidate', flush: true);
        await stampStagedImport(candidatePath, markerPath);
        await confirmStagedImport(candidatePath, '$candidatePath.confirmed');
        await File(candidatePath).writeAsString('tampered', flush: true);
        expect(
          await stagedImportConfirmed(
            candidatePath,
            markerPath,
            '$candidatePath.confirmed',
          ),
          isFalse,
        );
      },
    );
  });

  group('import probing', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('e1547_probe');
      addTearDown(() => dir.delete(recursive: true));
    });

    File file(String name) => File('${dir.path}${Platform.pathSeparator}$name');

    test('isEncryptedExport classifies by header only', () async {
      await file('plain.db').writeAsBytes(
        List<int>.filled(4096, 0), // a file far larger than the magic
      );
      expect(await isEncryptedExport(file('plain.db').path), isFalse);

      final encrypted = await encryptDatabaseExport(
        Uint8List.fromList([1, 2, 3]),
        'password',
      );
      await file('encrypted.db').writeAsBytes(encrypted);
      expect(await isEncryptedExport(file('encrypted.db').path), isTrue);

      await file('short.db').writeAsBytes([69, 49]);
      expect(await isEncryptedExport(file('short.db').path), isFalse);
    });

    test('fileHash matches a whole-file digest', () async {
      final bytes = List<int>.generate(3 * 1024 * 1024, (i) => i % 251);
      await file('big.db').writeAsBytes(bytes);

      final digest = await Sha256().hash(bytes);
      final expected = digest.bytes
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();

      expect(await fileHash(file('big.db').path), expected);
    });
  });

  group('sanitizeDatabase', () {
    test(
      "sanitizeDatabase drops imported triggers and rebuilds the app's own",
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        // A trigger in an import is attacker-made: one that survived the
        // cleanup could write the credentials straight back. The app's own
        // cascade triggers are then rebuilt from this build's DDL - without
        // them, deleting an identity fails its NO ACTION foreign keys.
        await db.customStatement(
          'CREATE TRIGGER sneak AFTER UPDATE ON identities_table BEGIN '
          'SELECT 1; END',
        );
        await sanitizeDatabase(db);
        final triggers = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'trigger'",
            )
            .get();
        expect(
          triggers.map((row) => row.read<String>('name')),
          unorderedEquals([
            'delete_identity_follows',
            'delete_identity_histories',
            'delete_identity_tasks',
          ]),
        );
      },
    );

    test('sanitizeDatabase empties the imported cache index', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      // The index is rebuildable cache metadata; a crafted row could
      // otherwise point the cleaner outside the cache root through a
      // relativePath like `../..`.
      await db.customStatement(
        'INSERT INTO file_cache_table '
        '(cache, key, url, relative_path, valid_till, e_tag, length, touched) '
        "VALUES ('app', 'smuggled', 'https://example.test/a.jpg', "
        "'../outside-cache.txt', 1893456000, NULL, 1024, 1893456000)",
      );
      await sanitizeDatabase(db);
      final rows = await db
          .customSelect('SELECT COUNT(*) AS n FROM file_cache_table')
          .getSingle();
      expect(rows.read<int>('n'), 0);
    });

    test('sanitizeDatabase cancels imported executable tasks', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      // Imported pending/running tasks are executable todos from another
      // device: their download URLs and filenames come straight from the
      // backup's TaskMetadata, and the task controller would auto-claim
      // them after the import. Cancel them in the staging phase; terminal
      // task history stays.
      await db.customStatement(
        'INSERT INTO tasks_table (action, post_id, status, created_at) VALUES '
        "('download', 1, 'pending', 0), "
        "('download', 2, 'running', 0), "
        "('download', 3, 'completed', 0), "
        "('favorite', 4, 'failed', 0), "
        "('unfavorite', 5, 'canceled', 0)",
      );
      await sanitizeDatabase(db);
      final rows = await db
          .customSelect(
            'SELECT post_id, status FROM tasks_table ORDER BY post_id',
          )
          .get();
      expect(
        rows.map(
          (row) => '${row.read<int>('post_id')}:${row.read<String>('status')}',
        ),
        ['1:canceled', '2:canceled', '3:completed', '4:failed', '5:canceled'],
      );
    });
  });
  group('swapDatabase', () {
    late Directory dir;
    late String dbPath;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('e1547_swap');
      dbPath = '${dir.path}${Platform.pathSeparator}app.db';
    });
    tearDown(() => dir.delete(recursive: true));

    File file(String name) => File('${dir.path}${Platform.pathSeparator}$name');

    test('the old database survives the install as one backup', () async {
      file('app.db').writeAsStringSync('old', flush: true);
      file('app.db.new').writeAsStringSync('new', flush: true);

      await swapDatabase(file('app.db.new'), dbPath);

      expect(file('app.db').readAsStringSync(), 'new');
      expect(file('app.db.bak').readAsStringSync(), 'old');
      expect(file('app.db.new').existsSync(), isFalse);
    });

    test('journal companions follow the old database aside', () async {
      file('app.db').writeAsStringSync('old', flush: true);
      file('app.db-wal').writeAsStringSync('wal', flush: true);
      file('app.db-shm').writeAsStringSync('shm', flush: true);
      file('app.db.new').writeAsStringSync('new', flush: true);

      await swapDatabase(file('app.db.new'), dbPath);

      expect(file('app.db.bak').readAsStringSync(), 'old');
      expect(file('app.db.bak-wal').readAsStringSync(), 'wal');
      expect(file('app.db.bak-shm').readAsStringSync(), 'shm');
      // the live path ships without stale journals next to it
      expect(file('app.db-wal').existsSync(), isFalse);
      expect(file('app.db-shm').existsSync(), isFalse);
    });

    test('a failed install restores the backup', () async {
      file('app.db').writeAsStringSync('old', flush: true);
      // A missing candidate makes the rename and its copy fallback fail;
      // the previous database must come back instead of leaving none.
      await swapDatabase(file('app.db.new'), dbPath);

      expect(file('app.db').readAsStringSync(), 'old');
    });

    test('a previous backup is replaced by the newest generation', () async {
      file('app.db').writeAsStringSync('second', flush: true);
      file('app.db.bak').writeAsStringSync('first', flush: true);
      file('app.db.new').writeAsStringSync('third', flush: true);

      await swapDatabase(file('app.db.new'), dbPath);

      expect(file('app.db').readAsStringSync(), 'third');
      expect(file('app.db.bak').readAsStringSync(), 'second');
    });

    test('an interrupted swap keeps the only old generation', () async {
      // A first entry died after renaming the live database aside: the
      // live path is empty and .bak holds the only copy of the old data.
      // Retrying must not delete it ahead of installing the candidate.
      file('app.db.bak').writeAsStringSync('old', flush: true);
      file('app.db.new').writeAsStringSync('new', flush: true);

      await swapDatabase(file('app.db.new'), dbPath);

      expect(file('app.db').readAsStringSync(), 'new');
      expect(file('app.db.bak').readAsStringSync(), 'old');
      expect(file('app.db.new').existsSync(), isFalse);
    });
  });

  group('snapshotDatabase', () {
    late Directory dir;
    late String dbPath;
    late AppDatabase db;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('e1547_snapshot');
      dbPath = '${dir.path}${Platform.pathSeparator}app.db';
      db = AppDatabase(NativeDatabase(File(dbPath)));
      await db.customSelect('SELECT 1').get();
    });
    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    test('snapshots the live database into a fresh file', () async {
      final target = '${dir.path}${Platform.pathSeparator}export.db';
      await snapshotDatabase(db, dbPath, target);
      expect(File(target).existsSync(), isTrue);
    });

    test('a failed snapshot reports itself instead of copying', () async {
      // A read-only target directory makes VACUUM INTO fail; the export
      // must surface that error rather than fall back to a plain copy,
      // which cannot guarantee the newest committed rows left the wal.
      final roDir = Directory('${dir.path}${Platform.pathSeparator}ro')
        ..createSync();
      final target = '${roDir.path}${Platform.pathSeparator}export.db';
      Process.runSync('chmod', ['555', roDir.path]);
      addTearDown(() async {
        Process.runSync('chmod', ['755', roDir.path]);
        await roDir.delete(recursive: true);
      });
      await expectLater(snapshotDatabase(db, dbPath, target), throwsException);
      expect(File(target).existsSync(), isFalse);
    });
  });
}
