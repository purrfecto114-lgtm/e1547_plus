import 'dart:math';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

enum GridQuilt { square, vertical }

/// A column-count preference over the grid's computed layout.
///
/// Auto keeps the column count the tile size computes, dense packs one
/// more column for scroll-efficient browsing, and loose gives the cards
/// more room. The tiers mirror how gallery apps expose density: a named
/// nudge instead of a free column number, so every choice stays a
/// designed layout.
enum GridDensity {
  auto,
  dense,
  loose;

  int get offset => switch (this) {
    GridDensity.auto => 0,
    GridDensity.dense => 1,
    GridDensity.loose => -1,
  };

  /// Localized display name for pickers.
  String localizedTitle(BuildContext context) => switch (this) {
    GridDensity.auto => AppLocalizations.of(context).gridDensityAuto,
    GridDensity.dense => AppLocalizations.of(context).gridDensityDense,
    GridDensity.loose => AppLocalizations.of(context).gridDensityLoose,
  };
}

/// The density tiers of the post grid.
///
/// A tier is a curated tile size in pixels rather than a free slider, so
/// the grid always snaps to a layout that was actually designed and
/// tested, and the choice stays explainable in three words.
///
/// The three sizes are spaced so that the resulting column count stays
/// distinct on any phone width above 300dp: 360dp divides into 3 / 2 / 1
/// columns. The previous 150/200/300 ladder collapsed the low and the
/// medium tier onto the same two columns there, which made the middle
/// option look like it did nothing.
enum TileSize {
  small,
  medium,
  large;

  int get pixels => switch (this) {
    TileSize.small => 120,
    TileSize.medium => 180,
    TileSize.large => 300,
  };

  /// Localized display name for pickers.
  String localizedTitle(BuildContext context) => switch (this) {
    TileSize.small => AppLocalizations.of(context).tileSmall,
    TileSize.medium => AppLocalizations.of(context).tileMedium,
    TileSize.large => AppLocalizations.of(context).tileLarge,
  };
}

/// How sharp grid thumbnails decode, independent of how large the
/// cards lay out. The factor multiplies the card's device pixels, so
/// low covers a normal display exactly, medium doubles it for zooming
/// and dense screens, and high goes further for near-fullscreen reuse.
///
/// The cap bounds very dense screens; the decode itself never
/// up-scales (see PostImage). Switching tiers costs no traffic: the
/// memory decode size does not change the disk cache key.
enum ThumbnailQuality {
  low,
  medium,
  high;

  double get factor => switch (this) {
    ThumbnailQuality.low => 1,
    ThumbnailQuality.medium => 2,
    ThumbnailQuality.high => 3,
  };

  int get cap => switch (this) {
    ThumbnailQuality.low => 540,
    ThumbnailQuality.medium => 1080,
    ThumbnailQuality.high => 1620,
  };

  /// Localized display name for pickers.
  String localizedTitle(BuildContext context) => switch (this) {
    ThumbnailQuality.low => AppLocalizations.of(context).qualityLow,
    ThumbnailQuality.medium => AppLocalizations.of(context).qualityMedium,
    ThumbnailQuality.high => AppLocalizations.of(context).qualityHigh,
  };
}

class TileLayoutData extends InheritedWidget {
  const TileLayoutData({
    super.key,
    required super.child,
    required this.tileHeightFactor,
    required this.tileSize,
    required this.mainAxisCount,
    required this.crossAxisCount,
    required this.stagger,
    required this.qualityFactor,
    required this.qualityCap,
  });

  final double tileHeightFactor;
  final int tileSize;
  final int mainAxisCount;
  final int crossAxisCount;
  final GridQuilt stagger;

  /// The thumbnail-quality tier resolved for this layout, feeding the
  /// image cache sizing of grid tiles so builders below can read it
  /// from [TileLayout.of] without their own provider subscription.
  final double qualityFactor;
  final int qualityCap;

  @override
  bool updateShouldNotify(covariant TileLayoutData oldWidget) =>
      (oldWidget.tileHeightFactor != tileHeightFactor ||
      // The tile size feeds the image cache sizing: a tier switch that
      // happens to keep the same column count must still rebuild.
      oldWidget.tileSize != tileSize ||
      oldWidget.crossAxisCount != crossAxisCount ||
      oldWidget.stagger != stagger ||
      oldWidget.qualityFactor != qualityFactor ||
      oldWidget.qualityCap != qualityCap);
}

class TileLayout extends StatelessWidget {
  const TileLayout({
    super.key,
    required this.child,
    this.tileHeightFactor = 1.2,
    this.tileSize,
    this.stagger,
  });

  final Widget child;
  final double tileHeightFactor;
  final int? tileSize;
  final GridQuilt? stagger;

  static TileLayoutData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TileLayoutData>()!;

  static TileLayoutData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TileLayoutData>();

  @override
  Widget build(BuildContext context) {
    final Settings settings = context.watch<Settings>();
    return ValueListenableBuilder<TileSize>(
      valueListenable: settings.tileSize,
      builder: (context, tier, child) => ValueListenableBuilder<GridQuilt>(
        valueListenable: settings.quilt,
        builder: (context, stagger, child) =>
            ValueListenableBuilder<ThumbnailQuality>(
              valueListenable: settings.thumbnailQuality,
              builder: (context, quality, child) => LayoutBuilder(
                builder: (context, constraints) {
                  int tileSize = this.tileSize ?? tier.pixels;
                  stagger = this.stagger ?? stagger;
                  // The density preference nudges the computed column
                  // count by one either way; auto keeps it as computed.
                  int crossAxisCount = max(
                    1,
                    (constraints.maxWidth / tileSize).round() +
                        settings.gridDensity.value.offset,
                  );
                  int mainAxisCount = max(
                    1,
                    constraints.maxHeight / tileSize,
                  ).round();
                  return TileLayoutData(
                    tileHeightFactor: tileHeightFactor,
                    tileSize: tileSize,
                    mainAxisCount: mainAxisCount,
                    crossAxisCount: crossAxisCount,
                    stagger: stagger,
                    qualityFactor: quality.factor,
                    qualityCap: quality.cap,
                    child: this.child,
                  );
                },
              ),
            ),
      ),
    );
  }
}
