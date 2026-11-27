import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/flag/flag.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/foundation.dart';

export 'package:dio/dio.dart' show CancelToken;

class Client with Disposable {
  Client({
    required this.identity,
    required this.traits,
    required this.storage,
    bool ownsTraitsNotifier = false,
    ({String host, int port})? proxy,
  }) : _ownsTraitsNotifier = ownsTraitsNotifier,
       dio = createDefaultDio(
         identity,
         queryCache: storage.queryCache,
         proxy: proxy,
       );

  final Dio dio;
  final AppStorage storage;
  final Identity identity;
  final ValueNotifier<Traits> traits;

  /// Cancels the requests [dio] still has in flight when this client
  /// goes away.
  ///
  /// Disposal used to close the dio — and with it the platform's
  /// request engine — while requests like the follow sync were still
  /// running, which the engine answers with an IllegalStateException
  /// on Android and leaves the requests torn down mid-flight. The
  /// token cancellations let every in-flight request unwind through
  /// its own cancellation path first, so the engine closes clean.
  InFlightInterceptor get inFlight =>
      dio.interceptors.whereType<InFlightInterceptor>().first;

  /// Whether [dispose] owns [traits].
  ///
  /// Factory-made clients hold the streamed traits notifier created for
  /// them; disposing it cancels its database subscription. Clients built
  /// directly (mostly tests) leave the notifier to their caller.
  final bool _ownsTraitsNotifier;

  late final AccountClient accounts = AccountClient(
    dio: dio,
    identity: identity,
    traits: traits,
    postsService: posts,
  );
  late final UserClient users = UserClient(dio: dio);

  late final PostClient posts = PostClient(
    dio: dio,
    pools: pools,
    tags: tags,
    traits: traits,
    identity: identity,
  );

  late final TagClient tags = TagClient(dio: dio);
  late final WikiClient wikis = WikiClient(dio: dio);

  late final CommentClient comments = CommentClient(dio: dio);

  late final PoolClient pools = PoolClient(dio: dio);
  // TODO: add Sets

  late final TopicClient topics = TopicClient(dio: dio);
  late final ReplyClient replies = ReplyClient(dio: dio);

  late final FlagClient flags = FlagClient(dio: dio);
  late final TicketClient tickets = TicketClient(dio: dio);

  late final FollowClient follows = FollowClient(
    database: storage.sqlite,
    identity: identity,
    dio: dio,
  );

  late final FollowServer followServer = FollowServer(
    database: storage.sqlite,
    identity: identity,
    traits: traits,
    postsClient: posts,
    poolsClient: pools,
    tagsClient: tags,
    onSynced: () => dio.queryCache?.invalidateKey(follows.queryKey),
  );

  late final HistoryServer historyServer = HistoryServer(
    database: storage.sqlite,
    identity: identity,
    traits: traits,
  );

  late final HistoryClient histories = HistoryClient(
    server: historyServer,
    dio: dio,
  );

  @override
  void dispose() {
    // In-flight requests unwinding through their cancellation paths
    // must reach the engine before it goes; sub-clients' disposals
    // (the follow server cancels its sync) can trigger that unwind, so
    // they run before the dio itself closes.
    for (final client in [
      accounts,
      users,
      posts,
      tags,
      wikis,
      comments,
      pools,
      topics,
      replies,
      flags,
      tickets,
      follows,
      followServer,
      historyServer,
      histories,
    ]) {
      Disposable.tryDispose(client);
    }
    dio.shutdown();
    // The streamed notifier's subscription only ends with its dispose;
    // owning it means every identity switch frees the previous one.
    if (_ownsTraitsNotifier) traits.dispose();
    super.dispose();
  }
}

extension ClientExtension on Client {
  String get host => identity.host;
  bool get hasLogin => identity.username != null;
  String withHost(String path) => identity.withHost(path);
}
