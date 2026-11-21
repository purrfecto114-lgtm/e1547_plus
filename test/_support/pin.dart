import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:e1547/app/app.dart';
import 'package:flutter/foundation.dart';

/// Hashes [pin] at an explicit cost, building a record from another
/// era of the iteration constant: rehash tests use it to prove the
/// lock realigns whatever it verifies with the current default.
Future<String> hashPinAt(String pin, {required int iterations}) async {
  final salt = Uint8List.fromList(
    List.generate(16, (_) => Random.secure().nextInt(256)),
  );
  final kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: 256,
  );
  final key = await kdf.deriveKey(
    secretKey: SecretKey(utf8.encode(pin)),
    nonce: salt,
  );
  final bytes = await key.extractBytes();
  return [
    pinHashPrefix,
    '$iterations',
    base64Encode(salt),
    base64Encode(bytes),
  ].join(r'$');
}
