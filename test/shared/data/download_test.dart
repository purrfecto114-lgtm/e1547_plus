import 'dart:io';

import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
// ignore: depend_on_referenced_packages
import 'package:file/file.dart' as pkg_file;
// ignore: depend_on_referenced_packages
import 'package:file/local.dart' as pkg_file;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/posts.dart';

class FakeSingleFileCache implements BaseCacheManager {
  FakeSingleFileCache(this.path);

  final String path;

  @override
  Future<pkg_file.File> getSingleFile(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) async => pkg_file.LocalFileSystem().file(path);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  // The download path and the file name flow into plain file operations on
  // desktop; a hostile server controls both the post's ext field and can
  // influence names, so neither may smuggle path segments out of the chosen
  // download directory.
  test('downloadFile flattens server-provided file names', () async {
    final outer = await Directory.systemTemp.createTemp('download-escape');
    addTearDown(() => outer.delete(recursive: true));
    final dir = Directory('${outer.path}/downloads')..createSync();
    final source = File('${outer.path}/source.bin')..writeAsBytesSync([1]);

    await FileDownloader.downloadFile(
      file: source,
      directory: dir.path,
      fileName: '../escape.bin',
    );

    expect(File('${dir.path}/escape.bin').existsSync(), isTrue);
    expect(File('${outer.path}/escape.bin').existsSync(), isFalse);
  });

  test('download names flatten the server-provided extension', () async {
    final outer = await Directory.systemTemp.createTemp('download-ext');
    addTearDown(() => outer.delete(recursive: true));
    final dir = Directory('${outer.path}/downloads')..createSync();
    final source = File('${outer.path}/source.bin')..writeAsBytesSync([1]);

    final post = samplePost(
      id: 7,
      ext: '../../evil',
      file: 'https://example.com/x.bin',
    );
    await post.download(
      path: dir.path,
      onPathChanged: (_) {},
      folder: 'e1547',
      cache: FakeSingleFileCache(source.path),
    );

    expect(File('${dir.path}/7.evil').existsSync(), isTrue);
    expect(File('${outer.path}/evil').existsSync(), isFalse);
  });
}
