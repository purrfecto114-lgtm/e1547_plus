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
}
