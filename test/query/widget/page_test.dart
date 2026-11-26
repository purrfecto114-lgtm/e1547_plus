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
  ///
  /// The returned record carries the query so a test can drive extra
  /// pages with [InfiniteQuery.getNextPage].
  ({Widget tree, InfiniteQuery<List<int>, int> query}) harness({
    required List<List<int>> pages,
    required void Function(List<Item?> items) observe,
    GlobalObjectKey<_RebuildCounterState>? counterKey,
    void Function(List<List<Item>> pages)? onPageList,
  }) {
    final query = InfiniteQuery<List<int>, int>(
      cache: cache,
      key: 'ids',
      getNextArg: (state) =>
          state == null ? 1 : (state.pages.length < pages.length
              ? state.pages.length + 1
              : null),
      // Unsubscribe must not schedule a delete timer the test's fake
      // clock cannot wait out.
      config: const QueryConfig(ignoreCacheDuration: true),
      queryFn: (page) async => pages[page - 1],
    );
    final tree = MaterialApp(
      home: _RebuildCounter(
        key: counterKey,
        child: PagedQueryBuilder<Item, int>(
          query: query,
          // Real fetches: like the live pipeline, the item queries resolve
          // through their own network round (queryFn), so their fetch
          // starts and data arrivals fire the emissions the rebuild
          // coalescing has to fold.
          getItem: (id) => Query(
            cache: cache,
            key: ['item', id],
            queryFn: () async => Item(id, 0),
            config: const QueryConfig(ignoreCacheDuration: true),
          )..fetch(),
          builder: (context, state) {
            final pages = state.data?.pages.toList() ?? const <List<Item>>[];
            onPageList?.call(pages.cast<List<Item>>());
            observe([
              for (final item in pages.expand((p) => p))
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
    return (tree: tree, query: query);
  }

  testWidgets('one item update rebuilds the list once', (tester) async {
    // A vote lands on one post: the item query emits, and the paged list
    // needs exactly one rebuild to show it — not one per emitted no-op
    // (fetch starts, unchanged data echoes), which storm the framework
    // with layout work during every page load.
    int rebuilds = 0;
    List<Item?> seen = const [];
    final counterKey = GlobalObjectKey<_RebuildCounterState>(#one);

    await tester.pumpWidget(
      harness(
        pages: const [
          [1, 2, 3],
        ],
        observe: (items) {
          rebuilds++;
          seen = items;
        },
        counterKey: counterKey,
      ).tree,
    );
    // Initial settle: the page query + item queries all resolve.
    await tester.pumpAndSettle();
    rebuilds = 0;

    // A single item's data changes: one emission.
    cache.setQueryData<Item>(key: ['item', 1], data: const Item(1, 5));
    await tester.pumpAndSettle();

    expect(seen[0]!.votes, 5);
    expect(rebuilds, 1);
  });


  testWidgets('a same-data emission does not rebuild the list', (
    tester,
  ) async {
    // cached_query re-emits the same data (setData echoes, storage
    // round trips, refetch votes on staleness): each re-emission used
    // to rebuild the whole paged list even though nothing changed.
    // On the fake clock every fetch settles inside one frame, so the
    // honest measurable is the echo: a no-change emission must cost
    // zero rebuilds.
    int rebuilds = 0;

    final h = harness(
      pages: const [
        [1, 2, 3],
      ],
      observe: (_) => rebuilds++,
      counterKey: GlobalObjectKey<_RebuildCounterState>(#four),
    );
    await tester.pumpWidget(h.tree);
    await tester.pumpAndSettle();
    rebuilds = 0;

    // Echo the same data the query already holds.
    cache.setQueryData<Item>(key: ['item', 1], data: Item(1, 0));
    await tester.pumpAndSettle();

    expect(rebuilds, 0);
  });

}

class _PageRecorder {
  List<List<Item>>? before;
  List<List<Item>>? after;

  void record(List<List<Item>> pages) {
    after = pages;
    before ??= pages;
  }

  void reset() {
    before = null;
    after = null;
  }
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
