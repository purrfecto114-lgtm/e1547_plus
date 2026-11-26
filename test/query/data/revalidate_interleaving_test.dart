import 'dart:math';

import 'package:e1547/query/query.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hunts for a false "success" verdict from revalidate() when the network is
/// dead, across interleavings of the mechanisms that run in production:
/// subscriptions coming and going (onListen fetches), background fetches
/// (connectivity controller), pagination (getNextPage) and pulls.
void main() {
  test(
    'fuzz: no interleaving reports success against a dead network',
    () async {
      final random = Random(20261114);
      bool offline = false;
      int networkCalls = 0;

      Future<void> scenario(int i) async {
        final cache = CachedQuery.asNewInstance()
          ..config(
            config: const GlobalQueryConfig(
              staleDuration: Duration(minutes: 5),
              refetchOnResume: false,
              cacheDuration: Duration(milliseconds: 1),
            ),
          );

        offline = false;
        networkCalls = 0;

        final query = InfiniteQuery<List<int>, Object>(
          cache: cache,
          key: 'fuzz-$i',
          config: pagedObjectIdConfig(),
          getNextArg: (state) => state.nextCursorPage(),
          queryFn: (page) async {
            networkCalls++;
            if (offline) {
              throw Exception('offline');
            }
            return [1, 2, 3];
          },
        );

        // The page opens and loads.
        final subscription = query.stream.listen((_) {});
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        if (query.state is! InfiniteQuerySuccess) {
          throw StateError('scenario $i: initial load failed');
        }

        offline = true;
        final int callsAtPullTime = networkCalls;

        // A random interleaving of background activity around the pull.
        final backgroundOps = <Future<void>>[];
        final ops = <String>[];
        final int opCount = random.nextInt(4);
        for (var op = 0; op < opCount; op++) {
          switch (random.nextInt(4)) {
            case 0:
              ops.add('fetch');
              // connectivity-style fetch
              backgroundOps.add(query.fetch());
            case 1:
              ops.add('nextPage');
              // pagination
              backgroundOps.add(query.getNextPage());
            case 2:
              ops.add('resub');
              // subscription cycling: cancel then re-listen
              await subscription.cancel();
              final relisten = query.stream.listen((_) {});
              backgroundOps.add(
                Future<void>.delayed(
                  Duration(milliseconds: random.nextInt(3)),
                ).then((_) => relisten.cancel()),
              );
              backgroundOps.add(relisten.cancel());
            case 3:
              ops.add('wait');
              // a short wait to shift the interleaving
              await Future<void>.delayed(
                Duration(milliseconds: random.nextInt(3)),
              );
          }
        }
        // ignore: avoid_print
        print('scenario $i ops: $ops');

        final bool verdict = await query.revalidate();
        await Future.wait(backgroundOps).catchError((_) => <void>[]);
        await subscription.cancel();

        if (verdict) {
          // ignore: avoid_print
          print(
            'FALSE SUCCESS in scenario $i (networkCalls='
            '$networkCalls, atPull=$callsAtPullTime)',
          );
        }
        expect(
          verdict,
          isFalse,
          reason: 'scenario $i reported success offline',
        );
      }

      for (var i = 0; i < 60; i++) {
        await scenario(i);
      }
    },
  );
}
