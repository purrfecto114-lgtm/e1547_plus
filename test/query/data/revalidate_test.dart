import 'package:e1547/query/query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Query.revalidate reports success after a successful refetch', () async {
    final query = Query<int>(
      key: 'revalidate-query-ok',
      queryFn: () async => 42,
    );
    final subscription = query.stream.listen((_) {});
    addTearDown(subscription.cancel);

    expect(await query.revalidate(), isTrue);
    expect(query.state, isA<QuerySuccess>());
  });

  test('Query.revalidate reports failure when the refetch errors', () async {
    final query = Query<int>(
      key: 'revalidate-query-fail',
      queryFn: () async => throw Exception('offline'),
    );
    final subscription = query.stream.listen((_) {});
    addTearDown(subscription.cancel);

    expect(await query.revalidate(), isFalse);
    expect(query.state, isA<QueryError>());
  });

  test(
    'InfiniteQuery.revalidate reports success when the refetch succeeds',
    () async {
      final query = InfiniteQuery<InfiniteQueryData<List<int>, int>, int>(
        key: 'revalidate-infinite-ok',
        queryFn: (page) async => InfiniteQueryData(
          pages: [
            [1, 2],
          ],
          args: [page],
        ),
        getNextArg: (data) => (data?.args.isEmpty ?? true) ? 0 : null,
      );
      final subscription = query.stream.listen((_) {});
      addTearDown(subscription.cancel);

      expect(await query.revalidate(), isTrue);
      expect(query.state, isA<InfiniteQuerySuccess>());
    },
  );

  test('InfiniteQuery.revalidate reports failure when offline', () async {
    final query = InfiniteQuery<InfiniteQueryData<List<int>, int>, int>(
      key: 'revalidate-infinite-fail',
      queryFn: (page) async => throw Exception('offline'),
      getNextArg: (data) => (data?.args.isEmpty ?? true) ? 0 : null,
    );
    final subscription = query.stream.listen((_) {});
    addTearDown(subscription.cancel);

    expect(await query.revalidate(), isFalse);
    expect(query.state, isA<InfiniteQueryError>());
  });
}
