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
    final String? preferredUrl = switch (size) {
      PostImageSize.preview => post.preview,
      PostImageSize.sample => post.sample,
      PostImageSize.file => post.file,
    };
    // A preview or sample which fell back to the original file must not
    // decode that original at full size just to act as a thumbnail.
    final bool fellBackToFile = preferredUrl == null && post.file != null;
    String? url = preferredUrl ?? post.file;
    if (url == null) return const TornImagePlaceholder();
    Size dimensions = Size(post.width.toDouble(), post.height.toDouble());

    double aspectRatio = dimensions.width / dimensions.height;

    int? memCacheWidth;
    int? memCacheHeight;

    int? cacheSize = this.cacheSize;
    int? maxPixels = this.maxPixels;
    if (fellBackToFile && cacheSize == null) {
      // The same fixed cap the comic and timeline tiles decode their
      // images with; see PostComicSliver and PostTimelineSliver.
      cacheSize = 800;
    }
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
/// Shows a dedicated broken-image glyph instead of a generic warning
/// exclamation: the photo is ripped into left and right halves that
/// slide apart, so the state it stands in reads at a glance even at
/// thumbnail sizes. Like every other icon of the app the glyph is
/// monochrome and follows the outlined Material vocabulary.
Widget defaultErrorBuilder(BuildContext context, String url, dynamic error) =>
    const TornImagePlaceholder();

/// The size the torn image glyph caps out at, in logical pixels. Smaller
/// tiles scale it down to stay inside their bounds.
const double tornImageMaxSize = 48;

/// The error placeholder of failed images: a photo ripped into two
/// halves that slide apart.
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

/// Paints a ripped photo in the outlined Material icon language the app
/// draws every other glyph in: a small cornered frame ripped top to
/// bottom into two halves that slide apart. The sun stays on the left
/// half, the mountain ridge is torn across and survives as two stubs,
/// so the rip reads as a broken picture instead of a decoration line.
/// The tear is a few bold straight teeth instead of fine ragged fuzz,
/// and nothing else piles onto the glyph, so it reads cleanly down to
/// thumbnail sizes.
class _TornImagePainter extends CustomPainter {
  const _TornImagePainter({required this.color});

  final Color color;

  static const inset = 0.125;

  /// The tear running top to bottom through the photo, as fractions of
  /// the glyph square. Its ends sit on the frame's top and bottom edges
  /// and two bold teeth slant across the middle: few, sharp teeth read
  /// as an actual rip, while finer ragged fuzz turns into noise at
  /// thumbnail sizes.
  static const List<Offset> tear = [
    Offset(0.50, 0.125),
    Offset(0.43, 0.30),
    Offset(0.53, 0.48),
    Offset(0.42, 0.66),
    Offset(0.50, 0.875),
  ];

  /// The mountain ridge torn across by the rip, a stroked polyline like
  /// the one Material's image glyphs draw instead of a filled
  /// silhouette. The stubs line up across the tear like one mountain
  /// split in two, and each slides away with its half.
  static const List<Offset> ridgeLeft = [
    Offset(0.145, 0.60),
    Offset(0.28, 0.47),
    Offset(0.39, 0.55),
  ];
  static const List<Offset> ridgeRight = [
    Offset(0.545, 0.51),
    Offset(0.66, 0.44),
    Offset(0.855, 0.55),
  ];

  /// The sun dot on the left half, filled like the one Material's image
  /// glyphs draw. Expressed relative to the unshifted frame.
  static const sunCenter = Offset(0.26, 0.235);
  static const sunRadius = 0.048;

  /// How far each half slides away from the tear, so the rip opens into
  /// a visible gap with offset frame edges instead of reading as a
  /// decoration line: the left half pulls up and out, the right one
  /// down and out.
  static const leftShift = Offset(-0.07, 0);
  static const rightShift = Offset(0.07, 0);

  @override
  void paint(Canvas canvas, Size size) {
    const corner = 0.045; // matches the 4px rounding of the app's cards
    const stroke = 0.0833; // the 2px stroke of Material's 24px grid

    final square = size.width;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * square
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    canvas.save();
    canvas.translate(leftShift.dx * square, leftShift.dy * square);
    canvas.drawPath(_leftHalf(square, corner), line);
    canvas.drawPath(_polyline(ridgeLeft, square), line);
    canvas.drawCircle(
      Offset(sunCenter.dx * square, sunCenter.dy * square),
      sunRadius * square,
      Paint()..color = color,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(rightShift.dx * square, rightShift.dy * square);
    canvas.drawPath(_rightHalf(square, corner), line);
    canvas.drawPath(_polyline(ridgeRight, square), line);
    canvas.restore();
  }

  /// The closed outline of the left half: the tear edge plus the frame
  /// edges and corners that belong to it. Every coordinate is a fraction
  /// of the glyph square.
  Path _leftHalf(double square, double corner) {
    final radius = corner * square;
    Rect cornerBox(Offset center) =>
        Rect.fromCircle(center: center, radius: radius);
    final left = inset * square;
    final top = inset * square;
    final bottom = (1 - inset) * square;
    final tearPoints = tear
        .map((point) => Offset(point.dx * square, point.dy * square))
        .toList();
    final path = Path()..moveTo(tearPoints.first.dx, tearPoints.first.dy);
    for (final point in tearPoints.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path
      ..lineTo(left + radius, bottom)
      ..arcTo(
        cornerBox(Offset(left + radius, bottom - radius)),
        pi / 2,
        pi / 2,
        false,
      )
      ..lineTo(left, top + radius)
      ..arcTo(cornerBox(Offset(left + radius, top + radius)), pi, pi / 2, false)
      ..close();
  }

  /// The closed outline of the right half: the frame edges and corners
  /// on the right plus the tear edge running back up.
  Path _rightHalf(double square, double corner) {
    final radius = corner * square;
    Rect cornerBox(Offset center) =>
        Rect.fromCircle(center: center, radius: radius);
    final right = (1 - inset) * square;
    final top = inset * square;
    final bottom = (1 - inset) * square;
    final tearPoints = tear
        .map((point) => Offset(point.dx * square, point.dy * square))
        .toList();
    final path = Path()
      ..moveTo(tearPoints.first.dx, tearPoints.first.dy)
      ..lineTo(right - radius, top)
      ..arcTo(
        cornerBox(Offset(right - radius, top + radius)),
        3 * pi / 2,
        pi / 2,
        false,
      )
      ..lineTo(right, bottom - radius)
      ..arcTo(
        cornerBox(Offset(right - radius, bottom - radius)),
        0,
        pi / 2,
        false,
      )
      ..lineTo(tearPoints.last.dx, tearPoints.last.dy);
    for (final point in tearPoints.reversed.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  /// Maps glyph fractions onto the glyph square as an open polyline.
  Path _polyline(List<Offset> points, double square) {
    final path = Path();
    for (final (index, point) in points.indexed) {
      final vertex = Offset(point.dx * square, point.dy * square);
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
