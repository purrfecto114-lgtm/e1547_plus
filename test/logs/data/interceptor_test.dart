import 'package:e1547/logs/logs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoggingDioInterceptor.describePath', () {
    test('keeps ordinary query parameters intact', () {
      final Uri uri = Uri.parse('https://e621.net/posts.json?limit=75&page=2');
      expect(
        LoggingDioInterceptor.describePath(uri),
        '/posts.json?limit=75&page=2',
      );
    });

    test('redacts secret-named query parameters', () {
      final Uri uri = Uri.parse(
        'https://e621.net/session.json?login=user&api_key=hunter2',
      );
      expect(
        LoggingDioInterceptor.describePath(uri),
        '/session.json?login=[redacted]&api_key=[redacted]',
      );
    });

    test('redacts secrets even when decoded values contain spaces', () {
      // Decoded tag queries contain spaces, which break the string-level
      // redactor's no-space URL regex downstream. The path description
      // must therefore already be safe at the source.
      final Uri uri = Uri.parse(
        'https://e621.net/posts.json?tags=big%20cat&api_key=hunter2',
      );
      expect(
        LoggingDioInterceptor.describePath(uri),
        '/posts.json?tags=big cat&api_key=[redacted]',
      );
    });
  });

  group('LoggingDioInterceptor.describeReason', () {
    test('reads the reason an error response gives', () {
      expect(
        LoggingDioInterceptor.describeReason({
          'success': false,
          'reason': 'Access denied',
        }),
        'Access denied',
      );
    });

    test('falls back to the message field', () {
      expect(
        LoggingDioInterceptor.describeReason({'message': 'Throttled'}),
        'Throttled',
      );
    });

    test('ignores bodies that are not structured', () {
      expect(LoggingDioInterceptor.describeReason('<html>denied</html>'), null);
      expect(LoggingDioInterceptor.describeReason(null), null);
    });

    test('ignores a response without a reason', () {
      expect(LoggingDioInterceptor.describeReason({'posts': []}), null);
    });

    test('caps a reason that runs long', () {
      final String result = LoggingDioInterceptor.describeReason({
        'reason': 'x' * 500,
      })!;
      expect(result.length, LoggingDioInterceptor.reasonLimit + 1);
      expect(result.endsWith('…'), isTrue);
    });
  });
}
