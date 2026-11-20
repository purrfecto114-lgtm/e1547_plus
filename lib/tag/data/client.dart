import 'dart:math';

import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';

class TagClient {
  TagClient({required this.dio});

  final Dio dio;

  /// Names whose category id is already known, cached for the client's
  /// lifetime: tag categories effectively never change.
  final Map<String, int> _categoryCache = {};

  // Technically missing get()
  Future<List<Tag>> page({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/tags.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        cancelToken: cancelToken,
      )
      .then(unwrapRailsArray)
      .then((response) => response.data.map<Tag>(E621Tag.fromJson).toList());

  Future<List<TagPreview>> preview({
    required String tags,
    CancelToken? cancelToken,
  }) => dio
      .post(
        '/tags/preview.json',
        data: {'tags': tags},
        cancelToken: cancelToken,
      )
      .then(unwrapRailsArray)
      .then(
        (response) => response.data
            .map<TagPreview>(
              (json) => TagPreview.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
      );

  Future<List<Tag>> autocomplete({
    String? search,
    int? limit,
    int? category,
    CancelToken? cancelToken,
  }) async {
    search ??= '';
    if (search.contains(':')) return [];
    if (category == null) {
      if (search.length < 3) return [];
      return dio
          .get(
            '/tags/autocomplete.json',
            queryParameters: {'search[name_matches]': search},
            cancelToken: cancelToken,
          )
          .then(unwrapRailsArray)
          .then(
            (response) =>
                response.data.map<Tag>(E621Tag.fromJson).take(3).toList(),
          );
    } else {
      return page(
        limit: limit,
        query: {
          'search[name_matches]': '$search*',
          'search[category]': category,
          'search[order]': 'count',
        }.toQuery(),
      );
    }
  }

  /// Exact category ids for the given tag names, queried in bulk through
  /// the comma-separated `search[name]` lookup and cached.
  ///
  /// The post payload no longer carries tag categories, so posts ask this
  /// in bulk to group their tags. Names the server does not know (and a
  /// failed lookup, which must not fail the posts it serves for) are left
  /// out, which their parser counts as general.
  Future<Map<String, int>> categories(
    Iterable<String> names, {
    CancelToken? cancelToken,
  }) async {
    final wanted = names.toSet();
    final missing = wanted.difference(_categoryCache.keys.toSet()).toList()
      ..sort();
    // The exact lookup only matches what it is given, and the query url
    // must stay short: 100 names per request is a safe chunk.
    const chunkSize = 100;
    final chunks = [
      for (var start = 0; start < missing.length; start += chunkSize)
        missing.sublist(start, min(start + chunkSize, missing.length)),
    ];
    // A pageful of posts easily misses a thousand distinct names: ten
    // chunks in a row stretched every first page load by ten round
    // trips. A few workers at a time keep the burst polite for the
    // server's rate limit while cutting the wait down to a few.
    const workerCount = 3;
    DioException? cancellation;
    var next = 0;
    Future<void> worker() async {
      while (next < chunks.length) {
        final chunk = chunks[next++];
        try {
          final response = await dio.get(
            '/tags.json',
            queryParameters: {
              'search[name]': chunk.join(','),
              'limit': chunk.length,
            },
            cancelToken: cancelToken,
          );
          final tags = unwrapRailsArray(response).data as List<dynamic>;
          for (final tag in tags) {
            final parsed = E621Tag.fromJson(tag);
            _categoryCache[parsed.name] = parsed.category;
          }
          // A name the lookup answered without is one the server does
          // not know: remembering it as general keeps every later page
          // from re-asking for the same missing tag.
          for (final name in chunk) {
            _categoryCache.putIfAbsent(name, () => 0);
          }
        } on DioException catch (error) {
          if (CancelToken.isCancel(error)) {
            // The cancellation is rethrown once every worker has
            // stopped; rethrowing here directly would orphan the
            // errors of the workers still running.
            cancellation ??= error;
            return;
          }
          // A failed lookup leaves those names uncategorized for now; a
          // later page retries them through the cache miss.
        }
      }
    }

    if (chunks.isNotEmpty) {
      await Future.wait([
        for (var i = 0; i < min(workerCount, chunks.length); i++) worker(),
      ]);
    }
    if (cancellation != null) {
      throw cancellation!;
    }
    return {
      for (final name in wanted)
        if (_categoryCache.containsKey(name)) name: _categoryCache[name]!,
    };
  }

  Future<String?> aliases({
    int? page,
    int? limit,
    QueryMap? query,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/tag_aliases.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        cancelToken: cancelToken,
      )
      .then(unwrapRailsArray)
      .then((response) {
        return (response.data as List)
            .cast<Map<String, dynamic>>()
            .where((e) => e['status'] != 'deleted')
            .map((e) => e['consequent_name'] as String?)
            .firstOrNull;
      });
}
