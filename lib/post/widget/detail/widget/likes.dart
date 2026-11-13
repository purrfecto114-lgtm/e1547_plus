import 'package:e1547/client/client.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  const LikeDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MutationBuilder(
              mutation: client.posts.useVote(id: post.id),
              builder: (context, state, mutate) {
                final bool enabled = client.hasLogin && !state.isLoading;
                return VoteDisplay(
                  vote: post.vote,
                  score: post.score,
                  onUpvote: enabled
                      ? (isLiked) async {
                          mutate((upvote: true, replace: !isLiked)).catchError((
                            error,
                          ) {
                            messenger.showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(l10n.postUpvoteFailed(post.id)),
                              ),
                            );
                            return error;
                          });
                          return !isLiked;
                        }
                      : null,
                  onDownvote: enabled
                      ? (isLiked) async {
                          mutate((
                            upvote: false,
                            replace: !isLiked,
                          )).catchError((error) {
                            messenger.showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(l10n.postDownvoteFailed(post.id)),
                              ),
                            );
                            return error;
                          });
                          return !isLiked;
                        }
                      : null,
                );
              },
            ),
            Row(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(post.favCount.toString()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.favorite,
                    color: post.isFavorited
                        ? Colors.pinkAccent
                        : IconTheme.of(context).color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    final settings = context.read<Settings>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    final addMutation = client.posts.useAddFavorite();
    final removeMutation = client.posts.useRemoveFavorite();
    return MutationBuilder(
      mutation: post.isFavorited ? removeMutation : addMutation,
      builder: (context, state, mutate) {
        return InkResponse(
          onTap: state.isLoading ? null : () {},
          child: Tooltip(
            // Reuses the task action names, which match the action of
            // this button, since no dedicated tooltip key exists.
            message: post.isFavorited
                ? l10n.taskActionUnfavorite
                : l10n.taskActionFavorite,
            child: LikeButton(
              isLiked: post.isFavorited,
              circleColor: const CircleColor(
                start: Colors.pink,
                end: Colors.red,
              ),
              bubblesColor: const BubblesColor(
                dotPrimaryColor: Colors.pink,
                dotSecondaryColor: Colors.red,
              ),
              likeBuilder: (isLiked) => Icon(
                Icons.favorite,
                color: isLiked
                    ? Colors.pinkAccent
                    : IconTheme.of(context).color,
              ),
              onTap: (isLiked) async {
                // cached_query swallows failures into the returned state,
                // so the outcome has to be checked instead of caught.
                final state = await mutate(post.id);
                if (state.isError) {
                  messenger.showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(
                        isLiked
                            ? l10n.postRemoveFavoriteFailed(post.id)
                            : l10n.postAddFavoriteFailed(post.id),
                      ),
                    ),
                  );
                  return isLiked;
                }
                if (!isLiked && settings.upvoteFavs.value) {
                  // upvote is best-effort once the favorite succeeded, its
                  // failure stays silent by design
                  await client.posts.useVote(id: post.id).mutate((
                    upvote: true,
                    replace: true,
                  ));
                }
                return !isLiked;
              },
            ),
          ),
        );
      },
    );
  }
}
