import 'dart:io';

import 'package:flutter/services.dart';
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

/// Probes the biometric state for the settings page.
///
/// local_auth answers through androidx.biometric, whose probe collapses
/// several legacy failure modes into "no biometrics": on older android
/// releases it can report an empty device even when the fingerprint
/// reader holds enrolled prints. The plugin result is therefore
/// cross-checked against a direct FingerprintManagerCompat probe on the
/// android side, and the most optimistic consistent answer wins.
///
/// The native fallback only sees fingerprints: on a device whose sole
/// biometric sensor is face or iris, and where the plugin probe fails as
/// well, the answer degrades to [BiometricAvailability.unenrolled] and the
/// switch stays off, which is safe, just conservative.
///
/// The [android] override exists for the tests, which run on the host
/// platform but exercise the android fallback path.
Future<BiometricAvailability> biometricAvailability({bool? android}) async {
  final bool onAndroid = android ?? Platform.isAndroid;
  bool hardware = false;
  bool enrolled = false;
  try {
    final LocalAuthentication localAuth = LocalAuthentication();
    // canCheckBiometrics asks whether the device could do biometrics at
    // all, which stays true when prints were merely removed again.
    hardware = await localAuth.canCheckBiometrics;
    enrolled = (await localAuth.getAvailableBiometrics()).isNotEmpty;
  } on Object {
    // a failed plugin probe must not hide what the fallback finds below
  }
  if (onAndroid) {
    try {
      final Map<Object?, Object?>? state = await const MethodChannel(
        'e1547/biometrics',
      ).invokeMethod<Map<Object?, Object?>>('fingerprintState');
      if (state != null) {
        hardware = hardware || state['hardware'] == true;
        enrolled = enrolled || state['enrolled'] == true;
      }
    } on Object {
      // no native handler (tests, unsupported builds); the plugin's
      // answer stands on its own
    }
  }
  if (enrolled) return BiometricAvailability.ready;
  if (hardware) return BiometricAvailability.unenrolled;
  return BiometricAvailability.none;
}
