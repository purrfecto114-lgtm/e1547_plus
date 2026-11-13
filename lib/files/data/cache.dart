import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/files/files.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const String fileCacheKey = DefaultCacheManager.key;

/// A [CacheManager] that closes the [Dio] it downloads through.
///
/// The media client has no credentials to send (see [createMediaDio]), so
/// its lifecycle is the cache's own: disposing the manager releases the
/// connection pool instead of leaking it per identity switch.
class MediaCacheManager extends CacheManager {
  MediaCacheManager._(this._dio, super.config);

  final Dio _dio;

  @override
  Future<void> dispose() {
    _dio.close();
    return super.dispose();
  }
}

BaseCacheManager createFileCache({
  required GeneratedDatabase database,
  Duration stalePeriod = const Duration(days: 7),
  // e621 originals are large; the old default of 2000 objects could pile
  // up gigabytes on old devices, filling their storage and inviting the
  // OS to wipe the cache directory altogether (see issue #178).
  int maxNrOfCacheObjects = 500,
  // A count-only budget still admits 500 large originals, so a byte
  // budget bounds the cache regardless of file sizes; entries are given
  // up least-recently-touched first.
  int maxCacheBytes = 1024 * 1024 * 1024,
}) {
  // Media URLs come from API responses and may point at any host, so the
  // downloads deliberately travel without the identity's credentials.
  final dio = createMediaDio();
  return MediaCacheManager._(
    dio,
    Config(
      fileCacheKey,
      stalePeriod: stalePeriod,
      maxNrOfCacheObjects: maxNrOfCacheObjects,
      repo: DriftFileCacheStorage(
        repository: FileCacheRepository(database: database),
        cache: fileCacheKey,
        maxBytes: maxCacheBytes,
      ),
      fileService: DioFileService(dio),
    ),
  );
}

Future<void> discardLegacyFileCache() async {
  final File index = File(
    join((await getApplicationSupportDirectory()).path, '$fileCacheKey.json'),
  );
  if (!index.existsSync()) return;
  await index.delete();
  final Directory files = Directory(
    join((await getTemporaryDirectory()).path, fileCacheKey),
  );
  if (files.existsSync()) {
    await files.delete(recursive: true);
  }
}
