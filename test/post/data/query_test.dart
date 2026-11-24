import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/fake_e621.dart';
import '../../_support/harness.dart';

void main() {
  late FakeE621 fake;
  late PostClient client;
  late CachedQuery cache;

  setUpAll(initializeTestApp);

  setUp(() async {
    fake = await FakeE621.start(state: FakeE621State.seeded(posts: 200));
    // Cursor pagination relies on the server serving the newest posts first,
    // so model that by sorting the fake's posts by descending id.
    fake.state.posts.sort(
      (a, b) => (b['id']! as int).compareTo(a['id']! as int),
    );
    cache = CachedQuery.asNewInstance();
    final identity = Identity(
      id: 1,
      host: fake.url,
      username: 'tester',
      headers: {
        'authorization': const Credentials(
          username: 'tester',
          password: 'key',
        ).basicAuth,
      },
    );
    final dio = createDefaultDio(identity, queryCache: cache);
    client = PostClient(
      dio: dio,
      pools: PoolClient(dio: dio),
      tags: TagClient(dio: dio),
      traits: ValueNotifier(
        const Traits(
          id: 1,
          userId: null,
          denylist: [],
          homeTags: '',
          avatar: null,
          perPage: null,
        ),
      ),
      identity: identity,
    );
  });

  tearDown(() async {
    await fake.stop();
    await cache.dispose();
  });

  /// The post ids the fake serves, in the order it serves them.
  List<int> servedIds() =>
      fake.state.posts.map((e) => e['id']! as int).toList();

  /// The list requests of one path the fake served, in order: post list
  /// fetches now end with a tag category lookup, which these assertions
  /// must not mistake for the list itself.
  List<FakeRequest> listRequests(String path) => [
    for (final request in fake.requests)
      if (request.path == path) request,
  ];

  group('order dispatch', () {
    test('id orders paginate by cursor', () {
      for (final tags in [null, 'order:new', 'order:id', 'order:id_desc']) {
        expect(
          servesNewestFirst(PostParams(tags: tags).toQuery()),
          isTrue,
          reason: 'tags: $tags',
        );
      }
    });

    test('other orders paginate by page number', () {
      for (final tags in [
        'order:score',
        'order:favcount',
        'order:rank',
        'order:random',
        'order:id_asc',
        'order:custom',
      ]) {
        expect(
          servesNewestFirst(PostParams(tags: tags).toQuery()),
          isFalse,
          reason: 'tags: $tags',
        );
      }
    });
  });

  group('page number arguments', () {
    test('start at page 1', () {
      InfiniteQueryData<List<int>, Object>? state;
      expect(state.nextPageArg(), 1);
      expect(state.nextCursorPage(), 1);
    });

    test('an empty last page ends the search', () {
      final state = InfiniteQueryData<List<int>, Object>(
        pages: const [[]],
        args: const [5],
      );
      expect(state.nextPageArg(), isNull);
      expect(state.nextCursorPage(), isNull);
    });

    test('a page cap ends the search', () {
      expect(
        InfiniteQueryData<List<int>, Object>(
          pages: const [
            [1],
          ],
          args: const [maxSitePage],
        ).nextPageArg(maxPage: maxSitePage),
        isNull,
      );
      expect(
        InfiniteQueryData<List<int>, Object>(
          pages: const [
            [1],
          ],
          args: const [maxSitePage - 1],
        ).nextPageArg(maxPage: maxSitePage),
        maxSitePage,
      );
    });

    test('a cursor argument cannot continue a page sequence', () {
      expect(
        InfiniteQueryData<List<int>, Object>(
          pages: const [
            [1],
          ],
          args: const ['b123'],
        ).nextPageArg(),
        isNull,
      );
    });
  });

  group('cursor arguments', () {
    test('continue before the lowest id of the last page', () {
      expect(
        InfiniteQueryData<List<int>, Object>(
          pages: const [
            [5, 3],
            [2, 9],
          ],
          args: const [1, 'b5'],
        ).nextCursorPage(),
        'b2',
      );
    });
  });

  test('stored page args restore with and without cursors', () {
    final restored = pagedObjectIdsFromJson({
      'pages': [
        [1, 2],
        [3],
      ],
      'args': [1, 'b123'],
    });
    expect(restored.pages, [
      [1, 2],
      [3],
    ]);
    expect(restored.args, [1, 'b123']);

    final legacy = pagedObjectIdsFromJson({
      'pages': [
        [1, 2],
        [3],
      ],
      'args': [1, 2],
    });
    expect(legacy.pages, [
      [1, 2],
      [3],
    ]);
    expect(legacy.args, [1, 2]);
  });

  test(
    'cursor searches request the first page, then the posts before it',
    () async {
      final query = client.usePage(query: const PostParams().toQuery());
      await query.fetch();

      expect(query.state.data!.pages.single, servedIds().take(75));
      expect(listRequests('/posts.json').last.query['page'], '1');
      expect(query.hasNextPage(), isTrue);

      await query.getNextPage();
      expect(
        listRequests('/posts.json').last.query['page'],
        'b${servedIds().take(75).reduce(min)}',
      );
      expect(query.state.data!.pages.last, servedIds().skip(75).take(75));
    },
  );

  test('an empty page ends a cursor search', () async {
    final query = client.usePage(query: const PostParams().toQuery());
    await query.fetch();
    await query.getNextPage();
    await query.getNextPage();
    expect(query.state.data!.pages.last, hasLength(50));
    await query.getNextPage();
    expect(query.state.data!.pages.last, isEmpty);
    expect(query.hasNextPage(), isFalse);
    expect(query.state.data!.pages.expand((page) => page), servedIds());
  });

  test('jumping to a page refetches only that page', () async {
    final query = client.usePage(
      query: const PostParams(tags: 'order:score').toQuery(),
    );
    final sub = query.stream.listen((_) {});
    addTearDown(sub.cancel);

    await query.fetch();
    await query.getNextPage();
    expect(query.state.data!.pages, hasLength(2));
    final requestsBefore = fake.requests.length;

    query.setData(
      InfiniteQueryData<List<int>, Object>(pages: const [], args: const [3]),
    );
    await query.invalidate();

    expect(fake.requests.length, requestsBefore + 1);
    expect(fake.requests.last.query['page'], '3');
    expect(query.state.data!.args, [3]);
    expect(query.state.data!.pages, [servedIds().skip(150)]);
    expect(query.hasNextPage(), isTrue);
  });

  test('favorites paginate by page numbers', () async {
    fake.state.favorites.addAll(servedIds().take(100));
    final query = client.useFavorites();
    await query.fetch();
    expect(listRequests('/favorites.json').last.path, '/favorites.json');
    expect(listRequests('/favorites.json').last.query['page'], '1');

    await query.getNextPage();
    expect(listRequests('/favorites.json').last.query['page'], '2');
    expect(query.state.data!.pages.last, servedIds().skip(75).take(25));
  });

  test('tag searches paginate by page numbers', () async {
    final query = client.useByTags(tags: ['tag_1', 'tag_2']);
    await query.fetch();
    expect(listRequests('/posts.json').last.query['page'], '1');
    // A tag page spans a whole chunk round, so it asks for the full page
    // limit rather than the site default of 75.
    expect(listRequests('/posts.json').last.query['limit'], '320');
    expect(query.state.data!.pages.single, servedIds().take(200));

    await query.getNextPage();
    expect(listRequests('/posts.json').last.query['page'], '2');
    // The fake holds 200 posts; the second page is past all of them.
    expect(query.state.data!.pages.last, isEmpty);
  });

  test('tag chunk pages merge into one newest-first list', () async {
    // With more than 40 tags the client splits the search into tag
    // chunks; the timeline must not show chunk-local orderings glued
    // together, but one list sorted by id.
    final tags = [for (int i = 0; i < 45; i++) 'tag_$i'];
    final query = client.useByTags(tags: tags);
    await query.fetch();

    final ids = query.state.data!.pages.expand((p) => p).toList();
    final sorted = [...ids]..sort((a, b) => b.compareTo(a));
    expect(ids, sorted, reason: 'timeline pages must be newest first');
    // 45 tags split into two chunks of 23 and 22; both request page 1
    // with the full limit, and the fake holds 200 posts, so the merged
    // first page carries every distinct id once.
    expect(ids, hasLength(200));
  });

  test('pool searches paginate through the pool locally', () async {
    fake.state.pools.first['post_ids'] = servedIds();
    final query = client.useByPool(id: 1252);
    await query.fetch();
    expect(query.state.data!.pages.single, servedIds().take(75));

    await query.getNextPage();
    expect(query.state.data!.pages.last, servedIds().skip(75).take(75));
    expect(query.hasNextPage(), isTrue);
  });

  group('undisplayable pages', () {
    /// Makes every post with an id in [ids] undisplayable: flash posts the
    /// app cannot render, or censored posts without a file.
    void makeUndisplayable(Iterable<int> ids, {required bool flash}) {
      final wanted = ids.toSet();
      for (final post in fake.state.posts) {
        if (!wanted.contains(post['id'])) continue;
        final files = {...(post['files']! as Map)};
        final original = {...(files['original']! as Map)};
        if (flash) {
          final meta = {...(files['meta']! as Map)};
          meta['ext'] = 'swf';
          files['meta'] = meta;
        } else {
          original['url'] = null;
        }
        files['original'] = original;
        post['files'] = files;
      }
    }

    test('a cursor search continues past a fully undisplayable page', () async {
      // The first page holds only flash posts; the second is normal.
      makeUndisplayable(servedIds().take(75), flash: true);
      final query = client.usePage(query: const PostParams().toQuery());
      await query.fetch();

      // The page keeps its raw items: pagination advances on the raw
      // response, so the list must not end on an undisplayable page.
      expect(query.state.data!.pages.single, servedIds().take(75));
      expect(query.hasNextPage(), isTrue);

      await query.getNextPage();
      expect(
        fake.requests.last.query['page'],
        'b${servedIds().take(75).reduce(min)}',
      );
      expect(query.state.data!.pages.last, servedIds().skip(75).take(75));
    });

    test(
      'a page-number search continues past a fully undisplayable page',
      () async {
        makeUndisplayable(servedIds().take(75), flash: false);
        final query = client.usePage(
          query: const PostParams(tags: 'order:score').toQuery(),
        );
        await query.fetch();

        expect(query.state.data!.pages.single, servedIds().take(75));
        expect(query.hasNextPage(), isTrue);

        await query.getNextPage();
        expect(fake.requests.last.query['page'], '2');
        expect(query.state.data!.pages.last, servedIds().skip(75).take(75));
      },
    );

    test('a pool continues past a fully undisplayable slice', () async {
      fake.state.pools.first['post_ids'] = servedIds();
      makeUndisplayable(servedIds().take(75), flash: true);
      final query = client.useByPool(id: 1252);
      await query.fetch();

      expect(query.state.data!.pages.single, servedIds().take(75));
      expect(query.hasNextPage(), isTrue);

      await query.getNextPage();
      expect(query.state.data!.pages.last, servedIds().skip(75).take(75));
    });
  });
}
