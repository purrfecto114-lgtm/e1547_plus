import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart'
    show SecretBoxAuthenticationError;
import 'package:e1547/app/app.dart';
import 'package:e1547/app/widget/initialize.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:path/path.dart';

typedef DatabaseInfo = ({String name, String? size});

final _logger = Logger('DbManagement');

class DatabaseManagementPage extends StatelessWidget {
  const DatabaseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TransparentAppBar(
        child: DefaultAppBar(leading: CloseButton()),
      ),
      body: LimitedWidthLayout.builder(
        builder: (context) => ListView(
          padding: defaultActionListPadding.add(
            LimitedWidthLayout.of(context).padding,
          ),
          children: const [
            DatabaseInfoDisplay(),
            SizedBox(height: 64),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Card(
                child: Column(
                  children: [DatabaseExportTile(), DatabaseImportTile()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseInfoDisplay extends StatelessWidget {
  const DatabaseInfoDisplay({super.key});

  Future<DatabaseInfo> _loadDatabaseInfo() async {
    final dbPath = await getAppDatabasePath();
    final dbFile = File(dbPath);

    final name = dbPath.split(Platform.pathSeparator).last;
    final size = dbFile.existsSync() ? filesize(dbFile.lengthSync()) : null;

    return (name: name, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return SubFuture<DatabaseInfo>(
      create: _loadDatabaseInfo,
      builder: (context, snapshot) {
        final dbInfo =
            snapshot.data ??
            (snapshot.error != null
                ? (
                    name: AppLocalizations.of(context).databaseErrorLoading,
                    size: 'N/A',
                  )
                : (name: AppLocalizations.of(context).loading, size: '...'));

        return Center(
          child: Column(
            children: [
              const SizedBox(height: 32),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.primary,
                radius: 64,
                child: const Icon(Icons.storage, size: 64),
              ),
              const SizedBox(height: 16),
              Text(dbInfo.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Dimmed(
                child: Text(
                  dbInfo.size ??
                      AppLocalizations.of(context).databaseUnknownSize,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class DatabaseExportTile extends StatelessWidget {
  const DatabaseExportTile({super.key});

  /// Shows the export confirmation with an optional encryption password.
  ///
  /// Returns null when the export was cancelled, an empty string for a
  /// plain unencrypted file, and the password otherwise.
  Future<String?> _showExportDialog(BuildContext context) => showPasswordPrompt(
    context,
    title: AppLocalizations.of(context).databaseExportTitle,
    body: AppLocalizations.of(context).databaseExportSanitizedBody,
    label: AppLocalizations.of(context).databaseExportPasswordLabel,
    helper: AppLocalizations.of(context).databaseExportPasswordHint,
    confirm: AppLocalizations.of(context).actionExport,
  );

  Future<void> _exportDatabase(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final sqlite = context.read<AppStorage>().sqlite;

    final String? password = await _showExportDialog(context);
    if (password == null) return;
    if (!context.mounted) return;

    File? tempFile;
    try {
      showBlockingProgressDialog(context, l10n.databaseExporting);

      final dbPath = await getAppDatabasePath();
      final tempPath = join(
        await getTemporaryAppDirectory(),
        'e1547_export.db',
      );
      await snapshotDatabase(sqlite, dbPath, tempPath);
      tempFile = File(tempPath);
      await withIsolatedDatabase('export-sanitize', tempPath, (db) async {
        await sanitizeDatabase(db);
      });

      // Desktop pickers only choose a path, so an unencrypted export can
      // stream from the snapshot; the buffered path stays for mobile
      // pickers and for the encrypted format, which is a single blob.
      final bool desktop = [
        Platform.isLinux,
        Platform.isWindows,
        Platform.isMacOS,
      ].any((e) => e);
      final bool streamToFile = desktop && password.isEmpty;

      Uint8List? outputBytes;
      if (!streamToFile) {
        final bytes = await tempFile.readAsBytes();
        await tempFile.delete();
        tempFile = null;

        outputBytes = bytes;
        if (password.isNotEmpty) {
          outputBytes = await encryptDatabaseExport(bytes, password);
        }
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: l10n.databaseExportTitle,
        fileName: 'e1547_database_backup.db',
        type: FileType.custom,
        allowedExtensions: ['db'],
        bytes: outputBytes,
      );
      if (outputFile != null && outputBytes == null) {
        try {
          await tempFile!.copy(outputFile);
        } on Object {
          // A failed copy must not leave a half-written file behind: a
          // corrupt backup with a valid SQLite header is worse than no
          // backup, because it looks trustworthy.
          try {
            await File(outputFile).delete();
          } on FileSystemException {
            // nothing was written to clean up
          }
          rethrow;
        }
      }

      navigator.pop();
      if (outputFile != null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.databaseExported)));
      }
    } on Exception catch (e) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.databaseExportFailed)),
      );
      _logger.warn('Database export failed', null, e);
    } finally {
      if (tempFile != null && tempFile.existsSync()) {
        try {
          await tempFile.delete();
        } on FileSystemException {
          // already deleted elsewhere
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.download),
      title: Text(AppLocalizations.of(context).databaseExport),
      subtitle: Text(
        AppLocalizations.of(context).databaseExportSubtitle,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _exportDatabase(context),
    );
  }
}

class DatabaseImportTile extends StatelessWidget {
  const DatabaseImportTile({super.key});

  Future<void> _importDatabase(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    final confirmed = await _showImportWarning(context);
    if (!confirmed) return;

    // A decrypted copy of a picked encrypted export, if any. Deleted again
    // in the finally below; the picked file itself is never modified.
    File? decryptedFile;

    try {
      // iOS needs custom file type declarations but we are lazy so we pick any
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: l10n.databaseImportTitle,
        type: Platform.isIOS ? FileType.any : FileType.custom,
        allowedExtensions: Platform.isIOS ? null : ['db'],
      );

      final path = result?.files.single.path;

      if (path == null) return;
      if (!context.mounted) return;

      // Encrypted exports carry a magic header sqlite cannot read. Ask for
      // the password up front, decrypt into a temporary file and let the
      // regular checks below run against that.
      String sourcePath = path;
      if (await isEncryptedExport(path)) {
        // The v1 format must be buffered whole to be decrypted; a bound
        // keeps a mistakenly picked huge file from peaking several times
        // its size before the first format check runs.
        if (await File(path).length() > maxImportBytes) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.databaseImportTooLarge)),
          );
          return;
        }
        bool wrongPassword = false;
        while (true) {
          if (!context.mounted) return;
          final password = await showPasswordPrompt(
            context,
            title: AppLocalizations.of(context).databaseImportEncryptedTitle,
            label: AppLocalizations.of(context).databaseImportPasswordLabel,
            confirm: AppLocalizations.of(context).actionUnlock,
            warning: wrongPassword
                ? AppLocalizations.of(context).databaseImportWrongPassword
                : null,
          );
          if (password == null) return;
          try {
            final plain = await decryptDatabaseExport(
              await File(path).readAsBytes(),
              password,
            );
            final tempPath = join(
              await getTemporaryAppDirectory(),
              'e1547_import.db',
            );
            await Directory(dirname(tempPath)).create(recursive: true);
            decryptedFile = File(tempPath);
            if (decryptedFile.existsSync()) await decryptedFile.delete();
            await decryptedFile.writeAsBytes(plain);
            sourcePath = tempPath;
            break;
          } on SecretBoxAuthenticationError {
            // AES-GCM tag mismatch: wrong password or a corrupted file.
            wrongPassword = true;
          }
        }
        if (!context.mounted) return;
      }

      // Reject files this build cannot understand before touching anything.
      final version = await readSqliteUserVersion(sourcePath);
      switch (classifyImportSchemaVersion(version)) {
        case ImportSchemaGate.tooNew:
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.databaseImportNewerFile)),
          );
          _logger.warn('Rejected database from a newer schema version', {
            'version': version,
          });
          return;
        case ImportSchemaGate.empty:
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.databaseNotE1547)),
          );
          _logger.warn('Rejected database without a schema version', {
            'version': version,
          });
          return;
        case ImportSchemaGate.ok:
          break;
      }
      if (!context.mounted) return;

      showBlockingProgressDialog(context, l10n.databaseImporting);
      try {
        final hosts = await stageImportCandidate(sourcePath);
        await excludeDatabaseFromBackup();

        navigator.pop();
        if (context.mounted) {
          await _showRestartDialog(context, hosts: hosts);
        }
      } on Exception catch (e) {
        // The staged candidate is dropped even if it had already passed
        // validation: a file the restart did not confirm must never be
        // adopted by the next boot.
        await discardStagedImport();
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.databaseInvalidFile(e.toString()))),
        );
        _logger.warn('Database validation failed', null, e);
      }
    } on Exception catch (e) {
      // Failures before the progress dialog opened only surface as a
      // message; popping here would dismiss the page instead.
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.databaseImportFailed(e.toString()))),
      );
      _logger.warn('Database import failed', null, e);
    } finally {
      if (decryptedFile != null && decryptedFile.existsSync()) {
        try {
          await decryptedFile.delete();
        } on FileSystemException {
          // already deleted elsewhere
        }
      }
    }
  }

  Future<bool> _showImportWarning(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (context) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: AlertDialog(
          title: Text(AppLocalizations.of(context).databaseImportTitle),
          content: Text(AppLocalizations.of(context).databaseImportWarning),
          actions: [
            TextButton(
              onPressed: () => popDialog(context, false),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            TextButton(
              onPressed: () => popDialog(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppLocalizations.of(context).actionImport),
            ),
          ],
        ),
      ),
    ),
  ).then((value) => value ?? false);

  Future<void> _showRestartDialog(
    BuildContext context, {
    required Set<String> hosts,
  }) async {
    // Whether the user pressed restart. Every other exit from this
    // dialog — the system back key popping the route, a process death —
    // leaves the candidate unconfirmed, and the next boot must not
    // mistake validation for consent.
    var restarting = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final foreignHosts = hosts.difference(defaultHosts);
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AlertDialog(
              title: Text(l10n.databaseRestartTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.databaseRestartBody),
                  const SizedBox(height: 12),
                  Text(l10n.databaseImportSanitized),
                  if (foreignHosts.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.databaseImportHostsWarning(foreignHosts.join(', ')),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Drop the staged import; the current database stays.
                    final messenger = ScaffoldMessenger.of(context);
                    await discardStagedImport();
                    if (!context.mounted) return;
                    popDialog(context);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.databaseImportCancelled)),
                    );
                  },
                  child: Text(l10n.actionCancel),
                ),
                TextButton(
                  onPressed: () async {
                    // Record the user's consent right before the restart
                    // adopts it; a boot that never sees this marker keeps
                    // the live database instead.
                    restarting = true;
                    await confirmStagedImport(
                      await pendingImportPath(),
                      await pendingImportConfirmPath(),
                    );
                    if (!context.mounted) return;
                    AppInit.of(context).reinitialize();
                  },
                  child: Text(l10n.actionRestartNow),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!restarting) {
      // The dialog went away without the restart: the staged candidate
      // must never reach the next boot as installable.
      await discardStagedImport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.file_upload),
      title: Text(AppLocalizations.of(context).databaseImport),
      subtitle: Text(
        AppLocalizations.of(context).databaseImportSubtitle,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _importDatabase(context),
    );
  }
}

/// A progress dialog that stays until its navigator pops it.
///
/// Both the export and the import show one while working; neither is
/// dismissible, so the underlying action owns the dialog's lifetime.
/// [PopScope] keeps the system back button from dismissing it as well:
/// the back gesture would pop the page underneath once the action
/// finishes and pops the dialog itself.
void showBlockingProgressDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(4),
              child: SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(message),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A password prompt for encrypted exports and imports.
///
/// The export passes a body and helper text, the import a wrong-password
/// warning; everything else is shared.
Future<String?> showPasswordPrompt(
  BuildContext context, {
  required String title,
  required String label,
  required String confirm,
  String? body,
  String? helper,
  String? warning,
}) => showDialog<String>(
  context: context,
  barrierDismissible: false,
  builder: (context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: _PasswordPromptDialog(
        title: title,
        label: label,
        confirm: confirm,
        body: body,
        helper: helper,
        warning: warning,
      ),
    ),
  ),
);

class _PasswordPromptDialog extends StatefulWidget {
  const _PasswordPromptDialog({
    required this.title,
    required this.label,
    required this.confirm,
    this.body,
    this.helper,
    this.warning,
  });

  final String title;
  final String label;
  final String confirm;
  final String? body;
  final String? helper;
  final String? warning;

  @override
  State<_PasswordPromptDialog> createState() => _PasswordPromptDialogState();
}

class _PasswordPromptDialogState extends State<_PasswordPromptDialog> {
  final TextEditingController controller = TextEditingController();
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.body != null) ...[
            Text(widget.body!),
            const SizedBox(height: 16),
          ],
          if (widget.warning != null) ...[
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.warning!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: controller,
            obscureText: obscure,
            autocorrect: false,
            enableSuggestions: false,
            autofocus: true,
            onSubmitted: (_) => popDialog(context, controller.text),
            decoration: InputDecoration(
              labelText: widget.label,
              helperText: widget.helper,
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                tooltip: obscure ? l10n.actionShow : l10n.actionHide,
                onPressed: () => setState(() => obscure = !obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => popDialog(context),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => popDialog(context, controller.text),
          child: Text(widget.confirm),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
