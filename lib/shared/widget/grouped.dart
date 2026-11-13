import 'package:flutter/material.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PagedSliverGroupedListView<PageKeyType, ItemType, SortType>
    extends StatefulWidget {
  const PagedSliverGroupedListView({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    this.shrinkWrapFirstPageIndicators = false,
    required this.groupBy,
    this.groupComparator,
    this.groupSeparatorBuilder,
    this.groupHeaderBuilder,
    this.itemComparator,
    this.order = GroupedListOrder.ASC,
    this.sort = true,
    this.separator = const SizedBox.shrink(),
  });

  /// Matches [PagedLayoutBuilder.state].
  final PagingState<PageKeyType, ItemType> state;

  /// Matches [PagedLayoutBuilder.fetchNextPage].
  final NextPageCallback fetchNextPage;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  /// Matches [SliverGroupedListView.groupBy].
  final SortType Function(ItemType element) groupBy;

  /// Matches [SliverGroupedListView.groupComparator].
  final int Function(SortType value1, SortType value2)? groupComparator;

  /// Matches [SliverGroupedListView.itemComparator].
  final int Function(ItemType element1, ItemType element2)? itemComparator;

  /// Matches [SliverGroupedListView.groupSeparatorBuilder].
  final Widget Function(SortType value)? groupSeparatorBuilder;

  /// Matches [SliverGroupedListView.groupHeaderBuilder].
  final Widget Function(ItemType element)? groupHeaderBuilder;

  /// Matches [SliverGroupedListView.order].
  final GroupedListOrder order;

  /// Matches [SliverGroupedListView.sort].
  final bool sort;

  /// Matches [SliverGroupedListView.separator].
  final Widget separator;

  @override
  State<PagedSliverGroupedListView<PageKeyType, ItemType, SortType>>
  createState() =>
      _PagedSliverGroupedListViewState<PageKeyType, ItemType, SortType>();
}

class _PagedSliverGroupedListViewState<PageKeyType, ItemType, SortType>
    extends State<PagedSliverGroupedListView<PageKeyType, ItemType, SortType>> {
  /// The items the current index map was built for.
  List<ItemType>? _mappedItems;

  /// Maps each item of the current emission to its index, so builders can
  /// find their item in the unsorted list.
  ///
  /// Rebuilt only when a new emission arrives, not on every rebuild: the
  /// list around this widget rebuilds for selection changes and status
  /// indicators, which do not move any item.
  Map<ItemType, int> _itemIndices = Map<ItemType, int>.identity();

  Map<ItemType, int> _indicesOf(List<ItemType> items) {
    if (!identical(_mappedItems, items)) {
      _mappedItems = items;
      _itemIndices = Map<ItemType, int>.identity();
      for (int i = 0; i < items.length; i++) {
        _itemIndices[items[i]] = i;
      }
    }
    return _itemIndices;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildLayout(
      IndexedWidgetBuilder itemBuilder,
      int itemCount, {
      WidgetBuilder? statusIndicatorBuilder,
    }) {
      // SliverGroupedListView sorts its items, so the item index in its builder
      // is within a sorted list, not the original list.
      // To prevent children from being confused when trying to find their item
      // in the original list, we keep a map.
      final items = widget.state.items!;
      final itemIndices = _indicesOf(items);
      return SliverMainAxisGroup(
        slivers: [
          SliverGroupedListView<ItemType, SortType>(
            key: widget.key,
            elements: items,
            groupBy: widget.groupBy,
            groupComparator: widget.groupComparator,
            groupSeparatorBuilder: widget.groupSeparatorBuilder,
            groupHeaderBuilder: widget.groupHeaderBuilder,
            indexedItemBuilder: (context, item, index) =>
                itemBuilder(context, itemIndices[item] ?? index),
            itemComparator: widget.itemComparator,
            order: widget.order,
            sort: widget.sort,
            separator: widget.separator,
          ),
          if (statusIndicatorBuilder != null)
            SliverToBoxAdapter(child: statusIndicatorBuilder(context)),
        ],
      );
    }

    return PagedLayoutBuilder<PageKeyType, ItemType>(
      layoutProtocol: PagedLayoutProtocol.sliver,
      state: widget.state,
      fetchNextPage: widget.fetchNextPage,
      builderDelegate: widget.builderDelegate,
      shrinkWrapFirstPageIndicators: widget.shrinkWrapFirstPageIndicators,
      completedListingBuilder:
          (context, itemBuilder, itemCount, noMoreItemsIndicatorBuilder) =>
              buildLayout(
                itemBuilder,
                itemCount,
                statusIndicatorBuilder: noMoreItemsIndicatorBuilder,
              ),
      loadingListingBuilder:
          (context, itemBuilder, itemCount, progressIndicatorBuilder) =>
              buildLayout(
                itemBuilder,
                itemCount,
                statusIndicatorBuilder: progressIndicatorBuilder,
              ),
      errorListingBuilder:
          (context, itemBuilder, itemCount, errorIndicatorBuilder) =>
              buildLayout(
                itemBuilder,
                itemCount,
                statusIndicatorBuilder: errorIndicatorBuilder,
              ),
    );
  }
}
