import 'dart:ffi';

import 'package:e1547/app/app.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:notified_preferences/notified_preferences.dart';

class Settings extends NotifiedSettings {
  Settings(super.preferences);

  static Future<Settings> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    await migratePreferences(prefs);
    return Settings(prefs);
  }

  /// Runs the stored preference migrations over [prefs].
  ///
  /// Production code wires this into [initializeAppStorage], where the
  /// shared preferences singleton is created; the app assembles settings
  /// through the bare constructor, which skips everything below, so an
  /// un-migrated store would fall back to defaults or, worse, collide
  /// old and new enum names.
  static Future<void> migratePreferences(SharedPreferences prefs) async {
    await _migrateLegacyDefaults(prefs);
    await _migrateQualityTiers(prefs);
  }

  /// Resets settings that were persisted with outdated defaults.
  ///
  /// Older versions defaulted `muteVideos` to false and wrote that default
  /// into storage for every user who never touched the setting, so those
  /// installs kept playing video sound after the default flipped. The
  /// stale value is cleared once; a sound preference chosen afterwards
  /// survives, guarded by the marker key.
  static Future<void> _migrateLegacyDefaults(SharedPreferences prefs) async {
    const marker = 'legacyDefaultsMigrated';
    if (prefs.getBool(marker) ?? false) return;
    if (prefs.getBool('muteVideos') == false) {
      await prefs.remove('muteVideos');
    }
    await prefs.setBool(marker, true);
  }

  /// Rewrites the quality settings into their tiered successors.
  ///
  /// The video resolution five-step enum collapsed into three tiers and
  /// the tile size slider snapped to the same three, so values stored
  /// under the old schemes are mapped onto their nearest tier once,
  /// guarded by the marker key. Fresh installs store nothing under
  /// these keys and pass through untouched.
  static Future<void> _migrateQualityTiers(SharedPreferences prefs) async {
    const marker = 'qualityTiersMigrated';
    if (prefs.getBool(marker) ?? false) return;

    const legacyVideoResolutions = {
      'standard': 'low',
      'high': 'medium',
      'full': 'high',
      'ultra': 'high',
      'source': 'high',
    };
    final resolution = prefs.getString('videoResolution');
    if (resolution != null && legacyVideoResolutions.containsKey(resolution)) {
      await prefs.setString(
        'videoResolution',
        legacyVideoResolutions[resolution]!,
      );
    }

    final tileSize = prefs.getInt('tileSize');
    if (tileSize != null) {
      final String tier;
      if (tileSize <= 175) {
        tier = 'small';
      } else if (tileSize <= 250) {
        tier = 'medium';
      } else {
        tier = 'large';
      }
      // The key changes type from a free pixel count to a tier name;
      // removing it first keeps stores that key by type consistent.
      await prefs.remove('tileSize');
      await prefs.setString('tileSize', tier);
    }

    await prefs.setBool(marker, true);
  }

  late final ValueNotifier<int> identity = createSetting(
    key: 'identity',
    initialValue: 1,
  );

  late final ValueNotifier<bool> onboardingSeen = createSetting<bool>(
    key: 'onboardingSeen',
    initialValue: false,
  );

  late final ValueNotifier<AppTheme> theme = createEnumSetting(
    key: 'theme',
    initialValue: AppTheme.values.first,
    values: AppTheme.values,
  );
  late final ValueNotifier<Handedness> handedness = createEnumSetting(
    key: 'handedness',
    initialValue: Handedness.right,
    values: Handedness.values,
  );

  /// The app language, stored as a locale string.
  ///
  /// A null value follows the system language.
  late final ValueNotifier<String?> language = createSetting<String?>(
    key: 'language',
    initialValue: null,
  );

  late final ValueNotifier<TileSize> tileSize = createEnumSetting(
    key: 'tileSize',
    initialValue: TileSize.medium,
    values: TileSize.values,
  );
  late final ValueNotifier<GridQuilt> quilt = createEnumSetting(
    key: 'quilt',
    initialValue: GridQuilt.square,
    values: GridQuilt.values,
  );

  late final ValueNotifier<bool> filterUnseenFollows = createSetting(
    key: 'filterUnseenFollows',
    initialValue: false,
  );
  late final ValueNotifier<bool> showPostInfo = createSetting<bool>(
    key: 'showPostInfo',
    initialValue: false,
  );
  late final ValueNotifier<bool> upvoteFavs = createSetting<bool>(
    key: 'upvoteFavs',
    initialValue: false,
  );
  late final ValueNotifier<String?> downloadPath = createSetting<String?>(
    key: 'downloadPath',
    initialValue: null,
  );

  /// Whether videos start muted.
  ///
  /// Sound is opt-in: scrolling a public space should not blare audio,
  /// so every fresh install defaults to muted and users unmute per
  /// taste via the video overlay or this setting.
  late final ValueNotifier<bool> muteVideos = createSetting<bool>(
    key: 'muteVideos',
    initialValue: true,
  );
  late final ValueNotifier<VideoResolution> videoResolution = createEnumSetting(
    key: 'videoResolution',
    initialValue: _defaultVideoResolution(),
    values: VideoResolution.values,
  );

  /// Whether browsing silently downloads videos.
  ///
  /// When disabled, videos are only fetched once their play button is
  /// pressed, so scrolling a timeline stays data-free. Defaults to off.
  late final ValueNotifier<bool> autoLoadVideos = createSetting<bool>(
    key: 'autoLoadVideos',
    initialValue: false,
  );

  late final ValueNotifier<bool> secureDisplay = createSetting<bool>(
    key: 'secureDisplay',
    initialValue: false,
  );
  late final ValueNotifier<bool> incognitoKeyboard = createSetting<bool>(
    key: 'incognitoKeyboard',
    initialValue: false,
  );
  late final ValueNotifier<String?> appPin = createSetting(
    key: 'appPin',
    initialValue: null,
  );

  /// Failed pin unlock attempts since the last success.
  ///
  /// Security bookkeeping for the lockout backoff: the counter persists,
  /// so restarting the app does not reset the price of guessing. The
  /// hash itself lives in [appPin]; these two keys hold no secret.
  late final ValueNotifier<int> appPinFailures = createSetting<int>(
    key: 'appPinFailures',
    initialValue: 0,
  );

  /// Epoch milliseconds until which pin entry stays locked out.
  late final ValueNotifier<int> appPinLockedUntil = createSetting<int>(
    key: 'appPinLockedUntil',
    initialValue: 0,
  );
  late final ValueNotifier<bool> biometricAuth = createSetting<bool>(
    key: 'biometricAuth',
    initialValue: false,
  );

  /// Whether the updater offers the latest releases, including pre-releases.
  ///
  /// Debug builds skip update checks entirely unless this is enabled, so the
  /// updater stays testable during development.
  late final ValueNotifier<bool> updaterBeta = createSetting<bool>(
    key: 'updaterBeta',
    initialValue: false,
  );

  late final ValueNotifier<bool> verboseLogs = createSetting<bool>(
    key: 'verboseLogs',
    initialValue: false,
  );

  late final ValueNotifier<bool> showDev = createSetting<bool>(
    key: 'showDev',
    initialValue: false,
  );
}

// Decoding high tier videos can push low end Android devices, especially
// 32 bit ones, over their memory limits. iOS kills equally greedy apps
// through Jetsam, so its 64 bit devices get the same tier as Android's.
// Such devices default to the low tier; users can still raise it in the
// settings. Intel iOS simulators (iosX64) are a development-only
// scenario on desktop-class hardware and keep the high tier.
VideoResolution _defaultVideoResolution() {
  switch (Abi.current()) {
    case Abi.androidArm:
    case Abi.androidIA32:
      return VideoResolution.low;
    case Abi.androidArm64:
    case Abi.androidX64:
    case Abi.androidRiscv64:
    case Abi.iosArm64:
      return VideoResolution.medium;
    default:
      return VideoResolution.high;
  }
}
