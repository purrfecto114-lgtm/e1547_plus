import 'dart:io';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_support/posts.dart';

/// Loads DejaVu Sans under the families Material resolves, so goldens
/// show real Latin glyphs with Roboto-like metrics instead of Ahem
/// boxes. (Merging a CJK font into the same family would inflate the
/// line height beyond what a device renders for Latin tag text.)
Future<void> loadRealFonts() async {
  final latin = File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf');
  final latinBold = File(
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
  );
  for (final family in ['Roboto', 'NotoSansSC']) {
    final loader = FontLoader(family);
    for (final path in [latin, latinBold]) {
      if (path.existsSync()) {
        final bytes = path.readAsBytesSync();
        loader.addFont(Future.value(bytes.buffer.asByteData()));
      }
    }
    await loader.load();
  }
}

/// Renders the tag chips of the detail page and the search drawer, so
/// reported text alignment regressions can be compared against real
/// device screenshots pixel by pixel.
void main() {
  testWidgets('tag chips match device geometry', (tester) async {
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
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepaintBoundary(
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
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('_goldens/tags_zh_1080x1920.png'),
    );
  });
}
