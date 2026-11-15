import 'dart:async';

import 'package:e1547/app/app.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:provider/provider.dart';

/// Exercises the lock screen wiring against the real settings store: the
/// backoff counters and the in place legacy pin upgrade are safety
/// behavior, so the tests pump the genuine [LockScreen] with the genuine
/// hash derivation instead of stubs.
void main() {
  late Settings settings;
  late BiometricsWatcher watcher;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = Settings(await SharedPreferences.getInstance());
    // The host has no fingerprint sensor and no plugin behind the probe,
    // so the watcher gets a scripted answer the tests can overwrite.
    watcher = BiometricsWatcher(probe: () async => BiometricAvailability.none);
  });

  Future<void> pumpLock(
    WidgetTester tester, [
    BiometricsWatcher? pending,
  ]) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Settings>.value(value: settings),
          ListenableProvider<BiometricsWatcher>.value(
            value: pending ?? watcher,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LockScreen(child: Text('unlocked content')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> enter(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    // The keypad submits a full entry after a short beat, then the
    // derivation runs on a real isolate, which fake async would never
    // see complete on its own: real async work needs runAsync.
    await tester.pump(const Duration(milliseconds: 250));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    });
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('consecutive failures feed the persisted backoff', (
    tester,
  ) async {
    settings.appPin.value = await tester.runAsync(() => hashPin('2468'));
    await pumpLock(tester);

    // The first two failures stay free, the third one starts the wait.
    for (int i = 1; i <= 3; i++) {
      await enter(tester, '1357');
    }
    expect(settings.appPinFailures.value, 3);
    expect(
      settings.appPinLockedUntil.value,
      greaterThan(DateTime.now().millisecondsSinceEpoch),
    );
    expect(find.textContaining('秒后再试'), findsOneWidget);

    // A fresh settings store over the same persistence simulates a
    // restart: the cooldown must survive it, killing the app does not
    // reset the wait.
    final restarted = Settings(await SharedPreferences.getInstance());
    expect(restarted.appPinFailures.value, 3);
    expect(
      restarted.appPinLockedUntil.value,
      greaterThan(DateTime.now().millisecondsSinceEpoch),
    );

    // Unmount before the test ends, so the cooldown timer does not
    // outlive the fake async zone.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a correct entry clears the failure streak and unlocks', (
    tester,
  ) async {
    settings.appPin.value = await tester.runAsync(() => hashPin('2468'));
    settings.appPinFailures.value = 2;
    await pumpLock(tester);

    await enter(tester, '2468');
    expect(settings.appPinFailures.value, 0);
    expect(settings.appPinLockedUntil.value, 0);
    expect(find.text('unlocked content'), findsOneWidget);
  });

  testWidgets('a legacy plain text pin upgrades in place', (tester) async {
    settings.appPin.value = '2468';
    await pumpLock(tester);

    await enter(tester, '2468');
    final stored = settings.appPin.value!;
    expect(isPinHash(stored), isTrue);
    expect(pinHashIterationsOf(stored), pinHashIterations);
  });

  testWidgets('a wrong entry never upgrades a legacy pin', (tester) async {
    settings.appPin.value = '2468';
    await pumpLock(tester);

    await enter(tester, '1357');
    expect(settings.appPin.value, '2468');
    expect(settings.appPinFailures.value, 1);
    expect(find.text('unlocked content'), findsNothing);
  });

  testWidgets('the fingerprint shortcut follows the live probe answer', (
    tester,
  ) async {
    settings.appPin.value = await tester.runAsync(() => hashPin('2468'));
    settings.biometricAuth.value = true;
    await pumpLock(tester);

    // The setting alone decides nothing: the shortcut only shows while
    // the watcher still believes the sensor carries prints.
    expect(find.byIcon(Icons.fingerprint), findsNothing);
    watcher.value = BiometricAvailability.ready;
    await tester.pump();
    expect(find.byIcon(Icons.fingerprint), findsOneWidget);

    // Prints removed in the system settings while the app sat in the
    // background: the watcher answers again, and the dead shortcut must
    // vanish without waiting for a restart. The pin pad stays, so the
    // way back in survives.
    watcher.value = BiometricAvailability.unenrolled;
    await tester.pump();
    expect(find.byIcon(Icons.fingerprint), findsNothing);

    await enter(tester, '2468');
    expect(find.text('unlocked content'), findsOneWidget);
  });

  testWidgets('a probe that never answers keeps the shortcut off', (
    tester,
  ) async {
    // The watcher publishes null until its first probe lands: the lock
    // screen must read that as "not usable", not as "usable".
    final pending = BiometricsWatcher(
      probe: () => Completer<BiometricAvailability>().future,
    );
    settings.appPin.value = await tester.runAsync(() => hashPin('2468'));
    settings.biometricAuth.value = true;
    await pumpLock(tester, pending);

    expect(pending.value, isNull);
    expect(find.byIcon(Icons.fingerprint), findsNothing);

    // The watcher listens for its own disposal; without a frame tree
    // owning it the test unmounts it by hand.
    pending.dispose();
  });
}
