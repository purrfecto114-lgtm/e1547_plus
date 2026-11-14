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

  // The pull below races a fetch that has already settled but whose slot
  // the controller has not released yet — a re-armed subscription while
  // the data is fresh, exactly like a page that is left and re-entered.
  // The settled fetch reports a success whose data was never refreshed
  // off the network, which the pull would adopt as its own verdict.
  group('a pull racing a settled fetch', () {
    CachedQuery appCache() {
      final cache = CachedQuery.asNewInstance();
      cache.config(
        config: const GlobalQueryConfig(
          staleDuration: Duration(minutes: 5),
          refetchOnResume: false,
          cacheDuration: Duration(milliseconds: 1),
        ),
      );
      return cache;
    }

    test(
      'Query.revalidate re-runs the refresh it did not run itself',
      () async {
        final cache = appCache();
        bool offline = false;
        int networkCalls = 0;

        final query = Query<List<int>>(
          cache: cache,
          key: 'revalidate-query-race',
          queryFn: () async {
            networkCalls++;
            if (offline) throw Exception('offline');
            return [1, 2, 3];
          },
        );

        final subscription = query.stream.listen((_) {});
        addTearDown(subscription.cancel);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(query.state, isA<QuerySuccess>());

        offline = true;

        // Re-arming the subscription settles a fetch without a round trip
        // while the data is fresh; the pull starts inside the window before
        // the controller releases that fetch's slot.
        await subscription.cancel();
        final resubscription = query.stream.listen((_) {});
        final Future<bool> verdict = query.revalidate();
        await resubscription.cancel();

        expect(
          await verdict,
          isFalse,
          reason: 'the pull must report the failure of its own round trip',
        );
        expect(networkCalls, 2, reason: 'the pull must reach the network');
      },
    );

    test(
      'InfiniteQuery.revalidate re-runs the refresh it did not run itself',
      () async {
        final cache = appCache();
        bool offline = false;
        int networkCalls = 0;

        final query = InfiniteQuery<List<int>, Object>(
          cache: cache,
          key: 'revalidate-infinite-race',
          config: pagedObjectIdConfig(),
          getNextArg: (state) => state.nextCursorPage(),
          queryFn: (page) async {
            networkCalls++;
            if (offline) throw Exception('offline');
            return [1, 2, 3];
          },
        );

        final subscription = query.stream.listen((_) {});
        addTearDown(subscription.cancel);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(query.state, isA<InfiniteQuerySuccess>());

        offline = true;

        await subscription.cancel();
        final resubscription = query.stream.listen((_) {});
        final Future<bool> verdict = query.revalidate();
        await resubscription.cancel();

        expect(
          await verdict,
          isFalse,
          reason: 'the pull must report the failure of its own round trip',
        );
        expect(networkCalls, 2, reason: 'the pull must reach the network');
      },
    );

    test('a pull that runs its own refresh reports it directly', () async {
      final cache = appCache();
      int networkCalls = 0;

      final query = InfiniteQuery<List<int>, Object>(
        cache: cache,
        key: 'revalidate-infinite-race-ok',
        config: pagedObjectIdConfig(),
        getNextArg: (state) => state.nextCursorPage(),
        queryFn: (page) async {
          networkCalls++;
          return [1, 2, 3];
        },
      );

      final subscription = query.stream.listen((_) {});
      addTearDown(subscription.cancel);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(query.state, isA<InfiniteQuerySuccess>());

      // The refresh runs undisturbed: one round trip, one verdict.
      final int callsBefore = networkCalls;
      expect(await query.revalidate(), isTrue);
      expect(
        networkCalls,
        callsBefore + 1,
        reason: 'an honest success costs exactly one round trip',
      );
    });
  });
}
