import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift_flutter/drift_flutter.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/identity/identity.dart';
import 'package:path/path.dart';

/// The schema version this build understands.
///
/// Files from newer versions are rejected by the import. Keep in sync with
/// AppDatabase.schemaVersion; test/app/data/initialize_test.dart guards it.
const int supportedSchemaVersion = 9;

/// How an import candidate's schema version classifies.
enum ImportSchemaGate { ok, tooNew, empty }

/// Classifies a database file's [userVersion] (as reported by
/// [readSqliteUserVersion]) for the import.
///
/// sqlite reports null for files that are no databases at all, and drift
/// treats version 0 as brand new: opening either would run onCreate, create
/// every app table itself, and let an empty file pass the table check —
/// the import would then replace the user's data with an empty database.
/// Version 0 therefore means "not an e1547 export".
ImportSchemaGate classifyImportSchemaVersion(int? userVersion) {
  if (userVersion == null || userVersion == 0) {
    return ImportSchemaGate.empty;
  }
  if (userVersion > supportedSchemaVersion) {
    return ImportSchemaGate.tooNew;
  }
  return ImportSchemaGate.ok;
}

/// The tables a complete app database must have.
const Set<String> appTables = {
  'identities_table',
  'traits_table',
  'histories_table',
  'histories_identities_table',
  'follows_table',
  'follows_identities_table',
  'tasks_table',
  'tasks_identities_table',
  'query_storage_table',
  'file_cache_table',
};

/// The hosts identities are expected to live on.
///
/// Accounts on any other host are called out during imports: a crafted
/// database could otherwise quietly point the app, and its login form,
/// at a server the user never chose.
const Set<String> defaultHosts = {'https://e621.net', 'https://e926.net'};

/// The staging path a validated import lands on before its restart.
///
/// The boot sequence adopts it through completeDbImport; the import
/// dialogs can discard it again without touching the live database.
Future<String> pendingImportPath() async => '${await getAppDatabasePath()}.new';

/// Runs [action] against a private connection of the database file at
/// [path].
///
/// Export sanitization and import validation both open a second drift
/// connection next to the live one, which drift warns about unless told
/// not to; the warning is silenced exactly for the connection's lifetime.
Future<T> withIsolatedDatabase<T>(
  String name,
  String path,
  Future<T> Function(AppDatabase db) action,
) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  try {
    final db = AppDatabase(
      driftDatabase(
        name: name,
        native: DriftNativeOptions(databasePath: () async => path),
      ),
    );
    try {
      return await action(db);
    } finally {
      await db.close();
    }
  } finally {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
  }
}

/// Strips the credentials from [db] and rebuilds the file so the removed
/// rows cannot be recovered from free pages left behind by the UPDATE.
Future<void> sanitizeDatabase(AppDatabase db) async {
  await IdentityRepository(db).removeCredentials();
  await db.customStatement('VACUUM');
}

/// Snapshots the live database into a fresh file at [targetPath].
///
/// VACUUM INTO produces a compact, consistent copy through the live
/// connection; a plain file copy only serves as the fallback, it may
/// catch the file mid-write.
Future<void> snapshotDatabase(
  AppDatabase sqlite,
  String dbPath,
  String targetPath,
) async {
  final dbFile = File(dbPath);
  if (!dbFile.existsSync()) {
    throw Exception('Database file does not exist');
  }
  await Directory(dirname(targetPath)).create(recursive: true);
  final targetFile = File(targetPath);
  if (targetFile.existsSync()) await targetFile.delete();
  try {
    await sqlite.customStatement('VACUUM INTO ?', [targetPath]);
  } on Exception {
    // Not worse than what a plain file copy would produce.
    await dbFile.copy(targetPath);
  }
}

/// Copies the import candidate at [sourcePath] to the staging path and
/// validates it as an app database.
///
/// Throws when the file is not a complete e1547 database; the staged
/// copy is removed again in that case. Returns the hosts its identities
/// live on, with credentials already stripped from the staged file.
Future<Set<String>> stageImportCandidate(String sourcePath) async {
  final newDbPath = await pendingImportPath();
  final newDbFile = File(newDbPath);
  if (newDbFile.existsSync()) await newDbFile.delete();
  await File(sourcePath).copy(newDbPath);
  try {
    return await withIsolatedDatabase('import', newDbPath, (db) async {
      await db.customSelect('SELECT 1').get();
      final tables = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      final present = tables.map((row) => row.read<String>('name')).toSet();
      final missing = appTables.difference(present);
      if (missing.isNotEmpty) {
        throw Exception('Missing app tables: ${missing.join(', ')}');
      }
      final hosts = await IdentityRepository(db).hosts();
      // Strip untrusted credentials in the installed copy.
      await sanitizeDatabase(db);
      return hosts;
    });
  } on Exception {
    if (newDbFile.existsSync()) await newDbFile.delete();
    rethrow;
  }
}

/// Drops a staged import candidate, keeping the current database.
Future<void> discardStagedImport() async {
  final newDbFile = File(await pendingImportPath());
  if (newDbFile.existsSync()) await newDbFile.delete();
}
