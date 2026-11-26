import 'package:flutter/material.dart';

double smallIconSize(BuildContext context) => 18;

/// The opacity of decorative dimming.
///
/// Used for content which only conveys secondary information, like
/// dates, aliases or code block frames.
const double dimmedOpacity = 0.35;

/// The opacity of dimming for content which is still interactive.
///
/// Tappable controls, like the popup menu icon of a tile or a vote
/// row, must stay recognizable as enabled, so they keep more contrast
/// than decorative dimming.
const double interactiveDimmedOpacity = 0.55;

Color dimTextColor(BuildContext context, [double opacity = dimmedOpacity]) =>
    Theme.of(
      context,
    ).textTheme.bodyMedium!.color!.withAlpha((opacity * 255).ceil());

class Dimmed extends StatelessWidget {
  const Dimmed({super.key, required this.child, this.opacity = dimmedOpacity});

  /// Dims a child which is still interactive, like a popup menu icon,
  /// a vote row or a tappable name.
  const Dimmed.interactive({super.key, required this.child})
    : opacity = interactiveDimmedOpacity;

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: Theme.of(context).iconTheme.copyWith(
        color: dimTextColor(context, opacity),
        size: smallIconSize(context),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: dimTextColor(context, opacity)),
        child: child,
      ),
    );
  }
}
