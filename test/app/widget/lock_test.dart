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
    // The fourth tap starts the derivation immediately, overlapping the
    // last dot's entrance; the derivation runs on a real isolate, which
    // fake async would never see complete on its own: real async work
    // needs runAsync.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    });
    // The verdict waits for the dot entrance before it lands, then the
    // screen settles into its new state.
    await tester.pump(const Duration(milliseconds: 200));
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

  /// Pumps a bare [PinLock] with a stubbed verdict, so tests drive the
  /// keypad state machine directly instead of through the settings
  /// store and the real hash derivation.
  Future<void> pumpPad(
    WidgetTester tester, {
    required Future<bool> Function(String pin) verify,
    ValueNotifier<int>? attempts,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PinLock(
          title: 'pin',
          verify: verify,
          attempts: attempts,
          onCompleted: (_) {},
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> tapKey(WidgetTester tester, String digit) async {
    await tester.tap(find.text(digit).last);
    await tester.pump();
  }

  testWidgets(
    'presses during a running verification are buffered and replayed',
    (tester) async {
      final List<String> submitted = [];
      final Completer<bool> gate = Completer<bool>();
      await pumpPad(
        tester,
        verify: (pin) {
          submitted.add(pin);
          return gate.future;
        },
      );

      for (final digit in '1357'.split('')) {
        await tapKey(tester, digit);
      }
      expect(submitted, ['1357']);

      // The verdict is still in flight. Re-entering the pin the moment a
      // wrong verdict appears must not lose the presses to the derivation
      // window: they buffer and replay instead of vanishing.
      for (final digit in '2468'.split('')) {
        await tapKey(tester, digit);
      }
      expect(submitted, ['1357']);

      gate.complete(false);
      await tester.pump(const Duration(milliseconds: 200));
      // The buffered run arrived intact and started its own verification.
      expect(submitted, ['1357', '2468']);
      // The replayed entry verifies against the now completed gate; let
      // its settle timer and verdict finish before the tree goes away.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('a key registers on touch down at the cell edge', (tester) async {
    final List<String> submitted = [];
    await pumpPad(
      tester,
      verify: (pin) async {
        submitted.add(pin);
        return false;
      },
    );

    // The point sits in the padding ring outside the drawn circle: the
    // old inkwell surface left that ring dead, and a tap there pressed
    // nothing. Registering on touch down also means the press lands
    // before the finger ever lifts.
    final Offset edge = tester.getCenter(find.text('1')) + const Offset(0, -44);
    final TestGesture gesture = await tester.startGesture(edge);
    await tester.pump();
    await gesture.up();
    await tester.pump();

    for (final digit in ['2', '3', '4']) {
      await tapKey(tester, digit);
    }
    expect(submitted, ['1234']);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a fast verdict still waits for the dot entrance', (
    tester,
  ) async {
    final ValueNotifier<int> attempts = ValueNotifier<int>(0);
    addTearDown(attempts.dispose);
    await pumpPad(
      tester,
      attempts: attempts,
      verify: (_) => Future<bool>.value(false),
    );

    for (final digit in '1593'.split('')) {
      await tapKey(tester, digit);
    }
    // The stub verdict resolves immediately, but the entrance gate
    // holds the failure back: within the entrance window nothing has
    // landed yet.
    await tester.pump(const Duration(milliseconds: 100));
    expect(attempts.value, 0);
    expect(find.textContaining('PIN 不正确'), findsNothing);

    // Past the entrance the verdict applies.
    await tester.pump(const Duration(milliseconds: 200));
    expect(attempts.value, 1);
    expect(find.textContaining('PIN 不正确'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
