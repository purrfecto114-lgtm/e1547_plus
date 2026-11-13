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
  /// reached the network. The first refresh may still land on a live
  /// registration and fail honestly, while every later one silently
  /// claims success. Reading the state the refetch itself returned also
  /// keeps another concurrent event from repainting the verdict.
  Future<bool> revalidate() async {
    final QueryStatus<T> state = await refetch();
    return state is! QueryError<T>;
  }
}

extension InfiniteQueryRevalidate<T, Arg> on InfiniteQuery<T, Arg> {
  /// Forces a refetch and reports whether it ended in a success state.
  ///
  /// See [QueryRevalidate.revalidate] for why this goes through [refetch]
  /// instead of [invalidate].
  Future<bool> revalidate() async {
    final InfiniteQueryStatus<T, Arg> state = await refetch();
    return state is! InfiniteQueryError<T, Arg>;
  }
}
