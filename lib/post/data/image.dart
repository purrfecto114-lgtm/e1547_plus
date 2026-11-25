import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum PostImageSize { preview, sample, file }

Future<void> preloadPostImage({
  required BuildContext context,
  required Post post,
  required PostImageSize size,
}) async {
  String? url = switch (size) {
    PostImageSize.preview => post.preview,
    PostImageSize.sample => post.sample,
    PostImageSize.file => post.file,
  };
  if (post.type != PostType.image) return;
  if (url == null) return;
  final manager = context.read<BaseCacheManager>();
  if (size == PostImageSize.file) {
    // Decoding originals ahead of time would fill the image cache with
    // multi-megabyte bitmaps that a capped decode cannot even reuse.
    // They are only fetched to disk instead and get decoded,
    // at a capped size, once they are actually shown.
    try {
      await manager.getSingleFile(url);
    } on Object {
      // A failed prefetch must not break preloading; the image downloads
      // again when it is shown. Errors are caught too, not just
      // exceptions: cache managers surface missing capability as
      // noSuchMethod, which is an Error.
    }
    return;
  }
  await precacheImage(
    CachedNetworkImageProvider(url, cacheManager: manager),
    context,
    onError: (error, stack) {},
  );
}

/// Warms the cache for the [reach] posts after [index].
///
/// Only positions ahead are touched: the post at [index] is already
/// being loaded by the widget that displays it, and the ones behind it
/// the user has already seen — re-fetching those either races the
/// visible download for the same file or re-reads cached ones for no
/// effect.
Future<void> preloadPostImages({
  required BuildContext context,
  required int index,
  required List<Post> posts,
  required PostImageSize size,
  int reach = 1,
}) async {
  for (int target = index + 1; target <= index + reach; target++) {
    if (0 <= target && target < posts.length) {
      Post post = posts[target];
      if (post.type == PostType.image && post.file != null) {
        if (!context.mounted) return;
        await preloadPostImage(context: context, post: post, size: size);
      }
    }
  }
}
