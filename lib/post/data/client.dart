import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class PostClient {
  PostClient({
    required this.dio,
    required this.pools,
    required this.tags,
    required this.traits,
    required this.identity,
  });

  final Dio dio;
  final PoolClient pools;
  final TagClient tags;
  final ValueNotifier<Traits> traits;
  final Identity identity;

  Future<Post> get({required int id, CancelToken? cancelToken}) async {
    final response = await dio.get(
      '/posts/$id.json',
      // extended responses carry the uploader_name the parser reads.
      queryParameters: {'mode': 'extended'},
      cancelToken: cancelToken,
    );
    return (await _parse([
      unwrapRailsArray(response).data!,
    ], cancelToken: cancelToken)).single;
  }

  /// [page] is either a 1-based page number or a `b<id>` cursor, which the
  /// server serves with the posts before that id in descending id order.
  ///
  /// Returns the posts the server sends, without client-side removal:
  /// pagination must advance on the raw response, or a page whose items
  /// are all undisplayable would end the list early. Display filtering
  /// happens through [PostFilter].
  Future<List<Post>> page({
    Object? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/posts.json',
      queryParameters: {
        'page': page,
        'limit': limit,
        'mode': 'extended',
        ...?query,
      }.toQuery(),
      cancelToken: cancelToken,
    );
    return _parse(
      unwrapRailsArray(response).data! as List<dynamic>,
      cancelToken: cancelToken,
    );
  }

  /// Parses post payloads and groups their tags by category.
  ///
  /// The post payload lists tag names without categories, so the tag
  /// client classifies them in bulk. Names it cannot resolve (a failed
  /// lookup, unknown tags) stay general: loading posts must not hinge on
  /// the category lookup.
  Future<List<Post>> _parse(
    List<dynamic> raw, {
    CancelToken? cancelToken,
  }) async {
    final posts = raw.map<Post>((post) => E621Post.fromJson(post)).toList();
    if (posts.isEmpty) return posts;
    final names =
        posts.expand((post) => post.tags.values).expand((tags) => tags).toList()
          ..sort();
    final categories = await tags.categories(names, cancelToken: cancelToken);
    if (categories.isEmpty) return posts;
    return [
      for (final post in posts)
        post.copyWith(
          tags: E621Post.groupTags(
            post.tags.values.expand((tags) => tags).toList(),
            categories,
          ),
        ),
    ];
  }

  Future<List<Post>> byIds({
    required List<int> ids,
    bool hidden = false,
    CancelToken? cancelToken,
  }) async {
    if (ids.isEmpty) return [];

    // Server-side maximum id and page request size.
    const int chunkSize = 320;

    List<List<int>> chunks = [];
    for (int i = 0; i < ids.length; i += chunkSize) {
      chunks.add(ids.sublist(i, min(i + chunkSize, ids.length)));
    }

    // The upstream _search helper collapsed into our page request; the
    // byIds semantics (hidden lookups skip the censored-file filter)
    // stay the same.
    List<Post> found = [
      for (final chunk in chunks)
        await page(
          limit: min(chunk.length, maxPageLimit),
          query: {
            'tags': 'id:${chunk.join(',')}${hidden ? ' status:any' : ''}',
          },
          cancelToken: cancelToken,
        ),
    ].expand((list) => list).toList();
    if (!hidden) {
      // Censored posts, which have contentious tags and are unavailable
      // to anonymous users, are also considered broken. Posts which are
      // not deleted but have no file are censored.
      found = found
          .whereNot((post) => !post.isDeleted && post.file == null)
          .whereNot((post) => post.ext == 'swf')
          .toList();
    }
    Map<int, Post> table = {for (Post e in found) e.id: e};
    return ids.map((e) => table[e]).nonNulls.toList();
  }

  /// The posts e621 recommends as similar for [id], in the server's
  /// order. The endpoint answers with summaries only; the full posts
  /// load through the regular page queries.
  Future<List<PartialPost>> artistRecommendations({
    required int id,
    int? limit,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/posts/$id/similar/artist.json',
        queryParameters: {'limit': limit}.toQuery(),
        cancelToken: cancelToken,
      )
      .then((response) {
        final Map<int, PartialPost> posts = {
          for (final PartialPost post
              in (response.data['post_data'] as List).map(
                E621Post.partialFromJson,
              ))
            post.id: post,
        };
        return [
          for (final Map<String, dynamic> result
              in (response.data['results'] as List)
                  .cast<Map<String, dynamic>>())
            if (posts[result['post_id']] case final PartialPost post) post,
        ];
      });

  Future<List<Post>> byTags({
    required List<String> tags,
    int? page,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    page ??= 1;
    // The list is filtered through a copy: it belongs to the caller, and
    // callers embed it in query keys, which an in-place edit would leave
    // behind as a different key.
    tags = tags.where((e) => !e.contains(' ') && !e.contains(':')).toList();
    if (tags.isEmpty) return [];
    int max = 40;
    int pages = (tags.length / max).ceil();
    int chunkSize = (tags.length / pages).ceil();

    int tagPage = page % pages != 0 ? page % pages : pages;
    int sitePage = (page / pages).ceil();

    List<String> chunk = tags
        .sublist((tagPage - 1) * chunkSize)
        .take(chunkSize)
        .toList();
    String filter = chunk.map((e) => '~$e').join(' ');
    return this.page(
      page: sitePage,
      query: {'tags': filter},
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  Future<void> update({required int id, required Map<String, String?> data}) =>
      dio.put('/posts/$id.json', data: FormData.fromMap(data));

  Future<void> vote({
    required int id,
    required bool upvote,
    required bool replace,
  }) => dio.post(
    '/posts/$id/votes.json',
    queryParameters: {'score': upvote ? 1 : -1, 'no_unvote': replace},
  );

  /// Returns the server's favorite posts as-is.
  ///
  /// Like [page], removal of undisplayable posts is a display concern:
  /// filtering here would end page-number pagination early whenever a
  /// favorites page holds only such posts.
  Future<List<Post>> favorites({
    Object? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) async {
    // The query belongs to the caller and doubles as their cache key,
    // so the tags entry is dropped from a copy: an in-place edit
    // would change every later request keyed by the same map.
    final Map<String, String>? filteredQuery = query == null
        ? null
        : (Map<String, String>.of(query)..remove('tags'));
    final response = await dio.get(
      '/favorites.json',
      queryParameters: {
        'page': page,
        'limit': limit,
        'mode': 'extended',
        // may not contain tags, or we get redirected to a html page
        ...?filteredQuery,
      },
      cancelToken: cancelToken,
    );
    return _parse(
      unwrapRailsArray(response).data! as List<dynamic>,
      cancelToken: cancelToken,
    );
  }

  Future<void> addFavorite(int postId, {CancelToken? cancelToken}) => dio.post(
    '/favorites.json',
    queryParameters: {'post_id': postId},
    cancelToken: cancelToken,
  );

  Future<void> removeFavorite(int postId, {CancelToken? cancelToken}) =>
      dio.delete('/favorites/$postId.json', cancelToken: cancelToken);
}
