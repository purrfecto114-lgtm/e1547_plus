import 'dart:math';

import 'package:dio/dio.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class PostClient {
  PostClient({
    required this.dio,
    required this.pools,
    required this.traits,
    required this.identity,
  });

  final Dio dio;
  final PoolClient pools;
  final ValueNotifier<Traits> traits;
  final Identity identity;

  Future<Post> get({required int id, CancelToken? cancelToken}) => dio
      .get('/posts/$id.json', cancelToken: cancelToken)
      .then(unwrapRailsArray)
      .then((response) => E621Post.fromJson(response.data));

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
  }) => dio
      .get(
        '/posts.json',
        queryParameters: {'page': page, 'limit': limit, ...?query}.toQuery(),
        cancelToken: cancelToken,
      )
      .then(unwrapRailsArray)
      .then(
        (response) =>
            (response.data as List).map<Post>(E621Post.fromJson).toList(),
      );

  Future<List<Post>> byIds({
    required List<int> ids,
    CancelToken? cancelToken,
  }) async {
    if (ids.isEmpty) return [];

    // Server-side maximum id and page request size.
    const int chunkSize = 320;

    List<List<int>> chunks = [];
    for (int i = 0; i < ids.length; i += chunkSize) {
      chunks.add(ids.sublist(i, min(i + chunkSize, ids.length)));
    }

    List<Post> result = [];
    for (final chunk in chunks) {
      String filter = 'id:${chunk.join(',')}';
      List<Post> part = await page(
        query: {'tags': filter},
        limit: chunk.length,
        cancelToken: cancelToken,
      );
      Map<int, Post> table = {for (Post e in part) e.id: e};
      result.addAll(
        (chunk.map((e) => table[e]).toList()..removeWhere((e) => e == null))
            .cast<Post>(),
      );
    }
    return result;
  }

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
  }) {
    // The query belongs to the caller and doubles as their cache key,
    // so the tags entry is dropped from a copy: an in-place edit
    // would change every later request keyed by the same map.
    final Map<String, String>? filteredQuery = query == null
        ? null
        : (Map<String, String>.of(query)..remove('tags'));
    return dio
        .get(
          '/favorites.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            // may not contain tags, or we get redirected to a html page
            ...?filteredQuery,
          },
          cancelToken: cancelToken,
        )
        .then(unwrapRailsArray)
        .then(
          (response) =>
              (response.data as List).map<Post>(E621Post.fromJson).toList(),
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
