import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  // The entry hands users straight to the fork's issue tracker; its
  // label and target must follow the configured repository.
  Future<void> pumpAboutLinks(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SingleChildScrollView(child: AboutLinks())),
      ),
    );
    await tester.pumpAndSettle();
  }

  await AppInfo.initializeMock(
    developer: 'test',
    github: 'purrfecto114-lgtm/e1547_plus',
    discord: null,
    website: null,
    kofi: null,
    email: null,
    forumTopicId: null,
    appName: 'e1547',
    packageName: 'net.e1547',
    version: '1.0.0',
    buildNumber: '1',
  );

  testWidgets('lists an issue entry targeting the fork repository', (
    tester,
  ) async {
    await pumpAboutLinks(tester);
    expect(find.text('Report an issue'), findsOneWidget);
    expect(find.text('purrfecto114-lgtm/e1547_plus/issues'), findsOneWidget);
  });

  testWidgets('translates the issue entry', (tester) async {
    await pumpAboutLinks(tester, locale: const Locale('zh'));
    expect(find.text('问题反馈'), findsOneWidget);
    expect(find.text('purrfecto114-lgtm/e1547_plus/issues'), findsOneWidget);
  });
}
