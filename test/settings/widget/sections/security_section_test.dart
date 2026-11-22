import 'package:e1547/app/app.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:provider/provider.dart';

/// The security section must follow the live biometric probe answer:
/// enrollment changes in the system settings while the app sits in the
/// background, and a snapshot taken at page mount used to stick until
/// something else rebuilt the section.
void main() {
  late Settings settings;
  late BiometricsWatcher watcher;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = Settings(await SharedPreferences.getInstance());
    watcher = BiometricsWatcher(probe: () async => BiometricAvailability.none);
  });

  Future<void> pumpSection(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Settings>.value(value: settings),
          ListenableProvider<BiometricsWatcher>.value(value: watcher),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SettingsSecuritySection()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Switch switchOf(WidgetTester tester) =>
      tester.widget<Switch>(find.byType(Switch).last);

  testWidgets('an enrolled sensor reports a usable biometric lock', (
    tester,
  ) async {
    settings.biometricAuth.value = true;
    await pumpSection(tester);

    watcher.value = BiometricAvailability.ready;
    await tester.pump();
    expect(switchOf(tester).value, isTrue);
    // The enabled/disabled subtitle pair belongs to the ready state.
    expect(find.text('生物识别已启用'), findsOneWidget);
  });

  testWidgets('prints removed in the system settings update the section', (
    tester,
  ) async {
    settings.biometricAuth.value = true;
    await pumpSection(tester);

    watcher.value = BiometricAvailability.ready;
    await tester.pump();
    expect(find.text('生物识别已启用'), findsOneWidget);

    watcher.value = BiometricAvailability.unenrolled;
    await tester.pump();

    // The switch keeps the stored setting but goes dead, and the
    // subtitle says why: the sensor lost its prints, the app did not.
    expect(switchOf(tester).value, isTrue);
    expect(find.text('检测到生物识别硬件，但尚未录入指纹'), findsOneWidget);

    // Dead means dead: flipping the switch must be impossible.
    await tester.tap(find.byType(Switch).last);
    await tester.pump();
    expect(settings.biometricAuth.value, isTrue);
  });

  testWidgets('absent biometric hardware updates the section too', (
    tester,
  ) async {
    settings.biometricAuth.value = true;
    await pumpSection(tester);

    watcher.value = BiometricAvailability.ready;
    await tester.pump();

    watcher.value = BiometricAvailability.none;
    await tester.pump();
    expect(find.text('未检测到生物识别硬件'), findsOneWidget);
    await tester.tap(find.byType(Switch).last);
    await tester.pump();
    expect(settings.biometricAuth.value, isTrue);
  });
}
