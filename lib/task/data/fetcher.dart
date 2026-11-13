import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/settings/settings.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Fetches a file over the network into a temporary file.
///
/// Reports raw transfer progress while the download runs: [onProgress]
/// receives the bytes received so far and the total length, or null when
/// the response does not announce one. Canceling [cancelToken] aborts the
/// underlying network transfer, so no further bytes are received, and the
/// partial file is removed.
typedef DownloadFileFetcher =
    Future<File> Function(
      String url,
      CancelToken cancelToken,
      void Function(int count, int? total)? onProgress,
    );

/// Creates the credential-free transfer client the task controller keeps
/// for the lifetime of all its downloads.
///
/// Downloads go to the CDN instead of the API, so the client carries only a
/// user agent — never account credentials — and its connection pool is
/// reused across the files of a whole batch instead of being rebuilt for
/// every single file.
Dio createTransferClient() {
  final Dio dio = Dio(
    BaseOptions(
      headers: {HttpHeaders.userAgentHeader: AppInfo.instance.userAgent},
      connectTimeout: const Duration(seconds: 30),
      // for streamed bodies this applies between chunks, not to the whole file
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  dio.httpClientAdapter = NativeAdapter();
  return dio;
}

/// How often a running transfer refreshes its reported progress at most.
const Duration transferProgressInterval = Duration(milliseconds: 100);

/// The default [DownloadFileFetcher] used by the task controller.
///
/// Downloads go straight to a temporary file with a bare CDN request,
/// without api credentials, and are exported to their destination once
/// complete. Passing [client] reuses a long-lived transfer client — like
/// the one [createTransferClient] builds — instead of creating and closing
/// one per file; the caller keeps ownership of a shared client and closes
/// it when its downloads end.
Future<File> fetchFileToTemp(
  String url,
  CancelToken cancelToken,
  void Function(int count, int? total)? onProgress, {
  Dio? client,
}) async {
  final Dio dio = client ?? createTransferClient();
  final Directory tempDir = await getTemporaryDirectory();
  final File file = File(
    p.join(
      tempDir.path,
      'e1547-task-${DateTime.now().microsecondsSinceEpoch}${p.extension(p.fromUri(url))}',
    ),
  );
  DateTime? lastReport;
  try {
    await dio.download(
      url,
      file.path,
      cancelToken: cancelToken,
      onReceiveProgress: (int count, int total) {
        // Transfers report at a moderate rate: often enough for the
        // progress to stay alive, rarely enough to skip rebuilding progress
        // bars for every other chunk. The first and final events always go
        // through.
        final bool finalEvent = total > 0 && count >= total;
        final DateTime now = DateTime.now();
        if (!finalEvent &&
            lastReport != null &&
            now.difference(lastReport!) < transferProgressInterval) {
          return;
        }
        lastReport = now;
        onProgress?.call(count, total > 0 ? total : null);
      },
    );
    return file;
  } on Object {
    if (file.existsSync()) {
      try {
        file.deleteSync();
      } on FileSystemException {
        // best-effort cleanup of the partial download
      }
    }
    rethrow;
  } finally {
    // a shared client stays open for the next file; a local one does not
    if (client == null) {
      dio.close();
    }
  }
}
