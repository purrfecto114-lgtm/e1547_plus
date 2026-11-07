import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/files/files.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

export 'package:e1547/logs/logs.dart' show LogErrors, Logs;
export 'package:e1547/settings/settings.dart' show AppInfo;
export 'package:window_manager/window_manager.dart' show WindowManager;

/// Initializes an AppInfo with default production values.
Future<void> initializeAppInfo() => AppInfo.initializePlatform(
  developer: 'binaryfloof',
  github: 'purrfecto114-lgtm/e1547_plus',
  discord: 'MRwKGqfmUz',
  website: 'e1547.clynamic.net',
  kofi: 'binaryfloof',
  email: 'support@clynamic.net',
  forumTopicId: 25854,
);

Future<String> getTemporaryAppDirectory() => getTemporaryDirectory().then(
  (dir) => join(dir.path, AppInfo.instance.appName),
);

Future<String> getAppDatabasePath() =>
    getApplicationSupportDirectory().then((dir) => join(dir.path, 'app.db'));

/// Initializes the logger used by the app with default production values.
Future<Logs> initializeLogger({
  String? path,
  String? postfix,
  List<LogPrinter>? printers,
  LogLevel? level,
}) async {
  setLogLevel(level ?? verboseLogLevel(verbose: false));
  path ??= await getTemporaryAppDirectory();

  final logFile = createLogFile(path, postfix);
  final logs = Logs(
    printers: [
      ...?printers,
      JsonLogPrinter(logFile),
      const ConsoleLogPrinter(),
    ],
  );

  logs.connect();

  registerFlutterErrorHandler(
    (error, trace) =>
        Logger('Flutter').error('Uncaught framework error', null, error, trace),
  );
  return logs;
}

LogLevel verboseLogLevel({required bool verbose}) {
  if (verbose) return LogLevel.trace;
  return kDebugMode ? LogLevel.debug : LogLevel.info;
}

File createLogFile(String directoryPath, String? postfix) {
  File logFile = File(
    join(
      directoryPath,
      '${logFileDateFormat.format(DateTime.now())}${postfix != null ? '.$postfix' : ''}$logFileExtension',
    ),
  );

  Directory dir = Directory(directoryPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  List<({File file, DateTime date})> logFiles = [];
  for (final entity in dir.listSync().whereType<File>()) {
    if (!entity.path.endsWith(logFileExtension)) continue;
    try {
      logFiles.add((file: entity, date: LogFileInfo.parse(entity.path).date));
    } on FormatException {
      continue;
    }
  }

  logFiles.sort((a, b) => b.date.compareTo(a.date));

  if (logFiles.length > 50) {
    for (final old in logFiles.sublist(10)) {
      try {
        old.file.deleteSync();
      } on FileSystemException {
        continue;
      }
    }
  }

  return logFile;
}

/// Registers an error callback for uncaught exceptions and flutter errors.
void registerFlutterErrorHandler(
  void Function(Object error, StackTrace? trace) handler,
) {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    handler(error, stack);
    return false;
  };
  FlutterError.onError = (details) => handler(details.exception, details.stack);
}

/// Initializes the storages used by the app with default production values.
Future<AppStorage> initializeAppStorage() async {
  final String temporaryFiles = await getTemporaryAppDirectory();
  await completeDbImport();
  final AppDatabase sqlite = AppDatabase(
    driftDatabase(
      name: 'app',
      native: const DriftNativeOptions(
        shareAcrossIsolates: true,
        databasePath: getAppDatabasePath,
      ),
    ),
  );
  await discardLegacyFileCache();
  final preferences = await SharedPreferences.getInstance();
  // The settings assemble through their bare constructor, which skips the
  // stored preference migrations; they run here, where the singleton is
  // created, so every reader sees migrated values.
  await Settings.migratePreferences(preferences);
  return AppStorage(
    preferences: preferences,
    temporaryFiles: temporaryFiles,
    // TODO: query storage is disabled because a page of writes costs a frame
    queryCache: CachedQuery.asNewInstance()
      ..configFlutter(
        config: const GlobalQueryConfig(
          staleDuration: Duration(minutes: 5),
          refetchOnResume: false,
          // Leaving refetchOnConnection at its default (true), so queries
          // with active listeners refetch when the network returns.
        ),
      ),
    sqlite: sqlite,
  );
}

Future<void> backfillOnboardingSeen(AppStorage storage) async {
  if (storage.preferences.getBool('onboardingSeen') ?? false) return;
  final identities = await IdentityRepository(storage.sqlite).all();
  final defaultHost = ClientFactory().createDefaultIdentity().host;
  final existing =
      identities.length > 1 ||
      identities.any((identity) => identity.host != defaultHost);
  if (existing) {
    await storage.preferences.setBool('onboardingSeen', true);
  }
}

Future<void> completeDbImport() async {
  final dbPath = await getAppDatabasePath();
  final newDbPath = await pendingImportPath();
  final markerPath = await pendingImportMarkerPath();
  final newDbFile = File(newDbPath);

  if (newDbFile.existsSync()) {
    // A staged import may only take over when validation stamped it: a
    // crash during the validation, the copy or before the user confirmed
    // otherwise leaves a file the boot sequence must not mistake for an
    // install, and the live database stays untouched.
    if (!await stagedImportVerified(newDbPath, markerPath)) {
      Logger('Storage').warn('Discarded an unverified staged import');
      await discardStagedImport();
      return;
    }
    await swapDatabase(newDbFile, dbPath);
    // the marker served its purpose once the candidate is installed
    await discardStagedImport();
  }
}

/// Installs the staged import at [newDbFile] over the database at [dbPath],
/// keeping the previous database as one recoverable generation.
///
/// The old database first moves aside as `app.db.bak` (its journal
/// companions following), a stale journal next to the fresh file is
/// removed, and only then does the candidate take the live path. Should
/// the swap fail midway, the backup moves back, so the app keeps a
/// working database instead of none. The backup itself stays until the
/// next import replaces it; the backup rules keep it out of cloud backups.
Future<void> swapDatabase(File newDbFile, String dbPath) async {
  final logger = Logger('Storage');
  const companions = ['-wal', '-shm', '-journal'];
  final oldDbFile = File(dbPath);
  final backupPath = '$dbPath.bak';
  final backupFile = File(backupPath);
  try {
    if (backupFile.existsSync()) await backupFile.delete();
    for (final suffix in companions) {
      final stale = File('$backupPath$suffix');
      if (stale.existsSync()) await stale.delete();
    }
    if (oldDbFile.existsSync()) {
      await oldDbFile.rename(backupPath);
      for (final suffix in companions) {
        final companion = File('$dbPath$suffix');
        if (!companion.existsSync()) continue;
        try {
          await companion.rename('$backupPath$suffix');
        } on FileSystemException {
          await companion.delete();
        }
      }
    }
    for (final suffix in companions) {
      final stale = File('$dbPath$suffix');
      if (stale.existsSync()) await stale.delete();
    }
    try {
      await newDbFile.rename(dbPath);
    } on Exception {
      // Cross-directory renames can fail where a copy works.
      await newDbFile.copy(dbPath);
      await newDbFile.delete();
    }
  } on Exception catch (e, s) {
    // The swap failed midway: put the backup back so the app keeps a
    // working database instead of none, and leave the staged candidate
    // for discardStagedImport to clean up.
    if (!oldDbFile.existsSync() && backupFile.existsSync()) {
      try {
        await backupFile.rename(dbPath);
      } on FileSystemException {
        // nothing left to restore; the error below reports the damage
      }
    }
    logger.warn('Failed to install the staged import', null, e, s);
  }
}

/// Reads `PRAGMA user_version` (header offset 60, big endian) without
/// opening the database. Returns null if [path] is not a SQLite file.
Future<int?> readSqliteUserVersion(String path) async {
  final file = File(path);
  if (!file.existsSync()) return null;
  final handle = await file.open();
  try {
    final header = await handle.read(64);
    if (header.length < 64) return null;
    if (String.fromCharCodes(header.take(15)) != 'SQLite format 3') return null;
    // getUint32 reads big endian by default, which is the SQLite format.
    return ByteData.sublistView(header, 60, 64).getUint32(0);
  } finally {
    await handle.close();
  }
}

const MethodChannel _storageChannel = MethodChannel('e1547/storage');

Future<void> excludeFileFromBackup(String path) async {
  if (!Platform.isIOS) return;
  try {
    await _storageChannel.invokeMethod('excludeFromBackup', {'path': path});
  } on PlatformException catch (e, s) {
    Logger(
      'Storage',
    ).warn('Failed to exclude file from backup', {'path': path}, e, s);
  } on MissingPluginException {
    // platform without the handler; nothing to do
  }
}

/// Excludes the database and its sidecar/staging files from OS backups.
Future<void> excludeDatabaseFromBackup() async {
  final dbPath = await getAppDatabasePath();
  for (final suffix in ['', '-journal', '-wal', '-shm', '.new']) {
    final file = File('$dbPath$suffix');
    if (file.existsSync()) await excludeFileFromBackup(file.path);
  }
}

/// Returns an initialized WindowManager or null the current Platform is unsupported.
Future<WindowManager?> initializeWindowManager() async {
  if ([Platform.isWindows, Platform.isLinux, Platform.isMacOS].any((e) => e)) {
    WindowManager manager = WindowManager.instance;
    await manager.ensureInitialized();
    return manager;
  }
  return null;
}
