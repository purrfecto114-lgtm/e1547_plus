import 'package:flutter/material.dart';

/// Defers the content of a list tile while the enclosing scroll flings
/// fast, so tiles a fast fling sweeps past never start the downloads and
/// decodes of pixels nobody sees.
///
/// The gate reads the framework's own velocity heuristic
/// ([Scrollable.recommendDeferredLoadingForContext]: the current scroll
/// velocity above the screen's physical pixel length) when the tile
/// builds. A tile the fling sweeps past builds under that fast velocity,
/// so it renders its placeholder and starts no image stream; the sliver
/// destroys the tile once it leaves the viewport and nothing lingers
/// behind it. While the scroll keeps the tile deferred, the gate re
/// checks the heuristic once per frame — a tile built under the last
/// frame of a ballistic cannot rely on a scroll end notification
/// reaching it, because that notification is dispatched before the frame
/// that mounts the tile. The first frame whose velocity is below the
/// threshold releases the gate and loads the content for real. Slow
/// drags stay below the threshold, so tiles built under them load
/// immediately, and a gate that has released never engages again.
class ScrollSettleGate extends StatefulWidget {
  const ScrollSettleGate({
    super.key,
    required this.child,
    required this.placeholder,
  });

  /// The real content, built once the scroll has settled.
  final Widget child;

  /// Shown while the tile waits for the scroll to settle.
  final Widget placeholder;

  @override
  State<ScrollSettleGate> createState() => _ScrollSettleGateState();
}

class _ScrollSettleGateState extends State<ScrollSettleGate> {
  bool settled = false;

  /// Whether a re-check chain is already running, so a re-entering
  /// [didChangeDependencies] cannot stack a second one on top of it.
  bool checkPending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The heuristic does not register a dependency, so this stays a one
    // shot verdict taken at the velocity the tile mounted under: a tile
    // built under a resting scroll shows its content at once, one built
    // under a fast fling waits for the per frame checks below.
    if (!settled && !Scrollable.recommendDeferredLoadingForContext(context)) {
      settled = true;
    } else {
      _checkOnNextFrame();
    }
  }

  /// Re-checks the heuristic once per frame until the scroll the tile
  /// was mounted under comes to rest. Every callback runs after its
  /// frame has painted, so the verdict sees the velocity the scroll
  /// carries into the next one, and a tile that left the viewport in
  /// the meantime stops the chain through [mounted].
  void _checkOnNextFrame() {
    if (checkPending) return;
    checkPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPending = false;
      if (!mounted || settled) return;
      if (!Scrollable.recommendDeferredLoadingForContext(context)) {
        release();
      } else {
        _checkOnNextFrame();
      }
    });
  }

  void release() {
    if (!settled) setState(() => settled = true);
  }

  @override
  Widget build(BuildContext context) {
    if (settled) return widget.child;
    return widget.placeholder;
  }
}
