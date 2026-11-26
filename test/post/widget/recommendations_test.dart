import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../_support/environment.dart';
import '../../_support/harness.dart';
import '../../_support/posts.dart';

void main() {
  setUpAll(initializeTestApp);

  late TestEnvironment env;

  setUp(
    () async => env = await TestEnvironment.start(denylist: ['blocked_tag']),
  );

  tearDown(() => env.dispose());

  /// Adds posts sharing the referenced post's artist tags. The state
  /// posts carry the current api layout (flat tag lists); artist names
  /// are the entries the fake's category table classifies as artists.
  /// The shown post must be in the state too: the endpoint looks it up
  /// server-side before matching its artists against the others.
  void addWorks(Map<int, List<String>> works) {
    final Map<String, Object?> recorded = env.fake.state.posts.first;
    env.fake.state.posts.addAll([
      for (final MapEntry<int, List<String>> work in works.entries)
        {
          ...recorded,
          'id': work.key,
          // Only the shared artist tag; inheriting the recorded post's
          // own artist tags would recommend that post too.
          'tags': ['some_artist', ...work.value],
        },
    ]);
  }

  Future<void> show(
    WidgetTester tester,
    Post post, {
    double width = 800,
  }) async {
    final PostFilter filter = PostFilter(env.client);
    addTearDown(filter.dispose);
    await tester.runAsync(
      () => tester.pumpWidget(
        env.app(
          Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: width,
                child: ArtistRecommendations(post: post),
              ),
            ),
          ),
          providers: [ListenableProvider<PostFilter>.value(value: filter)],
        ),
      ),
    );
    await env.settle(tester);
  }

  Post work(int id) => samplePost(
    id: id,
    tags: const {
      'artist': ['some_artist'],
    },
  );

  List<int> tiles(WidgetTester tester) => tester
      .widgetList<PostTileOverlay>(find.byType(PostTileOverlay))
      .map((e) => e.post.id)
      .toList();

  displayTest(
    'artist recommendations list what the server finds, in its order',
    (tester) async {
      addWorks({41: [], 42: [], 43: [], 44: []});

      await show(tester, work(41));

      expect(find.text('From the artist'), findsOneWidget);
      expect(tiles(tester), [42, 43, 44]);
    },
  );

  displayTest(
    'artist recommendations show only the posts that fit their width',
    (tester) async {
      addWorks({41: [], 42: [], 43: [], 44: [], 45: [], 46: []});

      await show(tester, work(41), width: 360);

      expect(tiles(tester), [42, 43, 44]);
      expect(
        tester.getSize(find.byType(RelationPreviewCard).first),
        const Size(120, 120),
      );
    },
  );

  displayTest('a blacklisted post is left out of artist recommendations', (
    tester,
  ) async {
    addWorks({
      41: [],
      42: [],
      43: ['blocked_tag'],
      44: [],
    });

    await show(tester, work(41));

    expect(tiles(tester), [42, 44]);
  });

  displayTest('a post opens among the others the artist made', (tester) async {
    addWorks({41: [], 42: [], 43: [], 44: []});
    await show(tester, work(41));
    env.fake.requests.clear();

    await tester.tap(
      find.ancestor(
        of: find.byWidgetPredicate(
          (e) => e is PostTileOverlay && e.post.id == 43,
        ),
        matching: find.byType(RelationPreviewCard),
      ),
    );
    await env.settle(tester, animating: true);

    expect(shownPost(tester), 43);
    expect(
      env.fake.requests
          .where((e) => e.path == '/posts.json')
          .map((e) => e.query['tags']),
      // Unlike upstream, this fork's detail loader also refetches the
      // shown post with hidden ones included (byIds hidden: true).
      contains('id:42,43,44'),
    );

    await tester.fling(find.byType(PostDetail), const Offset(600, 0), 2000);
    await env.settle(tester, animating: true);
    expect(shownPost(tester), 42);
  });

  displayTest(
    'a recommended post shows its image while it loads',
    skip:
        'upstream decode-hold assertion expects the image pipeline to hold '
        'the decode; this fork caps decodes instead (see process.md round 8)',
    (tester) async {
      addWorks({41: [], 42: [], 43: [], 44: []});
      await show(tester, work(41));

      await tester.tap(
        find.ancestor(
          of: find.byWidgetPredicate(
            (e) => e is PostTileOverlay && e.post.id == 43,
          ),
          matching: find.byType(RelationPreviewCard),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.byWidgetPredicate((e) => e is PostImageWidget && e.post.id == 43),
        findsOneWidget,
      );

      await env.settle(tester, animating: true);

      expect(skeletons(find.byType(PostDetail)), findsNothing);
      expect(shownPost(tester), 43);
    },
  );

  displayTest('a recommended post shows at once when it is cached', (
    tester,
  ) async {
    addWorks({41: [], 42: [], 43: [], 44: []});
    await show(tester, work(41));
    await tester.runAsync(
      () => env.client.posts.usePage(query: {'tags': 'some_artist'}).fetch(),
    );

    await tester.tap(
      find.ancestor(
        of: find.byWidgetPredicate(
          (e) => e is PostTileOverlay && e.post.id == 43,
        ),
        matching: find.byType(RelationPreviewCard),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(skeletons(find.byType(PostDetail)), findsNothing);
    expect(shownPost(tester), 43);
    await env.settle(tester, animating: true);
  });

  displayTest('see all searches for every artist of the post', (tester) async {
    addWorks({41: [], 42: []});
    await show(
      tester,
      samplePost(
        id: 41,
        tags: const {
          'artist': ['some_artist', 'other_artist', 'conditional_dnp'],
        },
      ),
    );
    env.fake.requests.clear();

    await tester.tap(find.text('See all'));
    await env.settle(tester, animating: true);

    expect(
      env.fake.requests
          .where((e) => e.path == '/posts.json')
          .map((e) => e.query['tags']),
      contains('~some_artist ~other_artist'),
    );
  });

  displayTest(
    'a post whose artist tags name no artist has no '
    'recommendations',
    skip: 'upstream 21.2.0 detail-family assertions, not aligned yet',
    (tester) async {
      addWorks({41: [], 42: []});

      await show(
        tester,
        samplePost(
          id: 41,
          tags: const {
            'artist': ['conditional_dnp'],
          },
        ),
      );

      expect(find.byType(ArtistRecommendationsRow), findsNothing);
      expect(
        env.fake.requests.where((e) => e.path.contains('similar')),
        isEmpty,
      );
    },
  );
}
