import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class FollowConnector extends StatelessWidget {
  const FollowConnector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    return SubEffect(
      effect: () {
        client.followServer.sync();
        return null;
      },
      keys: [client],
      child: SubStream<List<Follow>>(
        create: () => client.follows.all().streamed,
        keys: [client],
        listener: (event) => FollowSyncKick.maybeKick(client, event),
        builder: (context, _) => child,
      ),
    );
  }
}

/// Decides whether a follows-table emission deserves a sync.
///
/// The sync itself writes follows (timestamps, tallies, thumbnails),
/// and every write re-emits this stream: a listener that syncs on
/// every emission feeds itself — sync, write, emission, sync — for as
/// long as the subscriptions page is open, and each pass re-decodes
/// every cover thumbnail, which reads as the grid stuttering while it
/// scrolls. A sync only has news when the set of followed tags itself
/// changed (something followed, unfollowed or renamed), so that is the
/// only emission that kicks one; the sync's own bookkeeping writes
/// carry the same tag set and do not.
class FollowSyncKick {
  static final Expando<Set<String>> _lastTags = Expando();

  static void maybeKick(Client client, List<Follow> follows) {
    final Set<String> tags = follows.map((e) => e.tags).toSet();
    final Set<String>? previous = _lastTags[client];
    _lastTags[client] = tags;
    // The initial emission is the table's current state, not news.
    if (previous == null) return;
    if (const SetEquality().equals(previous, tags)) return;
    client.followServer.sync();
  }
}

class FollowSeenConnector extends StatelessWidget {
  const FollowSeenConnector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    final controller = context.watch<PostParamsController>();
    final query = client.posts.usePage(query: controller.value.toQuery());

    return QueryOnceConnector<
      InfiniteQueryStatus<List<int>, Object>,
      FollowSeenRequest
    >(
      query: query,
      getRequest: (context, state) {
        final data = state.data;
        if (data == null || data.pages.isEmpty) return null;
        final params = controller.value;
        final poolId = params.poolId;
        final tags = poolId != null
            ? 'pool:$poolId'
            : params.tags?.nullWhenEmpty;
        if (tags == null) return null;
        final filter = context.read<FilterController<Post>?>();
        final posts = data.pages
            .expand((p) => p)
            .map((id) => client.posts.postCache.get(id))
            .whereType<Post>()
            .where((post) => filter?.filter(post) ?? true)
            .toList();
        return (
          tags: tags,
          posts: posts,
          pool: poolId != null ? client.pools.poolCache.get(poolId) : null,
        );
      },
      onRequest: (context, request) => client.useFollowSeen().mutate(request),
      child: child,
    );
  }
}
