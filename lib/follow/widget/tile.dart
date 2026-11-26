import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FollowTile extends StatelessWidget {
  const FollowTile({super.key, required this.follow});

  final Follow follow;

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    PromptActionController? promptController = PromptActions.maybeOf(context);
    bool active = follow.latest != null && follow.thumbnail != null;
    // Thumbnails render inside a grid tile, so their decode is capped
    // like the one of post grid tiles: a thumbnail which is actually a
    // sample or original must never decode at full size just to be
    // cover-fitted back into a small cell. The cap follows the tile
    // layout's quality tier, so the thumbnail quality setting reaches
    // the subscription grid the same way it reaches post grids.
    final TileLayoutData? layout = TileLayout.maybeOf(context);
    final int tileSize = layout?.tileSize ?? 300;

    void editTitle() {
      promptController!.show(
        context,
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: Theme.of(context).isDesktop ? 600 : 0,
          ),
          child: ControlledTextField(
            labelText: AppLocalizations.of(context).followTitlePrompt,
            actionController: promptController,
            textController: TextEditingController(text: follow.name),
            submit: (value) {
              String? title = value.trim();
              if (follow.title != value) {
                client.follows.update(id: follow.id, title: title);
              }
            },
          ),
        ),
      );
    }

    void edit() {
      promptController!.show(
        context,
        EditTagPrompt(
          onSubmit: (value) async {
            value = value.trim();
            if (value.isNotEmpty) {
              try {
                await client.follows.update(id: follow.id, tags: value);
              } on FollowTagsTakenException {
                throw const ActionControllerException(
                  message: 'Already followed',
                );
              }
            } else {
              await client.follows.delete(follow.id);
            }
          },
          actionController: promptController,
          tag: follow.tags,
          title: AppLocalizations.of(context).followEditPrompt,
        ),
      );
    }

    Widget contextMenu() {
      bool notified = follow.type == FollowType.notify;
      bool bookmarked = follow.type == FollowType.bookmark;
      final l10n = AppLocalizations.of(context);

      return PopupMenuButton<VoidCallback>(
        icon: const Dimmed.interactive(child: Icon(Icons.more_vert)),
        onSelected: (value) => value(),
        itemBuilder: (context) => [
          if ((follow.unseen ?? 0) > 0)
            PopupMenuTile(
              value: () => client.follows.markSeen(follow.id),
              title: l10n.followMarkAsRead,
              icon: Icons.mark_email_read,
            ),
          if (PlatformCapabilities.hasNotifications && !bookmarked)
            PopupMenuTile(
              value: () => client.follows.update(
                id: follow.id,
                type: !notified ? FollowType.notify : FollowType.update,
              ),
              title: notified
                  ? l10n.followDisableNotifications
                  : l10n.followEnableNotifications,
              icon: notified
                  ? Icons.notifications_off
                  : Icons.notifications_active,
            ),
          if (!PlatformCapabilities.hasNotifications || !notified)
            PopupMenuTile(
              value: () => client.follows.update(
                id: follow.id,
                type: !bookmarked ? FollowType.bookmark : FollowType.update,
              ),
              title: bookmarked ? l10n.followSubscribe : l10n.actionBookmark,
              icon: bookmarked ? Icons.person_add : Icons.bookmark,
            ),
          if (promptController != null && follow.tags.split(' ').length > 1)
            PopupMenuTile(
              value: editTitle,
              title: l10n.followRename,
              icon: Icons.label,
            ),
          if (promptController != null)
            PopupMenuTile(value: edit, title: l10n.menuEdit, icon: Icons.edit),
          PopupMenuTile(
            value: () => client.follows.delete(follow.id),
            title: l10n.actionUnfollow,
            icon: Icons.person_remove,
          ),
        ],
      );
    }

    String getStatusText() {
      int unseen = follow.unseen ?? 0;
      String label = unseen >= 5 ? '$unseen+' : '$unseen';
      return AppLocalizations.of(context).followNewPosts(unseen, label);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1 / 1.2,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: CrossFade.builder(
                    showChild: active,
                    secondChild: const Icon(Icons.image_not_supported_outlined),
                    builder: (context) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Hero(
                            tag: PostLinking.getPostLink(follow.latest!),
                            child: CachedNetworkImage(
                              imageUrl: follow.thumbnail!,
                              errorWidget: defaultErrorBuilder,
                              fit: BoxFit.cover,
                              cacheManager: context.read<BaseCacheManager>(),
                              // Covers are previews of arbitrary aspect:
                              // capping both decode axes would scale
                              // every source onto the tile's own ratio,
                              // stretching some and squishing others.
                              // One axis keeps the source's ratio, and
                              // the cover fit crops it into the cell.
                              // Like the post grid's caps, the limit
                              // scales with the device pixel ratio and
                              // the quality tier so covers stay sharp on
                              // dense screens without decoding samples at
                              // full size on the low tier.
                              memCacheWidth: min(
                                (tileSize *
                                        (layout?.qualityFactor ?? 2) *
                                        MediaQuery.devicePixelRatioOf(context))
                                    .round(),
                                layout?.qualityCap ?? 1080,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: SelectionItemOverlay<Follow>(
                    item: follow,
                    child: InkWell(
                      onTap: () {
                        final poolId = poolRegex()
                            .firstMatch(follow.tags)
                            ?.namedGroup('id');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => poolId != null
                                ? PoolLoadingPage(
                                    int.parse(poolId),
                                    orderByOldest: (follow.unseen ?? 0) == 0,
                                  )
                                : PostsPage(
                                    params: PostParams(tags: follow.tags),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ).copyWith(bottom: 4, right: 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        follow.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                      ),
                      CrossFade(
                        showChild: follow.alias != null,
                        child: Dimmed(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).followAlias(follow.alias),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      CrossFade(
                        showChild:
                            follow.title != null &&
                            follow.tags.split(' ').length > 1,
                        child: Dimmed(
                          child: Text(
                            tagToTitle(follow.tags),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      Dimmed(
                        opacity: 0.7,
                        child: Row(
                          children: [
                            CrossFade(
                              showChild: follow.type == FollowType.notify,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(follow.type.icon),
                              ),
                            ),
                            Expanded(
                              child: CrossFade(
                                style: FadeAnimationStyle.stacked,
                                showChild: (follow.unseen ?? 0) > 0,
                                child: Text(
                                  getStatusText(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                contextMenu(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
