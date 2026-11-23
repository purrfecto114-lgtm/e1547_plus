import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../_support/images.dart';
import '../../_support/posts.dart';

/// The pixel budget a fullscreen image may decode to on mobile devices.
const int _fullscreenMaxPixels = 2048 * 2048;

void main() {
  for ((String, int, int) shape in [
    ('both axes missing', 0, 0),
    ('only the width missing', 0, 100),
    ('only the height missing', 100, 0),
  ]) {
    final (String name, int width, int height) = shape;
    testWidgets(
      'a file with no dimensions still decodes within the pixel budget '
      '— $name',
      (tester) async {
        const manager = NoImageCacheManager();
        await tester.pumpWidget(
          Provider<BaseCacheManager>.value(
            value: manager,
            child: MaterialApp(
              home: Scaffold(
                body: RawPostImageWidget(
                  post: samplePost(
                    file: 'https://example.org/file.jpg',
                    width: width,
                    height: height,
                  ),
                  size: PostImageSize.file,
                  cacheSize: 2048,
                  maxPixels: _fullscreenMaxPixels,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final CachedNetworkImage image = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );
        // The pixel budget is the cap that bounds the decode: either axis
        // may stay null, but at least one must be set, and whatever is
        // set must be inside the budget's square.
        final int? w = image.memCacheWidth;
        final int? h = image.memCacheHeight;
        expect(
          w != null || h != null,
          isTrue,
          reason:
              'a file with no dimensions ($name) must not decode at its '
              'native size',
        );
        if (w != null) {
          expect(w * (h ?? w), lessThanOrEqualTo(_fullscreenMaxPixels));
        } else {
          expect(h, lessThanOrEqualTo(2048));
        }
      },
    );
  }
}
