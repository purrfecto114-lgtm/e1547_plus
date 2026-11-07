import 'dart:async';
import 'dart:io';

import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

extension PostDownloading on Post {
  Future<void> download({
    required String? path,
    required void Function(String value) onPathChanged,
    required String folder,
    required BaseCacheManager cache,
  }) async {
    try {
      String? url = file;

      if (url == null) {
        throw FileDownloadException('Post does not have a file!');
      }

      File downloadFile = await cache.getSingleFile(url);

      await FileDownloader.downloadImage(
        file: downloadFile,
        directory: path,
        folderName: folder,
        fileName: _downloadName(),
        onDirectoryChanged: onPathChanged,
      );
    } on FileDownloadException {
      rethrow;
    } on Exception catch (e) {
      throw FileDownloadException.from(e);
    }
  }

  String _downloadName() {
    String filename = '';
    List<String> artists = filterArtists(tags['artist'] ?? []);
    if (artists.isNotEmpty) {
      filename = '${artists.join(', ')} - ';
    }
    // ext comes from the server's post json; a hostile host must not be
    // able to smuggle path segments into the file name
    final String safeExt = ext.replaceAll(RegExp(r'[^\w]'), '');
    return filename += '$id.$safeExt';
  }
}
