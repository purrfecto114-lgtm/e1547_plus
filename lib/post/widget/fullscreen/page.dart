import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

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
                switch (widget.post.type) {
                  case PostType.image:
                    return _PostFullscreenImage(post: widget.post);
                  case PostType.video:
                    VideoPlayer? player = widget.post.getVideo(context);
                    return Center(
                      child: ContentHero(
                        tag: widget.post.link,
                        content: FittedContent(
                          fit: BoxFit.contain,
                          aspectRatio:
                              widget.post.width / widget.post.height,
                        ),
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

class _PostFullscreenImage extends StatefulWidget {
  const _PostFullscreenImage({required this.post});

  final Post post;

  @override
  State<_PostFullscreenImage> createState() => _PostFullscreenImageState();
}

class _PostFullscreenImageState extends State<_PostFullscreenImage> {
  final ZoomController zoom = ZoomController();
  final ImageLoadController load = ImageLoadController();

  @override
  void dispose() {
    zoom.dispose();
    load.dispose();
    super.dispose();
  }

  void onSpare(Offset spare) =>
      DismissController.maybeOf(context)?.push(spare.dy);

  void onSpareEnd(Velocity velocity) {
    final DismissController? dismiss = DismissController.maybeOf(context);
    if (dismiss != null && dismiss.release(velocity.pixelsPerSecond.dy)) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Post post = widget.post;
    final Size content = Size(post.width.toDouble(), post.height.toDouble());
    return Stack(
      fit: StackFit.expand,
      children: [
        DismissPointers(
          child: DismissTransform(
            child: Zoomable(
              controller: zoom,
              content: content,
              onSpare: onSpare,
              onSpareEnd: onSpareEnd,
              onSpareCancel: () => DismissController.maybeOf(context)?.settle(),
              child: Center(
                child: AspectRatio(
                  aspectRatio: content.aspectRatio,
                  child: ContentHero(
                    tag: post.link,
                    content: FittedContent(
                      fit: BoxFit.contain,
                      aspectRatio: content.aspectRatio,
                    ),
                    child: PostImageWidget(
                      post: post,
                      fit: BoxFit.cover,
                      size: PostImageSize.file,
                      cacheSize: context.watch<ImageCacheSize?>()?.size,
                      lowResCacheSize: context.watch<ImageCacheSize?>()?.size,
                      maxPixels: fullscreenImageMaxPixels,
                      load: load,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        DismissFade(
          child: ImageLoadOverlay(
            load: load,
            moves: zoom.transformation,
            locate: (size) => switch (containedRect(content, size)) {
              final Rect image => MatrixUtils.transformRect(
                zoom.transformation.value,
                image,
              ),
              null => null,
            },
          ),
        ),
      ],
    );
  }
}
