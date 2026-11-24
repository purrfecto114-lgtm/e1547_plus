import 'dart:math';

import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';

/// The highest page number e621 serves, past which it rejects requests.
const int maxSitePage = 750;

/// The `order` values that keep results in descending id order.
///
/// Only these orders honor `b<id>` cursor pagination on the server; any other
/// order makes it silently ignore the cursor and restart from the newest
/// posts, which would duplicate and skip entries. Searches with those orders
/// must therefore paginate by page number, capped at [maxSitePage].
const Set<String?> cursorOrders = {null, 'new', 'id', 'id_desc'};

/// Whether posts for [query] are served in descending id order, making cursor
/// pagination usable for it.
bool servesNewestFirst(QueryMap? query) =>
    cursorOrders.contains(TagMap(query?['tags'])['order']);

/// Bridges per client, so the optimistic-mutation serialization inside
/// [QueryBridge] spans every caller of the same client instead of only the
/// mutations that happened to share one bridge instance — batch tasks and
/// single-item widgets alike.
final Expando<QueryBridge<Post, int>> _postCacheBridges =
    Expando<QueryBridge<Post, int>>();

final Expando<QueryLoader<int, Post>> _postLoaders = Expando();

extension PostQuerying on PostClient {
  static const queryDomain = 'posts';

  List<Object> get queryKey => dio.identityQueryKey(queryDomain);

  CachedQuery get queryCache => dio.queryCache!;

  QueryBridge<Post, int> get postCache => _postCacheBridges[this] ??= queryCache
      .bridge(queryKey, fromJson: Post.fromJson);

  QueryBridge<PartialPost, int> get partialPostCache => queryCache.bridge([
    ...queryKey,
    'partial',
  ], fromJson: PartialPost.fromJson);

  QueryLoader<int, Post> get postLoader => _postLoaders[this] ??= postCache
      .loader((ids) => byIds(ids: ids, hidden: true), limit: maxPageLimit);

  Query<Post> useGet({required int id, bool? vendored}) => Query(
    cache: queryCache,
    key: [...queryKey, id],
    queryFn: () => postLoader.require(id),
    config: postCache.getConfig(vendored: vendored),
  );

  Query<List<PartialPost>> useArtistRecommendations({required int id}) => Query(
    cache: queryCache,
    key: [...queryKey, 'recommendations', 'artist', id],
    queryFn: () async {
      final List<PartialPost> posts = await artistRecommendations(id: id);
      partialPostCache.savePage(posts);
      return posts;
    },
  );

  InfiniteQuery<List<int>, Object> usePageOfIds({required List<int> ids}) =>
      InfiniteQuery<List<int>, Object>(
        cache: queryCache,
        key: [...queryKey, 'page_of_ids', ids.join(',')],
        getNextArg: (state) => state == null || state.args.isEmpty ? 1 : null,
        config: pagedObjectIdConfig(),
        queryFn: (_) => byIds(ids: ids).then(postCache.savePage),
      );

  InfiniteQuery<List<int>, Object> usePage({required QueryMap? query}) {
    final normalized = _normalize(query);
    final tags = TagMap(normalized?['tags']);
    final order = tags['order'];
    final username = identity.username;

    if (tags.length == 2 && order == 'pool') {
      final poolId = int.tryParse(tags['pool'] ?? '');
      if (poolId != null) return useByPool(id: poolId);
    }
    if (tags['id'] case final id? when tags.length == 1 && id.contains(',')) {
      final List<int?> ids = id.split(',').map(int.tryParse).toList();
      if (!ids.contains(null)) return usePageOfIds(ids: ids.nonNulls.toList());
    }
    if (tags.length == 2 && order == 'id') {
      final parentId = int.tryParse(tags['parent'] ?? '');
      if (parentId != null) return useByParent(id: parentId);
    }
    if (tags.length == 2 &&
        order == 'fav' &&
        username != null &&
        tags['fav'] == username) {
      return useFavorites();
    }

    return _usePage(query: normalized);
  }

  QueryMap? _normalize(QueryMap? query) {
    final tags = TagMap(query?['tags']);
    if (tags.length != 1) return query;
    if (tags['order'] != null) return query;

    if (int.tryParse(tags['pool'] ?? '') != null) {
      tags['order'] = 'pool';
      return {...?query, 'tags': tags.toString()};
    }
    final username = identity.username;
    if (username != null && tags['fav'] == username) {
      tags['order'] = 'fav';
      return {...?query, 'tags': tags.toString()};
    }
    return query;
  }

  InfiniteQuery<List<int>, Object> _usePage({required QueryMap? query}) {
    final cursor = servesNewestFirst(query);
    return InfiniteQuery<List<int>, Object>(
      cache: queryCache,
      key: [...queryKey, query],
      getNextArg: (state) => cursor
          ? state.nextCursorPage()
          : state.nextPageArg(maxPage: maxSitePage),
      config: pagedObjectIdConfig(),
      queryFn: (page) =>
          this.page(page: page, query: query).then(postCache.savePage),
    );
  }

  InfiniteQuery<List<int>, Object> useFavorites() =>
      InfiniteQuery<List<int>, Object>(
        cache: queryCache,
        key: [...queryKey, 'favorites'],
        getNextArg: (state) => state.nextPageArg(maxPage: maxSitePage),
        config: pagedObjectIdConfig(),
        queryFn: (page) => favorites(page: page).then(postCache.savePage),
      );

  InfiniteQuery<List<int>, Object> useByPool({required int id}) =>
      InfiniteQuery<List<int>, Object>(
        cache: queryCache,
        key: [...queryKey, 'by_pool', id],
        getNextArg: (state) => state.nextPageArg(),
        config: pagedObjectIdConfig(),
        queryFn: (page) async {
          final poolQuery = pools.useGet(id: id);
          await poolQuery.fetch();
          final pool = poolQuery.state.data;
          if (pool == null) return const [];
          final perPage = traits.value.perPage ?? 75;
          final ids = pool.postIds;
          final lower = ((page as int) - 1) * perPage;
          if (lower >= ids.length) return const [];
          final slice = ids.sublist(lower, min(lower + perPage, ids.length));
          final fetched = await byIds(ids: slice);
          return postCache.savePage(fetched);
        },
      );

  InfiniteQuery<List<int>, Object> useByParent({required int id}) {
    final QueryMap query = {'tags': 'parent:$id order:id'};
    final List<int> children =
        postCache.get(id)?.relationships.children ?? const [];
    return InfiniteQuery<List<int>, Object>(
      cache: queryCache,
      key: [...queryKey, query],
      getNextArg: (state) {
        if (state == null || state.args.isEmpty) return 1;
        if (children.isNotEmpty && children.length <= maxPageLimit) {
          return null;
        }
        return state.nextPageArg();
      },
      config: pagedObjectIdConfig(),
      queryFn: (page) => this
          .page(page: page, limit: maxPageLimit, query: query)
          .then(postCache.savePage),
    );
  }

  InfiniteQuery<List<int>, Object> useByTags({required List<String> tags}) =>
      InfiniteQuery<List<int>, Object>(
        cache: queryCache,
        key: [...queryKey, 'by_tags', tags],
        getNextArg: (state) => state.nextPageArg(maxPage: maxSitePage),
        config: pagedObjectIdConfig(),
        queryFn: (page) async {
          final fetched = await byTags(
            tags: tags,
            page: page as int?,
            // One page must span a whole tag chunk round: a shorter page
            // would hand the merge below half a chunk's posts, and the
            // chunk's other half would arrive on a later page with ids
            // above the ones already shown.
            limit: maxPageLimit,
          );
          postCache.savePage(fetched);
          // The search splits tags into chunks, and every chunk answers
          // newest-first on its own. Gluing those answers together shows
          // chunk-local orderings, which reads as "the newest sort is
          // broken" on a timeline. Sorting the whole page by id — and
          // dropping ids an earlier chunk already served — keeps the
          // merged list globally newest-first.
          final seen = servedByTagsIds(tags);
          return [
            for (final id in [...fetched.map((e) => e.id)]
              ..sort((a, b) => b.compareTo(a)))
              if (seen.add(id)) id,
          ];
        },
      );

  /// The ids already served by the tag search at [tags], or null before
  /// its first page lands. Feeds the duplicate check of the next page.
  Set<int> servedByTagsIds(List<String> tags) => {
    ...?queryCache
        .getQuery<InfiniteQuery<List<int>, Object>>([
          ...queryKey,
          'by_tags',
          tags,
        ])
        ?.state
        .data
        ?.pages
        .expand((page) => page),
  };

  Query<List<Post>> useByIds({required List<int> ids}) => Query(
    cache: queryCache,
    key: [...queryKey, 'ids', ids],
    queryFn: () => byIds(ids: ids, hidden: true).then((fetched) {
      postCache.savePage(fetched);
      return fetched;
    }),
  );

  Mutation<void, PostEdit> useUpdate({required int id}) => Mutation(
    mutationFn: (edit) {
      final body = edit.toForm();
      if (body == null) return Future.value();
      return postCache.optimistic(
        id,
        edit.applyTo,
        () => update(id: id, data: body),
      );
    },
    onSuccess: (_, _) => get(id: id).then(postCache.set).ignore(),
  );

  Mutation<void, VoteRequest> useVote({required int id}) => Mutation(
    mutationFn: (p) {
      final (:upvote, :replace) = p;
      return postCache.optimistic(
        id,
        (post) => post.withVote(upvote: upvote, replace: replace),
        () => vote(id: id, upvote: upvote, replace: replace),
      );
    },
  );

  Mutation<void, int> useAddFavorite() => Mutation(
    mutationFn: (postId) => postCache.optimistic(
      postId,
      (post) => post.copyWith(isFavorited: true, favCount: post.favCount + 1),
      () => addFavorite(postId),
    ),
  );

  Mutation<void, int> useRemoveFavorite() => Mutation(
    mutationFn: (postId) => postCache.optimistic(
      postId,
      (post) => post.copyWith(isFavorited: false, favCount: post.favCount - 1),
      () => removeFavorite(postId),
    ),
  );
}
