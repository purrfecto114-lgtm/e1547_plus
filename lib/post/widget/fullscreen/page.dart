import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostFullscreen extends StatefulWidget {
  const PostFullscreen({super.key, required this.post});

  final Post post;

  @override
  State<PostFullscreen> createState() => PostFullscreenState();
}

class PostFullscreenState extends State<PostFullscreen> {
  String? _videoQuality;

  @override
  void didUpdateWidget(covariant PostFullscreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Gallery pages recycle this state for other posts; a quality choice
    // of a previous post must not leak into theirs.
    if (oldWidget.post.id != widget.post.id) {
      _videoQuality = null;
    }
  }

  /// Overrides which video url plays in this fullscreen.
  ///
  /// The url is loaded immediately, resuming the position of the player
  /// it replaces. Passing null returns to resolution-based selection.
  void setVideoQuality(String? url) => setState(() => _videoQuality = url);

  @override
  Widget build(BuildContext context) {
    return PostHistoryConnector(
      post: widget.post,
      // The scope is always provided, even without an override, so that
      // PostVideoRoute reacts to quality changes while it is mounted.
      child: Provider<PostVideoQuality?>.value(
        value: _videoQuality == null
            ? null
            : PostVideoQuality(url: _videoQuality!),
        child: PostVideoRoute(
          post: widget.post,
          stopOnDispose: false,
          child: PostFullscreenFrame(
            post: widget.post,
            child: PostImageOverlay(
              post: widget.post,
              builder: (context) {
                int? cacheSize = context.watch<ImageCacheSize?>()?.size;
                switch (widget.post.type) {
                  case PostType.image:
                    if (Theme.of(context).isDesktop) {
                      return InteractiveViewer(
                        maxScale: 6,
                        child: Center(
                          child: Hero(
                            tag: widget.post.link,
                            child: PostImageWidget(
                              post: widget.post,
                              fit: BoxFit.cover,
                              size: PostImageSize.file,
                              cacheSize: cacheSize,
                              lowResCacheSize: cacheSize,
                              maxPixels: fullscreenImageMaxPixels,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return PhotoViewGestureDetectorScope(
                        axis: Axis.horizontal,
                        child: PhotoView.customChild(
                          heroAttributes: PhotoViewHeroAttributes(
                            tag: widget.post.link,
                          ),
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          childSize: Size(
                            widget.post.width.toDouble(),
                            widget.post.height.toDouble(),
                          ),
                          initialScale: PhotoViewComputedScale.contained,
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 6,
                          child: PostImageWidget(
                            fit: BoxFit.cover,
                            post: widget.post,
                            size: PostImageSize.file,
                            cacheSize: cacheSize,
                            lowResCacheSize: cacheSize,
                            maxPixels: fullscreenImageMaxPixels,
                          ),
                        ),
                      );
                    }
                  case PostType.video:
                    VideoPlayer? player = widget.post.getVideo(context);
                    return Center(
                      child: Hero(
                        tag: widget.post.link,
                        child: player != null
                            ? VideoGestures(
                                player: player,
                                child: PostVideoWidget(post: widget.post),
                              )
                            : PostVideoWidget(post: widget.post),
                      ),
                    );
                  case PostType.unsupported:
                    // this never occurs, ImageOverlay will display instead.
                    throw StateError(
                      'PostFullscreen received an unsupported image!',
                    );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
