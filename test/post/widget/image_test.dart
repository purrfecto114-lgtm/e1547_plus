import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../_support/images.dart';
import '../../_support/posts.dart';

void main() {
  Future<Uint8List> png(WidgetTester tester, int width, int height) async {
    return (await tester.runAsync(() async {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = const Color(0xFFFF0000),
      );
      final ui.Image image = await recorder.endRecording().toImage(
        width,
        height,
      );
      final ByteData? data = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return data!.buffer.asUint8List();
    }))!;
  }

  /// The bitmaps actually drawn under the post image widget.
  ///
  /// This reads the decoded size off every RawImage, which is the thing
  /// the memory diagnosis measured: the caps may cap any number of
  /// internal streams, but only the drawn bitmaps cost the RAM.
  Future<List<ui.Image>> drawnBitmaps(
    WidgetTester tester,
    BaseCacheManager images,
    String url,
  ) async {
    await tester.runAsync(
      () => precacheImage(
        CachedNetworkImageProvider(url, cacheManager: images),
        tester.element(find.byType(RawPostImageWidget)),
      ),
    );
    await tester.pumpAndSettle();
    return tester
        .widgetList<RawImage>(
          find.descendant(
            of: find.byType(RawPostImageWidget),
            matching: find.byType(RawImage),
          ),
        )
        .map((raw) => raw.image)
        .whereType<ui.Image>()
        .toList();
  }

  testWidgets('a capped thumbnail draws a bitmap within the cap', (
    tester,
  ) async {
    // The caps cover the stream inside CachedNetworkImage only; the
    // provider its imageBuilder hands out used to rebuild an Image
    // that decoded at the file's full size, so the thumbnail quality
    // setting never reached the screen. What is drawn must carry the
    // cap itself: a 400x200 file at a 50 short-side cap decodes to
    // 100x50, never to its native size.
    // A dedicated url per test: the provider's cache key is the url,
    // and one shared key would leak the first test's bitmap here.
    const String url = 'http://example.invalid/capped.png';
    final ServedImageCacheManager images = ServedImageCacheManager(
      await png(tester, 200, 100),
    );

    await tester.pumpWidget(
      Provider<BaseCacheManager>.value(
        value: images,
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox.square(
                dimension: 100,
                child: RawPostImageWidget(
                  post: samplePost(
                    width: 400,
                    height: 200,
                    file: url,
                    preview: url,
                  ),
                  size: PostImageSize.preview,
                  cacheSize: 50,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final List<ui.Image> bitmaps = await drawnBitmaps(tester, images, url);
    expect(bitmaps, isNotEmpty);
    for (final ui.Image bitmap in bitmaps) {
      // The short side is capped to 50, the long side follows the ratio.
      expect(bitmap.width, 100);
      expect(bitmap.height, 50);
    }
  });

  testWidgets('an uncapped thumbnail draws its native bitmap', (tester) async {
    const String url = 'http://example.invalid/uncapped.png';
    final ServedImageCacheManager images = ServedImageCacheManager(
      await png(tester, 40, 20),
    );

    await tester.pumpWidget(
      Provider<BaseCacheManager>.value(
        value: images,
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox.square(
                dimension: 100,
                child: RawPostImageWidget(
                  post: samplePost(
                    width: 40,
                    height: 20,
                    file: url,
                    preview: url,
                  ),
                  size: PostImageSize.preview,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final List<ui.Image> bitmaps = await drawnBitmaps(tester, images, url);
    expect(bitmaps, isNotEmpty);
    for (final ui.Image bitmap in bitmaps) {
      // No cap: the file decodes as delivered, never downscaled.
      expect(bitmap.width, 40);
      expect(bitmap.height, 20);
    }
  });

  testWidgets(
    'a post image under a page is drawn at once by a hero flight '
    'back after the app was hidden through memory pressure',
    skip: true, // upstream decode-hold behavior, not aligned yet
    (tester) async {
      final Uint8List png = (await tester.runAsync(() async {
        final ui.PictureRecorder recorder = ui.PictureRecorder();
        Canvas(recorder).drawRect(
          const Rect.fromLTWH(0, 0, 4, 4),
          Paint()..color = const Color(0xFFFF0000),
        );
        final ui.Image image = await recorder.endRecording().toImage(4, 4);
        final ByteData? data = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        return data!.buffer.asUint8List();
      }))!;
      const String url = 'http://example.invalid/post.png';
      final ServedImageCacheManager images = ServedImageCacheManager(png);
      final ValueNotifier<bool> hidden = ValueNotifier(false);
      addTearDown(hidden.dispose);
      final GlobalKey<NavigatorState> navigator = GlobalKey();

      await tester.pumpWidget(
        Provider<BaseCacheManager>.value(
          value: images,
          child: MaterialApp(
            navigatorKey: navigator,
            builder: (context, child) => ValueListenableBuilder<bool>(
              valueListenable: hidden,
              builder: (context, hidden, _) => Visibility(
                visible: !hidden,
                maintainState: true,
                child: child!,
              ),
            ),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox.square(
                  dimension: 100,
                  child: Hero(
                    tag: 'post',
                    child: RawPostImageWidget(
                      post: samplePost(file: url, preview: url),
                      size: PostImageSize.preview,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(
          CachedNetworkImageProvider(url, cacheManager: images),
          tester.element(find.byType(RawPostImageWidget)),
        ),
      );
      await tester.pumpAndSettle();
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            body: Center(
              child: SizedBox.square(
                dimension: 300,
                child: Hero(tag: 'post', child: Image.memory(png)),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      hidden.value = true;
      await tester.pump();
      tester.binding.handleMemoryPressure();
      hidden.value = false;
      await tester.pump();
      navigator.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      final RawImage flight = tester.widget<RawImage>(
        find
            .descendant(
              of: find.byType(RawPostImageWidget),
              matching: find.byType(RawImage),
            )
            .first,
      );
      expect(flight.image, isNotNull);
      await tester.pumpAndSettle();
    },
  );
}
