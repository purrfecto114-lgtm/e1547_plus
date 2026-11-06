import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install starts muted and on stable updates', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = await Settings.getInstance();

    expect(settings.muteVideos.value, isTrue);
    expect(settings.updaterBeta.value, isFalse);
  });

  test('a stale unmuted leftover resets to the muted default', () async {
    // Installs from before the mute default flipped carry the old default
    // in storage; the migration clears it so videos start muted again.
    SharedPreferences.setMockInitialValues({'muteVideos': false});
    final settings = await Settings.getInstance();

    expect(settings.muteVideos.value, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('legacyDefaultsMigrated'), isTrue);
    expect(prefs.getBool('muteVideos'), isNull);
  });

  test(
    'a deliberately chosen sound preference survives the migration',
    () async {
      SharedPreferences.setMockInitialValues({
        'muteVideos': false,
        'legacyDefaultsMigrated': true,
      });
      final settings = await Settings.getInstance();

      expect(settings.muteVideos.value, isFalse);
    },
  );

  test('the migration runs only once', () async {
    SharedPreferences.setMockInitialValues({'muteVideos': false});
    await Settings.getInstance();

    // A later unmute is the user's choice and must not be reset again.
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('muteVideos', false);
    await Settings.getInstance();

    expect(prefs.getBool('muteVideos'), isFalse);
  });

  group('quality tier migration', () {
    test('the old standard step maps onto the low tier', () async {
      SharedPreferences.setMockInitialValues({'videoResolution': 'standard'});
      expect(
        (await Settings.getInstance()).videoResolution.value,
        VideoResolution.low,
      );
    });

    test(
      "the old high step maps onto the medium tier, not the new high",
      () async {
        // The old "high" meant 720p; without the mapping its name would
        // collide with the new source-quality tier.
        SharedPreferences.setMockInitialValues({'videoResolution': 'high'});
        expect(
          (await Settings.getInstance()).videoResolution.value,
          VideoResolution.medium,
        );
      },
    );

    for (final legacy in ['full', 'ultra', 'source']) {
      test('the old $legacy step maps onto the high tier', () async {
        SharedPreferences.setMockInitialValues({'videoResolution': legacy});
        expect(
          (await Settings.getInstance()).videoResolution.value,
          VideoResolution.high,
        );
      });
    }

    // The tier boundaries are the midpoints between the tier pixels.
    for (final (pixels, tier) in [
      (100, TileSize.small),
      (175, TileSize.small),
      (176, TileSize.medium),
      (200, TileSize.medium),
      (250, TileSize.medium),
      (251, TileSize.large),
      (400, TileSize.large),
    ]) {
      test('an old tile size of $pixels snaps onto ${tier.name}', () async {
        SharedPreferences.setMockInitialValues({'tileSize': pixels});
        expect((await Settings.getInstance()).tileSize.value, tier);
      });
    }

    test(
      'the tier migration runs once and leaves fresh installs alone',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        await Settings.getInstance();

        expect(prefs.getBool('qualityTiersMigrated'), isTrue);
        expect(prefs.getString('tileSize'), isNull);
        expect(prefs.getString('videoResolution'), isNull);
      },
    );
  });
}
