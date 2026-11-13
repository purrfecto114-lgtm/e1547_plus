import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/task/task.dart';
import 'package:flutter/material.dart';

/// Enqueues download tasks for [items]. The floating task bubble surfaces
/// progress; this call returns as soon as the tasks are persisted.
///
/// Returns the tasks that were queued, including duplicates that were
/// absorbed into already-queued ones. Returns null when the user
/// cancelled the download-directory prompt; nothing was queued then,
/// and that is a choice, not a failure.
Future<List<Task>?> postDownloadingNotification(
  BuildContext context,
  Set<Post> items,
) async {
  if (items.isEmpty) return const [];
  final TasksController controller = context.read<TasksController>();
  final List<Task> queued = await controller.enqueueAll(
    items.map(
      (post) => TaskRequest(
        action: TaskAction.download,
        postId: post.id,
        metadata: TaskMetadata(
          previewUrl: post.preview,
          fileUrl: post.file,
          fileName: _downloadFileName(post),
        ),
      ),
    ),
  );
  // The only empty result a non-empty download batch can produce is a
  // canceled directory preflight.
  return queued.isEmpty ? null : queued;
}

/// Enqueues favorite or unfavorite tasks for [items], skipping ones already in
/// the target state.
///
/// Returns the tasks that were queued, including duplicates that were
/// absorbed into already-queued ones; an empty list means nothing was
/// queued.
Future<List<Task>> postFavoritingNotification(
  BuildContext context,
  Set<Post> items,
  bool isLiked,
) async {
  if (items.isEmpty) return const [];
  final TasksController controller = context.read<TasksController>();
  final TaskAction action = isLiked
      ? TaskAction.unfavorite
      : TaskAction.favorite;
  final Iterable<Post> targets = items.where(
    (post) => isLiked ? post.isFavorited : !post.isFavorited,
  );
  if (targets.isEmpty) return const [];
  return controller.enqueueAll(
    targets.map(
      (post) => TaskRequest(
        action: action,
        postId: post.id,
        metadata: TaskMetadata(previewUrl: post.preview),
      ),
    ),
  );
}

String _downloadFileName(Post post) {
  String filename = '';
  final List<String> artists = filterArtists(post.tags['artist'] ?? const []);
  if (artists.isNotEmpty) {
    // Artist tags come from the server as well; they get the same path
    // separator treatment as the extension, while keeping the spaces
    // the display name is made of.
    filename = '${_sanitizeFileName(artists.join(', '))} - ';
  }
  // ext comes from the server's post json; a hostile host must not be
  // able to smuggle path segments into the file name
  final String safeExt = post.ext.replaceAll(RegExp(r'[^\w]'), '');
  return filename += '${post.id}.$safeExt';
}

/// Removes path separators and control characters from a server-provided
/// file name component. The export paths flatten names again, so this is
/// defense in depth, not the only line.
String _sanitizeFileName(String value) =>
    value.replaceAll(RegExp(r'[/\\:\x00-\x1f]'), '');
