import 'dart:io';

import 'package:e1547/logs/logs.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';

/// The state of the device's biometric hardware.
enum BiometricAvailability {
  /// The device offers no usable biometric hardware.
  none,

  /// Biometric hardware exists, but nothing is enrolled on it yet.
  unenrolled,

  /// Biometric hardware exists and carries at least one enrolled print.
  ready,
}

/// androidx.biometric's canAuthenticate success code.
const int _biometricSuccess = 0;

/// Probes the biometric state for the settings page.
///
/// local_auth answers through androidx.biometric, whose probe collapses
/// several legacy failure modes into "no biometrics": on older android
/// releases it can report an empty device even when the fingerprint
/// reader holds enrolled prints. The plugin result is therefore
/// cross-checked against a direct probe on the android side, and the most
/// optimistic consistent answer wins.
///
/// The native fallback reports every signal it can reach — the
/// compatibility fingerprint probes and the androidx biometric codes —
/// with each signal isolated, because older OEM builds guard parts of the
/// fingerprint service and one throwing probe must not erase the rest.
/// The fallback only sees fingerprints: on a device whose sole biometric
/// sensor is face or iris, and where the plugin probe fails as well, the
/// answer degrades to [BiometricAvailability.unenrolled] and the switch
/// stays off, which is safe, just conservative.
///
/// Every layer's answer is logged, so a device that still ends up
/// reporting no biometrics carries the reason in the log page.
///
/// The [android] override exists for the tests, which run on the host
/// platform but exercise the android fallback path.
///
/// The merge takes the most optimistic answer of every signal: the
/// plugin's, the compatibility booleans', the androidx codes' and the
/// framework manager's. The framework signals matter because the
/// compatibility layer can stop answering entirely — androidx.core turned
/// FingerprintManagerCompat into a no-op that always reports false, which
/// disabled every compat-based probe, local_auth's included, on the old
/// releases that still route through the fingerprint service.
Future<BiometricAvailability> biometricAvailability({bool? android}) async {
  final Logger log = Logger('biometrics');
  final bool onAndroid = android ?? Platform.isAndroid;
  bool hardware = false;
  bool enrolled = false;
  try {
    final LocalAuthentication localAuth = LocalAuthentication();
    // canCheckBiometrics asks whether the device could do biometrics at
    // all, which stays true when prints were merely removed again.
    hardware = await localAuth.canCheckBiometrics;
    enrolled = (await localAuth.getAvailableBiometrics()).isNotEmpty;
  } on Object catch (error, stackTrace) {
    // a failed plugin probe must not hide what the fallback finds below
    log.warn(
      'the local_auth probe failed',
      {'hardware': hardware, 'enrolled': enrolled},
      error,
      stackTrace,
    );
  }
  if (onAndroid) {
    try {
      final Map<Object?, Object?>? state = await const MethodChannel(
        'e1547/biometrics',
      ).invokeMethod<Map<Object?, Object?>>('fingerprintState');
      if (state != null) {
        bool? flag(Object? key) => switch (state[key]) {
          bool value => value,
          _ => null,
        };
        int? code(Object? key) => switch (state[key]) {
          int value => value,
          _ => null,
        };
        final int enrolledCount = code('enrolledCount') ?? 0;
        final int weak = code('weak') ?? -1;
        final int strong = code('strong') ?? -1;
        final bool frameworkHardware = flag('frameworkHardware') == true;
        final bool frameworkEnrolled = flag('frameworkEnrolled') == true;
        final bool nativeHardware =
            flag('hardware') == true ||
            weak == _biometricSuccess ||
            frameworkHardware;
        final bool nativeEnrolled =
            flag('enrolled') == true ||
            enrolledCount > 0 ||
            weak == _biometricSuccess ||
            strong == _biometricSuccess ||
            frameworkEnrolled;
        hardware = hardware || nativeHardware;
        enrolled = enrolled || nativeEnrolled;
        log.info('the native fingerprint probe answered', {
          'hardware': hardware,
          'enrolled': enrolled,
          'nativeHardware': nativeHardware,
          'nativeEnrolled': nativeEnrolled,
          'frameworkHardware': frameworkHardware,
          'frameworkEnrolled': frameworkEnrolled,
          'enrolledCount': enrolledCount,
          'weak': weak,
          'strong': strong,
        });
      }
    } on Object catch (error, stackTrace) {
      // no native handler (tests, unsupported builds); the plugin's
      // answer stands on its own
      log.warn('the native fingerprint probe failed', null, error, stackTrace);
    }
  }
  final BiometricAvailability availability = enrolled
      ? BiometricAvailability.ready
      : hardware
      ? BiometricAvailability.unenrolled
      : BiometricAvailability.none;
  log.info('the biometric probe concluded', {
    'availability': availability.name,
  });
  return availability;
}

/// Keeps the biometric state current over the app's whole lifetime.
///
/// Enrollment lives in the system settings, so it changes behind the
/// app's back: prints removed (or added) while the app sat in the
/// background used to leave a stale answer in place, and the lock screen
/// went on offering a shortcut the sensor could no longer honor. The
/// answer is therefore re-probed when the app returns to the foreground,
/// the one moment the change can have happened.
///
/// The value starts at null, which reads as "unknown" rather than
/// "absent": consumers treat it as the conservative answer until the
/// first probe lands.
///
/// The `probe` override exists for the tests, which cannot reach a
/// fingerprint sensor from the host platform.
class BiometricsWatcher extends ValueNotifier<BiometricAvailability?>
    with WidgetsBindingObserver {
  BiometricsWatcher({Future<BiometricAvailability> Function()? probe})
    : _probe = probe ?? biometricAvailability,
      super(null) {
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  final Future<BiometricAvailability> Function() _probe;

  int _pending = 0;

  /// Probes the device again and publishes the answer.
  ///
  /// A probe that lands after a newer one started still carries the
  /// older answer, so it must not overwrite the fresher one.
  Future<void> refresh() async {
    final int stamp = ++_pending;
    final BiometricAvailability availability = await _probe();
    if (stamp == _pending) value = availability;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
