import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Password-based encryption for database exports.
///
/// # Format (version 1)
///
/// ```text
/// offset  size  field
/// 0       8     ASCII magic "E1547ENC"
/// 8       1     format version, currently 0x01
/// 9       16    PBKDF2 salt, random
/// 25      12    AES-GCM nonce, random
/// 37      rest  AES-256-GCM ciphertext, followed by the 16 byte tag
/// ```
///
/// # Design notes
///
/// - AES-256-GCM provides confidentiality *and* integrity: a wrong password
///   or a corrupted file fails the tag check instead of yielding garbage.
/// - The key is derived with PBKDF2-HMAC-SHA256. 150k iterations are a
///   compromise between brute force resistance and the pure Dart cost on
///   older phones (well under a second on recent hardware).
/// - A fresh random salt per export prevents precomputation across files;
///   a fresh random nonce per export prevents nonce reuse within one key.
/// - The magic header lets the import detect encrypted files before sqlite
///   tries to parse them, so the user is asked for the password instead of
///   receiving a misleading "not an e1547 database" error.
const String databaseExportMagic = 'E1547ENC';
const int databaseExportFormatVersion = 1;

const int _saltLength = 16;
const int _nonceLength = 12;
const int _headerLength =
    databaseExportMagic.length + 1 + _saltLength + _nonceLength;

final AesGcm _cipher = AesGcm.with256bits();
final Pbkdf2 _kdf = Pbkdf2(
  macAlgorithm: Hmac.sha256(),
  iterations: 150000,
  bits: 256,
);

/// Whether [bytes] starts with the encrypted database export header.
bool hasDatabaseExportMagic(List<int> bytes) {
  if (bytes.length < databaseExportMagic.length) return false;
  for (int i = 0; i < databaseExportMagic.length; i++) {
    if (bytes[i] != databaseExportMagic.codeUnitAt(i)) return false;
  }
  return true;
}

/// Encrypts [plaintext] with [password] into the version 1 export format.
Future<Uint8List> encryptDatabaseExport(
  Uint8List plaintext,
  String password,
) async {
  final salt = _randomBytes(_saltLength);
  final nonce = _cipher.newNonce();
  final key = await _deriveKey(password, salt);
  final box = await _cipher.encrypt(plaintext, secretKey: key, nonce: nonce);

  final builder = BytesBuilder();
  builder.add(ascii.encode(databaseExportMagic));
  builder.addByte(databaseExportFormatVersion);
  builder.add(salt);
  builder.add(nonce);
  builder.add(box.cipherText);
  builder.add(box.mac.bytes);
  return builder.toBytes();
}

/// Decrypts an export produced by [encryptDatabaseExport].
///
/// Throws a [FormatException] when the header is not an encrypted database
/// export, and lets the cipher's [SecretBoxAuthenticationError] bubble up
/// when the password is wrong or the file is corrupted.
Future<Uint8List> decryptDatabaseExport(
  Uint8List encrypted,
  String password,
) async {
  final magic = ascii.encode(databaseExportMagic);
  if (encrypted.length < _headerLength || !hasDatabaseExportMagic(encrypted)) {
    throw const FormatException('Not an encrypted database export');
  }
  if (encrypted[magic.length] != databaseExportFormatVersion) {
    throw FormatException(
      'Unsupported export format version ${encrypted[magic.length]}',
    );
  }

  final salt = encrypted.sublist(
    magic.length + 1,
    magic.length + 1 + _saltLength,
  );
  final nonceStart = magic.length + 1 + _saltLength;
  final nonce = encrypted.sublist(nonceStart, nonceStart + _nonceLength);
  final data = encrypted.sublist(_headerLength);
  // The tag is the trailing 16 bytes; the package splits both from the
  // concatenated byte range itself.
  if (data.length < 16) {
    throw const FormatException('Encrypted database export is truncated');
  }
  final cipherText = data.sublist(0, data.length - 16);
  final mac = Mac(data.sublist(data.length - 16));

  final key = await _deriveKey(password, salt);
  final plain = await _cipher.decrypt(
    SecretBox(cipherText, nonce: nonce, mac: mac),
    secretKey: key,
  );
  return Uint8List.fromList(plain);
}

Future<SecretKey> _deriveKey(String password, List<int> salt) =>
    _kdf.deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);

/// Cryptographically secure random bytes for salts.
Uint8List _randomBytes(int length) {
  final random = Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (_) => random.nextInt(256)),
  );
}
