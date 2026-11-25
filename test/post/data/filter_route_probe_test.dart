import 'package:cached_query/cached_query.dart';
import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

import '../../_support/harness.dart';
import '../../_support/posts.dart';

/// The route-sharing probe: the drawer's blocked total while the list
/// keeps tracking beneath the pushed detail and fullscreen routes.
/// The three routes share one PostFilter through PostRouteScope.
void main() {
  late AppDatabase sqlite;
  late Client client;
  late PostFilter filter;
  late Traits traits;

  setUpAll(initializeTestApp);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqlite = AppDatabase(NativeDatabase.memory());
    final identity = (await IdentityRepository(
      sqlite,
    ).add(const IdentityRequest(host: 'e621.net', username: 'tester')));
    traits = Traits(
      id: identity.id,
      userId: null,
      denylist: ['artist1'],
      homeTags: '',
      avatar: null,
      perPage: null,
    );
    client = Client(
      identity: Identity(
        id: identity.id,
        host: 'e621.net',
        username: null,
        headers: null,
      ),
      traits: ValueNotifier(traits),
      storage: AppStorage(
        preferences: await SharedPreferences.getInstance(),
        temporaryFiles: '.',
        queryCache: CachedQuery.asNewInstance(),
        sqlite: sqlite,
      ),
    );
    filter = PostFilter(client);
  });

  tearDown(() async {
    filter.dispose();
    await sqlite.close();
  });

  Post post(int id, {bool denied = false}) => samplePost(
    id: id,
    file: 'https://example.org/$id.jpg',
    tags: {
      'artist': [if (denied) 'artist1'],
      'general': ['general_$id'],
    },
  );

  test('drawer total stays flat across route pushes', () async {
    // The list page: 30 posts, one of them denied (id 2).
    final listPosts = [for (var i = 1; i <= 30; i++) post(i, denied: i == 2)];
    // The pages as the query hands them over (two pages of 15).
    filter.track('list', [
      ...listPosts.sublist(0, 15),
      ...listPosts.sublist(15),
    ]);
    // ignore: avoid_print
    print('list: ${filter.blockedCount}');
    expect(filter.blockedCount, 1);

    // The detail route tracks a single-post query for id 2 (the denied
    // one), through a DIFFERENT instance of the same post, as the
    // detail cache would serve it.
    final detailPost = post(2, denied: true);
    filter.track('detail', [detailPost]);
    // ignore: avoid_print
    print('detail: ${filter.blockedCount}');
    expect(filter.blockedCount, 1);

    // The fullscreen route tracks its own single-post query, again a
    // fresh instance of the same id.
    final fullscreenPost = post(2, denied: true);
    filter.track('fullscreen', [fullscreenPost]);
    // ignore: avoid_print
    print('fullscreen: ${filter.blockedCount}');
    expect(filter.blockedCount, 1);

    // Popping back: the fullscreen key untracks.
    filter.untrack('fullscreen');
    expect(filter.blockedCount, 1);
    filter.untrack('detail');
    expect(filter.blockedCount, 1);

    // A second visit pushes the detail again.
    filter.track('detail2', [post(2, denied: true)]);
    expect(filter.blockedCount, 1);
  });

  test('the per-rule counts agree with the total', () async {
    final listPosts = [
      for (var i = 1; i <= 30; i++) post(i, denied: i == 2 || i == 7),
    ];
    filter.track('list', listPosts);
    expect(filter.blockedCount, 2);
    expect(filter.blockedCountsByEntry, {'artist1': 2});

    filter.track('detail', [post(2, denied: true)]);
    expect(filter.blockedCount, 2);
    expect(filter.blockedCountsByEntry, {'artist1': 2});
  });

  test('an allowed post lifts the block across routes', () async {
    final listPosts = [for (var i = 1; i <= 30; i++) post(i, denied: i == 2)];
    filter.track('list', listPosts);
    expect(filter.blockedCount, 1);

    // The user allows the post from the detail page: the allow lands
    // on the shared filter, and both keys re-run the filter through
    // their next track.
    filter.allow(2);
    // The list re-tracks (a new flat list instance per rebuild, as
    // QueryFilter builds one per pass) with the same posts.
    filter.track('list', [
      for (var i = 1; i <= 30; i++) post(i, denied: i == 2),
    ]);
    expect(filter.blockedCount, 0);
    filter.track('detail', [post(2, denied: true)]);
    expect(filter.blockedCount, 0);
  });
}
