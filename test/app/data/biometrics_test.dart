import 'dart:async';

import 'package:e1547/app/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

/// A plugin probe whose answers the tests fully control.
class _FakeLocalAuth extends LocalAuthPlatform {
  _FakeLocalAuth({this.hardware = false, this.enrolled = const []});

  final bool hardware;
  final List<BiometricType> enrolled;

  @override
  Future<bool> deviceSupportsBiometrics() async => hardware;

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async => enrolled;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalAuthPlatform original;

  setUp(() => original = LocalAuthPlatform.instance);
  tearDown(() {
    LocalAuthPlatform.instance = original;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('e1547/biometrics'),
          null,
        );
  });

  void mockNative({bool hardware = false, bool enrolled = false}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('e1547/biometrics'), (
          call,
        ) async {
          if (call.method == 'fingerprintState') {
            return {'hardware': hardware, 'enrolled': enrolled};
          }
          return null;
        });
  }

  group('biometricAvailability on android', () {
    test(
      'enrolled prints win even when the plugin probe reports none',
      () async {
        // The legacy-device case: androidx.biometric collapses several
        // failure modes into "no biometrics", while the reader holds
        // enrolled prints. The native fallback must rescue the toggle.
        LocalAuthPlatform.instance = _FakeLocalAuth();
        mockNative(hardware: true, enrolled: true);
        expect(
          await biometricAvailability(android: true),
          BiometricAvailability.ready,
        );
      },
    );

    test('hardware without enrollment asks for a print first', () async {
      LocalAuthPlatform.instance = _FakeLocalAuth(hardware: true);
      mockNative(hardware: true);
      expect(
        await biometricAvailability(android: true),
        BiometricAvailability.unenrolled,
      );
    });

    test('a plugin-detected enrollment needs no fallback', () async {
      LocalAuthPlatform.instance = _FakeLocalAuth(
        hardware: true,
        enrolled: [BiometricType.fingerprint],
      );
      mockNative();
      expect(
        await biometricAvailability(android: true),
        BiometricAvailability.ready,
      );
    });

    test('absent hardware stays unavailable on both paths', () async {
      LocalAuthPlatform.instance = _FakeLocalAuth();
      mockNative();
      expect(
        await biometricAvailability(android: true),
        BiometricAvailability.none,
      );
    });

    test('a failing native probe falls back to the plugin answer', () async {
      LocalAuthPlatform.instance = _FakeLocalAuth(hardware: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('e1547/biometrics'),
            (call) async => throw MissingPluginException(),
          );
      expect(
        await biometricAvailability(android: true),
        BiometricAvailability.unenrolled,
      );
    });

    test(
      'enrollment is read from every native signal, not only the booleans',
      () async {
        // Legacy OEM builds can answer false through the compatibility
        // booleans while the androidx codes and the enrolled count still
        // tell the truth: the merged answer must take any one of them.
        LocalAuthPlatform.instance = _FakeLocalAuth();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('e1547/biometrics'),
              (call) async => {
                'hardware': false,
                'enrolled': false,
                'enrolledCount': 2,
                'weak': 0,
                'strong': 0,
              },
            );
        expect(
          await biometricAvailability(android: true),
          BiometricAvailability.ready,
        );
      },
    );

    test(
      'the framework manager rescues the probe when compat answers nothing',
      () async {
        // androidx.core 1.18 turned FingerprintManagerCompat into a no-op
        // that always reports false, which also feeds androidx.biometric's
        // codes on android 9 and older: every compat-based signal answers
        // an empty device while the reader holds enrolled prints. The
        // framework manager still asks the hardware directly, and its
        // answer must carry the toggle on its own.
        LocalAuthPlatform.instance = _FakeLocalAuth();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('e1547/biometrics'),
              (call) async => {
                'hardware': false,
                'enrolled': false,
                'frameworkHardware': true,
                'frameworkEnrolled': true,
                // An OEM build can guard the enrolled print list while the
                // booleans still answer, so the count may stay unknown.
                'enrolledCount': 0,
                // No biometrics / hardware unavailable.
                'weak': 12,
                'strong': 12,
              },
            );
        expect(
          await biometricAvailability(android: true),
          BiometricAvailability.ready,
        );
      },
    );

    test(
      'framework hardware without enrollment still asks for a print',
      () async {
        LocalAuthPlatform.instance = _FakeLocalAuth();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('e1547/biometrics'),
              (call) async => {
                'hardware': false,
                'enrolled': false,
                'frameworkHardware': true,
                'frameworkEnrolled': false,
                'enrolledCount': 0,
                'weak': 12,
                'strong': 12,
              },
            );
        expect(
          await biometricAvailability(android: true),
          BiometricAvailability.unenrolled,
        );
      },
    );
  });

  test('a host platform without biometrics stays unavailable', () async {
    // android: false keeps the native probe out; the linux plugin probe
    // runs and answers on the host.
    expect(
      await biometricAvailability(android: false),
      BiometricAvailability.none,
    );
  });

  group('BiometricsWatcher', () {
    testWidgets(
      'the watcher re-probes when the app returns to the foreground',
      (tester) async {
        // Enrollment changes in the system settings while the app sits
        // in the background: the foreground return is the moment the
        // stored answer can have gone stale, so it must be re-probed.
        int calls = 0;
        final watcher = BiometricsWatcher(
          probe: () async => switch (calls++) {
            0 => BiometricAvailability.none,
            1 => BiometricAvailability.ready,
            _ => BiometricAvailability.unenrolled,
          },
        );
        addTearDown(watcher.dispose);

        await tester.pump();
        expect(watcher.value, BiometricAvailability.none);
        expect(calls, 1);

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        expect(calls, 1, reason: 'hiding the app changes nothing');

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        expect(calls, 2);
        expect(watcher.value, BiometricAvailability.ready);
      },
    );

    testWidgets('a stale probe never overwrites a newer answer', (
      tester,
    ) async {
      // Two probes in flight at once: the foreground return fires a
      // second probe while the first one is still waiting, and the
      // slower older answer must lose.
      final pending = <Completer<BiometricAvailability>>[];
      final watcher = BiometricsWatcher(
        probe: () {
          final completer = Completer<BiometricAvailability>();
          pending.add(completer);
          return completer.future;
        },
      );
      addTearDown(watcher.dispose);

      expect(watcher.value, isNull);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(pending.length, 2);

      pending.first.complete(BiometricAvailability.ready);
      await tester.pump();
      expect(watcher.value, isNull, reason: 'the newer probe is still out');

      pending.last.complete(BiometricAvailability.unenrolled);
      await tester.pump();
      expect(watcher.value, BiometricAvailability.unenrolled);
    });
  });
}
