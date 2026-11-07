import 'package:e1547/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hashPin / verifyPin', () {
    test('round trip accepts the correct pin', () async {
      final stored = await hashPin('1234');
      expect(await verifyPin('1234', stored), isTrue);
    });

    test('rejects a wrong pin', () async {
      final stored = await hashPin('1234');
      expect(await verifyPin('0000', stored), isFalse);
      expect(await verifyPin('12345', stored), isFalse);
      expect(await verifyPin('', stored), isFalse);
    });

    test('hashes differ across salts for the same pin', () async {
      final a = await hashPin('9999');
      final b = await hashPin('9999');
      expect(a, isNot(b));
      expect(await verifyPin('9999', a), isTrue);
      expect(await verifyPin('9999', b), isTrue);
    });

    test('stored format is versioned and self describing', () async {
      final stored = await hashPin('1357');
      final parts = stored.split(r'$');
      expect(parts, hasLength(4));
      expect(parts[0], pinHashPrefix);
      expect(int.parse(parts[1]), pinHashIterations);
      expect(isPinHash(stored), isTrue);
    });

    test('legacy plain text pins still verify', () async {
      expect(await verifyPin('2468', '2468'), isTrue);
      expect(await verifyPin('0000', '2468'), isFalse);
      expect(isPinHash('2468'), isFalse);
    });

    test('tampered hash storage fails closed', () async {
      final stored = await hashPin('1234');
      final parts = stored.split(r'$');
      // A flipped hash byte must not verify.
      final hash = parts[3];
      final flipped =
          (hash.codeUnitAt(0) == 'A'.codeUnitAt(0) ? 'B' : 'A') +
          hash.substring(1);
      expect(
        await verifyPin(
          '1234',
          [parts[0], parts[1], parts[2], flipped].join(r'$'),
        ),
        isFalse,
      );
      // A corrupted salt must not verify either.
      expect(
        await verifyPin(
          '1234',
          [
            parts[0],
            parts[1],
            if (parts[2] == 'AAAA') 'AAAB' else 'AAAA',
            parts[3],
          ].join(r'$'),
        ),
        isFalse,
      );
      // A broken iteration count fails closed.
      expect(
        await verifyPin(
          '1234',
          [parts[0], 'NaN', parts[2], parts[3]].join(r'$'),
        ),
        isFalse,
      );
      // A truncated record fails closed.
      expect(await verifyPin('1234', '$pinHashPrefix\$30000'), isFalse);
      // Broken base64 fails closed.
      expect(
        await verifyPin(
          '1234',
          [parts[0], parts[1], '!!!!', parts[3]].join(r'$'),
        ),
        isFalse,
      );
    });

    test('a mismatched iteration count fails closed', () async {
      // The hash was derived with 30k iterations, so verifying with a
      // 1000 iteration derivation produces a different key and fails.
      final stored = await hashPin('1234');
      final parts = stored.split(r'$');
      final lowered = [parts[0], '1000', parts[2], parts[3]].join(r'$');
      expect(await verifyPin('1234', lowered), isFalse);
    });

    test('degenerate stored records never verify any pin', () async {
      // An empty hash segment would otherwise derive an empty key and
      // compare equal to itself: release builds run without the debug
      // asserts that used to catch this, so the floors are load
      // bearing. Every malformed record must fail closed.
      const pin = '1234';
      expect(await verifyPin(pin, '$pinHashPrefix\$30000\$AAAA\$'), isFalse);
      expect(
        await verifyPin(
          pin,
          [pinHashPrefix, '30000', 'AAAA', 'AAAA'].join(r'$'),
        ),
        isFalse,
      );
      expect(
        await verifyPin(
          pin,
          [
            pinHashPrefix,
            '30000',
            'AAAAAAAAAAAAAAAAAAAAAA==',
            'AAAA',
          ].join(r'$'),
        ),
        isFalse,
      );
      expect(
        await verifyPin(
          pin,
          [pinHashPrefix, '1', 'AAAAAAAAAAAAAAAAAAAAAA==', 'AAAA'].join(r'$'),
        ),
        isFalse,
      );
    });

    test('records the iteration count for staleness checks', () async {
      expect(pinHashIterationsOf('2468'), isNull);
      final stored = await hashPin('1234');
      expect(pinHashIterationsOf(stored), pinHashIterations);
    });
  });

  group('PinBackoff', () {
    test('the first attempts stay free', () {
      expect(PinBackoff.delayFor(0), Duration.zero);
      expect(PinBackoff.delayFor(1), Duration.zero);
      expect(PinBackoff.delayFor(PinBackoff.freeAttempts), Duration.zero);
    });

    test('the wait doubles and caps at a minute', () {
      expect(PinBackoff.delayFor(3), const Duration(seconds: 4));
      expect(PinBackoff.delayFor(4), const Duration(seconds: 8));
      expect(PinBackoff.delayFor(5), const Duration(seconds: 16));
      expect(PinBackoff.delayFor(6), const Duration(seconds: 32));
      expect(PinBackoff.delayFor(7), const Duration(seconds: 60));
      // Past the doubling range every failure stays at the cap.
      expect(PinBackoff.delayFor(8), const Duration(seconds: 60));
      expect(PinBackoff.delayFor(9), const Duration(seconds: 60));
      expect(PinBackoff.delayFor(10), const Duration(seconds: 60));
      expect(PinBackoff.delayFor(100), const Duration(seconds: 60));
      expect(PinBackoff.maxDelay, const Duration(seconds: 60));
    });
  });
}
