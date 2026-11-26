import 'package:e1547/query/query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('a filtered list counts overlapping page posts once', (
    tester,
  ) async {
    // Cursor pagination can hand a search two pages that share a post
    // (a refresh racing a page turn). The filter's rechunk must not
    // duplicate the shared post: every counter downstream counts it
    // once, or every tag in the drawer reads one post too many.
    final controller = _CountingFilter();
    await _pump(
      tester,
      controller,
      pages: const [
        [7, 6, 5],
        [5, 4, 3], // 5 again: the overlap
      ],
    );

    expect(controller.observed, [7, 6, 5, 4, 3]);
  });

  testWidgets('a filtered list counts a repeated post within one page once', (
    tester,
  ) async {
    // The same id can also arrive twice inside a single page (a server
    // hiccup, a pool that lists a post in two sections). One page or two
    // does not matter: the counters downstream see every id once.
    final controller = _CountingFilter();
    await _pump(
      tester,
      controller,
      pages: const [
        [7, 7, 6],
      ],
    );

    expect(controller.observed, [7, 6]);
  });

  testWidgets('a filter change re-filters an unchanged page set', (
    tester,
  ) async {
    // Toggling the denying switch (or editing the denylist) does not
    // refetch the search: the query hands over the same data instance.
    // The rechunk cache keys on the data instance AND the filter's
    // invalidation generation, so the same data re-filters instead of
    // serving the stale rechunk forever.
    final controller = _ToggleFilter();
    await _pump(
      tester,
      controller,
      pages: const [
        [5, 4],
      ],
    );
    expect(controller.observed, [5, 4]);

    controller.deny5 = true;
    controller.invalidate();
    await tester.pumpAndSettle();
    expect(controller.observed, [4]);

    controller.deny5 = false;
    controller.invalidate();
    await tester.pumpAndSettle();
    expect(controller.observed, [5, 4]);
  });

  testWidgets(
    'an unchanged page set on the same generation reuses the rechunk',
    (tester) async {
      // The cache exists so the common rebuild — same state, same
      // generation — does not re-expand and re-filter hundreds of posts.
      final controller = _CountingFilter();
      final state = InfiniteQuerySuccess<List<int>, int>(
        timeCreated: DateTime.now(),
        hasReachedMax: false,
        hasNextPage: true,
        hasPreviousPage: false,
        data: InfiniteQueryData<List<int>, int>(
          pages: const [
            [7, 6],
          ],
          args: const [1],
        ),
      );

      await _pumpState(tester, controller, state);
      final runs = controller.trackRuns;
      expect(runs, greaterThan(0));

      await _pumpState(tester, controller, state);
      expect(controller.trackRuns, runs);
    },
  );
}

Future<void> _pump(
  WidgetTester tester,
  _ObservedFilter controller, {
  required List<List<int>> pages,
}) async {
  await _pumpState(
    tester,
    controller,
    InfiniteQuerySuccess<List<int>, int>(
      timeCreated: DateTime.now(),
      hasReachedMax: false,
      hasNextPage: true,
      hasPreviousPage: false,
      data: InfiniteQueryData<List<int>, int>(pages: pages, args: const [1]),
    ),
  );
}

Future<void> _pumpState(
  WidgetTester tester,
  _ObservedFilter controller,
  InfiniteQueryStatus<List<int>, int> state,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<FilterController<int>?>.value(
        value: controller,
        child: QueryFilter<int, int>(
          state: state,
          builder: (context, state) {
            controller.observed = state.data!.pages.expand((p) => p).toList();
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  await tester.pump();
}

abstract class _ObservedFilter extends FilterController<int> {
  _ObservedFilter();

  List<int> observed = [];

  @override
  Object idOf(int item) => item;
}

class _CountingFilter extends _ObservedFilter {
  _CountingFilter();

  int trackRuns = 0;

  @override
  bool filter(int item) => true;

  @override
  List<int> track(Object key, List<int> items) {
    trackRuns++;
    return super.track(key, items);
  }
}

class _ToggleFilter extends _ObservedFilter {
  _ToggleFilter();

  bool deny5 = false;

  @override
  bool filter(int item) => !(deny5 && item == 5);
}
