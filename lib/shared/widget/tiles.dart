import 'dart:math';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

enum GridQuilt { square, vertical }

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
    TileSize.small => AppLocalizations.of(context).qualityLow,
    TileSize.medium => AppLocalizations.of(context).qualityMedium,
    TileSize.large => AppLocalizations.of(context).qualityHigh,
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
  });

  final double tileHeightFactor;
  final int tileSize;
  final int mainAxisCount;
  final int crossAxisCount;
  final GridQuilt stagger;

  @override
  bool updateShouldNotify(covariant TileLayoutData oldWidget) =>
      (oldWidget.tileHeightFactor != tileHeightFactor ||
      oldWidget.crossAxisCount != crossAxisCount ||
      oldWidget.stagger != stagger);
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
    return ValueListenableBuilder<TileSize>(
      valueListenable: context.watch<Settings>().tileSize,
      builder: (context, tier, child) => ValueListenableBuilder<GridQuilt>(
        valueListenable: context.watch<Settings>().quilt,
        builder: (context, stagger, child) => LayoutBuilder(
          builder: (context, constraints) {
            int tileSize = this.tileSize ?? tier.pixels;
            stagger = this.stagger ?? stagger;
            int crossAxisCount = max(
              1,
              constraints.maxWidth / tileSize,
            ).round();
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
              child: this.child,
            );
          },
        ),
      ),
    );
  }
}
