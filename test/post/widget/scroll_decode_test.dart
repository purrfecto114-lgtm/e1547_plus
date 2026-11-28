import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/environment.dart';
import '../../_support/harness.dart';
import '../../_support/posts.dart';

/// A manager that only counts stream requests and fails them: every
/// image the app asks for shows up as a request, and nothing lands in
/// the image cache, so the count is a pure measure of resolve volume.
class CountingManager implements BaseCacheManager {
  final requests = <String>[];

  bool contains(String url) => requests.contains(url);

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool? withProgress,
  }) {
    requests.add(url);
    return Stream<FileResponse>.error(Exception('no image at $url'));
  }

  @override
  Future<File> getSingleFile(
    String url, {
    String key = '',
    Map<String, String> headers = const {},
  }) => Future<File>.error(Exception('no image at $url'));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} holds no image');
}

void main() {
  setUpAll(initializeTestApp);

  late TestEnvironment env;

  setUp(() async => env = await TestEnvironment.start());

  tearDown(() => env.dispose());

  Future<void> show(WidgetTester tester, CountingManager manager) async {
    final posts = [
      for (int i = 1; i <= 60; i++)
        samplePost(id: i, file: '/file/$i', preview: '/preview/$i'),
    ];
    await tester.pumpWidget(
      env.app(
        Scaffold(
          body: TileLayout(
            child: CustomScrollView(
              slivers: [
                PostGridSliver(
                  state: PagingState<int, Post>(
                    pages: [posts.sublist(0, 20), posts.sublist(20, 60)],
                    keys: const [1, 2],
                    hasNextPage: false,
                  ),
                  fetchNextPage: () {},
                ),
              ],
            ),
          ),
        ),
        providers: [Provider<BaseCacheManager>.value(value: manager)],
      ),
    );
    await tester.pump();
  }

  testWidgets('a fling resolves the tiles it lands on, not the ones it '
      'swept past', (tester) async {
    final manager = CountingManager();
    await show(tester, manager);

    // The finger drags a little — tiles it passes load as they pass, the
    // way slow browsing always has — then releases into a ballistic that
    // carries the viewport all the way to the end.
    final scrollable = find.byType(Scrollable).first;
    final gesture = await tester.startGesture(tester.getCenter(scrollable));
    for (int i = 1; i <= 3; i++) {
      await gesture.moveBy(
        const Offset(0, -300),
        timeStamp: Duration(milliseconds: i * 16),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    final dragged = manager.requests.length;
    await gesture.up(timeStamp: const Duration(milliseconds: 64));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // The ballistic swept the tiles between the two resting points; none
    // of them may have started a download. The tiles under the resting
    // viewport did, released once the ballistic came to rest.
    expect(
      manager.contains('/file/35'),
      isFalse,
      reason: 'a tile the fling swept past never renders its image',
    );
    expect(
      manager.contains('/file/60'),
      isTrue,
      reason: 'the landing point loads its own tiles once settled',
    );
    expect(
      manager.requests.length,
      greaterThan(dragged),
      reason: 'the landing point loads its own tiles once settled',
    );
    expect(
      manager.requests.length,
      lessThan(60),
      reason: 'fast scrolling must not resolve every passed tile',
    );
  });

  testWidgets('a slow drag resolves the tiles it passes as it passes them', (
    tester,
  ) async {
    final manager = CountingManager();
    await show(tester, manager);

    // Dragging keeps the finger on the screen: the framework holds the
    // velocity at zero for the whole drag, so every tile built under it
    // loads right away — the user is watching the content scroll by.
    await tester.timedDrag(
      find.byType(Scrollable).first,
      const Offset(0, -3000),
      const Duration(seconds: 6),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(
      manager.contains('/file/35'),
      isTrue,
      reason: 'browsing speed renders what it passes',
    );
    expect(
      manager.contains('/file/60'),
      isTrue,
      reason: 'browsing speed renders what it passes',
    );
    expect(
      manager.requests.length,
      greaterThan(40),
      reason: 'browsing speed renders what it passes',
    );
  });
}
