import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show TableInfo, driftRuntimeOptions;
import 'package:drift_flutter/drift_flutter.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:path/path.dart';

/// The schema version this build understands.
///
/// Files from newer versions are rejected by the import. Keep in sync with
/// AppDatabase.schemaVersion; test/app/data/initialize_test.dart guards it.
const int supportedSchemaVersion = 10;

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

/// The path of the marker that proves a staged import passed validation.
Future<String> pendingImportMarkerPath() async =>
    '${await getAppDatabasePath()}.new.ok';

/// The path of the marker that records the user's consent to install the
/// staged import.
///
/// Validation alone must never install a file: the marker proves the
/// candidate is safe, this one proves the user chose it. A process death
/// or a dismissed dialog before the restart leaves it unwritten, and the
/// boot sequence then keeps the live database instead.
Future<String> pendingImportConfirmPath() async =>
    '${await getAppDatabasePath()}.new.confirmed';

/// Records the user's consent to install the staged candidate, stamped
/// with the same hash the validation marker carries.
Future<void> confirmStagedImport(
  String candidatePath,
  String confirmPath,
) async {
  await File(
    confirmPath,
  ).writeAsString(await fileHash(candidatePath), flush: true);
}

/// Whether the staged candidate at [candidatePath] is the validated one
/// the user consented to installing.
///
/// All three have to agree: the validation marker, the confirm marker and
/// the file on disk. Anything else — a missing consent, a candidate that
/// changed after the user pressed restart — must never be adopted by the
/// boot sequence.
Future<bool> stagedImportConfirmed(
  String candidatePath,
  String markerPath,
  String confirmPath,
) async {
  final marker = File(markerPath);
  final confirm = File(confirmPath);
  if (!marker.existsSync()) return false;
  if (!confirm.existsSync()) return false;
  final validated = (await marker.readAsString()).trim();
  final consented = (await confirm.readAsString()).trim();
  if (validated.isEmpty || consented != validated) return false;
  return stagedImportVerified(candidatePath, markerPath);
}

/// The sha256 of the file at [path], as lowercase hex.
///
/// Hashes in chunks: an import candidate can be large, and buffering it
/// whole would peak several times its size alongside the staged copy.
Future<String> fileHash(String path) async {
  final sink = Sha256().newHashSink();
  await for (final chunk in File(path).openRead()) {
    sink.add(chunk);
  }
  sink.close();
  final digest = await sink.hash();
  return digest.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}

/// The largest import candidate this build is willing to buffer.
///
/// The encrypted v1 format must be read whole to be decrypted; without a
/// bound, picking a multi-gigabyte file would peak at several times its
/// size before the first format check runs.
const int maxImportBytes = 256 * 1024 * 1024;

/// Whether the export at [path] is encrypted, read from its header only.
///
/// The magic probe needs the first bytes, not the whole file: a picked
/// multi-gigabyte file must not be buffered just to be classified.
Future<bool> isEncryptedExport(String path) async {
  final file = File(path);
  if (await file.length() < databaseExportMagic.length) return false;
  final header = await file.openRead(0, databaseExportMagic.length).first;
  return hasDatabaseExportMagic(header);
}

/// Stamps the staged candidate at [candidatePath] as validated by writing
/// its hash into the marker at [markerPath].
Future<void> stampStagedImport(String candidatePath, String markerPath) async {
  await File(
    markerPath,
  ).writeAsString(await fileHash(candidatePath), flush: true);
}

/// Whether the staged candidate at [candidatePath] is the one validation
/// stamped into [markerPath].
///
/// Only a marker that still matches the file proves the candidate is the
/// fully validated one: anything else — a missing marker, an interrupted
/// copy, a file modified after validation — must never be adopted by the
/// boot sequence.
Future<bool> stagedImportVerified(
  String candidatePath,
  String markerPath,
) async {
  if (!File(candidatePath).existsSync()) return false;
  final marker = File(markerPath);
  if (!marker.existsSync()) return false;
  final expected = (await marker.readAsString()).trim();
  if (expected.isEmpty) return false;
  return await fileHash(candidatePath) == expected;
}

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
///
/// Triggers the file carries are dropped first: one that survived the
/// cleanup could write the credentials straight back. The cascade
/// triggers the app itself ships are then rebuilt from this build's own
/// DDL — trusting an imported trigger body is not an option, but without
/// them deleting an identity fails its NO ACTION foreign keys.
///
/// The imported file cache index is emptied as well: its rows are
/// rebuildable cache metadata, and a crafted one could point the cleaner
/// outside the cache root through a relativePath like `../..`.
Future<void> sanitizeDatabase(AppDatabase db) async {
  final triggers = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'trigger'")
      .get();
  for (final row in triggers) {
    final name = row.read<String>('name');
    // sqlite_master names cannot contain a double quote, but a crafted
    // file may still try; the identifier is quoted regardless.
    final quoted = '"${name.replaceAll('"', '""')}"';
    await db.customStatement('DROP TRIGGER IF EXISTS $quoted');
  }
  await IdentityRepository(db).removeCredentials();
  await db.customStatement(identityCascadeTriggers);
  await db.customStatement('DELETE FROM file_cache_table');
  // Imported pending/running tasks are executable todos from another
  // device. Their download URLs and filenames come straight from the
  // backup's TaskMetadata, so the task controller would auto-claim
  // them after the import and silently start transfers. Cancel them
  // here; terminal task history stays. This also covers exports made
  // by older builds that still carried active tasks.
  await db.customStatement(
    "UPDATE tasks_table SET status = 'canceled' "
    "WHERE status IN ('pending', 'running')",
  );
  await db.customStatement('VACUUM');
}

/// Snapshots the live database into a fresh file at [targetPath].
///
/// VACUUM INTO produces a compact, consistent copy through the live
/// connection; there is no fallback — a plain file copy is only
/// consistent through pure luck, and the wal_checkpoint before it cannot
/// guarantee the newest committed rows left the wal while a reader holds
/// it busy, so a failed snapshot reports itself and lets the caller retry.
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
    // No fallback copy: a plain file copy is only consistent through
    // pure luck, and the wal_checkpoint before it cannot guarantee the
    // newest committed rows left the wal while a reader holds it busy.
    // A failed export reports itself and lets the user retry instead.
    if (targetFile.existsSync()) await targetFile.delete();
    rethrow;
  }
}

/// The columns of [db]'s tables that drift expects but the file lacks.
///
/// Table names alone do not make a usable database: a file with the right
/// names but wrong columns would replace the live database and break every
/// query touching the missing column. The comparison runs after drift's
/// migration, so the expectations are the ones this build ships. PRAGMA
/// table_info cannot take a bound parameter, but every compared table name
/// comes from drift's own generated schema, never from the imported file.
Future<List<String>> schemaMismatches(AppDatabase db) async {
  final problems = <String>[];
  for (final entity in db.allSchemaEntities) {
    if (entity is! TableInfo) continue;
    final rows = await db
        .customSelect('PRAGMA table_info(${entity.entityName})')
        .get();
    final expected = entity.$columns.map((column) => column.$name).toSet();
    final actual = rows.map((row) => row.read<String>('name')).toSet();
    final missing = expected.difference(actual);
    if (missing.isNotEmpty) {
      problems.add('${entity.entityName} misses ${missing.join(', ')}');
    }
  }
  return problems;
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
  final markerFile = File(await pendingImportMarkerPath());
  if (markerFile.existsSync()) await markerFile.delete();
  await File(sourcePath).copy(newDbPath);
  try {
    final hosts = await withIsolatedDatabase('import', newDbPath, (db) async {
      await db.customSelect('SELECT 1').get();
      final tables = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      final present = tables.map((row) => row.read<String>('name')).toSet();
      final missing = appTables.difference(present);
      if (missing.isNotEmpty) {
        throw Exception('Missing app tables: ${missing.join(', ')}');
      }
      // The column comparison happens after the migration drift ran while
      // opening the candidate, so an older export measures against this
      // build's expectations.
      final incomplete = await schemaMismatches(db);
      if (incomplete.isNotEmpty) {
        throw Exception('Incomplete app schema: ${incomplete.join(', ')}');
      }
      final hosts = await IdentityRepository(db).hosts();
      // Strip untrusted credentials in the installed copy.
      await sanitizeDatabase(db);
      return hosts;
    });
    // Only a fully validated and sanitized candidate earns the marker the
    // boot sequence looks for.
    await stampStagedImport(newDbPath, await pendingImportMarkerPath());
    return hosts;
  } on Exception {
    if (newDbFile.existsSync()) await newDbFile.delete();
    if (markerFile.existsSync()) await markerFile.delete();
    rethrow;
  }
}

/// Drops a staged import candidate, keeping the current database.
Future<void> discardStagedImport() async {
  final newDbFile = File(await pendingImportPath());
  if (newDbFile.existsSync()) await newDbFile.delete();
  final markerFile = File(await pendingImportMarkerPath());
  if (markerFile.existsSync()) await markerFile.delete();
  final confirmFile = File(await pendingImportConfirmPath());
  if (confirmFile.existsSync()) await confirmFile.delete();
}
