import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' show sqrt;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PostImageWidget extends StatelessWidget {
  /// Displays the image of a post.
  ///
  /// Provides various preview options while loading.
  const PostImageWidget({
    super.key,
    required this.post,
    required this.size,
    this.showProgress = true,
    this.withLowRes = true,
    this.fit = BoxFit.contain,
    this.cacheSize,
    this.lowResCacheSize,
    this.maxPixels,
    this.load,
  });

  /// The post which provides the image.
  final Post post;

  /// How the image should be fit.
  final BoxFit fit;

  /// The image size to be selected from that post (preview, sample, file).
  final PostImageSize size;

  /// Whether to display progress while the the image is loading.
  final bool showProgress;

  /// Whether an already loaded lower resolution image should be displayed while the image is loading.
  final bool withLowRes;

  /// The cache size for this image.
  final int? cacheSize;

  /// The cache size of a previously loaded lower resolution image.
  /// Used to bridge the gap between loading a downsized image and the full sized one.
  final int? lowResCacheSize;

  /// The maximum number of pixels this image may decode to.
  ///
  /// Constrains the total decoded size of images whose extreme aspect
  /// ratios would defeat a one dimensional [cacheSize] limit.
  final int? maxPixels;

  final ImageLoadController? load;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          double aspectRatio = post.width / post.height;

          switch (size) {
            case PostImageSize.preview:
              return RawPostImageWidget(
                post: post,
                size: PostImageSize.preview,
                showProgress: showProgress,
                fit: fit,
                cacheSize: cacheSize,
              );
            case PostImageSize.sample:
              return RawPostImageWidget(
                stacked: withLowRes,
                post: post,
                size: PostImageSize.sample,
                showProgress: showProgress,
                fit: fit,
                cacheSize: cacheSize,
                load: load,
                progressIndicatorBuilder: withLowRes
                    ? (context, url, progress) => ImageProgressWrapper(
                        aspectRatio: aspectRatio,
                        progress: load == null ? progress.progress : null,
                        child: lowResCacheSize != null
                            ? RawPostImageWidget(
                                post: post,
                                size: PostImageSize.sample,
                                fit: fit,
                                cacheSize: lowResCacheSize,
                              )
                            : RawPostImageWidget(
                                post: post,
                                size: PostImageSize.preview,
                                fit: fit,
                              ),
                      )
                    : null,
              );
            case PostImageSize.file:
              return RawPostImageWidget(
                stacked: true,
                post: post,
                size: PostImageSize.file,
                showProgress: showProgress,
                fit: fit,
                cacheSize: cacheSize,
                maxPixels: maxPixels,
                load: load,
                progressIndicatorBuilder: (context, url, progress) =>
                    ImageProgressWrapper(
                      progress: load == null ? progress.progress : null,
                      aspectRatio: aspectRatio,
                      child: RawPostImageWidget(
                        post: post,
                        size: PostImageSize.sample,
                        showProgress: showProgress,
                        fit: fit,
                        cacheSize: lowResCacheSize,
                      ),
                    ),
              );
          }
        },
      ),
    );
  }
}

class RawPostImageWidget extends StatelessWidget {
  const RawPostImageWidget({
    super.key,
    required this.post,
    required this.size,
    this.fit,
    this.progressIndicatorBuilder,
    this.stacked = false,
    this.showProgress = true,
    this.cacheSize,
    this.maxPixels,
    this.load,
  });

  final Post post;
  final PostImageSize size;
  final BoxFit? fit;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final bool stacked;
  final bool showProgress;
  final int? cacheSize;
  final ImageLoadController? load;

  /// The maximum number of pixels this image may decode to.
  final int? maxPixels;

  @override
  Widget build(BuildContext context) {
    final ImageLoadController? load = this.load;
    Duration fades = stacked
        ? Duration.zero
        : const Duration(milliseconds: 500);

    Widget progressIndicator(
      BuildContext context,
      String url,
      DownloadProgress progress,
    ) {
      return Center(
        child: SizedCircularProgressIndicator(
          size: 30,
          value: progress.progress,
        ),
      );
    }

    String url =
        switch (size) {
          PostImageSize.preview => post.preview,
          PostImageSize.sample => post.sample,
          PostImageSize.file => post.file!,
        } ??
        post.file!;
    Size dimensions = Size(post.width.toDouble(), post.height.toDouble());

    double aspectRatio = dimensions.width / dimensions.height;

    int? memCacheWidth;
    int? memCacheHeight;

    int? cacheSize = this.cacheSize;
    int? maxPixels = this.maxPixels;
    if (cacheSize != null || maxPixels != null) {
      double scale = 1;
      if (cacheSize != null) {
        if (aspectRatio > 1) {
          scale = cacheSize / dimensions.height;
        } else {
          scale = cacheSize / dimensions.width;
        }
      }
      if (maxPixels != null) {
        double pixelScale = sqrt(
          maxPixels / (dimensions.width * dimensions.height),
        );
        if (pixelScale < scale) {
          scale = pixelScale;
        }
      }
      // Never upscale, mirroring ResizeImage's default.
      if (scale < 1) {
        memCacheWidth = (dimensions.width * scale).round();
        memCacheHeight = (dimensions.height * scale).round();
      }
    }

    return CachedNetworkImage(
      fit: fit,
      fadeInDuration: fades,
      fadeOutDuration: fades,
      imageUrl: url,
      // A failed image used to render as a blank tile in grids, which
      // is indistinguishable from "no content"; show the broken image
      // hint everywhere instead.
      errorWidget: (context, url, error) {
        load?.report(url, ImageFailed(error));
        return defaultErrorBuilder(context, url, error);
      },
      progressIndicatorBuilder: showProgress || stacked
          ? (context, url, progress) {
              load?.report(url, ImageLoading(progress.progress));
              return (progressIndicatorBuilder ?? progressIndicator)(
                context,
                url,
                progress,
              );
            }
          : null,
      imageBuilder: load != null
          ? (context, image) {
              load.report(url, const ImageLoaded());
              return Image(image: image, fit: fit);
            }
          : null,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      cacheManager: context.read<BaseCacheManager>(),
    );
  }
}

class ImageProgressWrapper extends StatefulWidget {
  const ImageProgressWrapper({
    super.key,
    required this.child,
    required this.aspectRatio,
    required this.progress,
  });

  /// The widget below this one in the tree.
  final Widget child;

  /// The aspect ratio of the image.
  final double aspectRatio;

  /// The download progress.
  final double? progress;

  @override
  State<ImageProgressWrapper> createState() => _ImageProgressWrapperState();
}

class _ImageProgressWrapperState extends State<ImageProgressWrapper> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: widget.child),
          if (widget.progress != null)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: defaultAnimationDuration,
                child: LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A default error builder for cached network image.
///
/// Shows a dedicated torn-image glyph instead of a generic warning
/// exclamation: the photo is ripped apart and an exclamation badge marks
/// the bottom right corner, so the state it stands in reads at a glance
/// even at thumbnail sizes.
Widget defaultErrorBuilder(BuildContext context, String url, dynamic error) =>
    const TornImagePlaceholder();

/// The size the torn image glyph caps out at, in logical pixels. Smaller
/// tiles scale it down to stay inside their bounds.
const double tornImageMaxSize = 48;

/// The error placeholder of failed images: a photo torn in half with an
/// exclamation badge in the bottom right corner.
class TornImagePlaceholder extends StatelessWidget {
  const TornImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: tornImageMaxSize,
          maxHeight: tornImageMaxSize,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: _TornImagePainter(
              color: IconTheme.of(context).color ??
                  theme.colorScheme.onSurface,
              badgeColor: theme.colorScheme.error,
              badgeTextColor: theme.colorScheme.onError,
            ),
          ),
        ),
      ),
    );
  }
}

class _TornImagePainter extends CustomPainter {
  const _TornImagePainter({
    required this.color,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  final Color color;
  final Color badgeColor;
  final Color badgeTextColor;

  /// The jagged tear crossing the photo, as fractions of the glyph square
  /// with y measured from the top.
  static const List<Offset> tear = [
    Offset(0, 0.660),
    Offset(0.10, 0.690),
    Offset(0.22, 0.539),
    Offset(0.34, 0.623),
    Offset(0.46, 0.462),
    Offset(0.58, 0.546),
    Offset(0.72, 0.389),
    Offset(0.86, 0.452),
    Offset(1, 0.360),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 0.125; // keeps the slid strips inside the canvas
    const slide = 0.055; // torn paper: the strips slide apart horizontally
    const stroke = 0.055;
    const radius = 0.15;

    final square = size.width;
    final glyph = Rect.fromLTWH(
      inset * square,
      inset * square,
      (1 - 2 * inset) * square,
      (1 - 2 * inset) * square,
    );
    final frame = RRect.fromRectAndRadius(
      glyph,
      Radius.circular(radius * glyph.width),
    );
    final framePath = Path()..addRRect(frame);

    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * square
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final fillPaint = Paint()..color = color;

    // Each strip is the frame clipped to one side of the tear. Both draw
    // the full photo glyph, so the displaced strips carry their share of
    // sun and mountains with them.
    for (final upper in [true, false]) {
      final strip = Path.combine(
        PathOperation.intersect,
        framePath,
        _tearPath(size, above: upper),
      );
      canvas.save();
      canvas.clipPath(strip);
      canvas.translate((upper ? -1 : 1) * slide * square, 0);
      canvas.drawRRect(frame, framePaint);
      final base = glyph.bottom - framePaint.strokeWidth * 1.6;
      canvas.drawPath(
        Path()
          ..moveTo(glyph.left + 0.05 * glyph.width, base)
          ..lineTo(
            glyph.left + 0.30 * glyph.width,
            glyph.top + 0.66 * glyph.width,
          )
          ..lineTo(
            glyph.left + 0.46 * glyph.width,
            glyph.top + 0.87 * glyph.width,
          )
          ..lineTo(
            glyph.left + 0.60 * glyph.width,
            glyph.top + 0.76 * glyph.width,
          )
          ..lineTo(glyph.left + 0.76 * glyph.width, base)
          ..close(),
        fillPaint,
      );
      canvas.drawCircle(
        Offset(
          glyph.left + 0.27 * glyph.width,
          glyph.top + 0.26 * glyph.width,
        ),
        0.08 * glyph.width,
        fillPaint,
      );
      canvas.restore();
    }

    // The badge sits in the bottom right corner and overlaps the frame,
    // sized so the exclamation stays legible at thumbnail sizes.
    final badgeRadius = 0.195 * square;
    final badgeCenter = Offset(
      square - 1.32 * badgeRadius,
      square - 1.32 * badgeRadius,
    );
    canvas.drawCircle(badgeCenter, badgeRadius, Paint()..color = badgeColor);
    final barHalf = 0.16 * badgeRadius;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          badgeCenter.dx - barHalf,
          badgeCenter.dy - 0.50 * badgeRadius,
          badgeCenter.dx + barHalf,
          badgeCenter.dy + 0.12 * badgeRadius,
        ),
        Radius.circular(barHalf),
      ),
      Paint()..color = badgeTextColor,
    );
    canvas.drawCircle(
      Offset(badgeCenter.dx, badgeCenter.dy + 0.405 * badgeRadius),
      0.145 * badgeRadius,
      Paint()..color = badgeTextColor,
    );
  }

  /// The half plane on one side of the tear, extended far beyond the icon
  /// so clipping cannot leak around the tear ends.
  Path _tearPath(Size size, {required bool above}) {
    const inset = 0.125;
    final square = size.width;
    final points = tear
        .map(
          (fraction) => Offset(
            inset * square + fraction.dx * (1 - 2 * inset) * square,
            inset * square + fraction.dy * (1 - 2 * inset) * square,
          ),
        )
        .toList();
    final far = 4 * square;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (above) {
      path
        ..lineTo(size.width + far, -far)
        ..lineTo(-far, -far)
        ..close();
    } else {
      path
        ..lineTo(size.width + far, size.height + far)
        ..lineTo(-far, size.height + far)
        ..close();
    }
    return path;
  }

  @override
  bool shouldRepaint(_TornImagePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.badgeColor != badgeColor ||
      oldDelegate.badgeTextColor != badgeTextColor;
}

/// The cache size of images shown in fullscreen views on mobile.
///
/// Fullscreen images are e621 originals, which can exceed 4000px. Decoding
/// them at full size fills the image cache of low end devices within a
/// few posts, so their decoded size is capped. 2048px covers the physical
/// resolution of the 1080p screens such devices usually have. Other
/// platforms keep the uncapped fullscreen originals.
int? get fullscreenImageCacheSize =>
    Platform.isAndroid || Platform.isIOS ? 2048 : null;

/// The maximum number of pixels a decoded fullscreen image may occupy on
/// mobile.
///
/// The one dimensional [fullscreenImageCacheSize] limit alone lets extreme
/// aspect ratios decode to 25-30 MB, more than a 32 bit device's image
/// cache is willing to hold, so such images are never cached and get
/// redecoded whenever they scroll back into view. A pixel budget caps
/// every fullscreen image equally. Other platforms keep the uncapped
/// fullscreen originals.
int? get fullscreenImageMaxPixels =>
    Platform.isAndroid || Platform.isIOS ? 2048 * 2048 : null;

class ImageCacheSize {
  /// Configures the cache size for images.
  const ImageCacheSize(this.size);

  /// The cache size of the image.
  final int? size;
}

class ImageCacheSizeProvider extends SubProvider0<ImageCacheSize> {
  /// Provides the cache size for images to a subtree.
  ImageCacheSizeProvider({required int? size, super.child, super.builder})
    : super(
        create: (context) => ImageCacheSize(size),
        keys: (context) => [size],
      );

  /// Removes the cache size for images for a subtree.
  ImageCacheSizeProvider.none({super.child, super.builder})
    : super(create: (context) => const ImageCacheSize(null));
}
