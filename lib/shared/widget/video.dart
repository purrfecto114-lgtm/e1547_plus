import 'dart:async';
import 'dart:io';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:rxdart/rxdart.dart';

export 'package:media_kit_video/media_kit_video.dart';

class VideoPlayer extends Player {
  VideoPlayer({super.platformPlayer}) {
    _subscriptions.addAll([
      stream.videoParams.listen((event) {
        _hasParams = event.w != null && event.h != null;
        _update();
      }),
      stream.error.listen((_) {
        _failed = true;
        _update();
      }),
    ]);
    unawaited(
      controller.waitUntilFirstFrameRendered
          .then((_) {
            _rendered = true;
            _update();
          })
          .catchError((_) {}),
    );
  }

  late final VideoController _controller = VideoController(this);
  VideoController get controller => _controller;

  final List<StreamSubscription> _subscriptions = [];

  final BehaviorSubject<bool> _initialized = BehaviorSubject.seeded(false);
  Stream<bool> get initialized => _initialized.stream;

  bool get isInitialized => _initialized.value;

  bool _rendered = false;
  bool _hasParams = false;
  bool _failed = false;

  String? _media;
  String? get media => _media;

  /// The media url this player is deferred to, if any.
  ///
  /// A deferred player holds its slot in the video pool but downloads
  /// nothing; the media is loaded once [play] is called.
  String? defer;

  bool get isDeferred => defer != null;

  int _leases = 0;

  bool get isLeased => _leases > 0;

  void _update() {
    if (_initialized.isClosed) return;
    bool value = _failed || (_rendered && _hasParams);
    if (_initialized.value == value) return;
    _initialized.add(value);
  }

  Map<String, String>? _headers;

  /// Opens [media], optionally starting at [position] and resuming playback.
  Future<void> load(
    String media, {
    Duration? position,
    bool play = false,
    Map<String, String>? headers,
  }) async {
    _media = media;
    defer = null;
    _failed = false;
    _hasParams = false;
    _update();
    // The headers of the last load are reused when a deferred player is
    // started through [play], which has no headers of its own.
    _headers = headers ?? _headers;
    await open(
      Media(media, start: position, httpHeaders: _headers),
      play: play,
    );
  }

  @override
  Future<void> play() async {
    if (defer case String media) {
      await load(media, play: true, headers: _headers);
      return;
    }
    await super.play();
  }

  Future<void> unload() async {
    _media = null;
    defer = null;
    _failed = false;
    _hasParams = false;
    _update();
    await stop();
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _initialized.close();
    await super.dispose();
  }
}

class VideoService extends ChangeNotifier {
  VideoService({
    bool muteVideos = false,
    VideoPlayer Function()? createPlayer,
    ValueListenable<bool>? muteSetting,
    Map<String, String> Function()? headers,
    int? maxLoaded,
  }) : _muteVideos = muteVideos,
       _createPlayer = createPlayer ?? VideoPlayer.new,
       _muteSetting = muteSetting,
       _headers = headers,
       maxLoaded = maxLoaded ?? _defaultMaxLoaded {
    _muteSetting?.addListener(_onMuteSettingChanged);
  }

  static void ensureInitialized() => MediaKit.ensureInitialized();

  // To prevent the app from crashing due to OutOfMemoryErrors,
  // the list of all loaded videos is global.
  static final Map<String, VideoPlayer> _videos = {};

  // Disposing a Player closes the mpv wakeup callback,
  // which mpv can still invoke afterwards, aborting the process.
  static final List<VideoPlayer> _idle = [];

  final Logger _logger = Logger('Videos');

  /// The number of players the pool holds at most.
  ///
  /// Every player owns a full mpv instance, which low-memory devices
  /// cannot spare many of; the default scales with the device memory,
  /// see [_defaultMaxLoaded].
  final int maxLoaded;

  /// Derives the pool size from the device's total memory.
  ///
  /// Android exposes it via /proc/meminfo. Other platforms see little
  /// memory variance across devices and always use the full pool.
  static int get _defaultMaxLoaded {
    if (!Platform.isAndroid) return 3;
    try {
      final match = RegExp(
        r'MemTotal:\s+(\d+)\s+kB',
      ).firstMatch(File('/proc/meminfo').readAsStringSync());
      final int? totalKb = match == null ? null : int.parse(match.group(1)!);
      if (totalKb == null) return 3;
      if (totalKb < 2 * 1024 * 1024) return 1; // below 2 GiB
      if (totalKb < 4 * 1024 * 1024) return 2; // below 4 GiB
      return 3;
    } on Object {
      return 3;
    }
  }

  final VideoPlayer Function() _createPlayer;

  final ValueListenable<bool>? _muteSetting;

  /// Resolves the headers video requests are sent with, e.g. the app's
  /// user agent. Evaluated per load, so identity switches apply.
  final Map<String, String> Function()? _headers;

  bool _muteVideos;

  void _onMuteSettingChanged() {
    if (_muteSetting case ValueListenable<bool> setting) {
      if (setting.value != _muteVideos) muteVideos = setting.value;
    }
  }

  bool get muteVideos => _muteVideos;

  set muteVideos(bool value) {
    _muteVideos = value;
    _videos.values.forEach((e) => e.setVolume(muteVideos ? 0 : 100));
    notifyListeners();
    _logger.debug('Videos muted: {muted}', {'muted': _muteVideos});
  }

  VideoPlayer? getVideo(
    String key, {
    bool autoLoad = true,
    Duration? seekTo,
    bool resume = false,
  }) {
    final Map<String, String>? requestHeaders = _headers?.call();
    // Re-inserting moves the key to the back of the map,
    // so that eviction walks from least to most recently used.
    VideoPlayer? player = _videos.remove(key);
    if (player != null) {
      // A deferred player is loaded once auto-loading is enabled, e.g.
      // when the user turns the setting on and returns to a route.
      if (autoLoad && player.isDeferred) {
        unawaited(
          player.load(
            key,
            position: seekTo,
            play: resume,
            headers: requestHeaders,
          ),
        );
        _logger.debug('Backfilled {video}', {'video': key});
      } else if (player.media != null && (seekTo != null || resume)) {
        // Returning to an already loaded video, e.g. when switching video
        // quality back, restores the requested position and playback state.
        // VideoService notifies on every lease release, which re-runs route
        // dependencies with the player's own position; those pass through
        // without seeking or replaying here.
        if (seekTo case Duration position) {
          if (position != player.state.position) {
            unawaited(player.seek(position));
          }
        }
        if (resume && !player.state.playing) {
          unawaited(player.play());
        }
      }
      return _videos[key] = player;
    }
    while (_videos.length >= maxLoaded) {
      String? spare;
      for (final MapEntry(:key, :value) in _videos.entries) {
        if (value.isLeased) continue;
        spare = key;
        break;
      }
      if (spare == null) break;
      _logger.debug('Evicting {spare}, {loaded} of {max} videos loaded', {
        'spare': spare,
        'loaded': _videos.length,
        'max': maxLoaded,
      });
      unloadVideo(spare);
    }
    if (_videos.length >= maxLoaded && _idle.isEmpty) {
      // Every player is leased and none can be evicted. Creating
      // another one would grow the pool past maxLoaded forever,
      // since players are never disposed (see above). Return no
      // player instead; callers show a placeholder and retry once
      // VideoService notifies them of a released lease.
      _logger.debug('Refusing {video}, all {max} videos in use', {
        'video': key,
        'max': maxLoaded,
      });
      return null;
    }
    player = _idle.isNotEmpty ? _idle.removeAt(0) : _createPlayer();
    _videos[key] = player;
    player.setPlaylistMode(PlaylistMode.single);
    player.setVolume(_muteVideos ? 0 : 100);
    if (autoLoad || resume) {
      unawaited(
        player.load(
          key,
          position: seekTo,
          play: resume,
          headers: requestHeaders,
        ),
      );
      _logger.debug('Loaded {video}', {'video': key});
    } else {
      // The player is parked on its url without downloading anything;
      // a later cache hit can backfill it once auto-loading is enabled.
      player.defer = key;
      _logger.debug('Deferred {video}', {'video': key});
    }
    return player;
  }

  /// Keeps the player out of recycling until a matching [release].
  void acquire(VideoPlayer player) => player._leases++;

  void release(VideoPlayer player) {
    if (player._leases == 0) return;
    player._leases--;
    // Lets widgets that were refused a player in getVideo retry once
    // this build is over, now that this player can be evicted for them.
    // Deferred: notifyListeners here could mark a widget that is
    // currently building as needing rebuild, which asserts.
    scheduleMicrotask(notifyListeners);
  }

  void unloadVideo(String key) {
    VideoPlayer? player = _videos.remove(key);
    if (player == null) return;
    _idle.add(player);
    player.unload();
    _logger.debug('Unloaded {video}', {'video': key});
  }

  @override
  void dispose() {
    _muteSetting?.removeListener(_onMuteSettingChanged);
    super.dispose();
  }
}

class VideoServiceProvider
    extends SubChangeNotifierProvider<Settings, VideoService> {
  VideoServiceProvider({super.child, super.builder})
    : super(
        create: (context, settings) => VideoService(
          muteVideos: settings.muteVideos.value,
          muteSetting: settings.muteVideos,
          headers: () => {
            HttpHeaders.userAgentHeader: AppInfo.instance.userAgent,
          },
        ),
      );
}

/// A fullscreen-scoped video quality override.
///
/// While one is provided, [url] is played instead of the resolution-based
/// selection and the video is loaded immediately: the user just picked it,
/// so deferring it again would only stall their player.
class PostVideoQuality {
  const PostVideoQuality({required this.url});

  /// The video url to play.
  final String url;
}

class VideoServiceVolumeControl extends StatelessWidget {
  const VideoServiceVolumeControl({super.key});

  @override
  Widget build(BuildContext context) {
    VideoService service = context.watch<VideoService>();
    bool muted = service.muteVideos;
    return Tooltip(
      message: muted
          ? AppLocalizations.of(context).videoWithSound
          : AppLocalizations.of(context).videoMuted,
      child: InkWell(
        // Writing the setting instead of the service lets the service
        // mirror it through its listener, keeping player state and
        // preferences in sync in both directions.
        onTap: () => context.read<Settings>().muteVideos.value = !muted,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            muted ? Icons.volume_off : Icons.volume_up,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

enum VideoResolution {
  standard,
  high,
  full,
  ultra,
  source;

  /// Localized display name for pickers.
  String localizedTitle(BuildContext context) => switch (this) {
    VideoResolution.standard => AppLocalizations.of(context).videoResStandard,
    VideoResolution.high => AppLocalizations.of(context).videoResHigh,
    VideoResolution.full => AppLocalizations.of(context).videoResFull,
    VideoResolution.ultra => AppLocalizations.of(context).videoResUltra,
    VideoResolution.source => AppLocalizations.of(context).videoResSource,
  };

  int get pixels => switch (this) {
    VideoResolution.standard => 640 * 480,
    VideoResolution.high => 1280 * 720,
    VideoResolution.full => 1920 * 1080,
    VideoResolution.ultra => 3840 * 2160,
    VideoResolution.source => 4096 * 2160,
  };
}
