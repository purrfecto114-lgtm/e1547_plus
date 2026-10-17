import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

void main() {
  late Settings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = Settings(await SharedPreferences.getInstance());
  });

  Widget wrap(Widget child) => Provider<Settings>.value(
    value: settings,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );

  testWidgets('is off by default', (tester) async {
    await tester.pumpWidget(wrap(const AutoLoadVideosTile()));
    expect(settings.autoLoadVideos.value, isFalse);
    expect(find.text('videos load when played'), findsOneWidget);
  });

  testWidgets('enabling asks for confirmation first', (tester) async {
    await tester.pumpWidget(wrap(const AutoLoadVideosTile()));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text(
        'Videos will be downloaded in full while you browse and search. '
        'This can consume a lot of data on metered connections.',
      ),
      findsOneWidget,
    );
    // not yet enabled
    expect(settings.autoLoadVideos.value, isFalse);
  });

  testWidgets('confirming enables auto-loading', (tester) async {
    await tester.pumpWidget(wrap(const AutoLoadVideosTile()));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(settings.autoLoadVideos.value, isTrue);
    expect(find.text('videos load while browsing'), findsOneWidget);
  });

  testWidgets('canceling keeps auto-loading off', (tester) async {
    await tester.pumpWidget(wrap(const AutoLoadVideosTile()));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(settings.autoLoadVideos.value, isFalse);
    // the switch tile did not flip either
    expect(find.text('videos load when played'), findsOneWidget);
  });

  testWidgets('disabling takes effect without a dialog', (tester) async {
    settings.autoLoadVideos.value = true;
    await tester.pumpWidget(wrap(const AutoLoadVideosTile()));

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(settings.autoLoadVideos.value, isFalse);
  });
}
