import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'fixtures.dart';

class FakeE621 {
  FakeE621._(this.state);

  late final HttpServer _server;
  final FakeE621State state;

  final List<FakeRequest> requests = [];

  String get url => 'http://${_server.address.host}:${_server.port}';

  static Future<FakeE621> start({FakeE621State? state}) async {
    final fake = FakeE621._(state ?? FakeE621State.seeded());
    fake._server = await shelf_io.serve(
      // Tests end right after their last request settled, and a pooled
      // keepalive connection would sit on its idle timer past the end of
      // the fake clock. Closing every response keeps clients from
      // pooling connections at all.
      _closeConnections(
        _stall(_failing(fake._route, () => fake.failing), () => fake.stallFor),
      ),
      InternetAddress.loopbackIPv4,
      0,
    );
    return fake;
  }

  /// Duration a request waits before the route answers it; null (the
  /// default) answers at once. Tests that need a request to be truly
  /// in flight while its owner tears down set this.
  Duration? stallFor;

  /// When set, every request is answered with a 503, regardless of
  /// route: tests use it to observe client behavior on failure states.
  bool failing = false;

  /// Answers every request with a 503 when [FakeE621.failing] is set.
  static Handler _failing(Handler inner, bool Function() failing) =>
      (request) async {
        if (failing()) {
          return Response(503);
        }
        return inner(request);
      };

  /// Holds a request back for [stallFor] before delegating it.
  static Handler _stall(Handler inner, Duration? Function() stall) =>
      (request) async {
        final Duration? delay = stall();
        if (delay != null) {
          await Future<void>.delayed(delay);
        }
        return inner(request);
      };

  /// Marks every response as the last one on its connection.
  static Handler _closeConnections(Handler inner) => (request) async {
    final response = await inner(request);
    return response.change(headers: {HttpHeaders.connectionHeader: 'close'});
  };

  Future<void> stop() => _server.close(force: true);

  late final Router _router = Router()
    // The app's availability probe HEADs the post list; the server
    // dropped /status.json in its november 2026 update.
    ..head('/posts.json', _status)
    ..get('/data/<path|.*>', _serveImage)
    ..get('/posts.json', _listPosts)
    ..get('/favorites.json', _listFavorites)
    ..post('/favorites.json', _addFavorite)
    ..delete('/favorites/<id|[0-9]+>.json', _removeFavorite)
    ..get('/posts/<id|[0-9]+>.json', _showPost)
    ..get('/posts/<id|[0-9]+>/similar/artist.json', _artistRecommendations)
    ..post('/posts/<id|[0-9]+>/votes.json', _votePost)
    ..get('/forum_posts.json', _listReplies)
    ..post('/forum_posts.json', _createReply)
    ..get('/forum_posts/<id|[0-9]+>.json', _showReply)
    ..patch('/forum_posts/<id|[0-9]+>.json', _updateReply)
    ..get('/comments.json', (Request request) => _list(state.comments, request))
    ..post('/comments.json', _createComment)
    ..get(
      '/comments/<id|[0-9]+>.json',
      (Request request, String id) => _json(_find(state.comments, id)),
    )
    ..patch('/comments/<id|[0-9]+>.json', _updateComment)
    ..post('/comments/<id|[0-9]+>/votes.json', _voteComment)
    ..get(
      '/forum_topics.json',
      (Request request) => _list(state.topics, request),
    )
    ..get(
      '/forum_topics/<id|[0-9]+>.json',
      (Request request, String id) => _json(_find(state.topics, id)),
    )
    ..get('/pools.json', (Request request) => _list(state.pools, request))
    ..get(
      '/pools/<id|[0-9]+>.json',
      (Request request, String id) => _json(_find(state.pools, id)),
    )
    ..get('/tags.json', _listTags)
    ..post('/tags/preview.json', _previewTags)
    ..get('/tags/autocomplete.json', _autocompleteTags)
    ..get(
      '/tag_aliases.json',
      (Request request) => _list(state.tagAliases, request),
    )
    ..get('/users.json', (Request request) => _list(state.users, request))
    ..get('/users/<lookup>.json', _showUser)
    ..get('/wiki_pages.json', (Request request) => _list(state.wikis, request))
    ..get('/wiki_pages/<lookup>.json', _showWiki)
    ..get('/post_flags.json', _listFlags)
    ..post('/post_flags.json', _createFlag)
    ..post('/tickets', _createTicket);

  Response _list(List<Map<String, Object?>> items, Request request) =>
      _json(_paginate(items, request.url.queryParameters));

  /// Like the real api since its 2026-11 schema change: the exact,
  /// comma-separated `search[name]` lookup returns every tag whose name is
  /// listed; other queries return all tags unfiltered.
  Response _listTags(Request request) {
    final query = request.url.queryParameters;
    final names = query['search[name]']?.split(',');
    var tags = state.tags;
    if (names != null) {
      tags = tags.where((e) => names.contains(e['name'])).toList();
    }
    return _json(_paginate(tags, query));
  }

  /// The autocomplete endpoint the tag search switched to; it answers
  /// plain tag maps whose name starts with the search, capped at ten.
  Response _autocompleteTags(Request request) {
    final search = request.url.queryParameters['search[name_matches]'] ?? '';
    return _json(
      state.tags
          .where((e) => (e['name']! as String).startsWith(search))
          .take(10)
          .toList(),
    );
  }

  /// The tag editor's preview endpoint: one preview per name in the
  /// posted `tags` string. A name the fake has no record of is answered
  /// bare — no id — exactly the way the real api reports a tag that does
  /// not exist yet, which the editor renders as a new tag instead of
  /// failing the whole preview.
  Response _previewTags(Request request) {
    final params = _params(request);
    final names = (params['tags'] ?? '')
        .split(RegExp(r'\s+'))
        .where((name) => name.isNotEmpty)
        .toList();
    final known = {for (final tag in state.tags) tag['name']! as String: tag};
    return _json([
      for (final name in names)
        if (known.containsKey(name))
          {
            'id': known[name]!['id'],
            'name': name,
            'category': known[name]!['category'],
            'post_count': known[name]!['post_count'],
          }
        else
          {'name': name},
    ]);
  }

  Map<String, Object?> _find(List<Map<String, Object?>> items, String id) =>
      items.firstWhere(
        (e) => e['id'] == int.parse(id),
        orElse: () => throw FakeE621Error(404, 'Not found'),
      );

  Response _showUser(Request request, String lookup) =>
      _json(_lookup([state.user], lookup, 'name'));

  Response _showWiki(Request request, String lookup) =>
      _json(_lookup(state.wikis, lookup, 'title'));

  Map<String, Object?> _lookup(
    List<Map<String, Object?>> items,
    String lookup,
    String field,
  ) {
    final name = Uri.decodeComponent(lookup);
    final id = int.tryParse(name);
    return items.firstWhere(
      (e) => id != null ? e['id'] == id : e[field] == name,
      orElse: () => throw FakeE621Error(404, 'Not found'),
    );
  }

  Response _createComment(Request request) {
    final fields = _permit(_params(request), 'comment', [
      'body',
      'post_id',
      'do_not_bump_post',
    ]);
    _requirePresent(fields, 'body');
    final postId = _requireInt(fields, 'post_id');
    if (!state.posts.any((e) => e['id'] == postId)) {
      throw FakeE621Error(404, 'Not found');
    }
    return _json(
      state.addComment(postId: postId, body: fields['body']!),
      status: 201,
    );
  }

  Response _updateComment(Request request, String id) {
    final fields = _permit(_params(request), 'comment', ['body']);
    _requirePresent(fields, 'body');
    final comment = _find(state.comments, id);
    comment['body'] = fields['body'];
    return _json(comment);
  }

  Response _listFlags(Request request) {
    final type = request.url.queryParameters['search[type]'];
    final flags = switch (type) {
      'deletion' => state.flags.where((e) => e['is_deletion'] == true),
      'flag' => state.flags.where((e) => e['is_deletion'] == false),
      _ => state.flags,
    };
    return _list(flags.toList(), request);
  }

  Response _createFlag(Request request) {
    final fields = _permit(_params(request), 'post_flag', [
      'post_id',
      'reason_name',
      'parent_id',
      'note',
    ]);
    _requireInt(fields, 'post_id');
    _requirePresent(fields, 'reason_name');
    return _json({'id': 1, ...fields}, status: 201);
  }

  Future<Response> _route(Request request) async {
    final params = {
      ...request.url.queryParameters,
      ...await _readBody(request),
    };
    requests.add(
      FakeRequest(
        method: request.method,
        path: '/${request.url.path}',
        query: request.url.queryParameters,
        body: params,
      ),
    );
    try {
      return await _router.call(request.change(context: {'params': params}));
    } on FakeE621Error catch (e) {
      return _json({'message': e.message}, status: e.status);
    }
  }

  static final Uint8List _pixel = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGM4ceIEAAS0Al'
    'kWLoFAAAAAAElFTkSuQmCC',
  );

  Response _serveImage(Request request, String path) => Response.ok(
    _pixel,
    headers: {HttpHeaders.contentTypeHeader: 'image/png'},
  );

  Map<String, String> _params(Request request) =>
      request.context['params']! as Map<String, String>;

  Response _listPosts(Request request) {
    final query = request.url.queryParameters;
    var posts = state.posts;
    final tags = query['tags'] ?? '';
    final ids = RegExp(r'^id:([\d,]+)$').firstMatch(tags);
    if (ids != null) {
      final wanted = ids.group(1)!.split(',').map(int.parse).toSet();
      posts = posts.where((e) => wanted.contains(e['id'])).toList();
    }
    final userMatch = RegExp(r'^user:(.+)$').firstMatch(tags);
    if (userMatch != null) {
      final Object? id = [
        state.user,
        ...state.users,
      ].where((e) => e['name'] == userMatch.group(1)).firstOrNull?['id'];
      posts = posts.where((e) => e['uploader_id'] == id).toList();
    }
    final faved = RegExp(r'^fav:(.+)$').firstMatch(tags);
    if (faved != null) {
      final String name = faved.group(1)!;
      if (state.privateFavorites.contains(name)) {
        throw FakeE621Error(403, "This user's favorites are hidden");
      }
      final Set<int> wanted = state.favoritesOf[name] ?? const {};
      posts = posts.where((e) => wanted.contains(e['id'])).toList();
    }
    return _json(_paginate(_renderPosts(posts, request), query));
  }

  /// Like the real api's `mode=extended` query: the default post list
  /// carries a flat tag list, and the extended mode groups tags by
  /// category. The client sends extended on every posts request, so the
  /// fake answering with one fixed shape would hide drift between the
  /// parser and either live shape.
  List<Map<String, Object?>> _renderPosts(
    List<Map<String, Object?>> posts,
    Request request,
  ) {
    if (request.url.queryParameters['mode'] != 'extended') return posts;
    return [
      for (final Map<String, Object?> post in posts)
        {
          ...post,
          'tags': {
            // The category names the real api groups under, in its id
            // order; the fake's tag state maps names to categories.
            for (final MapEntry<String, int> category in _categoryIds.entries)
              category.key: [
                for (final String tag
                    in ((post['tags'] as List?) ?? const [])
                        .whereType<String>()
                        .where(
                          (tag) => _fixtureTagCategories[tag] == category.value,
                        ))
                  tag,
              ],
          },
        },
    ];
  }

  /// The category names the real api groups extended tags under, in its
  /// id order; every category key appears in a grouping, empty or not.
  static const Map<String, int> _categoryIds = {
    'general': 0,
    'artist': 1,
    'contributor': 2,
    'copyright': 3,
    'character': 4,
    'species': 5,
    'invalid': 6,
    'meta': 7,
    'lore': 8,
  };

  /// The baked-in category of every fixture tag name. The extended
  /// grouping reads this table instead of the /tags.json state: on the
  /// real server the grouping is internal knowledge a failing lookup
  /// cannot ungroup, and tests clear the lookup state on purpose.
  static const Map<String, int> _fixtureTagCategories = {
    'some_artist': 1,
    'other_artist': 1,
    'tag_1': 0,
    'tag_10': 0,
    'tag_100': 5,
    'tag_101': 5,
    'tag_102': 5,
    'tag_103': 5,
    'tag_104': 5,
    'tag_105': 7,
    'tag_106': 7,
    'tag_107': 7,
    'tag_108': 7,
    'tag_109': 7,
    'tag_11': 0,
    'tag_110': 7,
    'tag_111': 7,
    'tag_112': 7,
    'tag_113': 8,
    'tag_114': 0,
    'tag_115': 0,
    'tag_116': 0,
    'tag_117': 0,
    'tag_118': 0,
    'tag_119': 0,
    'tag_12': 0,
    'tag_120': 0,
    'tag_121': 0,
    'tag_122': 0,
    'tag_123': 0,
    'tag_124': 0,
    'tag_125': 0,
    'tag_126': 0,
    'tag_127': 0,
    'tag_128': 0,
    'tag_129': 0,
    'tag_13': 0,
    'tag_130': 0,
    'tag_131': 0,
    'tag_132': 0,
    'tag_133': 0,
    'tag_134': 0,
    'tag_135': 0,
    'tag_136': 1,
    'tag_137': 3,
    'tag_138': 4,
    'tag_139': 5,
    'tag_14': 0,
    'tag_140': 5,
    'tag_141': 5,
    'tag_142': 5,
    'tag_143': 7,
    'tag_144': 7,
    'tag_145': 7,
    'tag_146': 7,
    'tag_15': 0,
    'tag_16': 0,
    'tag_17': 0,
    'tag_18': 0,
    'tag_19': 0,
    'tag_2': 0,
    'tag_20': 0,
    'tag_21': 0,
    'tag_22': 0,
    'tag_23': 0,
    'tag_24': 0,
    'tag_25': 0,
    'tag_26': 0,
    'tag_27': 0,
    'tag_28': 0,
    'tag_29': 0,
    'tag_3': 0,
    'tag_30': 0,
    'tag_31': 0,
    'tag_32': 1,
    'tag_33': 5,
    'tag_34': 5,
    'tag_35': 5,
    'tag_36': 5,
    'tag_37': 5,
    'tag_38': 7,
    'tag_39': 7,
    'tag_4': 0,
    'tag_40': 7,
    'tag_41': 7,
    'tag_42': 7,
    'tag_43': 7,
    'tag_44': 7,
    'tag_45': 7,
    'tag_46': 7,
    'tag_47': 0,
    'tag_48': 0,
    'tag_49': 0,
    'tag_5': 0,
    'tag_50': 0,
    'tag_51': 0,
    'tag_52': 0,
    'tag_53': 0,
    'tag_54': 0,
    'tag_55': 0,
    'tag_56': 0,
    'tag_57': 0,
    'tag_58': 0,
    'tag_59': 0,
    'tag_6': 0,
    'tag_60': 0,
    'tag_61': 0,
    'tag_62': 0,
    'tag_63': 0,
    'tag_64': 0,
    'tag_65': 0,
    'tag_66': 0,
    'tag_67': 0,
    'tag_68': 0,
    'tag_69': 0,
    'tag_7': 0,
    'tag_70': 0,
    'tag_71': 0,
    'tag_72': 0,
    'tag_73': 0,
    'tag_74': 0,
    'tag_75': 0,
    'tag_76': 0,
    'tag_77': 0,
    'tag_78': 0,
    'tag_79': 0,
    'tag_8': 0,
    'tag_80': 0,
    'tag_81': 0,
    'tag_82': 0,
    'tag_83': 0,
    'tag_84': 0,
    'tag_85': 0,
    'tag_86': 0,
    'tag_87': 0,
    'tag_88': 0,
    'tag_89': 0,
    'tag_9': 0,
    'tag_90': 0,
    'tag_91': 0,
    'tag_92': 0,
    'tag_93': 1,
    'tag_94': 1,
    'tag_95': 3,
    'tag_96': 3,
    'tag_97': 4,
    'tag_98': 4,
    'tag_99': 5,
  };

  /// The site status. Like the real api, bad basic credentials are a 401:
  /// the app's login verification HEADs this endpoint before storing an
  /// identity, so it must be able to see a rejection here.
  Response _status(Request request) {
    final header = request.headers[HttpHeaders.authorizationHeader];
    if (header != null) {
      final match = RegExp(r'Basic (\S+)').firstMatch(header);
      if (match != null) {
        final decoded = utf8.decode(base64Decode(match.group(1)!));
        final separator = decoded.indexOf(':');
        final username = separator == -1
            ? decoded
            : decoded.substring(0, separator);
        final password = separator == -1
            ? ''
            : decoded.substring(separator + 1);
        if (username != (state.user['name'] as String?) || password != 'key') {
          throw FakeE621Error(401, 'Invalid credentials');
        }
      }
    }
    return _json({'online': true});
  }

  Response _addFavorite(Request request) {
    final int id = int.parse(request.url.queryParameters['post_id']!);
    final post = _find(state.posts, '$id');
    state.favorites.add(id);
    // The real api answers with the post's own live favourite count
    // (FavoriteManager.add! then @post.fav_count), not the size of the
    // account's favourites set.
    final Map stats = post['stats']! as Map;
    final int count = (stats['fav_count']! as int) + 1;
    stats['fav_count'] = count;
    return _json({'post_id': id, 'favorite_count': count});
  }

  Response _removeFavorite(Request request, String id) {
    final int postId = int.parse(id);
    final post = _find(state.posts, '$postId');
    state.favorites.remove(postId);
    // The real api answers the delete with the post's live favourite
    // count, not a bare no-content.
    final Map stats = post['stats']! as Map;
    final int count = math.max((stats['fav_count']! as int) - 1, 0);
    stats['fav_count'] = count;
    return _json({'post_id': postId, 'favorite_count': count});
  }

  Response _listFavorites(Request request) {
    final query = request.url.queryParameters;
    if (query['user_id'] == null && _username(request) == null) {
      throw FakeE621Error(404, 'Not found');
    }
    final favorites = state.posts
        .where((e) => state.favorites.contains(e['id']))
        .toList();
    return _json(_paginate(favorites, query));
  }

  String? _username(Request request) {
    final header = request.headers[HttpHeaders.authorizationHeader];
    if (header == null) return null;
    final match = RegExp(r'Basic (\S+)').firstMatch(header);
    if (match == null) return null;
    final decoded = utf8.decode(base64Decode(match.group(1)!));
    final separator = decoded.indexOf(':');
    if (separator == -1) return null;
    return decoded.substring(0, separator);
  }

  /// Posts sharing an artist tag with the referenced one, in the
  /// shape the recommendation endpoint answers with: unlike every
  /// other posts route, its post_data summaries carry the legacy flat
  /// layout (file_url and friends, space-separated tags), so the fake
  /// projects the v2 post state down into it. Artist names come from
  /// the fixture category table, the same knowledge the real server
  /// has internally.
  Response _artistRecommendations(Request request, String id) {
    final Map<String, Object?> post = _find(state.posts, id);
    List<Object?> artists(Map<String, Object?> post) =>
        ((post['tags'] as List?) ?? const [])
            .whereType<String>()
            .where((tag) => _fixtureTagCategories[tag] == 1)
            .toList();
    // The legacy summary layout, straight from the live endpoint.
    Map<String, Object?> summary(Map<String, Object?> e) {
      final Map files = e['files'] as Map? ?? const {};
      final Map meta = files['meta'] as Map? ?? const {};
      final Map stats = e['stats'] as Map? ?? const {};
      final Map original = files['original'] as Map? ?? const {};
      final Map sample = files['sample'] as Map? ?? const {};
      final Map preview = files['preview'] as Map? ?? const {};
      final Map score = stats['score'] as Map? ?? const {};
      return {
        'id': e['id'],
        'created_at': e['created_at'],
        'uploader': e['uploader_name'],
        'uploader_id': e['uploader_id'],
        'file_url': original['url'],
        'sample_url': sample['jpg'],
        'preview_url': preview['jpg'],
        'width': original['width'],
        'height': original['height'],
        'file_ext': meta['ext'],
        'size': meta['size'],
        'score': score['total'],
        'fav_count': stats['fav_count'],
        'is_favorited': stats['is_favorited'],
        'vote': stats['vote'],
        'comment_count': stats['comment_count'],
        'rating': e['rating'],
        // The server joins flat tags and flag words with spaces.
        'tags': ((e['tags'] as List?) ?? const []).whereType<String>().join(
          ' ',
        ),
        'pools': ((e['pools'] as List?) ?? const [])
            .map((pool) => '$pool')
            .join(' '),
        'flags': (e['flags']! as Map)['deleted'] == true ? 'deleted' : '',
      };
    }

    final int limit = int.parse(request.url.queryParameters['limit'] ?? '6');
    final List<Map<String, Object?>> similar = state.posts
        .where((e) => e['id'] != post['id'])
        .where((e) => artists(e).any(artists(post).contains))
        .take(limit)
        .toList();
    return _json({
      'post_id': post['id'],
      'model_version': 'os.artist',
      'results': [
        for (final Map<String, Object?> e in similar)
          {'post_id': e['id'], 'score': 1, 'explanation': null},
      ],
      'post_data': [
        // post_data arrives sorted by id, like the live endpoint;
        // results carries the recommendation order.
        for (final Map<String, Object?> e in similar.reversed) summary(e),
      ],
    });
  }

  Response _showPost(Request request, String id) {
    final post = state.posts.firstWhere(
      (e) => e['id'] == int.parse(id),
      orElse: () => throw FakeE621Error(404, 'Not found'),
    );
    return _json(post);
  }

  Response _votePost(Request request, String id) {
    final query = request.url.queryParameters;
    final score = int.tryParse(query['score'] ?? '');
    if (score != 1 && score != -1) {
      throw FakeE621Error(
        422,
        'score must be 1 or -1, got "${query['score']}"',
      );
    }
    if (!{'true', 'false'}.contains(query['no_unvote'])) {
      throw FakeE621Error(
        422,
        'no_unvote must be a boolean, got "${query['no_unvote']}"',
      );
    }
    final post = state.posts.firstWhere(
      (e) => e['id'] == int.parse(id),
      orElse: () => throw FakeE621Error(404, 'Not found'),
    );
    final scores = post['stats']! as Map;
    final total = (scores['score']! as Map)['total']! as int;
    final up = (scores['score']! as Map)['up']! as int;
    final down = (scores['score']! as Map)['down']! as int;
    // The real api answers with the post's live totals and the voter's
    // own score, and the totals stick (VoteManager updates the row);
    // the fake mutates them too, so repeated votes stay faithful.
    final int newTotal = total + score!;
    final int newUp = up + (score == 1 ? 1 : 0);
    final int newDown = down + (score == -1 ? 1 : 0);
    (scores['score'] as Map)['total'] = newTotal;
    (scores['score'] as Map)['up'] = newUp;
    (scores['score'] as Map)['down'] = newDown;
    return _json({
      'score': newTotal,
      'up': newUp,
      'down': newDown,
      'our_score': score,
    });
  }

  /// The vote response in the shape the server's 2026-11 schema change
  /// moved it to: a `vote` field instead of `our_score`. A client that
  /// consumes the response body would break on this; the app ignores it.
  Response _voteComment(Request request, String id) {
    final query = request.url.queryParameters;
    final score = int.tryParse(query['score'] ?? '');
    if (score != 1 && score != -1) {
      throw FakeE621Error(
        422,
        'score must be 1 or -1, got "${query['score']}"',
      );
    }
    if (!{'true', 'false'}.contains(query['no_unvote'])) {
      throw FakeE621Error(
        422,
        'no_unvote must be a boolean, got "${query['no_unvote']}"',
      );
    }
    final comment = _find(state.comments, id);
    return _json({'score': (comment['score']! as int) + score!, 'vote': score});
  }

  Response _listReplies(Request request) {
    final query = request.url.queryParameters;
    final topicId = query['search[topic_id]'];
    var replies = state.replies.where(
      (e) => topicId == null || e['topic_id'].toString() == topicId,
    );
    if (query['search[order]'] == 'id_desc') {
      replies = replies.toList().reversed;
    }
    return _json(_paginate(replies.toList(), query));
  }

  Response _createReply(Request request) {
    final fields = _permit(_params(request), 'forum_post', [
      'body',
      'topic_id',
    ]);
    final topicId = _requireInt(fields, 'topic_id');
    _requirePresent(fields, 'body');
    if (!state.topics.any((e) => e['id'] == topicId)) {
      throw FakeE621Error(404, 'Topic ID is invalid');
    }
    if (state.lockedTopics.contains(topicId)) {
      throw FakeE621Error(422, 'Topic does not allow replies');
    }
    return _json(
      state.addReply(topicId: topicId, body: fields['body']!),
      status: 201,
    );
  }

  Response _showReply(Request request, String id) =>
      _json(_reply(int.parse(id)));

  Response _updateReply(Request request, String id) {
    final fields = _permit(_params(request), 'forum_post', ['body']);
    _requirePresent(fields, 'body');
    final reply = _reply(int.parse(id));
    reply['body'] = fields['body'];
    reply['updated_at'] = DateTime.now().toIso8601String();
    return _json(reply);
  }

  Response _createTicket(Request request) {
    final fields = _permit(_params(request), 'ticket', [
      'qtype',
      'disp_id',
      'reason',
      'report_reason',
    ]);
    if (!_validQtypes.contains(fields['qtype'])) {
      throw FakeE621Error(422, 'qtype is not valid');
    }
    _requireInt(fields, 'disp_id');
    _requirePresent(fields, 'reason');
    final reportReason = fields['report_reason'];
    if (reportReason != null) {
      final id = int.tryParse(reportReason);
      if (id == null || !state.reportReasons.contains(id)) {
        throw FakeE621Error(
          422,
          'report_reason must reference a post report reason, '
          'got "$reportReason"',
        );
      }
    }
    return Response(302, headers: {HttpHeaders.locationHeader: '/tickets/1'});
  }

  Map<String, Object?> _reply(int id) => state.replies.firstWhere(
    (e) => e['id'] == id,
    orElse: () => throw FakeE621Error(404, 'Not found'),
  );

  static const _validQtypes = {
    'user',
    'dmail',
    'comment',
    'forum',
    'blip',
    'wiki',
    'pool',
    'set',
    'post',
  };

  /// Reads `name[field]` params, throwing when a field is not in [allowed].
  ///
  /// We throw to enforce validity in clients, unlike Rails which ignores extra parameters.
  Map<String, String> _permit(
    Map<String, String> params,
    String name,
    List<String> allowed,
  ) {
    final fields = <String, String>{};
    for (final entry in params.entries) {
      final match = RegExp('^$name\\[([a-z_]+)\\]\$').firstMatch(entry.key);
      if (match == null) continue;
      final field = match.group(1)!;
      if (!allowed.contains(field)) {
        throw FakeE621Error(
          400,
          'unpermitted parameter $name[$field], allowed: $allowed',
        );
      }
      fields[field] = entry.value;
    }
    return fields;
  }

  void _requirePresent(Map<String, String> fields, String key) {
    if ((fields[key] ?? '').isEmpty) {
      throw FakeE621Error(422, '$key cannot be blank');
    }
  }

  int _requireInt(Map<String, String> fields, String key) {
    final value = int.tryParse(fields[key] ?? '');
    if (value == null) {
      throw FakeE621Error(422, '$key must be an integer, got "${fields[key]}"');
    }
    return value;
  }

  static const int recordsPerPage = 75;
  static const int maxPerPage = 320;
  static const int maxNumberedPages = 750;

  List<Object?> _paginate(
    List<Map<String, Object?>> items,
    Map<String, String> query,
  ) {
    final limit = _parseLimit(query['limit']);
    final (page, anchor) = _parsePageParams(query);
    if (anchor != null) {
      // e621 serves the posts before a cursor anchor in descending id order,
      // while our fixtures are stored ascending, so sort them.
      final remaining = items.where((e) => (e['id']! as int) < anchor).toList()
        ..sort((a, b) => (b['id']! as int).compareTo(a['id']! as int));
      if (limit == 0 || remaining.isEmpty) return const [];
      return remaining.sublist(0, limit.clamp(0, remaining.length));
    }
    final start = (page - 1) * limit;
    if (limit == 0 || start >= items.length) return const [];
    return items.sublist(start, (start + limit).clamp(0, items.length));
  }

  /// Parses the `page` parameter into a 1-based page number and, for a `b<id>`
  /// cursor request, the anchor id the server may honor.
  ///
  /// A cursor combined with an `order` tag that does not sort by descending id
  /// is parsed as page 1: the real e621 api silently ignores cursors for those
  /// orders and serves the first page instead, and since this fake does not
  /// implement order sorting, page 1 is exactly what it serves too.
  (int, int?) _parsePageParams(Map<String, String> query) {
    final page = query['page'];
    final cursor = page == null ? null : RegExp(r'^b(\d+)$').firstMatch(page);
    if (cursor != null) {
      if (_cursorOrder(query['tags'])) {
        return (1, int.parse(cursor.group(1)!));
      }
      return (1, null);
    }
    return (_parsePage(page), null);
  }

  /// Whether the `order` tags sort results by descending id, the only orders
  /// the real e621 api honors cursors for.
  bool _cursorOrder(String? tags) {
    for (final tag in (tags ?? '').split(' ')) {
      final order = RegExp(r'^order:(.+)$').firstMatch(tag);
      if (order != null && !{'new', 'id', 'id_desc'}.contains(order.group(1))) {
        return false;
      }
    }
    return true;
  }

  /// An invalid page or limit is [410].
  int _parseLimit(String? limit) {
    if (limit == null || limit.isEmpty) return recordsPerPage;
    final value = int.tryParse(limit);
    if (value == null || !RegExp(r'^\d+$').hasMatch(limit)) {
      throw FakeE621Error(410, 'Invalid limit.');
    }
    if (value < 0 || value > maxPerPage) {
      throw FakeE621Error(410, 'Limit must be between 0 and $maxPerPage.');
    }
    return value;
  }

  int _parsePage(String? page) {
    if (page == null || page.isEmpty) return 1;
    if (RegExp(r'^[ab]\d+$').hasMatch(page)) {
      throw FakeE621Error(501, 'sequential pagination is not implemented');
    }
    final value = int.tryParse(page);
    if (value == null || !RegExp(r'^\d+$').hasMatch(page)) {
      throw FakeE621Error(410, 'Invalid page number.');
    }
    if (value < 1) throw FakeE621Error(410, 'Invalid page number.');
    if (value > maxNumberedPages) {
      throw FakeE621Error(410, 'You cannot go beyond page $maxNumberedPages.');
    }
    return value;
  }

  Future<Map<String, String>> _readBody(Request request) async {
    final header = request.headers[HttpHeaders.contentTypeHeader];
    if (header == null) return {};
    final type = ContentType.parse(header);
    if (type.mimeType == 'multipart/form-data') {
      final boundary = type.parameters['boundary'];
      if (boundary == null) return {};
      final fields = <String, String>{};
      final parts = MimeMultipartTransformer(boundary).bind(request.read());
      await for (final part in parts) {
        final disposition = part.headers['content-disposition'] ?? '';
        final name = RegExp('name="([^"]*)"').firstMatch(disposition);
        final value = await utf8.decodeStream(part);
        if (name != null) fields[name.group(1)!] = value;
      }
      return fields;
    }
    if (type.mimeType == 'application/x-www-form-urlencoded') {
      return Uri.splitQueryString(await request.readAsString());
    }
    if (type.mimeType == 'application/json') {
      final decoded = jsonDecode(await request.readAsString());
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    }
    return {};
  }

  Response _json(Object? body, {int status = 200}) => Response(
    status,
    body: jsonEncode(body).replaceAll(fixtureHost, url),
    headers: {HttpHeaders.contentTypeHeader: ContentType.json.toString()},
  );
}

class FakeE621Error implements Exception {
  FakeE621Error(this.status, this.message);

  final int status;
  final String message;

  @override
  String toString() => 'FakeE621Error($status): $message';
}

class FakeRequest {
  FakeRequest({
    required this.method,
    required this.path,
    required this.query,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, String> query;
  final Map<String, String> body;

  @override
  String toString() => '$method $path $query $body';
}

class FakeE621State {
  FakeE621State({
    required this.posts,
    required this.favorites,
    required this.topics,
    required this.replies,
    required this.comments,
    required this.pools,
    required this.tags,
    required this.tagAliases,
    required this.users,
    required this.user,
    required this.wikis,
    required this.flags,
    required this.lockedTopics,
    required this.reportReasons,
  });

  factory FakeE621State.seeded({
    int? posts,
    int? topics,
    int? replies,
    int? comments,
  }) {
    final recordedTopics = _repeat(loadFixtureList('topics.json'), topics);
    final locked = recordedTopics[1];
    locked['is_locked'] = true;
    return FakeE621State(
      posts: _repeat(loadFixtureList('posts.json'), posts),
      favorites: {},
      topics: recordedTopics,
      replies: _repeat(loadFixtureList('replies.json'), replies),
      comments: _repeat(loadFixtureList('comments.json'), comments),
      pools: loadFixtureList('pools.json'),
      tags: loadFixtureList('tags.json'),
      tagAliases: loadFixtureList('tag_aliases.json'),
      users: loadFixtureList('users.json'),
      user: loadFixtureList('user.json').first,
      wikis: loadFixtureList('wiki_pages.json'),
      flags: loadFixtureList('flags.json'),
      lockedTopics: {locked['id']! as int},
      reportReasons: _postReportReasonIds,
    );
  }

  static const Set<int> _postReportReasonIds = {1, 2, 3, 4, 5, 6};

  static List<Map<String, Object?>> _repeat(
    List<Map<String, Object?>> templates,
    int? count,
  ) {
    if (count == null) return templates;
    final next =
        templates.map((e) => e['id']! as int).reduce((a, b) => a > b ? a : b) +
        1;
    return List.generate(count, (index) {
      final template = templates[index % templates.length];
      return {
        ...jsonDecode(jsonEncode(template)) as Map<String, Object?>,
        'id': next + index,
      };
    });
  }

  final List<Map<String, Object?>> posts;
  final Set<int> favorites;

  /// Per-user favorites, keyed by username; the `fav:` metatag reads these.
  final Map<String, Set<int>> favoritesOf = {};

  /// Users whose favorites the server hides from others.
  final Set<String> privateFavorites = {};
  final List<Map<String, Object?>> topics;
  final List<Map<String, Object?>> replies;
  final List<Map<String, Object?>> comments;
  final List<Map<String, Object?>> pools;
  final List<Map<String, Object?>> tags;
  final List<Map<String, Object?>> tagAliases;
  final List<Map<String, Object?>> users;

  /// `/users/<id>` returns more fields than `/users`.
  final Map<String, Object?> user;
  final List<Map<String, Object?>> wikis;
  final List<Map<String, Object?>> flags;
  final Set<int> lockedTopics;
  final Set<int> reportReasons;

  int _nextId = 100;

  Map<String, Object?> addComment({required int postId, required String body}) {
    final now = DateTime.now().toIso8601String();
    final comment = <String, Object?>{
      ...jsonDecode(jsonEncode(comments.first)) as Map<String, Object?>,
      'id': _nextId++,
      'post_id': postId,
      'body': body,
      'created_at': now,
      'updated_at': now,
    };
    comments.add(comment);
    return comment;
  }

  Map<String, Object?> addReply({required int topicId, required String body}) {
    final now = DateTime.now().toIso8601String();
    final reply = <String, Object?>{
      'id': _nextId++,
      'creator_id': 2,
      'creator_name': 'tester',
      'created_at': now,
      'updated_at': now,
      'updater_id': null,
      'updater_name': null,
      'body': body,
      'topic_id': topicId,
      'warning_type': null,
      'is_hidden': false,
    };
    replies.add(reply);
    return reply;
  }
}
