import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';

// Mirrors the documented version 1 layout of export_crypto.dart.
const int _magicLength = databaseExportMagic.length; // 8
const int _versionOffset = _magicLength; // 8
const int _saltStart = _magicLength + 1; // 9
const int _saltLength = 16;
const int _nonceLength = 12;
const int _headerLength = _saltStart + _saltLength + _nonceLength; // 37
const int _tagLength = 16;

Uint8List _payload(int length) {
  final random = Uint8List(length);
  for (int i = 0; i < length; i++) {
    random[i] = i % 251;
  }
  return random;
}

void main() {
  group('encryptDatabaseExport / decryptDatabaseExport', () {
    test('round trips a small payload', () async {
      final plain = _payload(64);
      final encrypted = await encryptDatabaseExport(plain, 'hunter2');
      final decrypted = await decryptDatabaseExport(encrypted, 'hunter2');
      expect(decrypted, plain);
    });

    test('round trips a database sized payload', () async {
      final plain = _payload(1024 * 1024);
      final encrypted = await encryptDatabaseExport(plain, 'hunter2');
      final decrypted = await decryptDatabaseExport(encrypted, 'hunter2');
      expect(decrypted, plain);
    });

    test('handles an empty payload', () async {
      final encrypted = await encryptDatabaseExport(Uint8List(0), 'hunter2');
      final decrypted = await decryptDatabaseExport(encrypted, 'hunter2');
      expect(decrypted, isEmpty);
    });

    test(
      'a wrong password fails the tag check instead of yielding garbage',
      () async {
        final encrypted = await encryptDatabaseExport(_payload(128), 'hunter2');
        await expectLater(
          decryptDatabaseExport(encrypted, 'hunter3'),
          throwsA(isA<SecretBoxAuthenticationError>()),
        );
      },
    );

    test('a corrupted ciphertext byte fails the tag check', () async {
      final encrypted = await encryptDatabaseExport(_payload(128), 'hunter2');
      encrypted[_headerLength + 3] ^= 0xFF;
      await expectLater(
        decryptDatabaseExport(encrypted, 'hunter2'),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('a corrupted mac byte fails the tag check', () async {
      final encrypted = await encryptDatabaseExport(_payload(128), 'hunter2');
      encrypted[encrypted.length - 1] ^= 0xFF;
      await expectLater(
        decryptDatabaseExport(encrypted, 'hunter2'),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('a corrupted salt derives the wrong key and fails', () async {
      final encrypted = await encryptDatabaseExport(_payload(128), 'hunter2');
      encrypted[_saltStart] ^= 0xFF;
      await expectLater(
        decryptDatabaseExport(encrypted, 'hunter2'),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('rejects files that are not encrypted exports', () async {
      expect(
        () => decryptDatabaseExport(_payload(64), 'hunter2'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => decryptDatabaseExport(Uint8List(0), 'hunter2'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a wrong magic', () async {
      final encrypted = await encryptDatabaseExport(_payload(128), 'hunter2');
      encrypted[0] = 0x58; // 'X'
      expect(
        () => decryptDatabaseExport(encrypted, 'hunter2'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an unsupported format version', () async {
      final encrypted = await encryptDatabaseExport(_payload(128), 'hunter2');
      encrypted[_versionOffset] = 0x99;
      expect(
        () => decryptDatabaseExport(encrypted, 'hunter2'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects truncated files', () async {
      final encrypted = await encryptDatabaseExport(_payload(128), 'hunter2');
      // Every truncation must throw rather than decrypt into something
      // unvalidated.
      for (final length in [0, 8, 9, 24, 25, 36, 37, encrypted.length - 17]) {
        expect(
          () => decryptDatabaseExport(encrypted.sublist(0, length), 'hunter2'),
          throwsA(
            anyOf(isA<FormatException>(), isA<SecretBoxAuthenticationError>()),
          ),
          reason: 'truncation to $length bytes must fail',
        );
      }
    });

    test('uses a fresh salt and nonce per export', () async {
      final plain = _payload(32);
      final a = await encryptDatabaseExport(plain, 'hunter2');
      final b = await encryptDatabaseExport(plain, 'hunter2');
      expect(a, isNot(b));
      // Same plaintext, different random salt and nonce.
      expect(
        a.sublist(_saltStart, _saltStart + _saltLength),
        isNot(equals(b.sublist(_saltStart, _saltStart + _saltLength))),
      );
      const nonceStart = _saltStart + _saltLength;
      expect(
        a.sublist(nonceStart, nonceStart + _nonceLength),
        isNot(equals(b.sublist(nonceStart, nonceStart + _nonceLength))),
      );
      // Both still decrypt to the same plaintext.
      expect(await decryptDatabaseExport(a, 'hunter2'), plain);
      expect(await decryptDatabaseExport(b, 'hunter2'), plain);
    });

    test('emits the documented version 1 layout', () async {
      final encrypted = await encryptDatabaseExport(_payload(10), 'hunter2');
      // 8 magic + 1 version + 16 salt + 12 nonce + 10 ciphertext + 16 tag
      expect(encrypted, hasLength(_headerLength + 10 + _tagLength));
      expect(encrypted.sublist(0, 8), 'E1547ENC'.codeUnits);
      expect(encrypted[_versionOffset], databaseExportFormatVersion);
      expect(hasDatabaseExportMagic(encrypted), isTrue);
    });

    test('magic detection respects short inputs', () {
      expect(hasDatabaseExportMagic('E1547ENC'.codeUnits), isTrue);
      expect(hasDatabaseExportMagic('E1547EN'.codeUnits), isFalse);
      expect(hasDatabaseExportMagic('XXXXXXXX'.codeUnits), isFalse);
      expect(hasDatabaseExportMagic(const <int>[]), isFalse);
    });

    test('passwords outside ascii survive', () async {
      final plain = _payload(48);
      const password = ' 密码 passphrase 🔐 ';
      final encrypted = await encryptDatabaseExport(plain, password);
      expect(await decryptDatabaseExport(encrypted, password), plain);
      await expectLater(
        decryptDatabaseExport(encrypted, ' 密码 passphrase 🔒 '),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });
  });
}
