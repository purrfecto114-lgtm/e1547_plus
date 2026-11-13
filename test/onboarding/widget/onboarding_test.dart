import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/onboarding/onboarding.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:relative_time/relative_time.dart';

import '../../_support/harness.dart';

void main() {
  late AppDatabase sqlite;
  late Settings settings;
  late IdentityClient identities;

  setUpAll(() => initializeTestApp());

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await Settings.getInstance();
    sqlite = AppDatabase(NativeDatabase.memory());
    identities = IdentityClient(database: sqlite);
    final identity = await identities.add(
      const IdentityRequest(host: 'e621.net'),
    );
    await identities.activate(identity.id);
  });

  tearDown(() async {
    identities.dispose();
    await sqlite.close();
  });

  Widget wrap(Widget child, {Locale locale = const Locale('en')}) =>
      MultiProvider(
        providers: [
          Provider<Settings>.value(value: settings),
          ChangeNotifierProvider<IdentityClient>.value(value: identities),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            GlobalCupertinoLocalizations.delegate,
            RelativeTimeLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );

  /// Whether the language chip carrying [label] is selected.
  bool chipSelected(WidgetTester tester, String label) => tester
      .widget<ChoiceChip>(
        find
            .ancestor(of: find.text(label), matching: find.byType(ChoiceChip))
            .first,
      )
      .selected;

  testWidgets('renders welcome and language as the first page', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // the introduction and the language list share the first page
    expect(find.text('Welcome to e1547'), findsOneWidget);
    expect(find.text('A sophisticated booru browser.'), findsOneWidget);
    expect(find.text('Choose a language'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);

    // the step is rendered in english, not any other locale
    expect(find.text('选择语言'), findsNothing);
    expect(find.text('選擇語言'), findsNothing);

    // without a stored language, the system default chip is selected
    expect(settings.language.value, isNull);
    expect(chipSelected(tester, 'System default'), isTrue);
    expect(chipSelected(tester, 'English'), isFalse);
  });

  testWidgets('selecting languages updates the setting', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();
    expect(settings.language.value, 'zh');
    expect(chipSelected(tester, '简体中文'), isTrue);
    expect(chipSelected(tester, 'System default'), isFalse);

    await tester.tap(find.text('System default'));
    await tester.pumpAndSettle();
    expect(settings.language.value, isNull);
    expect(chipSelected(tester, 'System default'), isTrue);
  });

  testWidgets('offers and selects the japanese and russian languages', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // both the onboarding step and the settings language dialog
    // iterate appLanguages, so these options appear in both
    expect(find.text('日本語'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);

    await tester.ensureVisible(find.text('日本語'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('日本語'));
    await tester.pumpAndSettle();
    expect(settings.language.value, 'ja');
    expect(chipSelected(tester, '日本語'), isTrue);

    await tester.ensureVisible(find.text('Русский'));
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(settings.language.value, 'ru');
    expect(chipSelected(tester, 'Русский'), isTrue);
  });

  testWidgets('picks the quality tiers before logging in', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // the quality step follows the theme step
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Tune your media'), findsOneWidget);
    expect(find.text('Video quality'), findsOneWidget);
    expect(find.text('Thumbnail quality'), findsOneWidget);

    // three tiers per picker, one selection each
    expect(find.text('Low'), findsNWidgets(2));
    expect(find.text('Medium'), findsNWidgets(2));
    expect(find.text('High'), findsNWidgets(2));
    expect(settings.videoResolution.value, isNotNull);
    expect(settings.tileSize.value, isNotNull);

    await tester.tap(find.text('High').first);
    await tester.pumpAndSettle();
    expect(settings.videoResolution.value, VideoResolution.high);

    await tester.tap(find.text('Low').last);
    await tester.pumpAndSettle();
    expect(settings.tileSize.value, TileSize.small);
  });

  testWidgets('theme step scrolls instead of overflowing on short screens', (
    tester,
  ) async {
    // 640x360 with enlarged text used to throw a RenderFlex overflow:
    // the swatch grid had no way to shrink, so the step now scrolls.
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Pick a look'), findsOneWidget);
    // The swatch grid stays reachable through the scroll view.
    expect(tester.getRect(find.text('dark')), isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skipping leads onto the age confirmation page', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(OnboardingScreen)),
    );

    // The skip shortcut ends up browsing as a guest on an adults-only
    // site, so it leads onto the age page like every other way to the
    // login does.
    await tester.tap(find.text(l10n.onboardingSkip));
    await tester.pumpAndSettle();
    expect(find.text(l10n.adultGateTitle), findsOneWidget);
    expect(settings.onboardingSeen.value, isFalse);

    // Denying takes the user back a page; the only way past the gate is
    // the confirmation.
    await tester.tap(find.text(l10n.adultGateDeny));
    await tester.pumpAndSettle();
    expect(find.text(l10n.adultGateTitle), findsNothing);
    expect(find.text(l10n.onboardingSkip), findsOneWidget);
    expect(settings.onboardingSeen.value, isFalse);

    // Confirming opens the login step — still without leaving the
    // onboarding, and without the form stacking its own dialog on top
    // of the page the user just confirmed.
    await tester.tap(find.text(l10n.onboardingSkip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.adultGateConfirm));
    await tester.pumpAndSettle();
    expect(find.text(l10n.adultGateTitle), findsNothing);
    expect(find.text(l10n.onboardingLoginTitle), findsOneWidget);
    expect(find.text(l10n.identityGuest), findsOneWidget);
    expect(settings.onboardingSeen.value, isFalse);
  });

  testWidgets('the login step stays behind the age page', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(OnboardingScreen)),
    );

    // Walk the pages to the age confirmation.
    await tester.tap(find.text(l10n.onboardingNext));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.onboardingNext));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.onboardingNext));
    await tester.pumpAndSettle();
    expect(find.text(l10n.adultGateTitle), findsOneWidget);

    // The pager offers no next button on the gate page, and a fling
    // cannot carry the user past it either: the login step is only
    // reachable through the confirmation.
    expect(find.text(l10n.onboardingNext), findsNothing);
    await tester.fling(find.byType(PageView), const Offset(-500, 0), 10000);
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingLoginTitle), findsNothing);
    expect(find.text(l10n.adultGateTitle), findsOneWidget);

    await tester.tap(find.text(l10n.adultGateConfirm));
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingLoginTitle), findsOneWidget);
  });

  testWidgets('the gate forces onboarding until it has been seen', (
    tester,
  ) async {
    settings.onboardingSeen.value = false;
    await tester.pumpWidget(
      wrap(const OnboardingGate(child: Text('app shell'))),
    );
    await tester.pumpAndSettle();

    // The app shell stays unreachable while onboarding has not been
    // seen: this outer wiring is what makes every way into the app hit
    // the onboarding — and with it the age gate — first.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('app shell'), findsNothing);

    settings.onboardingSeen.value = true;
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('app shell'), findsOneWidget);
  });
}
