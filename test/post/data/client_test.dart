import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/fake_e621.dart';
import '../../_support/fixtures.dart';
import '../../_support/harness.dart';

void main() {
  late FakeE621 fake;
  late PostClient client;
  late Dio dio;

  setUpAll(initializeTestApp);

  setUp(() async {
    fake = await FakeE621.start();
    final identity = Identity(
      id: 1,
      host: fake.url,
      username: 'tester',
      headers: null,
    );
    dio = createDefaultDio(identity);
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

  tearDown(() => fake.stop());

  String served(String url) => url.replaceAll(fixtureHost, fake.url);

  test('maps a recorded post onto the model', () async {
    final recorded = loadFixtureList('posts.json').first;
    final files = recorded['files']! as Map<String, Object?>;
    final original = files['original']! as Map<String, Object?>;
    final meta = files['meta']! as Map<String, Object?>;
    final stats = recorded['stats']! as Map<String, Object?>;

    final post = (await client.page()).first;

    expect(post.id, recorded['id']);
    expect(post.ext, meta['ext']);
    expect(post.width, original['width']);
    expect(post.height, original['height']);
    expect(post.size, meta['size']);
    expect(post.file, served(original['url']! as String));
    expect(post.preview, served((files['preview']! as Map)['jpg'] as String));
    expect(post.uploaderId, recorded['uploader_id']);
    expect(post.favCount, stats['fav_count']);
    expect(post.commentCount, stats['comment_count']);
    expect(post.rating.name, recorded['rating']);
    expect(post.score, (stats['score']! as Map)['total']);
    expect(post.isDeleted, (recorded['flags']! as Map)['deleted']);
  });

  test('groups flat tags by the category lookup', () async {
    final recorded = loadFixtureList('posts.json').first;
    final tags = (recorded['tags']! as List).cast<String>();

    final post = (await client.page()).first;

    expect(post.tags.keys, ['general', 'artist', 'species', 'meta']);
    expect(post.tags.values.expand((e) => e), tags); // same names, same order
  });

  test('classifies tags in bulk through one cached lookup', () async {
    await client.page();

    final before = fake.requests.where((e) => e.path == '/tags.json').length;
    await client.page();
    final after = fake.requests.where((e) => e.path == '/tags.json').length;

    expect(after, before);
  });

  test('chunks the bulk lookup at 100 names', () async {
    fake.state.tags.addAll([
      for (var i = 0; i < 150; i++)
        {
          'id': 10000 + i,
          'name': 'chunk_tag_$i',
          'post_count': 1,
          'related_tags': '',
          'category': 0,
          'is_locked': false,
          'created_at': '2020-03-05T05:49:37.994-05:00',
          'updated_at': '2026-11-01T00:00:00.001-05:00',
        },
    ]);

    final categories = await client.tags.categories([
      for (var i = 0; i < 150; i++) 'chunk_tag_$i',
    ]);

    expect(categories.length, 150);
    final requests = fake.requests.where((e) => e.path == '/tags.json');
    expect(requests.length, 2);
    // The chunks travel on parallel workers, so the order they land in
    // is not part of the contract; only the split itself is.
    expect(requests.map((e) => e.query['limit']).toSet(), {'100', '50'});
  });

  test('remembers unknown names instead of re-asking for them', () async {
    fake.state.tags.clear();

    await client.tags.categories(['no_such_tag']);
    final before = fake.requests.where((e) => e.path == '/tags.json').length;
    await client.tags.categories(['no_such_tag']);
    final after = fake.requests.where((e) => e.path == '/tags.json').length;

    // A name the server does not know stays general — remembering it
    // keeps every later page from re-requesting the same missing tag.
    expect(after, before);
  });

  test('keeps the server grouping when the category lookup fails', () async {
    fake.state.tags.clear();

    final post = (await client.page()).first;

    // The posts request asks for mode=extended, so the server already
    // grouped the tags; a failed lookup must not fail the page or wipe
    // that grouping.
    expect(post.tags.keys, isNotEmpty);
    expect(post.tags.values.expand((tags) => tags), isNotEmpty);
  });

  test('skips the category lookup when the server already grouped', () async {
    final before = fake.requests.where((e) => e.path == '/tags.json').length;
    await client.page();

    // The extended response carries grouped tags: classifying them
    // again is a pure round-trip tax on every page load (four requests
    // and a few hundred ms of cold-start latency). A flat response is
    // the only shape that still pays for the lookup.
    final after = fake.requests.where((e) => e.path == '/tags.json').length;
    expect(after, before);
  });

  test('classifies flat tag lists through the bulk lookup', () async {
    // The recorded basic payload carries its tags as a flat list: the
    // shape the api answers with when a payload skips extended mode.
    final flat = (loadFixtureList('posts.json').first['tags']! as List)
        .cast<String>()
        .toList();
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final data = response.data;
          if (response.requestOptions.path.endsWith('/posts.json') &&
              data is List) {
            response.data = [
              for (final post in data) {...post, 'tags': flat},
            ];
          }
          handler.next(response);
        },
      ),
    );
    fake.state.tags.addAll([
      for (final name in flat)
        {
          'id': 77,
          'name': name,
          'post_count': 1,
          'related_tags': '',
          'category': 1,
          'is_locked': false,
          'created_at': '2020-03-05T05:49:37.994-05:00',
          'updated_at': '2026-11-01T00:00:00.001-05:00',
        },
    ]);

    final posts = await client.page();

    // A flat payload has no grouping of its own: the bulk lookup is
    // what classifies its tags, here as artists.
    expect(posts.first.tags['artist'], isNotEmpty);
    expect(fake.requests.where((e) => e.path == '/tags.json'), isNotEmpty);
  });

  test('folds sample alternates into variants', () async {
    final posts = await client.page();
    final video = posts.firstWhere((e) => e.ext == 'webm');

    expect(video.variants, isNotNull);
    expect(video.variants!.keys, isNotEmpty);
    expect(video.variants!.keys, everyElement(matches(RegExp(r'^\d+x\d+$'))));
  });

  test('parses child relationships', () async {
    final recorded = loadFixtureList('posts.json').firstWhere(
      (e) => ((e['relationships']! as Map)['children']! as List).isNotEmpty,
    );
    final children = (recorded['relationships']! as Map)['children']! as List;

    final posts = await client.page();
    final parent = posts.firstWhere((e) => e.id == recorded['id']);

    expect(parent.relationships.children, children);
    expect(parent.relationships.hasChildren, isTrue);
  });

  test('asks for ids as a tag filter', () async {
    final ids = loadFixtureList(
      'posts.json',
    ).map((e) => e['id']! as int).toList().reversed.toList();

    await client.byIds(ids: ids);

    final posts = fake.requests.where((e) => e.path == '/posts.json');
    expect(posts.last.query['tags'], 'id:${ids.join(',')}');
  });

  test('splits ids into chunks of 320', () async {
    final ids = List.generate(321, (index) => index + 1);

    await client.byIds(ids: ids);

    final posts = fake.requests.where((e) => e.path == '/posts.json').toList();
    expect(posts.length, 2);
    expect(posts.first.query['tags'], 'id:${ids.take(320).join(',')}');
    expect(posts.first.query['limit'], '320');
    expect(posts.last.query['tags'], 'id:${ids.last}');
    expect(posts.last.query['limit'], '1');
  });

  test('restores the requested id order', () async {
    final ids = loadFixtureList(
      'posts.json',
    ).map((e) => e['id']! as int).toList().reversed.toList();

    final posts = await client.byIds(ids: ids);

    expect(posts.map((e) => e.id), ids);
  });

  test('returns undisplayable posts for the display layer to drop', () async {
    // Pagination must advance on the raw response: a page that is fully
    // undisplayable must still be non-empty, or the list would end early.
    // Dropping such posts is a display concern (PostFilter).
    final template = fake.state.posts.first;
    final files = template['files']! as Map<String, Object?>;
    fake.state.posts.add({
      ...template,
      'id': 999,
      'files': {
        ...files,
        'original': {
          ...(files['original']! as Map<String, Object?>),
          'url': null,
        },
      },
    });

    final posts = await client.page();

    final censored = posts.singleWhere((e) => e.id == 999);
    expect(censored.isDisplayable, isFalse);
    expect(posts.map((e) => e.id), contains(999));
  });

  test('serves recorded asset urls from itself', () async {
    final post = (await client.page()).first;

    expect(post.file, startsWith(fake.url));

    final response = await client.dio.get<List<int>>(
      post.file!,
      options: Options(responseType: ResponseType.bytes),
    );

    expect(response.headers.value(HttpHeaders.contentTypeHeader), 'image/png');
    expect(response.data!.take(4), [0x89, 0x50, 0x4e, 0x47]);
  });

  test('favorites are unavailable without credentials', () async {
    await expectLater(
      client.favorites(),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          404,
        ),
      ),
    );
  });

  test('favorites are served to a signed in user', () async {
    final id = loadFixtureList('posts.json').first['id']! as int;
    fake.state.favorites.add(id);
    final dio = createDefaultDio(
      Identity(
        id: 1,
        host: fake.url,
        username: 'tester',
        headers: {
          HttpHeaders.authorizationHeader: const Credentials(
            username: 'tester',
            password: 'key',
          ).basicAuth,
        },
      ),
    );
    final signedIn = PostClient(
      dio: dio,
      pools: client.pools,
      tags: TagClient(dio: dio),
      traits: client.traits,
      identity: client.identity,
    );

    final posts = await signedIn.favorites();

    expect(posts.map((e) => e.id), [id]);
  });

  test('sends a vote the way the server expects', () async {
    final id = loadFixtureList('posts.json').first['id']! as int;

    await client.vote(id: id, upvote: true, replace: true);

    expect(fake.requests.last.path, '/posts/$id/votes.json');
    expect(fake.requests.last.query, {'score': '1', 'no_unvote': 'true'});
  });
}
