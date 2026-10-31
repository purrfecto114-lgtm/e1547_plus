import 'dart:io';

/// Provides information about what features are available on this Platform.
abstract final class PlatformCapabilities {
  /// Whether this platform supports background workers.
  /// This returns false on iOS < 13 because the old API is unsupported.
  static bool get hasBackgroundWorker {
    if (Platform.isIOS) {
      // [Platform.operatingSystemVersion] is a human readable string
      // ("Version 17.5.1 (Build 21F90)") whose layout is not contractual.
      // Probe it defensively: this runs during startup, and a thrown
      // RangeError or FormatException here would keep the app from
      // launching at all.
      final match = RegExp(r'\d+').firstMatch(Platform.operatingSystemVersion);
      // If the version cannot be parsed at all, assume a modern iOS:
      // Flutter itself no longer runs on the versions worth guarding against.
      return match == null || int.parse(match.group(1)!) >= 13;
    }
    return Platform.isAndroid;
  }

  /// Whether this platform supports sending notifications.
  /// Note that this only returns true if the platform also returns true for [hasBackgroundWorker]
  /// because we usually send notifications from background workers.
  static bool get hasNotifications =>
      hasBackgroundWorker && [Platform.isAndroid, Platform.isIOS].any((e) => e);

  /// Whether this platform supports playing videos.
  /// Platform views are not supported on desktop right now.
  static bool get hasVideos => true;

  /// Whether this platform supports secure display.
  /// This means that the platform supports hiding the app from the app switcher.
  static bool get hasSecureDisplay =>
      [Platform.isAndroid, Platform.isIOS].any((e) => e);

  /// Whether this platform supports deep links.
  /// This means that the platform supports opening the app from a URL.
  static bool hasDeepLinks = [Platform.isAndroid, Platform.isIOS].any((e) => e);

  /// Whether this platform is experimental.
  /// Experimental platforms receive builds but no support.
  static bool get isExperimental =>
      [Platform.isWindows, Platform.isLinux].any((e) => e);
}
