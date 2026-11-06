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
    await _migrateLegacyDefaults(prefs);
    return Settings(prefs);
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

  late final ValueNotifier<int> tileSize = createSetting(
    key: 'tileSize',
    initialValue: 200,
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

// Decoding source quality videos can push low end Android devices,
// especially 32 bit ones, over their memory limits. iOS kills equally
// greedy apps through Jetsam, so its 64 bit devices get the same tier as
// Android's. Such devices get a lower default; users can still raise it in
// the settings. Intel iOS simulators (iosX64) are a development-only
// scenario on desktop-class hardware and keep the source default.
VideoResolution _defaultVideoResolution() {
  switch (Abi.current()) {
    case Abi.androidArm:
    case Abi.androidIA32:
      return VideoResolution.standard;
    case Abi.androidArm64:
    case Abi.androidX64:
    case Abi.androidRiscv64:
    case Abi.iosArm64:
      return VideoResolution.high;
    default:
      return VideoResolution.source;
  }
}
