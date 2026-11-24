import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/task/task.dart';
import 'package:flutter/material.dart';

/// The dialog result for the source-file row of the download quality
/// picker. Variant rows pop with their "WIDTHxHEIGHT" key instead, so a
/// post's file url — which can equal any string the server picked — is
/// never mistaken for the sentinel.
const String _sourcePick = 'source';

/// Enqueues download tasks for [items]. The floating task bubble surfaces
/// progress; this call returns as soon as the tasks are persisted.
///
/// A batch containing a video with several qualities asks once which
/// resolution to download; every video in the batch gets the variant
/// closest to that pick, and images are unaffected. The pick applies to
/// the whole batch, since asking per post would chain one dialog per
/// video. Dismissing the dialog queues nothing: the batch was not
/// confirmed.
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
  // Resolved before the awaits below: contexts must not cross async gaps.
  final TasksController controller = context.read<TasksController>();
  String? pickedKey;
  final Post? multiQualityVideo = items
      .where((post) => post.type == PostType.video && post.hasVideoQualities)
      .firstOrNull;
  if (multiQualityVideo != null) {
    pickedKey = await showDownloadVideoQualityDialog(
      context,
      multiQualityVideo,
    );
    if (pickedKey == null) return null;
  }
  final List<Task> queued = await controller.enqueueAll(
    items.map((post) {
      final String? url = post.type == PostType.video && pickedKey != null
          ? _downloadUrl(post, pickedKey)
          : post.file;
      return TaskRequest(
        action: TaskAction.download,
        postId: post.id,
        metadata: TaskMetadata(
          previewUrl: post.preview,
          fileUrl: url,
          fileName: _downloadFileName(post, url),
        ),
      );
    }),
  );
  // The only empty result a non-empty download batch can produce is a
  // canceled directory preflight.
  return queued.isEmpty ? null : queued;
}

/// The url a download of [post] serves for the picked [key]: the source
/// row keeps the untouched file, a resolution row picks the variant
/// closest to it, exactly like the player does.
String? _downloadUrl(Post post, String key) {
  if (post.file == null) return null;
  if (key == _sourcePick) return post.file;
  return post.videoUrl(VideoResolution.fromVariantKey(key));
}

/// Asks which resolution a download batch should serve, mirroring the
/// player's quality dialog: re-encodes sorted by size, then the source
/// file as its own row. Pops with the variant's "WIDTHxHEIGHT" key, the
/// [_sourcePick] sentinel for the source row, or null when dismissed.
Future<String?> showDownloadVideoQualityDialog(
  BuildContext context,
  Post post,
) {
  // Variant keys are expected as "WIDTHxHEIGHT", but the format comes
  // from the server; unparsable keys sort last instead of crashing.
  int pixels(String key) =>
      key.split('x').map((e) => int.tryParse(e) ?? 0).fold(1, (a, b) => a * b);
  // A variant that serves the untouched source file is covered by the
  // dedicated source entry, so only re-encodes get their own row.
  final variants =
      post.videoVariants.entries
          .where((entry) => entry.value != post.file)
          .toList()
        ..sort((a, b) => pixels(a.key).compareTo(pixels(b.key)));

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: Text(AppLocalizations.of(context).videoQuality),
      children: [
        for (final entry in variants)
          ListTile(
            title: Text(videoVariantLabel(entry.key, entry.value)),
            onTap: () => Navigator.of(dialogContext).pop(entry.key),
          ),
        if (post.file != null)
          ListTile(
            title: Text(AppLocalizations.of(context).videoResSource),
            onTap: () => Navigator.of(dialogContext).pop(_sourcePick),
          ),
      ],
    ),
  );
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

String _downloadFileName(Post post, String? url) {
  String filename = '';
  final List<String> artists = filterArtists(post.tags['artist'] ?? const []);
  if (artists.isNotEmpty) {
    // Artist tags come from the server as well; they get the same path
    // separator treatment as the extension, while keeping the spaces
    // the display name is made of.
    filename = '${_sanitizeFileName(artists.join(', '))} - ';
  }
  // The extension tracks the downloaded variant: a re-encoded mp4 or
  // webm variant carries its own extension, not the source's.
  final String safeExt = _extOf(
    url ?? post.file ?? '',
  ).replaceAll(RegExp(r'[^\w]'), '');
  return filename += '${post.id}.$safeExt';
}

String _extOf(String url) {
  final String clean = url.split('?').first;
  final int dot = clean.lastIndexOf('.');
  return dot == -1 || dot == clean.lastIndexOf('/')
      ? ''
      : clean.substring(dot + 1);
}

/// Removes path separators and control characters from a server-provided
/// file name component. The export paths flatten names again, so this is
/// defense in depth, not the only line.
String _sanitizeFileName(String value) =>
    value.replaceAll(RegExp(r'[/\\:\x00-\x1f]'), '');
