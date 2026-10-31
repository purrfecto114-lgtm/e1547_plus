import 'package:e1547/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';

import '../../_support/video.dart';

/// The video pool is process-global, so every test uses fresh urls and
/// asserts on the playables opened for them, never on raw call counts.
void main() {
  // Creating a VideoPlayer builds a VideoController, which needs a binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late VideoService videos;

  setUp(() {
    videos = fakeVideoService();
  });

  tearDown(() => videos.dispose());

  FakePlatformPlayer platformOf(VideoPlayer player) =>
      player.platform! as FakePlatformPlayer;

  List<Media> openedFor(FakePlatformPlayer platform, String url) => [
    for (final playable in platform.opened)
      if (playable is Media && playable.uri == url) playable,
  ];

  group('VideoService deferred loading', () {
    test('defers a video when auto-loading is disabled', () {
      final player = videos.getVideo('defer-url', autoLoad: false);
      expect(player, isNotNull);
      expect(player!.isDeferred, isTrue);
      expect(player.media, isNull);
      expect(openedFor(platformOf(player), 'defer-url'), isEmpty);
    });

    test('a deferred video stays deferred across cache hits', () {
      final first = videos.getVideo('stay-deferred', autoLoad: false)!;
      final again = videos.getVideo('stay-deferred', autoLoad: false);
      expect(again, same(first));
      expect(again!.isDeferred, isTrue);
      expect(openedFor(platformOf(again), 'stay-deferred'), isEmpty);
    });

    test('a deferred video loads once played', () async {
      final player = videos.getVideo('play-deferred', autoLoad: false)!;
      await player.play();
      expect(player.isDeferred, isFalse);
      expect(player.media, 'play-deferred');
      final opened = openedFor(platformOf(player), 'play-deferred');
      expect(opened, hasLength(1));
      expect(player.state.playing, isTrue);
    });

    test('enabling auto-loading backfills a deferred video', () {
      final first = videos.getVideo('backfill', autoLoad: false)!;
      final again = videos.getVideo('backfill');
      expect(again, same(first));
      expect(again!.isDeferred, isFalse);
      expect(again.media, 'backfill');
      expect(openedFor(platformOf(again), 'backfill'), hasLength(1));
      expect(again.state.playing, isFalse);
    });

    test('backfilling restores the requested position and playback', () {
      final first = videos.getVideo('backfill-seek', autoLoad: false)!;
      final again = videos.getVideo(
        'backfill-seek',
        seekTo: const Duration(seconds: 12),
        resume: true,
      );
      expect(again, same(first));
      final opened = openedFor(platformOf(again!), 'backfill-seek');
      expect(opened.single.start, const Duration(seconds: 12));
      expect(again.state.playing, isTrue);
    });
  });

  group('VideoService position restore', () {
    test('loads a new url at the requested position', () {
      final player = videos.getVideo(
        'restore-hi',
        seekTo: const Duration(minutes: 2),
        resume: true,
      )!;
      final opened = openedFor(platformOf(player), 'restore-hi');
      expect(opened.single.start, const Duration(minutes: 2));
      expect(player.state.playing, isTrue);
    });

    test('a paused position is restored without resuming', () {
      final player = videos.getVideo(
        'restore-paused',
        seekTo: const Duration(seconds: 30),
      )!;
      final opened = openedFor(platformOf(player), 'restore-paused');
      expect(opened.single.start, const Duration(seconds: 30));
      expect(player.state.playing, isFalse);
    });

    test('returning to a loaded video seeks and resumes it', () {
      final first = videos.getVideo('switch-away')!;
      platformOf(first).setPosition(const Duration(seconds: 30));

      // switching quality away...
      final second = videos.getVideo(
        'switch-back',
        seekTo: const Duration(seconds: 30),
        resume: true,
      )!;
      expect(second, isNot(same(first)));

      // ...and back restores the requested position on the old player.
      final back = videos.getVideo(
        'switch-away',
        seekTo: const Duration(seconds: 42),
        resume: true,
      );
      expect(back, same(first));
      expect(platformOf(first).seeks, [const Duration(seconds: 42)]);
      expect(first.state.playing, isTrue);
    });

    test('resuming without auto-loading loads a fresh player', () {
      // The user was watching, so a replacement player keeps playing
      // even with auto-loading off.
      final player = videos.getVideo(
        'resume-only',
        autoLoad: false,
        seekTo: const Duration(seconds: 20),
        resume: true,
      )!;
      expect(player.isDeferred, isFalse);
      expect(player.media, 'resume-only');
      expect(player.state.playing, isTrue);
    });
  });

  group('VideoService eviction', () {
    test('evicts the least recently used video', () {
      final first = videos.getVideo('evict-a', autoLoad: false)!;
      videos.getVideo('evict-b', autoLoad: false);
      videos.getVideo('evict-c', autoLoad: false);
      // requesting a fourth video evicts the least recently used one
      // and recycles its player for the new url
      final fourth = videos.getVideo('evict-d', autoLoad: false);
      expect(fourth, same(first));
      expect(first.media, isNull);
      expect(first.defer, 'evict-d');
      expect(openedFor(platformOf(first), 'evict-a'), isEmpty);
    });

    test('reuses the same player for the same url', () {
      final first = videos.getVideo('reuse')!;
      videos.getVideo('reuse-other');
      expect(videos.getVideo('reuse'), same(first));
      expect(openedFor(platformOf(first), 'reuse'), hasLength(1));
    });
  });

  // Regression guards for the player pool (issue #175): players are never
  // disposed, so the pool may only recycle players that no widget holds.
  group('VideoService lease invariants', () {
    test('never recycles a leased video for a new url', () {
      final leased = videos.getVideo('lease-held')!;
      videos.acquire(leased);
      addTearDown(() => videos.release(leased));
      videos.getVideo('lease-b', autoLoad: false);
      videos.getVideo('lease-c', autoLoad: false);

      // a fourth url would evict the least recently used video; the leased
      // one stays untouched even though it is the least recent
      final fourth = videos.getVideo('lease-d', autoLoad: false);
      expect(fourth, isNot(same(leased)));
      expect(leased.media, 'lease-held');
      expect(openedFor(platformOf(leased), 'lease-held'), hasLength(1));
    });

    test('refuses a video when every player is leased', () {
      final a = videos.getVideo('lease-a')!;
      final b = videos.getVideo('lease-b-url')!;
      final c = videos.getVideo('lease-c-url')!;
      for (final VideoPlayer player in [a, b, c]) {
        videos.acquire(player);
      }
      addTearDown(() {
        for (final VideoPlayer player in [a, b, c]) {
          videos.release(player);
        }
      });

      // creating a fourth player would grow the pool forever, since
      // players are never disposed; the caller gets a placeholder instead
      expect(videos.getVideo('lease-d-url'), isNull);
    });

    test('a released lease lets a refused video in', () async {
      final a = videos.getVideo('cycle-a')!;
      final b = videos.getVideo('cycle-b')!;
      final c = videos.getVideo('cycle-c')!;
      for (final VideoPlayer player in [a, b, c]) {
        videos.acquire(player);
      }
      addTearDown(() {
        for (final VideoPlayer player in [b, c]) {
          videos.release(player);
        }
      });
      expect(videos.getVideo('cycle-d'), isNull);

      bool notified = false;
      void listener() => notified = true;
      videos.addListener(listener);
      videos.release(a);
      await pumpEventQueue();
      expect(notified, isTrue);
      videos.removeListener(listener);

      // with the lease gone, the refused url recycles the released player;
      // recycling is the only way the pool could serve it without growing
      final d = videos.getVideo('cycle-d');
      expect(d, same(a));
      expect(a.media, 'cycle-d');
    });
  });
}
