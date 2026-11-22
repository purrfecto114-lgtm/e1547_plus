import 'dart:io';

import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';

import '../_support/environment.dart';
import '../_support/harness.dart';
import '../_support/posts.dart';

/// Loads DejaVu Sans under the families Material resolves, so goldens
/// show real Latin glyphs with Roboto-like metrics instead of Ahem
/// boxes. (Merging a CJK font into the same family would inflate the
/// line height beyond what a device renders for Latin tag text.) The
/// fonts are a host dependency, not a repo asset: without them the
/// golden would compare against tofu blocks and the test skips rather
/// than fail on a machine that never produced the baseline.
const List<String> _fontPaths = [
  '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
  '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
];

bool get realFontsAvailable => _fontPaths.every((p) => File(p).existsSync());

Future<void> loadRealFonts() async {
  for (final family in ['Roboto', 'NotoSansSC']) {
    final loader = FontLoader(family);
    for (final path in _fontPaths) {
      final file = File(path);
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        loader.addFont(Future.value(bytes.buffer.asByteData()));
      }
    }
    await loader.load();
  }
}

/// Renders the tag chips of the detail page and the search drawer. Latin
/// text carries real glyph metrics; Chinese stays tofu (the loader ships
/// no CJK font), so for zh the golden locks layout geometry only — the
/// pixel-by-pixel comparison against a device screenshot holds for the
/// Latin parts, not the glyph shapes.
void main() {
  setUpAll(initializeTestApp);

  late TestEnvironment env;
  setUp(() async => env = await TestEnvironment.start());
  tearDown(() => env.dispose());

  testWidgets('tag chips match device geometry', (tester) async {
    if (!realFontsAvailable) {
      // Ahem-based pixels differ from the DejaVu-based baseline on a
      // machine without the fonts (macOS and Windows developers).
      markTestSkipped('DejaVu fonts not installed');
    }
    await loadRealFonts();
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final post = samplePost(
      tags: {
        'artist': ['artist_one'],
        'copyright': [
          'copyright_long_sample_tag',
          'hello_kitty',
          'touhou',
          'undertale',
        ],
        'species': ['canid', 'wolf'],
        'character': ['character_sample'],
        'general': ['general_tag_one', 'solo', 'highres', 'long_text_tag'],
        'meta': ['meta_tag'],
      },
    );

    await tester.pumpWidget(
      env.app(
        RepaintBoundary(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    TagDisplay(post: post),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('抽屉计数'),
                    const SizedBox(height: 8),
                    const Column(
                      children: [
                        TagCounterCard(
                          tag: 'copyright_long_sample_tag',
                          count: 1234,
                          category: 'copyright',
                        ),
                        TagCounterCard(
                          tag: 'artist_one',
                          count: 56,
                          category: 'artist',
                        ),
                        TagCounterCard(
                          tag: 'short',
                          count: 7,
                          category: 'general',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        locale: const Locale('zh'),
      ),
    );
    // Let the follow query of the tag display resolve against the fake
    // before the frame is locked into the golden.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('_goldens/tags_zh_1080x1920.png'),
    );

    // The environment's query cache schedules cache-entry deletions whose
    // timers must run out while the test still owns the clock.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });
}
