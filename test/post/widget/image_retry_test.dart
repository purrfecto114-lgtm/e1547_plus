import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/posts.dart';

/// A failing manager that counts its stream requests, so a retry after
/// a refresh shows up as a second request for the same url.
class CountingFailingManager implements BaseCacheManager {
  int requests = 0;

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool? withProgress,
  }) {
    requests++;
    return Stream<FileResponse>.error(Exception('no image at $url'));
  }

  @override
  Future<File> getSingleFile(
    String url, {
    String key = '',
    Map<String, String> headers = const {},
  }) => Future<File>.error(Exception('no image at $url'));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} holds no image');
}

void main() {
  testWidgets('a failed image retries once the app refreshed', (tester) async {
    final manager = CountingFailingManager();
    final post = samplePost(preview: 'https://example.org/preview.jpg');
    await tester.pumpWidget(
      Provider<BaseCacheManager>.value(
        value: manager,
        child: MaterialApp(
          home: Scaffold(
            body: PostImageWidget(post: post, size: PostImageSize.preview),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // The first load failed: the tile shows the broken image hint and
    // must not pin that verdict until the user scrolls it away.
    expect(manager.requests, 1);
    expect(find.byType(TornImagePlaceholder), findsOneWidget);

    // A pull-to-refresh advanced the retry epoch: the failed tile
    // rebuilds and tries the url again instead of keeping the error.
    imageRetryEpoch.value++;
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(manager.requests, 2);
  });
}
