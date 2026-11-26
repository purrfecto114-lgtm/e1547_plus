import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FilterControllerProvider<C extends FilterController<T>, T>
    extends SubListenableProvider0<C> {
  // ignore: use_key_in_widget_constructors
  FilterControllerProvider({
    required super.create,
    super.child,
    TransitionBuilder? builder,
    super.keys,
  }) : super(
         builder: (context, child) =>
             // Also provide the generic version to allow [QueryFilter] to access the controller
             ListenableProvider<FilterController<T>>.value(
               value: context.read<C>(),
               builder: builder,
               child: child,
             ),
       );

  // ignore: use_key_in_widget_constructors
  FilterControllerProvider.value({
    required C value,
    super.child,
    TransitionBuilder? builder,
  }) : super(
         create: (_) => value,
         keys: (_) => [value],
         builder: (context, child) =>
             ListenableProvider<FilterController<T>>.value(
               value: context.read<C>(),
               builder: builder,
               child: child,
             ),
       );
}

typedef FilterableState<T, K> = InfiniteQueryStatus<List<T>, K>;

class QueryFilter<T, K> extends StatefulWidget {
  const QueryFilter({super.key, required this.state, required this.builder});

  final FilterableState<T, K> state;
  final Widget Function(BuildContext context, FilterableState<T, K> state)
  builder;

  @override
  State<QueryFilter<T, K>> createState() => _QueryFilterState<T, K>();
}

class _QueryFilterState<T, K> extends State<QueryFilter<T, K>> {
  final Object _key = Object();
  FilterController<T>? _controller;

  // The flat list built from the state's pages, cached against the
  // state instance and the filter's invalidation generation: a rebuild
  // that hands over the same state (the common one — the query stream
  // did not fire) on the same generation must not re-expand and
  // re-filter hundreds of posts just to produce a fresh identical
  // list. An invalidate() flips the generation — the same data now
  // filters into a different set (a denylist edit, the denying
  // switch), and the stale rechunk must go.
  InfiniteQueryData<List<T>, K>? _flattenedFrom;
  int? _flattenedGeneration;
  late List<T> _flattened;
  // The rechunked pages, cached the same way.
  late List<List<T>> _rechunked;

  @override
  void dispose() {
    _controller?.untrack(_key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FilterController<T>?>();
    if (!identical(_controller, controller)) {
      _controller?.untrack(_key);
      _controller = controller;
      // A different controller judges differently and owns its own
      // generation; the rechunk cached against the old one must not
      // survive the swap.
      _flattenedFrom = null;
      _flattenedGeneration = null;
    }

    final data = widget.state.data;
    if (data == null || controller == null) {
      return widget.builder(context, widget.state);
    }

    List<T> flat;
    List<List<T>> rechunked;
    final generation = controller.generation;
    if (identical(_flattenedFrom, data) && _flattenedGeneration == generation) {
      flat = _flattened;
      rechunked = _rechunked;
    } else {
      flat = data.pages.expand((p) => p).toList();
      // track() runs the filter predicate once over the flat list and
      // caches the result for identical re-tracks; re-chunking then walks
      // the pages once, testing each item against the filtered set.
      final filtered = controller.track(_key, flat);
      final filteredIds = filtered.map(controller.idOf).toSet();
      // Cursor pagination can hand the search two pages that share a post
      // (a refresh racing a page turn); handing the overlap downstream
      // counts it twice in every tag counter. An id already seen in an
      // earlier page is dropped from the later one, which keeps the
      // pages' own order and length budget intact.
      final seenIds = <Object>{};
      rechunked = data.pages
          .map(
            (page) => page
                .where((item) => filteredIds.contains(controller.idOf(item)))
                .where((item) => seenIds.add(controller.idOf(item)))
                .toList(),
          )
          .toList();
      _flattenedFrom = data;
      _flattenedGeneration = generation;
      _flattened = flat;
      _rechunked = rechunked;
    }

    return widget.builder(
      context,
      widget.state.copyWithData(
        InfiniteQueryData(pages: rechunked, args: data.args),
      ),
    );
  }
}
