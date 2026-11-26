import 'dart:async';

import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

typedef GetItemQuery<T> = Query<T> Function(int id);

typedef PageQueryBuilderCallback<T, Arg> =
    Widget Function(
      BuildContext context,
      InfiniteQueryStatus<List<T>, Arg> state,
      InfiniteQuery<List<Arg>, Arg> query,
    );

class PagedQueryBuilder<T, Arg> extends StatefulWidget {
  const PagedQueryBuilder({
    super.key,
    required this.query,
    required this.getItem,
    required this.builder,
    this.enabled = true,
  });

  final InfiniteQuery<List<int>, Arg> query;
  final GetItemQuery<T> getItem;
  final QueryBuilderCallback<InfiniteQueryStatus<List<T>, Arg>> builder;
  final bool enabled;

  @override
  State<PagedQueryBuilder<T, Arg>> createState() =>
      _PagedQueryBuilderState<T, Arg>();
}

class _PagedQueryBuilderState<T, Arg> extends State<PagedQueryBuilder<T, Arg>> {
  final Map<int, StreamSubscription<QueryState<T>>> subscriptions = {};
  final Map<int, T?> items = {};

  InfiniteQueryStatus<List<int>, Arg>? lastState;
  InfiniteQueryStatus<List<T>, Arg>? cachedState;

  /// A setState scheduled but not yet run.
  ///
  /// Emissions from the item queries arrive in bursts — a page landing
  /// fires every item query on it, each with a fetch-start and a data
  /// emission — and each one used to pay its own rebuild. Scheduling one
  /// setState per microtask window folds a whole burst into a single
  /// rebuild instead of one per emission.
  bool _setStateScheduled = false;

  @override
  void dispose() {
    for (final subscription in subscriptions.values) {
      subscription.cancel();
    }
    subscriptions.clear();
    items.clear();
    super.dispose();
  }

  void _scheduleSetState() {
    if (_setStateScheduled) return;
    _setStateScheduled = true;
    scheduleMicrotask(() {
      if (!mounted) return;
      _setStateScheduled = false;
      // ignore: no_op_in_public_api
      setState(() {});
    });
  }

  void subscribeToItem(int id) {
    if (subscriptions.containsKey(id)) return;

    final itemQuery = widget.getItem(id);
    subscriptions[id] = itemQuery.stream.listen((state) {
      // An emission that lands the same data as the last one leaves the
      // resolved list unchanged: re-resolving it would rebuild every
      // tile for nothing.
      if (items[id] == state.data) {
        if (state.data == null && items[id] != null) {
          // fall through: a lost item must update the list
        } else {
          return;
        }
      }
      items[id] = state.data;
      cachedState = null;
      _scheduleSetState();
    });

    items[id] = itemQuery.state.data;
  }

  void unsubscribeFromItem(int id) {
    subscriptions[id]?.cancel();
    subscriptions.remove(id);
    items.remove(id);
  }

  InfiniteQueryStatus<List<T>, Arg> _pending(DateTime timeCreated) =>
      InfiniteQueryStatus<List<T>, Arg>.loading(
        timeCreated: timeCreated,
        data: null,
        isRefetching: false,
        isFetchingNextPage: false,
        isInitialFetch: true,
      );

  InfiniteQueryStatus<List<T>, Arg> resolveState(
    InfiniteQueryStatus<List<int>, Arg> state,
  ) {
    if (cachedState != null && lastState == state) {
      return cachedState!;
    }

    final pages = state.data?.pages ?? [];

    final allIds = pages.expand((page) => page).toSet();

    for (final id in allIds) {
      subscribeToItem(id);
    }

    final idsToRemove = subscriptions.keys
        .where((id) => !allIds.contains(id))
        .toList();

    for (final id in idsToRemove) {
      unsubscribeFromItem(id);
    }

    final resolvedPages = <List<T>>[];
    final seenIds = <int>{};

    for (final page in pages) {
      final resolvedPage = <T>[];
      for (final id in page) {
        if (seenIds.contains(id)) continue;
        final item = items[id];
        if (item != null) {
          resolvedPage.add(item);
          seenIds.add(id);
        }
      }
      resolvedPages.add(resolvedPage);
    }

    final data = resolvedPages.isNotEmpty
        ? InfiniteQueryData<List<T>, Arg>(
            pages: resolvedPages,
            args: state.data?.args ?? [],
          )
        : null;

    if (state is! InfiniteQueryError &&
        pages.any((page) => page.isNotEmpty) &&
        resolvedPages.every((page) => page.isEmpty)) {
      final pending = _pending(state.timeCreated);
      lastState = state;
      cachedState = pending;
      return pending;
    }

    final resolved = switch (state) {
      InfiniteQueryInitial() => InfiniteQueryStatus<List<T>, Arg>.initial(
        timeCreated: state.timeCreated,
        data: data,
      ),
      InfiniteQueryLoading() => InfiniteQueryStatus<List<T>, Arg>.loading(
        timeCreated: state.timeCreated,
        data: data,
        isRefetching: state.isRefetching,
        isFetchingNextPage: state.isFetchingNextPage,
        isInitialFetch: state.isInitialFetch,
      ),
      InfiniteQuerySuccess() => InfiniteQueryStatus<List<T>, Arg>.success(
        timeCreated: state.timeCreated,
        data: data!,
        // ignore: deprecated_member_use
        hasReachedMax: state.hasReachedMax,
        hasNextPage: state.hasNextPage,
        hasPreviousPage: state.hasPreviousPage,
      ),
      InfiniteQueryError() => InfiniteQueryStatus<List<T>, Arg>.error(
        timeCreated: state.timeCreated,
        data: data,
        error: state.error,
        stackTrace: state.stackTrace,
      ),
    };

    lastState = state;
    cachedState = resolved;

    return resolved;
  }

  @override
  Widget build(BuildContext context) {
    final bool skeleton = isSkeleton(context);
    return QueryBuilder(
      query: widget.query,
      enabled: widget.enabled && !skeleton,
      builder: (context, state) => widget.builder(
        context,
        skeleton ? _pending(state.timeCreated) : resolveState(state),
      ),
    );
  }
}
