import 'package:e1547/app/app.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

extension PostTagging on PostSummary {
  /// Whether this post can be displayed at all.
  ///
  /// Flash posts cannot be rendered by the app, and a post that is not
  /// deleted but has no file is censored. Such posts stay in fetched
  /// pages — pagination must advance on the raw response — but the
  /// display layer drops them.
  bool get isDisplayable => ext != 'swf' && (isDeleted || file != null);

  bool hasTag(String tag) {
    if (tag.trim().isEmpty) return false;

    if (tag.contains(':')) {
      String identifier = tag.split(':')[0];
      String value = tag.split(':')[1];
      switch (identifier) {
        case 'id':
          return id == int.tryParse(value);
        case 'rating':
          return rating == Rating.values.asNameMap()[value] ||
              value == rating.title.toLowerCase();
        case 'type':
          return ext.toLowerCase() == value.toLowerCase();
        case 'width':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(width);
        case 'height':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(height);
        case 'filesize':
          NumberRange? range = NumberRange.tryParse(_sizeToBytes(value));
          if (range == null) return false;
          return range.has(size);
        case 'score':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(score);
        case 'favcount':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(favCount);
        case 'fav':
          return isFavorited;
        case 'status':
          return switch (value) {
            'deleted' => isDeleted,
            _ => false,
          };
        case 'uploader':
        case 'user':
          if (value.startsWith('!')) {
            return uploaderId == int.tryParse(value.substring(1));
          }
          return uploaderName?.toLowerCase() == value;
        case 'userid':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(uploaderId);
        case 'username':
          return uploaderName?.toLowerCase() == value;
        case 'pool':
          return pools?.contains(int.tryParse(value)) ?? false;
        case 'tagcount':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(allTags.length);
      }
    }

    if (tag.contains('*')) {
      final RegExp pattern = RegExp(
        '^${RegExp.escape(tag.toLowerCase()).replaceAll(r'\*', '.*')}\$',
      );
      return allTags.any(pattern.hasMatch);
    }

    return allTags.contains(tag.toLowerCase());
  }
}

final RegExp _sizeUnit = RegExp(
  r'(\d+(?:\.\d+)?)\s*(kb|mb|b)',
  caseSensitive: false,
);

/// Rewrites the units in a filesize expression into plain byte counts.
String _sizeToBytes(String value) => value.replaceAllMapped(_sizeUnit, (match) {
  final double number = double.parse(match.group(1)!);
  final int factor = switch (match.group(2)!.toLowerCase()) {
    'kb' => 1024,
    'mb' => 1048576,
    _ => 1,
  };
  return (number * factor).truncate().toString();
});

final RegExp _tagPrefix = RegExp(r'^[~-]+');

extension PostDenying on PostSummary {
  bool isDeniedBy(List<String> denylist) =>
      getDeniers(denylist).iterator.moveNext();

  Iterable<String> getDeniers(List<String> denylist) sync* {
    // The denylist is user-edited free text and accumulates duplicate
    // lines over the years; a post matching a duplicated line must not
    // count twice against it in the per-entry counters.
    final seenLines = <String>{};
    for (String line in denylist) {
      line = line.trim().toLowerCase();
      if (line.isEmpty || line.startsWith('#')) continue;

      line = line.replaceFirst(RegExp(r' #.*$'), '').trim();
      if (line.isEmpty || !seenLines.add(line)) continue;

      bool pass = true;
      bool isOptional = false;
      bool hasOptional = false;

      for (String tag in line.split(' ')) {
        if (tag.isEmpty) continue;

        bool optional = false;
        bool inverted = false;

        final String? prefix = _tagPrefix.stringMatch(tag);
        if (prefix != null) {
          optional = prefix.contains('~');
          inverted = prefix.contains('-');
          tag = tag.substring(prefix.length);
        }

        if (tag.isEmpty) continue;

        bool matches = hasTag(tag);

        if (inverted) {
          matches = !matches;
        }

        if (optional) {
          isOptional = true;
          if (matches) {
            hasOptional = true;
          }
        } else {
          if (!matches) {
            pass = false;
            break;
          }
        }
      }

      if (pass && isOptional) {
        pass = hasOptional;
      }

      if (!pass) continue;

      yield line;
    }
  }
}

enum PostType { image, video, unsupported }

extension PostTyping on PostSummary {
  PostType get type {
    switch (ext) {
      case 'mp4':
      case 'webm':
        if (PlatformCapabilities.hasVideos) {
          return PostType.video;
        }
        return PostType.unsupported;
      case 'swf':
        return PostType.unsupported;
      default:
        return PostType.image;
    }
  }
}

extension PostVideoPlaying on Post {
  /// All playable video variants of this post, keyed `"widthxheight"`.
  ///
  /// Entries that are null or not videos are dropped.
  Map<String, String> get videoVariants => {
    for (final MapEntry(:key, :value) in (variants ?? const {}).entries)
      if (value != null && (value.endsWith('mp4') || value.endsWith('webm')))
        key: value,
  };

  /// Whether this post offers a choice of re-encoded video qualities.
  ///
  /// A variant that serves the untouched source file is covered by the
  /// dedicated source row, so it does not count as a separate choice.
  bool get hasVideoQualities => videoVariants.values.any((url) => url != file);

  /// The video url closest to [target] in pixel count,
  /// falling back to the source file.
  String videoUrl(VideoResolution target) {
    String closestUrl = file!;
    int? closestDifference;
    for (final MapEntry(:key, :value) in videoVariants.entries) {
      final dimensions = key.split('x').map(int.tryParse).toList();
      // Variant keys come from the server; skip malformed ones instead
      // of crashing resolution selection.
      if (dimensions.length != 2 ||
          dimensions[0] == null ||
          dimensions[1] == null) {
        continue;
      }
      final pixelSize = dimensions[0]! * dimensions[1]!;
      final difference = (target.pixels - pixelSize).abs();

      if (closestDifference == null || difference < closestDifference) {
        closestDifference = difference;
        closestUrl = value;
      }
    }
    return closestUrl;
  }

  VideoPlayer? getVideo(
    BuildContext context, {
    Duration? seekTo,
    bool resume = false,
    bool? autoLoad,
  }) {
    if (type == PostType.video && file != null) {
      // An inactive subtree holds no player, so that a stack of post routes
      // cannot pin one video each.
      if (!TickerMode.valuesOf(context).enabled) return null;

      VideoService service = context.watch<VideoService>();
      Settings settings = context.watch<Settings>();
      PostVideoQuality? quality = context.watch<PostVideoQuality?>();

      String url = quality?.url ?? videoUrl(settings.videoResolution.value);

      return service.getVideo(
        url,
        // An explicit quality choice always loads: it was just requested.
        // Browsing a detail page defers until the play button — the
        // automatic side of loading is the neighbour prefetch, judged
        // by [preloadNeighborVideos].
        autoLoad: autoLoad ?? quality != null,
        seekTo: seekTo,
        resume: resume,
      );
    }
    return null;
  }
}

/// Preloads the video neighbours of [index] in [posts] into the video
/// pool, so stepping to them starts playing immediately.
///
/// This is what the auto-loading setting means now: opening a video
/// loads the videos next to it, not every video a browse walks past.
/// The function judges before it acts — a neighbour that is missing,
/// not a video, or without a file is skipped — and the pool's eviction
/// keeps a prefetch from squeezing out the video being watched.
void preloadNeighborVideos({
  required BuildContext context,
  required int index,
  required List<Post> posts,
}) {
  if (!context.read<Settings>().autoLoadVideos.value) return;
  VideoService service = context.read<VideoService>();
  Settings settings = context.read<Settings>();
  for (final int target in [index - 1, index + 1]) {
    // No neighbour on this side: nothing to load.
    if (target < 0 || target >= posts.length) continue;
    final Post post = posts[target];
    // Not a video (or the server dropped its file): nothing to load.
    if (post.type != PostType.video || post.file == null) continue;
    service.getVideo(post.videoUrl(settings.videoResolution.value));
  }
}

extension PostLinking on Post {
  static String getPostLink(int id) => '/posts/$id';

  String get link => getPostLink(id);
}

extension PostVoting on Post {
  Post withVote({required bool upvote, required bool replace}) {
    final result = applyVote(
      score: score,
      vote: vote,
      upvote: upvote,
      replace: replace,
    );
    return copyWith(score: result.score, vote: result.vote);
  }
}
