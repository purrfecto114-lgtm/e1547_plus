import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' show pi, sqrt;

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

    // The list filter only guarantees that posts carry a file when they
    // are not deleted, so a deleted post without one can slip through
    // every branch below. Such a post has nothing to load at all: show
    // the torn image placeholder instead of asserting into a crash.
    String? url =
        switch (size) {
          PostImageSize.preview => post.preview,
          PostImageSize.sample => post.sample,
          PostImageSize.file => post.file,
        } ??
        post.file;
    if (url == null) return const TornImagePlaceholder();
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
/// exclamation: the photo is ripped in half and an exclamation badge
/// marks the bottom right corner, so the state it stands in reads at a
/// glance even at thumbnail sizes. Like every other icon of the app the
/// glyph is monochrome and follows the outlined Material vocabulary.
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
              color: IconTheme.of(context).color ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a ripped photo in the outlined Material icon language: a round
/// edged frame torn across the middle, its halves slid apart so the tear
/// reads at thumbnail sizes, a stroked mountain ridge and a sun dot
/// inside, plus a solid badge with a knocked out exclamation mark in the
/// bottom right corner, the way Material composes badges onto glyphs.
class _TornImagePainter extends CustomPainter {
  const _TornImagePainter({required this.color});

  final Color color;

  /// The jagged tear crossing the photo, as fractions of the glyph square
  /// with y measured from the top. A shallow diagonal with small teeth:
  /// bold zigzags would read as a second mountain ridge instead of a rip.
  static const List<Offset> tear = [
    Offset(0, 0.40),
    Offset(0.13, 0.44),
    Offset(0.24, 0.38),
    Offset(0.38, 0.46),
    Offset(0.52, 0.41),
    Offset(0.63, 0.47),
    Offset(0.78, 0.42),
    Offset(1, 0.49),
  ];

  /// The mountain ridge of the photo, a stroked polyline like the one
  /// Material's image glyphs draw instead of a filled silhouette. It
  /// runs to the right edge and slides beneath the badge, the way
  /// Material lets glyphs disappear under their badge.
  static const List<Offset> ridge = [
    Offset(0, 0.68),
    Offset(0.24, 0.56),
    Offset(0.42, 0.68),
    Offset(0.56, 0.60),
    Offset(1, 0.72),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 0.115; // keeps the slid halves inside the canvas
    const lift = 0.06; // torn photo: the halves slide apart vertically
    const shear = 0.018; // ...and slightly along the tear
    const stroke = 0.06;

    final square = size.width;
    final glyph = Rect.fromLTWH(
      inset * square,
      inset * square,
      (1 - 2 * inset) * square,
      (1 - 2 * inset) * square,
    );
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * square
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final fill = Paint()..color = color;

    // Each half is drawn as one closed outline: the ragged tear edge plus
    // the frame edges and rounded corners that belong to it. Stroking
    // that single path keeps every joint round and needs no clipping,
    // which would eat half of every stroke it touches.
    for (final upper in [true, false]) {
      canvas.save();
      canvas.translate(
        (upper ? -1 : 1) * shear * square,
        (upper ? -1 : 1) * lift * square,
      );
      canvas.drawPath(_halfBoundary(upper: upper, glyph: glyph), line);
      if (upper) {
        canvas.drawCircle(
          Offset(
            glyph.left + 0.28 * glyph.width,
            glyph.top + 0.21 * glyph.width,
          ),
          0.07 * glyph.width,
          fill,
        );
      } else {
        canvas.drawPath(_polyline(ridge, glyph), line);
      }
      canvas.restore();
    }

    // The badge sits in the bottom right corner and overlaps the frame,
    // sized so the exclamation stays legible at thumbnail sizes. It is
    // solid like Material's badge glyphs and keeps its exclamation
    // knocked out, so it works on every background without a hard coded
    // error color clashing with the monochrome icon row it appears in.
    final badgeRadius = 0.16 * square;
    final badgeCenter = Offset(0.82 * square, 0.82 * square);
    final badge = Path()
      ..addOval(Rect.fromCircle(center: badgeCenter, radius: badgeRadius));
    final exclamation = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            badgeCenter.dx - 0.17 * badgeRadius,
            badgeCenter.dy - 0.52 * badgeRadius,
            badgeCenter.dx + 0.17 * badgeRadius,
            badgeCenter.dy + 0.10 * badgeRadius,
          ),
          Radius.circular(0.17 * badgeRadius),
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(badgeCenter.dx, badgeCenter.dy + 0.42 * badgeRadius),
          radius: 0.15 * badgeRadius,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, badge, exclamation),
      fill,
    );
  }

  /// The closed outline of one torn half: its ragged tear edge plus the
  /// frame edges and rounded corners that belong to it.
  Path _halfBoundary({required bool upper, required Rect glyph}) {
    final corner = 0.11 * glyph.width;
    Rect cornerBox(Offset center) =>
        Rect.fromCircle(center: center, radius: corner);
    final tearPoints = tear
        .map(
          (point) => Offset(
            glyph.left + point.dx * glyph.width,
            glyph.top + point.dy * glyph.width,
          ),
        )
        .toList();
    final start = tearPoints.first;
    final path = Path()..moveTo(start.dx, start.dy);
    for (final point in tearPoints.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (upper) {
      path
        ..lineTo(glyph.right, glyph.top + corner)
        ..arcTo(
          cornerBox(Offset(glyph.right - corner, glyph.top + corner)),
          0,
          -pi / 2,
          false,
        )
        ..lineTo(glyph.left + corner, glyph.top)
        ..arcTo(
          cornerBox(Offset(glyph.left + corner, glyph.top + corner)),
          -pi / 2,
          -pi / 2,
          false,
        )
        ..lineTo(start.dx, start.dy)
        ..close();
    } else {
      path
        ..lineTo(glyph.right, glyph.bottom - corner)
        ..arcTo(
          cornerBox(Offset(glyph.right - corner, glyph.bottom - corner)),
          0,
          pi / 2,
          false,
        )
        ..lineTo(glyph.left + corner, glyph.bottom)
        ..arcTo(
          cornerBox(Offset(glyph.left + corner, glyph.bottom - corner)),
          pi / 2,
          pi / 2,
          false,
        )
        ..lineTo(start.dx, start.dy)
        ..close();
    }
    return path;
  }

  /// Maps glyph fractions onto the glyph square as an open polyline.
  Path _polyline(List<Offset> points, Rect glyph) {
    final path = Path();
    for (final (index, point) in points.indexed) {
      final vertex = Offset(
        glyph.left + point.dx * glyph.width,
        glyph.top + point.dy * glyph.width,
      );
      index == 0
          ? path.moveTo(vertex.dx, vertex.dy)
          : path.lineTo(vertex.dx, vertex.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_TornImagePainter oldDelegate) =>
      oldDelegate.color != color;
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
