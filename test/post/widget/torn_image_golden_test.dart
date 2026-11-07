import 'package:e1547/app/app.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the torn image error placeholder at several tile sizes on both
/// theme brightnesses, so accidental glyph regressions are caught pixel
/// by pixel instead of only surfacing in device screenshots.
void main() {
  Widget tile(AppTheme theme, double size) => SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: theme.data.cardColor,
          child: const TornImagePlaceholder(),
        ),
      );

  Widget scaffold(AppTheme theme) => MaterialApp(
    theme: theme.data,
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 96 caps at 48, which exercises the size ceiling.
            for (final size in [24.0, 48.0, 96.0])
              Padding(padding: const EdgeInsets.all(8), child: tile(theme, size)),
            // A non square tile proves the placeholder stays a centered
            // square instead of stretching with its box.
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: 56,
                height: 80,
                child: ColoredBox(
                  color: theme.data.cardColor,
                  child: const TornImagePlaceholder(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  for (final (name, theme) in [
    ('dark', AppTheme.dark),
    ('light', AppTheme.light),
  ]) {
    testWidgets('torn image placeholder matches geometry ($name)',
        (tester) async {
      tester.view.physicalSize = const Size(400, 560);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(scaffold(theme));
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('_goldens/torn_image_placeholder_$name.png'),
      );
    });
  }
}
