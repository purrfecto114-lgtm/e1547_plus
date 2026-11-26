import 'dart:async';

import 'package:e1547/query/query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal cache item: equal values so no-op updates can be skipped.
class Item {
  const Item(this.id, this.votes);

  final int id;
  final int votes;

  @override
  bool operator ==(Object other) =>
      other is Item && other.id == id && other.votes == votes;

  @override
  int get hashCode => Object.hash(id, votes);

  @override
  String toString() => 'Item($id, $votes)';
}

void main() {
  // One cache per test, disposed manually before the widget tree unmounts:
  // the delete timers the queries schedule on unsubscribe would otherwise
  // outlive the test's fake clock.
  late CachedQuery cache;

  setUp(() {
    cache = CachedQuery.asNewInstance();
  });

  /// A [PagedQueryBuilder] wired to [cache] with one item query per id.
  Widget harness({
    required List<List<int>> pages,
    required void Function(List<Item?> items) observe,
    GlobalObjectKey<_RebuildCounterState>? counterKey,
  }) {
    final query = InfiniteQuery<List<int>, int>(
      cache: cache,
      key: 'ids',
      getNextArg: (state) => state == null ? 1 : null,
      // Unsubscribe must not schedule a delete timer the test's fake
      // clock cannot wait out.
      config: const QueryConfig(ignoreCacheDuration: true),
      queryFn: (page) async => pages[page - 1],
    );
    return MaterialApp(
      home: _RebuildCounter(
        key: counterKey,
        child: PagedQueryBuilder<Item, int>(
          query: query,
          getItem: (id) => Query(
            cache: cache,
            key: ['item', id],
            queryFn: () async => Item(id, 0),
            config: const QueryConfig(ignoreCacheDuration: true),
          ),
          builder: (context, state) {
            final items = state.data?.pages.expand((p) => p).toList() ?? [];
            observe([
              for (final item in items)
                item == null ? null : cache
                    .getQuery<Query<Item>>(['item', item.id])
                    ?.state
                    .data,
            ]);
            return const SizedBox();
          },
        ),
      ),
    );
  }

  testWidgets('one item update rebuilds the list once', (tester) async {
    // A vote lands on one post: the item query emits, and the paged list
    // needs exactly one rebuild to show it — not one per emitted no-op
    // (fetch starts, unchanged data echoes), which storm the framework
    // with layout work during every page load.
    int rebuilds = 0;
    List<Item?> seen = const [];
    final counterKey = GlobalObjectKey<_RebuildCounterState>(#one);

    await tester.pumpWidget(harness(
      pages: const [
        [1, 2, 3],
      ],
      observe: (items) {
        rebuilds++;
        seen = items;
      },
      counterKey: counterKey,
    ));
    // Initial settle: the page query + item queries all resolve.
    await tester.pumpAndSettle();
    rebuilds = 0;

    // A single item's data changes: one emission.
    cache.setQueryData<Item>(key: ['item', 1], data: const Item(1, 5));
    await tester.pumpAndSettle();

    expect(seen[0]!.votes, 5);
    expect(rebuilds, 1);
  });


  testWidgets('a burst of item fetch starts settles into few rebuilds', (
    tester,
  ) async {
    // A page landing means every item query on it fires: fetch-start
    // emissions with no data yet, then data emissions. The list must
    // coalesce that burst into a handful of frames, not one frame per
    // emission — 75 posts would mean 150+ frames per page on the wire.
    int rebuilds = 0;
    final counterKey = GlobalObjectKey<_RebuildCounterState>(#two);

    await tester.pumpWidget(harness(
      pages: const [
        [1, 2, 3, 4, 5],
      ],
      observe: (_) => rebuilds++,
      counterKey: counterKey,
    ));
    await tester.pumpAndSettle();

    // The whole burst coalesces into the three frames the data itself
    // needs — page fetch start, page data, item data — not one frame per
    // emission (the fetch-start echo of each of the five items used to
    // pay its own frame, and the item data arrivals each paid another).
    expect(rebuilds, 3);
  });

}

class _RebuildCounter extends StatefulWidget {
  const _RebuildCounter({super.key, required this.child});

  final Widget child;

  @override
  State<_RebuildCounter> createState() => _RebuildCounterState();
}

class _RebuildCounterState extends State<_RebuildCounter> {
  int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    return widget.child;
  }
}
