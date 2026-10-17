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
}
