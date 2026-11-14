import 'dart:async';

import 'package:e1547/query/query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('minimal: resubscribe after disconnect', () async {
    bool online = true;
    final cache = CachedQuery.asNewInstance()
      ..config(
        config: const GlobalQueryConfig(
          staleDuration: Duration(minutes: 5),
          cacheDuration: Duration(milliseconds: 1),
        ),
      );
    final query = InfiniteQuery<List<int>, Object>(
      cache: cache,
      key: 'resub-min',
      config: pagedObjectIdConfig(),
      getNextArg: (state) => state.nextPageArg(maxPage: 750),
      queryFn: (page) async {
        await Future<void>.delayed(Duration.zero);
        if (!online) throw Exception('offline');
        return [1];
      },
    );

    StreamSubscription<dynamic> sub = query.stream.listen((_) {});
    await query.fetch();

    online = false;
    await sub.cancel();
    sub = query.stream.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 5));

    final verdict = await query.revalidate();
    expect(verdict, isFalse);
    await sub.cancel();
  });
}
