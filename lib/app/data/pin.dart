import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// Salted, versioned hashing for the app pin.
///
/// The pin used to live in the settings store as plain text, so anyone
/// with the preference file (a backup, a synced export, a rooted device)
/// read the unlock code itself. Pins are now stored as
/// `e1547pin1$<iterations>$<salt>$<hash>` with PBKDF2-HMAC-SHA256.
///
/// # Migration
///
/// [verifyPin] still accepts the legacy plain text values, so existing
/// installations keep working. The lock screen upgrades a verified
/// legacy pin to the hashed form in place, which spreads the one time
/// derivation cost over the unlock attempts users actually make.
///
/// # Iteration count
///
/// 30k iterations cost clearly under a second even on the Android 7
/// class of hardware this fork targets, while pushing offline guessing
/// of a four digit pin from instant to hours per file.
/// Whether the lock screen currently covers the app.
///
/// The lock screen is not a route, so shortcuts that pop routes cannot
/// see it; they read this flag instead to stay inert while the lock is
/// up.
final ValueNotifier<bool> appLocked = ValueNotifier(false);

const String pinHashPrefix = 'e1547pin1';
const int pinHashIterations = 30000;
const int _saltLength = 16;

/// Smallest parameters a stored hash may carry and still verify.
///
/// A record that slips past these bounds (an empty or truncated hash
/// segment, a near empty salt, a token iteration count) is treated as
/// corrupt rather than trusted: without the floor an empty expected
/// hash would verify any pin in release builds, where the package's
/// own debug asserts no longer guard the derivation.
const int _minIterations = 1000;
const int _minSaltLength = 8;
const int _minHashLength = 32;

Pbkdf2 _kdfFor(int iterations, int bits) =>
    Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: bits);

/// Whether [stored] is a hashed pin rather than a legacy plain text one.
bool isPinHash(String stored) => stored.startsWith('$pinHashPrefix\$');

/// Hashes [pin] into the versioned storage format.
///
/// The derivation runs on a background isolate: thirty thousand
/// PBKDF2 rounds block the ui isolate for a visible fraction of a
/// second on the low end hardware this fork targets.
Future<String> hashPin(String pin) async {
  final salt = _randomBytes(_saltLength);
  final bytes = await Isolate.run(() async {
    final kdf = _kdfFor(pinHashIterations, 256);
    final key = await kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return key.extractBytes();
  });
  return [
    pinHashPrefix,
    '$pinHashIterations',
    base64Encode(salt),
    base64Encode(bytes),
  ].join(r'$');
}

/// The iteration count recorded in a hashed pin, or null for a legacy
/// plain text pin.
///
/// Callers use this to rehash a stored pin whose cost factor has since
/// been raised, instead of leaving old hashes at their old strength
/// forever.
int? pinHashIterationsOf(String stored) {
  if (!isPinHash(stored)) return null;
  return int.tryParse(stored.split(r'$')[1]);
}

/// Verifies [pin] against the stored value.
///
/// Hashed values derive the candidate with the stored salt and
/// iteration count and compare in constant time. Legacy plain text
/// values compare directly; the caller upgrades them via [hashPin]
/// once the verification succeeded.
Future<bool> verifyPin(String pin, String stored) async {
  if (!isPinHash(stored)) {
    return pin == stored;
  }
  final parts = stored.split(r'$');
  if (parts.length != 4) return false;
  final int? iterations = int.tryParse(parts[1]);
  if (iterations == null || iterations < _minIterations) return false;
  final Uint8List salt;
  final Uint8List expected;
  try {
    salt = base64Decode(parts[2]);
    expected = base64Decode(parts[3]);
  } on FormatException {
    return false;
  }
  // A record below these floors is corrupt or forged, never valid:
  // with an empty expected hash the derivation would yield an empty
  // key and compare equal to itself, silently unlocking for any pin.
  if (salt.length < _minSaltLength || expected.length < _minHashLength) {
    return false;
  }
  final actual = await Isolate.run(() async {
    final kdf = _kdfFor(iterations, expected.length * 8);
    final key = await kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return key.extractBytes();
  });
  return _constantTimeEquals(actual, expected);
}

/// Lockout policy for failed pin attempts.
///
/// The first failures stay free so a genuine typo costs nothing; from
/// the third onwards the wait doubles, capped at a minute. The counter
/// persists in the settings store, so restarting the app does not
/// reset the price of guessing.
abstract final class PinBackoff {
  /// Free attempts before waiting starts.
  static const int freeAttempts = 2;
  static const int _baseSeconds = 4;
  static const int _capSeconds = 60;

  /// The longest cooldown the policy hands out.
  ///
  /// Consumers clamp persisted timestamps against this, so a device
  /// clock set backwards cannot stretch a cooldown beyond what a
  /// correct run could have produced.
  static const Duration maxDelay = Duration(seconds: _capSeconds);

  /// How long to wait after [failures] consecutive wrong pins.
  ///
  /// The shift is clamped before it happens: a naive `1 << (failures)`
  /// overflows the 64 bit int for absurd failure counts and would hand
  /// out a zero wait instead of the cap.
  static Duration delayFor(int failures) {
    if (failures <= freeAttempts) return Duration.zero;
    final int exponent = min(failures - freeAttempts, 8);
    final seconds = _baseSeconds * (1 << (exponent - 1));
    return Duration(seconds: min(_capSeconds, seconds));
  }
}

/// Cryptographically secure random bytes for salts.
Uint8List _randomBytes(int length) {
  final random = Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (_) => random.nextInt(256)),
  );
}

/// Length independent constant time comparison.
///
/// Empty inputs never compare equal: an empty stored hash would
/// otherwise match an empty derivation and verify any pin.
bool _constantTimeEquals(List<int> a, List<int> b) {
  if (a.isEmpty || b.isEmpty) return false;
  int diff = a.length ^ b.length;
  for (int i = 0; i < a.length && i < b.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
