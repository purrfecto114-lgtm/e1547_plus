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

  test('Query.revalidate forces the refetch even without listeners', () async {
    // A page fed through getNextPage never registers its query with the
    // controller, so a refresh that only invalidates would skip the
    // round trip and report the untouched initial state as a success.
    final query = Query<int>(
      key: 'revalidate-query-no-listener',
      queryFn: () async => throw Exception('offline'),
    );

    expect(await query.revalidate(), isFalse);
    expect(await query.revalidate(), isFalse);
    expect(query.state, isA<QueryError>());
  });

  test(
    'Query.revalidate keeps reporting the failure it actually ran',
    () async {
      // The page holds the subscription while it shows the data, then
      // swaps it away: the refreshes after that must still run the
      // network round trip instead of re-reading the cached success.
      bool offline = false;
      final query = Query<int>(
        key: 'revalidate-query-flip',
        queryFn: () async {
          if (offline) throw Exception('offline');
          return 42;
        },
      );
      final subscription = query.stream.listen((_) {});
      addTearDown(subscription.cancel);

      expect(await query.revalidate(), isTrue);
      offline = true;
      // The first failing refresh is honest ...
      expect(await query.revalidate(), isFalse);
      // ... and the report comes from the refetch, so once the page no
      // longer holds a subscription the refreshes keep failing too.
      await subscription.cancel();
      expect(await query.revalidate(), isFalse);
      expect(await query.revalidate(), isFalse);
      expect(query.state, isA<QueryError>());
    },
  );

  test(
    'InfiniteQuery.revalidate forces the refetch even without listeners',
    () async {
      final query = InfiniteQuery<InfiniteQueryData<List<int>, int>, int>(
        key: 'revalidate-infinite-no-listener',
        queryFn: (page) async => throw Exception('offline'),
        getNextArg: (data) => (data?.args.isEmpty ?? true) ? 0 : null,
      );

      expect(await query.revalidate(), isFalse);
      expect(await query.revalidate(), isFalse);
      expect(query.state, isA<InfiniteQueryError>());
    },
  );
}
