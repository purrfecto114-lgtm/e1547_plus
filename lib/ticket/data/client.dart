import 'package:dio/dio.dart';
import 'package:e1547/ticket/ticket.dart';

class TicketClient {
  TicketClient({required this.dio});

  final Dio dio;

  Future<void> create({
    required TicketType type,
    required int item,
    required String reason,
    PostReportType? postReportType,
  }) {
    return dio.post(
      '/tickets',
      queryParameters: {
        'ticket[qtype]': type.id,
        'ticket[disp_id]': item,
        'ticket[reason]': reason,
        if (postReportType != null) 'ticket[report_reason]': postReportType.id,
      },
      // A created ticket answers with a redirect to its page, but any
      // success means the same thing to the caller: nothing to parse.
      options: Options(
        validateStatus: (status) => status != null && status < 400,
      ),
    );
  }
}
