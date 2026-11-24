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
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FilterController<int>?>.value(
          value: controller,
          child: QueryFilter<int, int>(
            state: InfiniteQuerySuccess<List<int>, int>(
              timeCreated: DateTime.now(),
              hasReachedMax: false,
              hasNextPage: true,
              hasPreviousPage: false,
              data: InfiniteQueryData<List<int>, int>(
                pages: const [
                  [7, 6, 5],
                  [5, 4, 3], // 5 again: the overlap
                ],
                args: const [1],
              ),
            ),
            builder: (context, state) {
              controller.observed = state.data!.pages.expand((p) => p).toList();
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(controller.observed, [7, 6, 5, 4, 3]);
  });
}

class _CountingFilter extends FilterController<int> {
  List<int> observed = [];

  @override
  Object idOf(int item) => item;

  @override
  bool filter(int item) => true;
}
