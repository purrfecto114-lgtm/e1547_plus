import 'dart:io';

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

    test('sanitizeDatabase drops triggers a file carried', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      // The app ships no triggers, so one in an import is attacker-made:
      // a trigger that survives the cleanup could write the credentials
      // straight back after they were stripped.
      await db.customStatement(
        'CREATE TRIGGER sneak AFTER UPDATE ON identities_table BEGIN '
        'SELECT 1; END',
      );
      await sanitizeDatabase(db);
      final triggers = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'trigger'")
          .get();
      expect(triggers, isEmpty);
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
  });
}
