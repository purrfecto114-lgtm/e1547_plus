import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/posts.dart';

void main() {
  late Post post;

  setUpAll(() {
    post = samplePost(
      ext: 'webm',
      file: 'source.webm',
      variants: const {'1280x720': 'hi.mp4', '960x540': 'lo.mp4'},
    );
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    String current = 'source.webm',
    required ValueChanged<String> onSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => VideoQualityDialog(
                post: post,
                current: current,
                onSelected: onSelected,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists qualities ascending with the source last', (tester) async {
    await pumpDialog(tester, onSelected: (_) {});
    expect(find.text('Video quality'), findsOneWidget);
    expect(find.text('960x540'), findsOneWidget);
    expect(find.text('1280x720'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
    // ascending order: the 540p entry precedes the 720p entry
    expect(
      tester.getTopLeft(find.text('960x540')).dy,
      lessThan(tester.getTopLeft(find.text('1280x720')).dy),
    );
    expect(
      tester.getTopLeft(find.text('1280x720')).dy,
      lessThan(tester.getTopLeft(find.text('Source')).dy),
    );
  });

  testWidgets('marks the current quality', (tester) async {
    await pumpDialog(tester, current: 'lo.mp4', onSelected: (_) {});
    final loTile = find.ancestor(
      of: find.text('960x540'),
      matching: find.byType(ListTile),
    );
    final hiTile = find.ancestor(
      of: find.text('1280x720'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: loTile, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: hiTile, matching: find.byIcon(Icons.check)),
      findsNothing,
    );
  });

  testWidgets('reports the picked url and closes', (tester) async {
    String? selected;
    await pumpDialog(tester, onSelected: (url) => selected = url);
    await tester.tap(find.text('1280x720'));
    await tester.pumpAndSettle();
    expect(selected, 'hi.mp4');
    expect(find.text('1280x720'), findsNothing);
  });

  testWidgets('the source entry reports the source file', (tester) async {
    String? selected;
    await pumpDialog(
      tester,
      current: 'hi.mp4',
      onSelected: (url) => selected = url,
    );
    await tester.tap(find.text('Source'));
    await tester.pumpAndSettle();
    expect(selected, 'source.webm');
  });
}
