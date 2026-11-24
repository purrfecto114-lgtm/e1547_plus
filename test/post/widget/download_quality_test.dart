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

  // The dialog result the button closure captured after the dialog left.
  Object? picked;

  Future<void> pumpDialog(WidgetTester tester) async {
    picked = null;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await showDownloadVideoQualityDialog(context, post);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists qualities ascending with the source last', (tester) async {
    await pumpDialog(tester);
    expect(find.text('Video quality'), findsOneWidget);
    expect(find.text('960x540'), findsOneWidget);
    expect(find.text('1280x720'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('960x540')).dy,
      lessThan(tester.getTopLeft(find.text('1280x720')).dy),
    );
    expect(
      tester.getTopLeft(find.text('1280x720')).dy,
      lessThan(tester.getTopLeft(find.text('Source')).dy),
    );
  });

  testWidgets('pops with the picked variant key', (tester) async {
    await pumpDialog(tester);
    await tester.tap(find.text('1280x720'));
    await tester.pumpAndSettle();
    expect(picked, '1280x720');
  });

  testWidgets('pops the source row with a distinct non-null pick', (
    tester,
  ) async {
    await pumpDialog(tester);
    await tester.tap(find.text('Source'));
    await tester.pumpAndSettle();
    expect(picked, isNotNull);
    expect(picked, isNot('1280x720'));
    expect(picked, isNot('960x540'));
  });

  testWidgets('pops null when dismissed', (tester) async {
    await pumpDialog(tester);
    // The barrier around the dialog swallows the tap and closes it.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(picked, isNull);
  });
}
