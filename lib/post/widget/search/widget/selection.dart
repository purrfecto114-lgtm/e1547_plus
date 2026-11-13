import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/task/task.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class PostSelectionAppBar extends StatefulWidget with AppBarBuilderWidget {
  const PostSelectionAppBar({super.key, required this.child});

  @override
  final PreferredSizeWidget child;

  @override
  State<PostSelectionAppBar> createState() => _PostSelectionAppBarState();
}

class _PostSelectionAppBarState extends State<PostSelectionAppBar> {
  /// Whether a batch action is currently waiting for its tasks to be
  /// persisted.
  ///
  /// Repeat submissions are ignored while this is true; the selection is
  /// only cleared once the enqueue actually queued something, so a failed
  /// batch can simply be retried.
  bool _queueing = false;

  final Logger logger = Logger('PostSelectionAppBar');

  /// Whether every currently selected post is favorited.
  ///
  /// Read from the layout on each use instead of cached from a build, so
  /// a retry works with whatever is selected by then, and building the
  /// appbar never writes state.
  bool get _selectionLiked {
    final SelectionLayoutData<Post>? data = SelectionLayout.maybeOf<Post>(
      context,
    );
    return data != null &&
        data.selections.isNotEmpty &&
        data.selections.every((post) => post.isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    return SelectionAppBar<Post>(
      child: widget.child,
      titleBuilder: (context, data) => data.selections.length == 1
          ? Text(
              AppLocalizations.of(
                context,
              ).selectionPost(data.selections.first.id),
            )
          : Text(
              AppLocalizations.of(
                context,
              ).selectionPostsCount(data.selections.length),
            ),
      actionBuilder: (context, data) {
        return [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: AppLocalizations.of(context).menuDownload,
            onPressed: _queueing ? null : _download,
          ),
          InkResponse(
            onTap: () {},
            child: LikeButton(
              isLiked:
                  data.selections.isNotEmpty &&
                  data.selections.every((post) => post.isFavorited),
              circleColor: const CircleColor(
                start: Colors.pink,
                end: Colors.red,
              ),
              bubblesColor: const BubblesColor(
                dotPrimaryColor: Colors.pink,
                dotSecondaryColor: Colors.red,
              ),
              likeBuilder: (bool isLiked) => Icon(
                Icons.favorite,
                color: isLiked
                    ? Colors.pinkAccent
                    : Theme.of(context).iconTheme.color,
              ),
              onTap: _favorite,
            ),
          ),
        ];
      },
    );
  }

  /// Enqueues download tasks for the current selection.
  ///
  /// The selection survives a failed enqueue untouched, so the user can
  /// retry the very same batch. A canceled directory prompt is a choice,
  /// not a failure: nothing is reported and the selection stays.
  Future<void> _download() async {
    // A stale snackbar retry action can outlive the page that queued it.
    if (!mounted) return;
    // Read from the layout instead of a value cached while building, so
    // this works with whatever is selected now, and building the appbar
    // stays free of side effects.
    final SelectionLayoutData<Post>? data = SelectionLayout.maybeOf<Post>(
      context,
    );
    if (data == null || data.selections.isEmpty) return;
    // Resolved before the awaits: contexts must not cross async gaps.
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _queueing = true);
    List<Task>? enqueued;
    try {
      enqueued = await postDownloadingNotification(
        context,
        Set.from(data.selections),
      );
    } on Object catch (e, s) {
      // A failed enqueue keeps the selection so the batch can be retried.
      logger.error('Failed to enqueue downloads', null, e, s);
    } finally {
      if (mounted) setState(() => _queueing = false);
    }
    if (!mounted) return;
    if (enqueued == null) {
      // The user canceled the directory prompt; nothing failed, and the
      // selection stays so the batch can be queued again.
      return;
    }
    if (enqueued.isNotEmpty) {
      data.clear();
      return;
    }
    _showQueueFailure(messenger, l10n.selectionQueueDownloadsFailed, _download);
  }

  /// Enqueues favorite or unfavorite tasks for the current selection.
  ///
  /// Returns the button state the favorite animation should settle on:
  /// only a batch which actually queued flips it, a failed enqueue keeps
  /// both the selection and the previous state.
  Future<bool> _favorite(bool isLiked) async {
    // A stale snackbar retry action can outlive the page that queued it.
    if (!mounted) return isLiked;
    // Read from the layout instead of a value cached while building, so
    // this works with whatever is selected now, and building the appbar
    // stays free of side effects.
    final SelectionLayoutData<Post>? data = SelectionLayout.maybeOf<Post>(
      context,
    );
    if (data == null || data.selections.isEmpty) return isLiked;
    if (_queueing) return isLiked;
    // Resolved before the awaits: contexts must not cross async gaps.
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _queueing = true);
    List<Task> enqueued = const [];
    try {
      enqueued = await postFavoritingNotification(
        context,
        Set.from(data.selections),
        isLiked,
      );
    } on Object catch (e, s) {
      // A failed enqueue keeps the selection so the batch can be retried.
      logger.error('Failed to enqueue favorites', null, e, s);
    } finally {
      if (mounted) setState(() => _queueing = false);
    }
    if (!mounted) return isLiked;
    if (enqueued.isNotEmpty) {
      data.clear();
      return !isLiked;
    }
    _showQueueFailure(
      messenger,
      l10n.selectionQueueFavoritesFailed,
      () => _favorite(_selectionLiked),
    );
    return isLiked;
  }

  /// Tells the user that a batch action queued nothing and offers to retry.
  void _showQueueFailure(
    ScaffoldMessengerState messenger,
    String message,
    VoidCallback onRetry,
  ) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: AppLocalizations.of(context).actionRetry,
          onPressed: onRetry,
        ),
      ),
    );
  }
}
