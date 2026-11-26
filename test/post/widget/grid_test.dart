import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/environment.dart';
import '../../_support/harness.dart';
import '../../_support/posts.dart';

void main() {
  setUpAll(initializeTestApp);

  late TestEnvironment env;

  setUp(() async => env = await TestEnvironment.start());

  tearDown(() => env.dispose());

  Future<void> show(WidgetTester tester, PagingState<int, Post> state) =>
      tester.pumpWidget(
        env.app(
          Scaffold(
            body: TileLayout(
              child: CustomScrollView(
                slivers: [PostGridSliver(state: state, fetchNextPage: () {})],
              ),
            ),
          ),
        ),
      );

  displayTest(
    'a grid loading its first page shows ghost tiles',
    skip: 'upstream 21.2.0 detail-family and decode-hold assertions, not aligned with this fork yet; see process.md',
    (tester) async {
      await show(tester, PagingState<int, Post>(isLoading: true));

      expect(skeletons(find.byType(PostImageTile)), findsWidgets);
    },
  );

  displayTest(
    'a loaded grid shows its posts and no ghosts',
    skip: 'upstream 21.2.0 detail-family and decode-hold assertions, not aligned with this fork yet; see process.md',
    (tester) async {
      await show(
        tester,
        PagingState<int, Post>(
          pages: [
            [samplePost(id: 7)],
          ],
          keys: const [1],
          hasNextPage: false,
        ),
      );

      expect(find.byType(PostImageTile), findsOneWidget);
      expect(skeletons(find.byType(PostImageTile)), findsNothing);
    },
  );

  displayTest('a grid on the low quality tier decodes previews', (
    tester,
  ) async {
    // The low tier is the one users can tell from the others: it swaps
    // the tile source from the sample down to the preview, which saves
    // the most traffic and memory of the three tiers.
    env.settings.thumbnailQuality.value = ThumbnailQuality.low;
    await show(
      tester,
      PagingState<int, Post>(
        pages: [
          [
            samplePost(
              id: 7,
              file: '/file/7',
              preview: '/preview/7',
            ).copyWith(sample: '/sample/7'),
          ],
        ],
        keys: const [1],
        hasNextPage: false,
      ),
    );

    final image = tester.widget<PostImageWidget>(find.byType(PostImageWidget));
    expect(image.size, PostImageSize.preview);
  });

  displayTest('a grid on the medium quality tier decodes samples', (
    tester,
  ) async {
    env.settings.thumbnailQuality.value = ThumbnailQuality.medium;
    await show(
      tester,
      PagingState<int, Post>(
        pages: [
          [
            samplePost(
              id: 7,
              file: '/file/7',
              preview: '/preview/7',
            ).copyWith(sample: '/sample/7'),
          ],
        ],
        keys: const [1],
        hasNextPage: false,
      ),
    );

    final image = tester.widget<PostImageWidget>(find.byType(PostImageWidget));
    expect(image.size, PostImageSize.sample);
  });
}
