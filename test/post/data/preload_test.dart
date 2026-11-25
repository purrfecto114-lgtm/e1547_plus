import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

import '../../_support/posts.dart';
import '../../_support/video.dart';

/// A cache manager that records every getSingleFile url: the file
/// prefetch goes through it, so its log is the list of positions the
/// prefetch actually reached.
class RecordingCacheManager implements BaseCacheManager {
  final List<String> requested = [];
  final _files = MemoryFileSystem();

  @override
  Future<File> getSingleFile(
    String url, {
    String? key,
    Map<String, String> headers = const {},
  }) async {
    requested.add(url);
    return _files.file(url)..writeAsBytesSync([1]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} only serves files');
}

/// The neighbour prefetch judges before it acts: only actual video
/// neighbours with a file are pooled, and only while the auto-loading
/// setting asks for it. Assertions query the pool with auto-loading
/// off, so a pooled neighbour shows its loaded media while an unpooled
/// url answers as deferred.
void main() {
  late VideoService videos;
  late Settings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = Settings(await SharedPreferences.getInstance());
    settings.autoLoadVideos.value = true;
    videos = fakeVideoService();
  });

  // The video pool is process-global: the prefetched players must not
  // leak into other test files' pool assertions.
  tearDown(() {
    for (final String url in [
      'https://cdn.example.org/1.mp4',
      'https://cdn.example.org/2.mp4',
      'https://cdn.example.org/3.mp4',
      'https://cdn.example.org/1.jpg',
      'https://cdn.example.org/2.jpg',
    ]) {
      videos.unloadVideo(url);
    }
    videos.dispose();
  });

  Future<void> pumpPreload(
    WidgetTester tester, {
    required int index,
    required List<Post> posts,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ListenableProvider<VideoService>.value(value: videos),
          Provider<Settings>.value(value: settings),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              preloadNeighborVideos(
                context: context,
                index: index,
                posts: posts,
              );
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Post videoPost(int id) =>
      samplePost(id: id, file: 'https://cdn.example.org/$id.mp4', ext: 'mp4');

  Post imagePost(int id) =>
      samplePost(id: id, file: 'https://cdn.example.org/$id.jpg');

  testWidgets('video neighbours on both sides are pooled and loaded', (
    tester,
  ) async {
    await pumpPreload(
      tester,
      index: 1,
      posts: [videoPost(1), imagePost(2), videoPost(3)],
    );
    expect(
      videos.getVideo('https://cdn.example.org/1.mp4', autoLoad: false)!.media,
      'https://cdn.example.org/1.mp4',
    );
    expect(
      videos.getVideo('https://cdn.example.org/3.mp4', autoLoad: false)!.media,
      'https://cdn.example.org/3.mp4',
    );
  });

  testWidgets('an image neighbour and a missing side load nothing', (
    tester,
  ) async {
    await pumpPreload(tester, index: 0, posts: [videoPost(1), imagePost(2)]);
    // The neighbour at index 1 is an image, the one at index -1 does
    // not exist: nothing was loaded by the prefetch. (Querying the pool
    // parks a deferred player on the url, but its media stays empty.)
    final stray = videos.getVideo(
      'https://cdn.example.org/1.mp4',
      autoLoad: false,
    );
    expect(stray!.media, isNull);
    expect(
      videos.getVideo('https://cdn.example.org/2.jpg', autoLoad: false)?.media,
      isNull,
    );
  });

  testWidgets('the setting off keeps the neighbours deferred', (tester) async {
    settings.autoLoadVideos.value = false;
    await pumpPreload(tester, index: 1, posts: [videoPost(1), videoPost(2)]);
    expect(
      videos.getVideo('https://cdn.example.org/1.mp4', autoLoad: false)?.media,
      isNull,
    );
    expect(
      videos.getVideo('https://cdn.example.org/2.mp4', autoLoad: false)?.media,
      isNull,
    );
  });

  testWidgets('the image prefetch only looks ahead', (tester) async {
    final manager = RecordingCacheManager();
    final posts = [imagePost(1), imagePost(2), imagePost(3), imagePost(4)];
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ListenableProvider<VideoService>.value(value: videos),
          Provider<Settings>.value(value: settings),
          Provider<BaseCacheManager>.value(value: manager),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              preloadPostImages(
                context: context,
                index: 1,
                posts: posts,
                size: PostImageSize.file,
              );
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    // Turning to the second post (index 1) must fetch exactly the next
    // one: the current post is already being loaded by the widget that
    // shows it, and posts the user has already seen sit in the disk
    // cache. Fetching them again either races the visible download or
    // re-reads files that were never going to change.
    expect(manager.requested, ['https://cdn.example.org/3.jpg']);
  });

  testWidgets('the image prefetch stops at the list end', (tester) async {
    final manager = RecordingCacheManager();
    final posts = [imagePost(1), imagePost(2)];
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ListenableProvider<VideoService>.value(value: videos),
          Provider<Settings>.value(value: settings),
          Provider<BaseCacheManager>.value(value: manager),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              preloadPostImages(
                context: context,
                index: 1,
                posts: posts,
                size: PostImageSize.file,
              );
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(manager.requested, isEmpty);
  });
}
