import 'dart:async';
import 'dart:io';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/data/language.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';

/// The outcome of a download directory preflight.
enum DownloadDirectoryCheck {
  /// A writable directory is ready; none had to be picked.
  ready,

  /// The user dismissed the directory picker; the caller must not start
  /// any transfer.
  canceled,
}

/// A utility class for downloading files to the device.
abstract final class FileDownloader {
  /// Allows the user to pick a directory for downloading files.
  static Future<String?> pickDirectory({String? initial}) async {
    if (Platform.isAndroid) {
      if (initial?.contains('/storage/emulated/') ?? false) {
        initial = null;
      }

      final dir = await SafUtil().pickDirectory(
        initialUri: initial,
        writePermission: true,
        persistablePermission: true,
      );
      return dir?.uri;
    } else {
      // Loads localizations from the stored language preference, since
      // the download stack has no BuildContext of its own.
      final AppLocalizations localizations =
          await loadPreferenceLocalizations();
      return FilePicker.platform.getDirectoryPath(
        dialogTitle: localizations.downloadChooseFolder,
        initialDirectory: initial,
      );
    }
  }

  /// Resolves a usable download directory before a transfer starts.
  ///
  /// This is the picker-and-permission part of [downloadFile], without the
  /// file: a batch of downloads can ask for its destination up front, so
  /// no transfer finishes only to find a directory picker waiting behind
  /// it. Android verifies the persisted write permission and prompts again
  /// when it lapsed; desktop prompts while no directory is configured.
  /// iOS writes to the photo gallery and needs no directory at all.
  ///
  /// A picked directory is reported through [onDirectoryChanged], mirroring
  /// [downloadFile]'s callback, so callers can persist the choice.
  static Future<DownloadDirectoryCheck> ensureDownloadDirectory({
    String? directory,
    void Function(String dir)? onDirectoryChanged,
  }) async {
    if (Platform.isIOS) {
      return DownloadDirectoryCheck.ready;
    }
    try {
      if (Platform.isAndroid) {
        if (directory?.contains('/storage/emulated/') ?? false) {
          directory = null;
        }
        if (directory != null &&
            await SafUtil().hasPersistedPermission(
              directory,
              checkWrite: true,
            )) {
          return DownloadDirectoryCheck.ready;
        }
        final String? picked = await pickDirectory(initial: directory);
        if (picked == null) return DownloadDirectoryCheck.canceled;
        onDirectoryChanged?.call(picked);
        return DownloadDirectoryCheck.ready;
      }
      if (directory != null) {
        return DownloadDirectoryCheck.ready;
      }
      final String? picked = await pickDirectory();
      if (picked == null) return DownloadDirectoryCheck.canceled;
      onDirectoryChanged?.call(picked);
      return DownloadDirectoryCheck.ready;
    } on Exception catch (e) {
      throw FileDownloadException.from(e);
    }
  }

  /// Releases permissions to a previously selected directory.
  static Future<void> forgetDirectory(String? directory) async {
    if (Platform.isAndroid && directory != null) {
      // TODO: not implemented, see https://github.com/flutter-cavalry/saf_util/issues/6
      // await SafUtil().releasePersistableUriPermission(directory);
    }
  }

  /// Downloads a file to the specified directory.
  /// The user may choose a directory, if the parameter `directory` is null or the app does not have permission to write to the specified directory.
  ///
  /// Returns the location the file was actually written to, when it can be
  /// addressed for a later rollback: a plain file path on desktop, a
  /// content uri pointing at the exact document on Android. iOS saves into
  /// the gallery and cannot name a file.
  ///
  /// Not supported on iOS.
  static Future<String?> downloadFile({
    required File file,
    required String? directory,
    String? folderName,
    String? fileName,
    void Function(String dir)? onDirectoryChanged,
  }) async {
    try {
      if (Platform.isIOS) {
        throw UnsupportedError(
          'Generic file downloading is not supported on iOS',
        );
      } else if (Platform.isAndroid) {
        if (directory?.contains('/storage/emulated/') ?? false) {
          directory = null;
        }

        String target;
        if (directory == null ||
            !await SafUtil().hasPersistedPermission(
              directory,
              checkWrite: true,
            )) {
          target = await _throwOnNull(
            pickDirectory(initial: directory),
            'No directory was selected.',
          );
        } else {
          target = directory;
        }

        String lastSegment = Uri.parse(target).pathSegments.last;
        if (folderName != null && lastSegment == 'Pictures') {
          try {
            final targetDir = await SafUtil().mkdirp(target, [folderName]);
            target = targetDir.uri;
          } on Exception {
            // can't create app specific sub-folder.
          }
        }

        onDirectoryChanged?.call(target);
        final safStream = SafStream();
        // The name may originate from a server's post json; flatten it so
        // a crafted name cannot smuggle path segments past the saf target.
        final String name = basename(fileName ?? basename(file.path));
        final mimeType = lookupMimeType(name) ?? 'application/octet-stream';
        // Whether the target name already holds a document. An overwrite
        // replaces its content the moment the paste runs, so by the time a
        // cancellation can race the export, deleting the name would leave
        // the user with no file at all — the location is not rollback-safe.
        final bool replacedExisting =
            (await SafUtil().child(target, [name])) != null;
        await safStream.pasteLocalFile(
          file.path,
          target,
          name,
          mimeType,
          overwrite: true,
        );
        // This should probably only happen in [downloadImage].
        await MediaScanner.loadMedia(path: target);
        if (replacedExisting) return null;
        // The exact document lets a raced cancellation remove the copy.
        return (await SafUtil().child(target, [name]))?.uri;
      } else {
        String directoryPath =
            directory ??
            await _throwOnNull(pickDirectory(), 'No directory was selected.');

        onDirectoryChanged?.call(directoryPath);

        if (folderName != null && basename(directoryPath) == 'Pictures') {
          directoryPath = join(directoryPath, folderName);
        }

        final targetDir = Directory(directoryPath);
        if (!targetDir.existsSync()) {
          await targetDir.create(recursive: true);
        }

        // The name may originate from a server's post json; flatten it so a
        // crafted name cannot escape the download directory.
        final targetFile = File(
          join(directoryPath, basename(fileName ?? basename(file.path))),
        );
        // Copy streams in chunks instead of buffering the whole file; a
        // same-file copy must stay a no-op, though.
        final bool existedBefore = targetFile.existsSync();
        final bool sameFile =
            existedBefore &&
            await file.resolveSymbolicLinks() ==
                await targetFile.resolveSymbolicLinks();
        if (sameFile) {
          // the target already is the source; a rollback must never
          // consider it deletable
          return null;
        }
        await file.copy(targetFile.path);
        // An overwrite has replaced the previous content by the time a
        // cancellation can race the export; deleting the name would leave
        // the user with no file at all, so only a freshly created file is
        // rollback-safe.
        if (existedBefore) return null;
        return targetFile.path;
      }
    } on Exception catch (e) {
      throw FileDownloadException.from(e);
    }
  }

  /// Downloads an image file to the device's gallery or a specified directory.
  /// Returns the written location where [downloadFile] can name one.
  static Future<String?> downloadImage({
    required File file,
    required String? directory,
    String? folderName,
    String? fileName,
    void Function(String dir)? onDirectoryChanged,
  }) async {
    if (Platform.isIOS) {
      return _saveToGallery(file.path);
    } else {
      return downloadFile(
        file: file,
        directory: directory,
        folderName: folderName,
        fileName: fileName,
        onDirectoryChanged: onDirectoryChanged,
      );
    }
  }

  /// Serializes iOS gallery writes.
  ///
  /// The plugin's iOS instance keeps a single pending-result slot: two
  /// overlapping saves would have the later call replace the earlier
  /// callback, misrouting results or leaving the earlier future forever
  /// pending. Chaining every write keeps parallel transfers intact while
  /// the gallery commits one at a time.
  static Future<void> _galleryWriteLock = Future.value();

  static Future<String?> _saveToGallery(String path) {
    final Future<void> write = _galleryWriteLock.then((_) async {
      final dynamic result = await ImageGallerySaverPlus.saveFile(path);
      checkGallerySaveResult(result);
    });
    // Keep the chain intact even when a write fails, so one rejected file
    // cannot wedge every later save.
    _galleryWriteLock = write.then<void>((_) {}, onError: (Object _) {});
    return write.then((_) => null);
  }

  /// Throws when a gallery save reported a partial failure.
  ///
  /// [ImageGallerySaverPlus.saveFile] reports rejected files (unsupported
  /// formats, failed save callbacks) through its result map instead of
  /// throwing; treating those as success would mark tasks completed that
  /// never landed in the gallery.
  @visibleForTesting
  static void checkGallerySaveResult(Object? result) {
    final bool success = result is Map && result['isSuccess'] == true;
    if (success) return;
    final Object? reason = result is Map ? result['errorMessage'] : null;
    throw FileDownloadException(
      reason is String && reason.isNotEmpty
          ? 'Saving to the gallery failed: $reason'
          : 'Saving to the gallery failed',
    );
  }

  /// Removes an export at the location [downloadFile] reported, for a
  /// cancellation that raced the write. Best-effort: a failed rollback
  /// must never mask the original error.
  static void deleteExported(String? location) {
    if (location == null) return;
    if (location.startsWith('content:')) {
      // Android gallery exports are saf documents and the reported uri
      // points at the exact file this export wrote.
      SafUtil().delete(location, false).ignore();
      return;
    }
    File(location).delete().ignore();
  }

  static Future<T> _throwOnNull<T>(FutureOr<T?> future, String message) async {
    T? result = await future;
    if (result == null) {
      throw FileDownloadException(message);
    }
    return result;
  }
}

class FileDownloadException implements Exception {
  FileDownloadException(this.message) : inner = null;

  FileDownloadException.from(Object this.inner) : message = null;

  final String? message;
  final Object? inner;

  @override
  String toString() {
    if (message != null) {
      return '$runtimeType: $message';
    }
    if (inner != null) {
      if (inner is FileDownloadException) {
        return inner.toString();
      }
      return '$runtimeType: $inner';
    }
    return '$runtimeType: unknown cause!';
  }
}
