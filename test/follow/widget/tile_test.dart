import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

import '../../_support/harness.dart';
import '../../_support/images.dart';

Follow sampleFollow({String? thumbnail, int? latest}) => Follow(
  id: 1,
  tags: 'canine',
  title: null,
  alias: null,
  type: FollowType.bookmark,
  latest: latest,
  unseen: 0,
  thumbnail: thumbnail,
  updated: null,
);

void main() {
  late Client client;
  late ValueNotifier<Traits> traits;
  late AppDatabase sqlite;
  late Settings settings;

  setUpAll(() async {
    await initializeTestApp();
    sqlite = AppDatabase(NativeDatabase.memory());
  });

  tearDownAll(() => sqlite.close());

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    traits = ValueNotifier(
      const Traits(
        id: 1,
        userId: null,
        denylist: [],
        homeTags: '',
        avatar: null,
        perPage: null,
      ),
    );
    client = Client(
      identity: const Identity(
        id: 1,
        host: 'e621.net',
        username: null,
        headers: null,
      ),
      traits: traits,
      storage: AppStorage(
        preferences: await SharedPreferences.getInstance(),
        temporaryFiles: '.',
        queryCache: CachedQuery.asNewInstance(),
        sqlite: sqlite,
      ),
    );
    // The fake clock would otherwise leave dio's timeout timers pending
    // on requests that are still in flight when the test ends.
    client.dio.options.connectTimeout = null;
    client.dio.options.receiveTimeout = null;
    settings = Settings(await SharedPreferences.getInstance());
  });

  tearDown(() => traits.dispose());

  Future<void> show(WidgetTester tester, Follow follow) => tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<Client>.value(value: client),
        Provider<BaseCacheManager>.value(value: const NoImageCacheManager()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 200, child: FollowTile(follow: follow)),
          ),
        ),
      ),
    ),
  );

  group('FollowTile', () {
    displayTest('shows a placeholder icon without a thumbnail', (tester) async {
      await show(tester, sampleFollow(latest: 10));

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    });

    displayTest('shows the thumbnail when it has one', (tester) async {
      await show(tester, sampleFollow(latest: 10, thumbnail: '/preview/10'));

      expect(find.byIcon(Icons.image_not_supported_outlined), findsNothing);
      expect(find.byType(Hero), findsOneWidget);
    });

    displayTest('caps the cover decode on the width alone', (tester) async {
      // Covers are previews of arbitrary aspect: capping both axes
      // would scale every source onto the tile's own ratio, stretching
      // some and squishing others. Only the width is capped, and the
      // cover fit crops what does not fit. Without a tile layout the
      // fallback cap stays at 1080, matching the previous fixed bound.
      await show(tester, sampleFollow(latest: 10, thumbnail: '/preview/10'));

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.memCacheWidth, 1080);
      expect(image.memCacheHeight, isNull);
    });

    displayTest('follows the tile quality tier when laid out', (tester) async {
      // Inside a tile layout the cover decode must track the thumbnail
      // quality tier like the post grid does, not a fixed bound: the low
      // tier caps a 180px tile at min(180 * 1 * 3, 540) = 540 pixels of
      // source width, where the old fixed bound decoded 1080.
      settings.thumbnailQuality.value = ThumbnailQuality.low;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<Client>.value(value: client),
            Provider<BaseCacheManager>.value(
              value: const NoImageCacheManager(),
            ),
            Provider<Settings>.value(value: settings),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TileLayout(
                child: Center(
                  child: SizedBox(
                    width: 200,
                    child: FollowTile(
                      follow: sampleFollow(latest: 10, thumbnail: '/p/10'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      // The test surface reports a device pixel ratio of 3.0, the default
      // tile tier is medium (180px) and the quality tier is low
      // (factor 1, cap 540): 180 * 1 * 3 = 540 fits under the cap.
      expect(image.memCacheWidth, 540);
      expect(image.memCacheHeight, isNull);
    });
  });
}
