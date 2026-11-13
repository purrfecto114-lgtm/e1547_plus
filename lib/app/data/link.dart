import 'dart:io';

import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as tabs;
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:url_launcher/url_launcher.dart' as urls;

Future<void> launch(String url) async {
  Uri uri = Uri.parse(url);
  if ((Platform.isAndroid || Platform.isIOS) &&
      ['e621.net', 'e926.net'].contains(uri.host)) {
    await tabs.launchUrl(
      uri,
      customTabsOptions: const tabs.CustomTabsOptions(
        browser: tabs.CustomTabsBrowserConfiguration(
          prefersDefaultBrowser: true,
        ),
      ),
    );
  } else {
    await urls.launchUrl(uri, mode: urls.LaunchMode.externalApplication);
  }
}

const String queryDivider = r'[^\s/?&#]';
const String _showEnding = r':_(s|/show)';

enum LinkType { post, pool, user, wiki, topic, reply }

class Link {
  const Link({required this.type, this.id, this.query});

  final LinkType type;
  final Object? id;
  final Map<String, String>? query;
}

@immutable
// ignore: one_member_abstracts
abstract class LinkParser {
  const LinkParser();

  Link? parse(String link);
}

class LeafLinkParser extends LinkParser {
  const LeafLinkParser({required this.path, required this.transformer});

  final String path;
  final Link? Function(Map<String, String> args, Map<String, String>? query)
  transformer;

  @override
  Link? parse(String link) {
    Uri? uri = Uri.tryParse(link);
    if (uri == null) return null;

    String path = uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    List<String> names = [];
    Match? match = pathToRegExp(
      this.path,
      parameters: names,
      caseSensitive: false,
    ).firstMatch(path);

    if (match != null) {
      Map<String, String> arguments = extract(names, match);
      Map<String, String>? query = uri.queryParameters;
      if (query.isEmpty) query = null;
      return transformer(arguments, query);
    }

    return null;
  }
}

abstract class BranchLinkParser extends LinkParser {
  const BranchLinkParser();

  List<LinkParser> get parsers;

  @override
  Link? parse(String link) {
    for (LinkParser parser in parsers) {
      Link? result = parser.parse(link);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

class E621LinkParser extends BranchLinkParser {
  const E621LinkParser();

  @override
  List<LinkParser> get parsers => [
    LeafLinkParser(
      path:
          r'/post'
          '$_showEnding'
          r'/:id(\d+)',
      transformer: (args, query) =>
          Link(type: LinkType.post, id: int.parse(args['id']!), query: query),
    ),
    LeafLinkParser(
      path: r'/post/:action(view|flag)/:id(\d+)',
      transformer: (args, query) =>
          Link(type: LinkType.post, id: int.parse(args['id']!), query: query),
    ),
    LeafLinkParser(
      path: r'/post/:action(show|view)/:id(\d+)/:title',
      transformer: (args, query) =>
          Link(type: LinkType.post, id: int.parse(args['id']!), query: query),
    ),
    LeafLinkParser(
      path: r'/posts',
      transformer: (args, query) => Link(type: LinkType.post, query: query),
    ),
    LeafLinkParser(
      path: r'/post',
      transformer: (args, query) => Link(type: LinkType.post, query: query),
    ),
    LeafLinkParser(
      path:
          r'/pool'
          '$_showEnding'
          r'/:id(\d+)',
      transformer: (args, query) =>
          Link(type: LinkType.pool, id: int.parse(args['id']!), query: query),
    ),
    LeafLinkParser(
      path: r'/pools',
      transformer: (args, query) => Link(type: LinkType.pool, query: query),
    ),
    LeafLinkParser(
      path: r'/pool',
      transformer: (args, query) => Link(type: LinkType.pool, query: query),
    ),
    LeafLinkParser(
      path:
          r'/user'
          '$_showEnding'
          r'/:name',
      transformer: (args, query) => Link(
        type: LinkType.user,
        id: int.tryParse(args['name']!) ?? args['name']!,
        query: query,
      ),
    ),
    LeafLinkParser(
      path: r'/user',
      transformer: (args, query) => Link(type: LinkType.user, query: query),
    ),
    LeafLinkParser(
      path: r'/wiki_pages/show_or_new',
      transformer: (args, query) =>
          Link(type: LinkType.wiki, id: query?['title'], query: query),
    ),
    LeafLinkParser(
      path: r'/wiki_pages/search',
      transformer: (args, query) => Link(type: LinkType.wiki, query: query),
    ),
    LeafLinkParser(
      path:
          r'/wiki_pages'
          r'/:name',
      transformer: (args, query) => Link(
        type: LinkType.wiki,
        id: int.tryParse(args['name']!) ?? args['name']!,
      ),
    ),
    LeafLinkParser(
      path: r'/wiki_pages',
      transformer: (args, query) => Link(type: LinkType.wiki, query: query),
    ),
    LeafLinkParser(
      path: r'/forum_topics/:id(\d+)',
      transformer: (args, query) =>
          Link(type: LinkType.topic, id: int.parse(args['id']!), query: query),
    ),
    LeafLinkParser(
      path: r'/forum_topics',
      transformer: (args, query) => Link(type: LinkType.topic, query: query),
    ),
    LeafLinkParser(
      path: r'/forum_posts/:id(\d+)',
      transformer: (args, query) =>
          Link(type: LinkType.reply, id: int.parse(args['id']!)),
    ),
    LeafLinkParser(
      path: r'/forum_posts',
      transformer: (args, query) => Link(type: LinkType.reply, query: query),
    ),
  ];
}

extension LinkOnTapExtension on LinkParser {
  VoidCallback? parseOnTap(BuildContext context, String link) {
    final Link? result = this.parse(link);
    if (result == null) return null;

    VoidCallback navWrapper(WidgetBuilder builder, [bool root = false]) {
      return () {
        if (root) {
          // Keep the first route rooted so the linked page can be
          // backed out of instead of falling off the app.
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        Navigator.of(context).push(MaterialPageRoute(builder: builder));
      };
    }

    switch (result.type) {
      case LinkType.post:
        int? id = result.id as int?;
        if (id != null) {
          return navWrapper((context) => PostLoadingPage(id));
        }
        return navWrapper(
          (context) =>
              PostsPage(params: PostParams(tags: result.query?['tags'])),
        );
      case LinkType.pool:
        int? id = result.id as int?;
        if (id != null) {
          return navWrapper((context) => PoolLoadingPage(id));
        }
        return navWrapper(
          (context) => PoolsPage(search: PoolParams.fromQuery(result.query)),
          true,
        );
      case LinkType.user:
        Object? id = result.id;
        if (id is int) {
          return navWrapper((context) => UserLoadingPage(id));
        }
        if (id != null) {
          return navWrapper((context) => UserLoadingPage.name(id.toString()));
        }
        break;
      case LinkType.wiki:
        Object? id = result.id;
        if (id is int) {
          return navWrapper((context) => WikiLoadingPage(id));
        }
        if (id != null) {
          return navWrapper((context) => WikiLoadingPage.title(id.toString()));
        }
        break;
      case LinkType.topic:
        int? id = result.id as int?;
        if (id != null) {
          return navWrapper((context) => TopicLoadingPage(id));
        }
        return navWrapper((context) => TopicsPage(query: result.query), true);
      case LinkType.reply:
        int? id = result.id as int?;
        if (id != null) {
          return navWrapper((context) => ReplyLoadingPage(id));
        }
        return navWrapper((context) => TopicsPage(query: result.query), true);
    }
    return null;
  }

  bool open(BuildContext context, String link) {
    VoidCallback? callback = parseOnTap(context, link);
    if (callback != null) {
      callback();
      return true;
    }
    return false;
  }
}

/// Deduplicates links that arrive through more than one entry point.
///
/// On Android, the first `uriLinkStream` subscription re-emits the link
/// that `getInitialLink` also reports, so a cold start link would be
/// handled twice — once per entry point — without this. A link handled
/// within [window] of a previous handling counts as the same event;
/// taps that arrive later are new intents and pass again.
///
/// Handling is a reservation protocol: [check] reserves a link for its
/// caller, [consume] commits the reservation once the link was acted
/// on, and [release] rolls it back when acting on it failed. A pending
/// reservation suppresses the same link like a consumed one, which is
/// what collapses concurrent duplicate deliveries into one handling.
class LinkDeduplicator {
  LinkDeduplicator({
    this.window = const Duration(seconds: 10),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// How long an handled link keeps suppressing the same link.
  final Duration window;

  final DateTime Function() _clock;
  final List<(String link, DateTime at)> _recent = [];

  /// Whether [url] has not been handled within the window; reserves it
  /// when true.
  bool check(Uri url) {
    final now = _clock();
    _recent.removeWhere((entry) => now.difference(entry.$2) > window);
    final link = url.toString();
    if (_recent.any((entry) => entry.$1 == link)) return false;
    _recent.add((link, now));
    return true;
  }

  /// Commits the handling of a reserved [url], restarting its window
  /// from the moment the link was acted on.
  void consume(Uri url) {
    release(url);
    _recent.add((url.toString(), _clock()));
  }

  /// Rolls back the reservation of a [url] that was never acted on.
  ///
  /// A dispatch that fails before opening the link must not suppress
  /// later deliveries of it for the rest of the window.
  void release(Uri url) {
    _recent.removeWhere((entry) => entry.$1 == url.toString());
  }
}
