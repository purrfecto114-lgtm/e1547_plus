import 'package:e1547/app/app.dart';
import 'package:flutter/services.dart';
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
  });

  test('a host platform without biometrics stays unavailable', () async {
    // android: false keeps the native probe out; the linux plugin probe
    // runs and answers on the host.
    expect(
      await biometricAvailability(android: false),
      BiometricAvailability.none,
    );
  });
}
