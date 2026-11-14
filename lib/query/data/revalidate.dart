import 'package:cached_query/cached_query.dart';

/// Extensions that turn a query invalidation into a reportable outcome.
///
/// cached_query never rethrows fetch errors: a refetch swallows its
/// failure into the query state, so callers that rely on exceptions to
/// detect failure, like the pull to refresh indicator, would always
/// report success. The [revalidate] methods restore that signal.
extension QueryRevalidate<T> on Query<T> {
  /// Forces a refetch and reports whether it ended in a success state.
  ///
  /// [refetch] and not [invalidate], because invalidate skips the whole
  /// round trip for a query whose controller holds no registered
  /// listeners — the common case for a page fed through `getNextPage` —
  /// and then a read of the untouched state reports a success that never
  /// reached the network.
  ///
  /// A refetch can also land on a fetch that has already settled: a
  /// subscription that re-arms the query, a connectivity refetch or a
  /// pagination, any fetch whose future finished between its own
  /// completion and the controller releasing the slot it occupies. The
  /// pull would await that settled future, skip the round trip and read
  /// a success whose data was never refreshed off the network. A verdict
  /// whose success predates the refresh itself is exactly that, so it is
  /// re-run; the first await guarantees the slot is free, so the re-run
  /// performs a round trip of its own.
  Future<bool> revalidate() async {
    final DateTime started = DateTime.now();
    QueryStatus<T> state = await refetch();
    for (var attempt = 0; attempt < 2; attempt++) {
      if (state is! QuerySuccess<T>) break;
      if (!state.timeCreated.isBefore(started)) break;
      state = await refetch();
    }
    // Whitelist, not "anything but Error": a fetch adopted from another
    // caller can end non-terminal (Loading) or even Initial; those used
    // to pass as successes here. Only a success state is a success.
    return state is QuerySuccess<T>;
  }
}

extension InfiniteQueryRevalidate<T, Arg> on InfiniteQuery<T, Arg> {
  /// Forces a refetch and reports whether it ended in a success state.
  ///
  /// See [QueryRevalidate.revalidate] for why this goes through [refetch]
  /// instead of [invalidate], and for how a settled fetch that the
  /// refetch would otherwise adopt is detected and re-run.
  Future<bool> revalidate() async {
    final DateTime started = DateTime.now();
    InfiniteQueryStatus<T, Arg> state = await refetch();
    for (var attempt = 0; attempt < 2; attempt++) {
      if (state is! InfiniteQuerySuccess<T, Arg>) break;
      if (!state.timeCreated.isBefore(started)) break;
      state = await refetch();
    }
    // Whitelist, see QueryRevalidate.revalidate.
    return state is InfiniteQuerySuccess<T, Arg>;
  }
}
