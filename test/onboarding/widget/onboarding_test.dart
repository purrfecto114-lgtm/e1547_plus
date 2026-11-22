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

  /// The localizations of the onboarding screen under test.
  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(OnboardingScreen)));

  /// Confirms the age gate, which opens onto the welcome page. The
  /// gate scrolls on short viewports, so the button is brought into
  /// view before the tap.
  Future<void> confirmAge(WidgetTester tester) async {
    final l10n = l10nOf(tester);
    await tester.ensureVisible(find.text(l10n.adultGateConfirm));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.adultGateConfirm));
    await tester.pumpAndSettle();
  }

  testWidgets('opens with the age confirmation', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();
    final l10n = l10nOf(tester);

    // The gate leads: on an adults-only site nothing, not even the
    // language picker, may come before the confirmation.
    expect(find.text(l10n.adultGateTitle), findsOneWidget);
    expect(find.text(l10n.adultGateDeny), findsOneWidget);
    expect(find.text('Welcome to e1547'), findsNothing);

    // The skip shortcut is gone: skipping used to mean going to the
    // gate, and the gate is now where the pager already starts. The
    // key is deleted, so the assertion reads the old label directly.
    expect(find.text('Skip'), findsNothing);
    expect(settings.onboardingSeen.value, isFalse);
  });

  testWidgets('selecting languages updates the setting', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();
    await confirmAge(tester);

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
    await confirmAge(tester);

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
    await confirmAge(tester);

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
    expect(settings.thumbnailQuality.value, isNotNull);

    await tester.tap(find.text('High').first);
    await tester.pumpAndSettle();
    expect(settings.videoResolution.value, VideoResolution.high);

    await tester.tap(find.text('Low').last);
    await tester.pumpAndSettle();
    expect(settings.thumbnailQuality.value, ThumbnailQuality.low);
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
    await confirmAge(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Pick a look'), findsOneWidget);
    // The swatch grid stays reachable through the scroll view.
    expect(tester.getRect(find.text('dark')), isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('denying the age page holds it open', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();
    final l10n = l10nOf(tester);

    // The gate is the first page, so denying has nowhere to go back
    // to: the step states the requirement and keeps only the
    // confirmation, which stays the one way forward.
    await tester.tap(find.text(l10n.adultGateDeny));
    await tester.pumpAndSettle();
    expect(find.text(l10n.adultGateTitle), findsOneWidget);
    expect(find.text(l10n.adultGateDeniedBody), findsOneWidget);
    expect(find.text(l10n.adultGateDeny), findsNothing);
    expect(settings.onboardingSeen.value, isFalse);

    // The confirmation keeps working from the refused state.
    await tester.tap(find.text(l10n.adultGateConfirm));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to e1547'), findsOneWidget);
    expect(settings.onboardingSeen.value, isFalse);
  });

  testWidgets('the login step stays behind the age page', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.pumpAndSettle();
    final l10n = l10nOf(tester);

    // The gate opens the pager, so nothing needs walking through to
    // reach it; a fling still cannot carry past it to the login.
    expect(find.text(l10n.onboardingNext), findsNothing);
    await tester.fling(find.byType(PageView), const Offset(-500, 0), 10000);
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingLoginTitle), findsNothing);
    expect(find.text(l10n.adultGateTitle), findsOneWidget);

    // Confirming moves on, and the login waits behind the rest.
    await tester.tap(find.text(l10n.adultGateConfirm));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to e1547'), findsOneWidget);
    for (int i = 0; i < 3; i++) {
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
    }
    expect(find.text(l10n.onboardingLoginTitle), findsOneWidget);
    expect(find.text(l10n.identityGuest), findsOneWidget);
    expect(settings.onboardingSeen.value, isFalse);
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
