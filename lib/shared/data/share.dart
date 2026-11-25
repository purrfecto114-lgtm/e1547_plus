import 'dart:io';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart' show AppInfo;
import 'package:e1547/shared/widget/animation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract final class Share {
  static Future<void> text(BuildContext context, String text) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await SharePlus.instance.share(ShareParams(text: text));
    } else {
      await clipboard(context, text);
    }
  }

  static Future<void> asFile(
    BuildContext context,
    String text,
    String name,
  ) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // The app's own subdirectory of the temp dir is what the startup
      // sweep watches; files written to the temp root itself (where
      // these exports used to land) never got cleaned up. Same
      // convention as getTemporaryAppDirectory in the app package.
      final dir = Directory(
        join((await getTemporaryDirectory()).path, AppInfo.instance.appName),
      );
      await dir.create(recursive: true);
      File file = File(join(dir.path, name));
      await file.writeAsString(text);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } else {
      final messenger = ScaffoldMessenger.of(context);
      final AppLocalizations localizations = AppLocalizations.of(context);
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: localizations.saveFile,
        fileName: name,
      );
      if (outputFile == null) return;

      await File(outputFile).writeAsString(text);
      messenger.showSnackBar(
        SnackBar(
          duration: shortSnackBarDuration,
          content: Text(localizations.fileSavedAs(basename(outputFile))),
        ),
      );
    }
  }

  static Future<void> file(BuildContext context, String path) async {
    XFile file = XFile(path);
    if (Platform.isAndroid || Platform.isIOS) {
      await SharePlus.instance.share(ShareParams(files: [file]));
    } else {
      final messenger = ScaffoldMessenger.of(context);
      final AppLocalizations localizations = AppLocalizations.of(context);
      String content = await file.readAsString();
      if (!context.mounted) return;

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: localizations.saveFile,
        fileName: basename(path),
      );
      if (outputFile == null) return;

      await File(outputFile).writeAsString(content);
      messenger.showSnackBar(
        SnackBar(
          duration: shortSnackBarDuration,
          content: Text(localizations.fileSavedAs(basename(outputFile))),
        ),
      );
    }
  }

  /// Copies [text] to the clipboard and confirms with a snackbar. A
  /// [message] overrides the generic confirmation, for surfaces that
  /// name what they copied ("Reply #123 copied"); the default suits
  /// every other spot.
  static Future<void> clipboard(
    BuildContext context,
    String text, {
    String? message,
  }) async {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(
      SnackBar(
        duration: shortSnackBarDuration,
        content: Text(message ?? localizations.copiedToClipboard),
      ),
    );
  }
}
