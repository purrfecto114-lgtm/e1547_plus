import 'dart:async';
import 'dart:math';

import 'package:e1547/query/query.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fuzzes the interleaving of the events a real device produces around a
/// pull to refresh — the pull itself, footer-driven next page fetches,
/// subscription churn from navigation, and resume/connection refetches —
/// while offline, and requires the verdict pull to report failure.
///
/// The fetch slot is shared by all of these; a sequence that lets a later
/// pull adopt an unrelated fetch is exactly the fake-success bug.
void main() {
  for (final seed in List.generate(300, (i) => i)) {
    test('fuzz seed $seed', () async {
      final rng = Random(seed);
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
        key: 'fuzz-$seed',
        config: pagedObjectIdConfig(),
        getNextArg: (state) => state.nextPageArg(maxPage: 750),
        queryFn: (page) async {
          // every network round trip crosses a microtask boundary
          await Future<void>.delayed(Duration.zero);
          if (!online) {
            throw Exception('offline');
          }
          return [seed];
        },
      );

      StreamSubscription<dynamic> sub = query.stream.listen((_) {});
      await query.fetch();
      expect(query.state, isA<InfiniteQuerySuccess>(), reason: 'online load');

      online = false;

      Future<void> pump([int n = 1]) async {
        for (var i = 0; i < n; i++) {
          await Future<void>.delayed(Duration.zero);
        }
      }

      final trace = <String>[];
      final ops = <Future<void> Function()>[
        () async {
          trace.add('pull');
          await query.revalidate();
        },
        () async {
          trace.add('next');
          await query.getNextPage();
        },
        () async {
          trace.add('resub');
          await sub.cancel();
          sub = query.stream.listen((_) {});
        },
        () async {
          trace.add('resume');
          await query.fetch();
        },
      ];

      final count = rng.nextInt(6);
      for (var i = 0; i < count; i++) {
        unawaited(ops[rng.nextInt(4)]());
        await pump(rng.nextInt(3));
      }

      // the verdict pull: what the user would see
      final result = await query.revalidate();
      expect(
        result,
        isFalse,
        reason: 'seed $seed, trace: ${trace.join(' > ')}',
      );
      await sub.cancel();
    });
  }
}
