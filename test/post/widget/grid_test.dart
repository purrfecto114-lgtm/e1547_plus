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
    skip:
        'upstream 21.2.0 detail-family and decode-hold assertions, not aligned with this fork yet; see process.md',
    (tester) async {
      await show(tester, PagingState<int, Post>(isLoading: true));

      expect(skeletons(find.byType(PostImageTile)), findsWidgets);
    },
  );

  displayTest(
    'a loaded grid shows its posts and no ghosts',
    skip:
        'upstream 21.2.0 detail-family and decode-hold assertions, not aligned with this fork yet; see process.md',
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
}
