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
  }) async => const pkg_file.LocalFileSystem().file(path);

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

  group('ios gallery routing', () {
    test('classifies what the photo library can store', () {
      // webm has no iOS decoder: saving used to report success while
      // nothing landed in the gallery.
      expect(
        FileDownloader.iosGalleryKindFor('a/video.webm'),
        IosGalleryKind.unsupported,
      );
      expect(
        FileDownloader.iosGalleryKindFor('a/clip.MP4'),
        IosGalleryKind.video,
      );
      expect(
        FileDownloader.iosGalleryKindFor('a/clip.mov'),
        IosGalleryKind.video,
      );
      expect(
        FileDownloader.iosGalleryKindFor('a/picture.png'),
        IosGalleryKind.image,
      );
      expect(
        FileDownloader.iosGalleryKindFor('a/picture.JPEG'),
        IosGalleryKind.image,
      );
      expect(
        FileDownloader.iosGalleryKindFor('a/loop.GIF'),
        IosGalleryKind.gif,
      );
      expect(
        FileDownloader.iosGalleryKindFor('a/archive.zip'),
        IosGalleryKind.unsupported,
      );
      expect(
        FileDownloader.iosGalleryKindFor('a/no-extension'),
        IosGalleryKind.unsupported,
      );
    });

    test('classifies by the intended name over the temp file path', () {
      // A fetched temp file or cache artifact carries whatever extension
      // its own path happened to have; the download's name holds the
      // post's true format and must win.
      expect(
        FileDownloader.iosGalleryKindFor('cache/xyz.tmp', name: 'post.GIF'),
        IosGalleryKind.gif,
      );
      expect(
        FileDownloader.iosGalleryKindFor('cache/uuid', name: 'post.MP4'),
        IosGalleryKind.video,
      );
      expect(
        FileDownloader.iosGalleryKindFor('cache/xyz.tmp', name: 'post.webm'),
        IosGalleryKind.unsupported,
      );
      // without a name, the path speaks for itself as before
      expect(
        FileDownloader.iosGalleryKindFor('cache/uuid.jpg'),
        IosGalleryKind.image,
      );
    });

    test('a rejected gallery save throws instead of passing', () {
      expect(
        () => FileDownloader.checkGallerySaveResult({
          'isSuccess': false,
          'errorMessage': 'nope',
        }),
        throwsA(
          isA<FileDownloadException>().having(
            (e) => e.message,
            'message',
            contains('nope'),
          ),
        ),
      );
      expect(
        () => FileDownloader.checkGallerySaveResult({'isSuccess': true}),
        returnsNormally,
      );
    });
  });
}
