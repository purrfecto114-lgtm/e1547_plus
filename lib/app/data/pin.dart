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
/// 30k keeps the cold-start unlock snappy: the 150k this fork briefly
/// tried cost about a second and a half on low end hardware, and the
/// user judged the wait not worth it. Against a four digit space no
/// affordable count buys real safety anyway: a single GPU still sweeps
/// the whole space in seconds at either cost factor. The pin lock is
/// a shoulder-surfing defense; the offline guesser is meant to be
/// stopped by the hash never leaving the device (backup exclusions)
/// and the on-screen backoff, not by the KDF alone. Records hashed at
/// another cost are realigned by [needsRehash] on their next verify.

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

// Session cache of the last verified derivation. Unlocks repeat within
// one app session (resume, quick returns) without paying the derivation
// again; the cold start still runs the full cost. The stored file does
// not change — an offline attacker sees the same hash as before. The
// entry carries the record's own parameters and the comparison always
// runs against the stored hash itself, so a re-set pin (fresh salt) or
// a forged record (tampered iteration field) misses by construction.
class _SessionVerification {
  const _SessionVerification(
    this.pin,
    this.iterations,
    this.salt,
    this.derivation,
  );

  final String pin;
  final int iterations;
  final Uint8List salt;
  final Uint8List derivation;
}

_SessionVerification? _session;

/// Drops the session verification cache, e.g. when the pin is removed:
/// the remembered pin and its derivation must not outlive the lock.
void clearSessionVerification() {
  _session = null;
}

/// Whether [stored] is a hashed pin rather than a legacy plain text one.
bool isPinHash(String stored) => stored.startsWith('$pinHashPrefix\$');

/// Hashes [pin] into the versioned storage format.
///
/// The derivation runs on a background isolate: the PBKDF2 rounds block
/// the ui isolate for about a second on the low end hardware this fork
/// targets.
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
  // Setting a pin is a verification-equivalent derivation: caching it
  // makes the very first unlock after a change instant too.
  _session = _SessionVerification(
    pin,
    pinHashIterations,
    salt,
    Uint8List.fromList(bytes),
  );
  return [
    pinHashPrefix,
    '$pinHashIterations',
    base64Encode(salt),
    base64Encode(bytes),
  ].join(r'$');
}

/// The iteration count recorded in a hashed pin, or null for a legacy
/// plain text pin.
int? pinHashIterationsOf(String stored) {
  if (!isPinHash(stored)) return null;
  return int.tryParse(stored.split(r'$')[1]);
}

/// Whether a stored pin should be rehashed once it verifies.
///
/// True for legacy plain text values and for any hashed record whose
/// cost is not the current default — recentering works both ways, so
/// a record from a costlier era of the iteration constant comes down
/// to today's default instead of pinning its user to the old wait.
bool needsRehash(String stored) =>
    pinHashIterationsOf(stored) != pinHashIterations;

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
  final _SessionVerification? cached = _session;
  if (cached != null &&
      cached.pin == pin &&
      cached.iterations == iterations &&
      _constantTimeEquals(cached.salt, salt) &&
      _constantTimeEquals(cached.derivation, expected)) {
    // Same pin, same record parameters, same stored hash: the stored
    // hash is part of the comparison even here, so a pin remembered
    // under an older record never re-validates against a new one.
    return true;
  }
  final actual = await Isolate.run(() async {
    final kdf = _kdfFor(iterations, expected.length * 8);
    final key = await kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return key.extractBytes();
  });
  final bool match = _constantTimeEquals(actual, expected);
  if (match) {
    _session = _SessionVerification(
      pin,
      iterations,
      salt,
      Uint8List.fromList(actual),
    );
  }
  return match;
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

  /// The wall clock stamp the [failures]-th failure should leave behind.
  ///
  /// The stamp is a ratchet: a previous stamp still in the future (a
  /// clock that was pushed forward when it was written) survives the
  /// next failure instead of being pulled back, while one already in
  /// the past (the wait ran out) is replaced by the fresh wait.
  static int nextUntil(int? previous, int failures, DateTime now) {
    final fresh = now.add(delayFor(failures)).millisecondsSinceEpoch;
    if (previous == null || previous <= 0) return fresh;
    return previous > fresh ? previous : fresh;
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
