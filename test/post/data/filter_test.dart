import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

import '../../_support/fake_e621.dart';
import '../../_support/harness.dart';
import '../../_support/posts.dart';

void main() {
  late FakeE621 fake;
  late Client client;
  late ValueNotifier<Traits> traits;
  late AppDatabase sqlite;
  late PostFilter filter;

  final Post post = samplePost(
    id: 7,
    tags: const {
      'general': ['bad_tag'],
    },
  );

  setUpAll(() async {
    await initializeTestApp();
    sqlite = AppDatabase(NativeDatabase.memory());
  });

  tearDownAll(() => sqlite.close());

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fake = await FakeE621.start();
    traits = ValueNotifier(
      const Traits(
        id: 1,
        userId: null,
        denylist: ['bad_tag'],
        homeTags: '',
        avatar: null,
        perPage: null,
      ),
    );
    client = Client(
      identity: Identity(id: 1, host: fake.url, username: null, headers: null),
      traits: traits,
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
    traits.dispose();
    await fake.stop();
  });

  test('a post with a denied entry is blocked and denied', () {
    expect(filter.blocks(post), true);
    expect(filter.denies(post), true);
  });

  test('nothing is blocked while denying is off', () {
    filter.denying = false;

    expect(filter.blocks(post), false);
    expect(filter.denies(post), false);
  });

  test('an allowed entry lifts the block', () {
    filter.enable('bad_tag');

    expect(filter.blocks(post), false);
    expect(filter.denies(post), false);
  });

  test('an allowed post stays blocked without being denied', () {
    filter.allow(post.id);

    expect(filter.blocks(post), true);
    expect(filter.denies(post), false);
  });

  group('undisplayable posts', () {
    test('flash posts are filtered from display', () {
      final flash = samplePost(id: 8, ext: 'swf', file: '/file/8.swf');
      expect(flash.isDisplayable, isFalse);
      expect(filter.filter(flash), isFalse);
    });

    test('censored posts without a file are filtered from display', () {
      final censored = samplePost(id: 9);
      expect(censored.isDisplayable, isFalse);
      expect(filter.filter(censored), isFalse);
    });

    test('deleted posts without a file stay displayable', () {
      final deleted = samplePost(id: 10, isDeleted: true);
      expect(deleted.isDisplayable, isTrue);
      expect(filter.filter(deleted), isTrue);
    });

    test('undisplayable posts do not inflate the blocked count', () {
      final flash = samplePost(id: 8, ext: 'swf', file: '/file/8.swf');
      final denied = samplePost(
        id: 11,
        file: '/file/11.jpg',
        tags: const {
          'general': ['bad_tag'],
        },
      );
      final clean = samplePost(id: 12, file: '/file/12.jpg');
      filter.track('key', [flash, denied, clean]);

      // Only the denylist block counts; the flash post is not one.
      expect(filter.blockedCount, 1);
    });

    test('favorite filters still drop undisplayable favorites', () {
      final favoriteFilter = FavoritePostFilter(client);
      addTearDown(favoriteFilter.dispose);

      final flashFavorite = samplePost(
        id: 12,
        ext: 'swf',
        file: '/file/12.swf',
        isFavorited: true,
      );
      expect(favoriteFilter.filter(flashFavorite), isFalse);

      final normalFavorite = samplePost(
        id: 13,
        file: '/file/13.jpg',
        isFavorited: true,
      );
      expect(favoriteFilter.filter(normalFavorite), isTrue);
    });
  });
}
