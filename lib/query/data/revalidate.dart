import 'package:cached_query/cached_query.dart';

/// Extensions that turn a query invalidation into a reportable outcome.
///
/// cached_query never rethrows fetch errors: [invalidate] awaits the
/// refetch but swallows its failure into the query state, so callers that
/// rely on exceptions to detect failure, like the pull to refresh
/// indicator, would always report success. The [revalidate] methods
/// restore that signal.
extension QueryRevalidate<T> on Query<T> {
  /// Invalidates the query, awaits the resulting refetch and reports
  /// whether it ended in a success state instead of an error.
  Future<bool> revalidate() async {
    await invalidate();
    return state is! QueryError<T>;
  }
}

extension InfiniteQueryRevalidate<T, Arg> on InfiniteQuery<T, Arg> {
  /// Invalidates the query, awaits the resulting refetch and reports
  /// whether it ended in a success state instead of an error.
  Future<bool> revalidate() async {
    await invalidate();
    return state is! InfiniteQueryError<T, Arg>;
  }
}
