import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/environment.dart';
import '../../_support/harness.dart';
import '../../_support/posts.dart';

void main() {
  setUpAll(initializeTestApp);

  late TestEnvironment env;

  setUp(
    () async => env = await TestEnvironment.start(
      credentials: const Credentials(username: 'tester', password: 'key'),
    ),
  );

  tearDown(() => env.dispose());

  Future<void> tapOn(WidgetTester tester, Widget child, IconData icon) async {
    await tester.pumpWidget(env.app(Scaffold(body: child)));
    await tester.tap(find.byIcon(icon));
    await env.settle(tester);
  }

  Color? colorOf(WidgetTester tester, IconData icon) =>
      tester.widget<Icon>(find.byIcon(icon)).color;

  displayTest('a favorite the site accepts lands and shows', (tester) async {
    await tapOn(
      tester,
      FavoriteButton(post: samplePost(id: 1000)),
      Icons.favorite,
    );

    expect(
      env.fake.requests
          .where((e) => e.path == '/favorites.json' && e.method == 'POST')
          .map((e) => e.query['post_id']),
      ['1000'],
    );
    expect(find.text('Failed to add Post #1000 to favorites'), findsNothing);
    expect(colorOf(tester, Icons.favorite), Colors.pinkAccent);
  });

  displayTest('an unfavorite the site accepts lands and shows', (tester) async {
    await tapOn(
      tester,
      FavoriteButton(post: samplePost(id: 1000, isFavorited: true)),
      Icons.favorite,
    );

    expect(
      env.fake.requests
          .where((e) => e.path == '/favorites/1000.json')
          .map((e) => e.method),
      ['DELETE'],
    );
    expect(
      find.text('Failed to remove Post #1000 from favorites'),
      findsNothing,
    );
    // the unliked heart falls back to the theme icon color; what
    // matters is that it left pinkAccent
    expect(colorOf(tester, Icons.favorite), isNot(Colors.pinkAccent));
  });

  displayTest('an upvote the site accepts lands and shows', (tester) async {
    await tapOn(
      tester,
      LikeDisplay(post: samplePost(id: 1000)),
      Icons.arrow_upward,
    );

    final request = env.fake.requests
        .where((e) => e.path == '/posts/1000/votes.json')
        .single;
    expect(request.query['score'], '1');
    expect(request.query['no_unvote'], 'true');
    expect(find.text('Failed to upvote Post #1000'), findsNothing);
    expect(colorOf(tester, Icons.arrow_upward), isNotNull);
  });

  displayTest('a downvote the site accepts lands and shows', (tester) async {
    await tapOn(
      tester,
      LikeDisplay(post: samplePost(id: 1000)),
      Icons.arrow_downward,
    );

    final request = env.fake.requests
        .where((e) => e.path == '/posts/1000/votes.json')
        .single;
    expect(request.query['score'], '-1');
    expect(find.text('Failed to downvote Post #1000'), findsNothing);
    expect(colorOf(tester, Icons.arrow_downward), isNotNull);
  });

  displayTest('a favorite the site refuses says so and stays off', (
    tester,
  ) async {
    await tapOn(
      tester,
      FavoriteButton(post: samplePost(id: 999999)),
      Icons.favorite,
    );

    expect(
      find.text('Failed to add Post #999999 to favorites'),
      findsOneWidget,
    );
    expect(colorOf(tester, Icons.favorite), isNot(Colors.pinkAccent));
  });

  displayTest('an upvote the site refuses says so and stays off', (
    tester,
  ) async {
    await tapOn(
      tester,
      LikeDisplay(post: samplePost(id: 999999)),
      Icons.arrow_upward,
    );

    expect(find.text('Failed to upvote Post #999999'), findsOneWidget);
    expect(colorOf(tester, Icons.arrow_upward), isNull);
  });

  displayTest('a downvote the site refuses says so and stays off', (
    tester,
  ) async {
    await tapOn(
      tester,
      LikeDisplay(post: samplePost(id: 999999)),
      Icons.arrow_downward,
    );

    expect(find.text('Failed to downvote Post #999999'), findsOneWidget);
    expect(colorOf(tester, Icons.arrow_downward), isNull);
  });

  displayTest('a feed tile vote the site refuses says so and stays off', (
    tester,
  ) async {
    await tapOn(
      tester,
      ImageCacheSizeProvider.none(
        child: PostFeedTile(post: samplePost(id: 999999)),
      ),
      Icons.arrow_upward,
    );

    expect(find.text('Failed to upvote Post #999999'), findsOneWidget);
    expect(colorOf(tester, Icons.arrow_upward), isNull);
  });

  test('a vote lands on the score the server answered with', () async {
    // Concurrent votes make the optimistic arithmetic stale: the copy the
    // UI holds says 5, the server's stored copy says 40. The cached post
    // must end on the server's authoritative total, not the optimistic 6.
    final Map<String, Object?> stored = env.fake.state.posts.firstWhere(
      (post) => post['id'] == 1000,
    );
    final Map stats = stored['stats']! as Map;
    (stats['score']! as Map)['total'] = 40;

    env.client.posts.postCache.set(samplePost(id: 1000, score: 5));

    await env.client.posts.useVote(id: 1000).mutate((
      upvote: true,
      replace: true,
    ));

    expect(env.client.posts.postCache.get(1000)!.score, 41);
    expect(env.client.posts.postCache.get(1000)!.vote, 1);
  });

  test('a favorite lands on the count the server answered with', () async {
    final Map<String, Object?> stored = env.fake.state.posts.firstWhere(
      (post) => post['id'] == 1000,
    );
    (stored['stats']! as Map)['fav_count'] = 30;

    env.client.posts.postCache.set(samplePost(id: 1000, favCount: 3));

    await env.client.posts.useAddFavorite().mutate(1000);

    expect(env.client.posts.postCache.get(1000)!.favCount, 31);
    expect(env.client.posts.postCache.get(1000)!.isFavorited, isTrue);
  });

  test('an unfavorite lands on the count the server answered with', () async {
    final Map<String, Object?> stored = env.fake.state.posts.firstWhere(
      (post) => post['id'] == 1000,
    );
    (stored['stats']! as Map)['fav_count'] = 30;

    env.client.posts.postCache.set(
      samplePost(id: 1000, favCount: 3, isFavorited: true),
    );

    await env.client.posts.useRemoveFavorite().mutate(1000);

    expect(env.client.posts.postCache.get(1000)!.favCount, 29);
    expect(env.client.posts.postCache.get(1000)!.isFavorited, isFalse);
  });
}
