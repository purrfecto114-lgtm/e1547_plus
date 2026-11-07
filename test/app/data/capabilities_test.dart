import 'package:e1547/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers the iOS version probe: it runs during startup, so any throw
/// here would keep the app from launching at all.
void main() {
  group('PlatformCapabilities.backgroundWorkerForVersion', () {
    test('parses the documented iOS version string', () {
      expect(
        PlatformCapabilities.backgroundWorkerForVersion(
          'Version 17.5.1 (Build 21F90)',
        ),
        isTrue,
      );
      expect(
        PlatformCapabilities.backgroundWorkerForVersion('Version 12.4 (16H5)'),
        isFalse,
      );
    });

    test('takes the leading integer, not a later digit run', () {
      // Build numbers and parentheses must not win over the version.
      expect(
        PlatformCapabilities.backgroundWorkerForVersion('9.3.5 (13G36)'),
        isFalse,
      );
      expect(
        PlatformCapabilities.backgroundWorkerForVersion('13.0 (17A577)'),
        isTrue,
      );
    });

    test('single segment versions work', () {
      expect(PlatformCapabilities.backgroundWorkerForVersion('15'), isTrue);
      expect(PlatformCapabilities.backgroundWorkerForVersion('12'), isFalse);
    });

    test('unparseable input counts as modern iOS', () {
      expect(PlatformCapabilities.backgroundWorkerForVersion(''), isTrue);
      expect(
        PlatformCapabilities.backgroundWorkerForVersion('unknown'),
        isTrue,
      );
    });

    test('non ascii prefixes still find the version', () {
      expect(
        PlatformCapabilities.backgroundWorkerForVersion('版本 16.2 (20C65)'),
        isTrue,
      );
    });

    test('never throws, whatever the input', () {
      const inputs = [
        '',
        ' ',
        'no digits at all',
        '999999999999999999999999.5 (build)',
        '0.0',
        '.5',
        '١٤ middle eastern digits',
      ];
      for (final input in inputs) {
        expect(
          () => PlatformCapabilities.backgroundWorkerForVersion(input),
          returnsNormally,
          reason: 'input: $input',
        );
      }
    });

    test('absurd digit runs fall back to the modern branch', () {
      // int.tryParse overflow must yield null, not a FormatException.
      expect(
        PlatformCapabilities.backgroundWorkerForVersion(
          '99999999999999999999.0',
        ),
        isTrue,
      );
    });
  });
}
