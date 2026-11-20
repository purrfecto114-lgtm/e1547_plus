import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

class CapturingAdapter implements HttpClientAdapter {
  CapturingAdapter({this.status = 302});

  int status;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString('', status);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late CapturingAdapter adapter;
  late TicketClient client;

  setUp(() {
    adapter = CapturingAdapter();
    client = TicketClient(
      dio: Dio(BaseOptions(baseUrl: 'https://example.invalid'))
        ..httpClientAdapter = adapter,
    );
  });

  QueryMap sent() => adapter.captured!.queryParameters.map(
    (key, value) => MapEntry(key, value.toString()),
  );

  test('sends the ticket type and item', () async {
    await client.create(type: TicketType.forum, item: 123, reason: 'spam');

    expect(sent(), {
      'ticket[qtype]': 'forum',
      'ticket[disp_id]': '123',
      'ticket[reason]': 'spam',
    });
  });

  test('sends the post report reason as its id', () async {
    await client.create(
      type: TicketType.post,
      item: 123,
      reason: 'spam',
      postReportType: PostReportType.rating,
    );

    expect(sent()['ticket[report_reason]'], '6');
  });

  test('accepts whatever success the creation answers with', () async {
    for (final status in [200, 302, 303]) {
      adapter.status = status;
      await client.create(type: TicketType.forum, item: 1, reason: 'spam');
    }
  });

  test('a rejected creation still throws', () async {
    adapter.status = 422;

    await expectLater(
      client.create(type: TicketType.forum, item: 1, reason: 'spam'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          422,
        ),
      ),
    );
  });
}
