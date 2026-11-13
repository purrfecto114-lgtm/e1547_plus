import 'dart:async';

import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';

class ScaffoldFrameController extends ValueNotifier<bool> {
  ScaffoldFrameController({bool visible = false}) : super(visible);

  Timer? frameToggler;
  set visible(bool value) => this.value = value;
  bool get visible => value;

  void showFrame({Duration? duration}) =>
      toggleFrame(shown: true, duration: duration);

  void hideFrame({Duration? duration}) =>
      toggleFrame(shown: false, duration: duration);

  void toggleFrame({bool? shown, Duration? duration}) {
    bool result = shown ?? !visible;

    frameToggler?.cancel();
    void toggle() {
      visible = result;
    }

    if (duration == null) {
      toggle();
    } else {
      frameToggler = Timer(duration, toggle);
    }
  }

  void cancel() => frameToggler?.cancel();

  @override
  void dispose() {
    cancel();
    super.dispose();
  }
}

class ScaffoldFrame extends StatelessWidget {
  const ScaffoldFrame({super.key, required this.child, this.controller});

  final Widget child;
  final ScaffoldFrameController? controller;

  static ScaffoldFrameController of(BuildContext context) => maybeOf(context)!;

  static ScaffoldFrameController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ScaffoldFrameData>()
      ?.notifier;

  @override
  Widget build(BuildContext context) => SubDefault<ScaffoldFrameController>(
    value: controller,
    create: () => ScaffoldFrameController(),
    builder: (context, controller) =>
        _ScaffoldFrameData(controller: controller, child: child),
  );
}

class _ScaffoldFrameData extends InheritedNotifier<ScaffoldFrameController> {
  const _ScaffoldFrameData({
    required super.child,
    required ScaffoldFrameController controller,
  }) : super(notifier: controller);
}

class ScaffoldFrameChild extends StatelessWidget {
  const ScaffoldFrameChild({super.key, required this.child, this.shown});

  final bool? shown;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    ScaffoldFrameController? controller = ScaffoldFrame.maybeOf(context);
    bool shown = this.shown ?? controller?.visible ?? true;

    Widget body() {
      return AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: defaultAnimationDuration,
        child: ExcludeFocus(
          excluding: !shown,
          child: IgnorePointer(ignoring: !shown, child: child),
        ),
      );
    }

    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) => body(),
        child: child,
      );
    } else {
      return body();
    }
  }
}

class ScaffoldFrameAppBar extends StatelessWidget with AppBarBuilderWidget {
  const ScaffoldFrameAppBar({super.key, required this.child});

  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) => ScaffoldFrameChild(child: child);
}

class ScaffoldFrameSystemUI extends StatefulWidget {
  const ScaffoldFrameSystemUI({super.key, required this.child});

  final Widget child;

  @override
  State<ScaffoldFrameSystemUI> createState() => _ScaffoldFrameSystemUIState();
}

class _ScaffoldFrameSystemUIState extends State<ScaffoldFrameSystemUI>
    with DefaultRouteAware<ScaffoldFrameSystemUI> {
  late RouterDrawerController navigation;

  /// Generation token for the system UI change callback slot.
  ///
  /// [SystemChrome.setSystemUIChangeCallback] is one global slot: a
  /// newer frame registering itself replaces an older one's callback,
  /// and that older frame's dispose would then clear the newer
  /// registration. Every registration carries the latest token; a
  /// callback firing under a stale token is ignored, and only the
  /// current registration may clear the slot.
  static int _callbackToken = 0;
  int _token = 0;

  Future<void> toggleFrame(bool shown) async {
    if (shown) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  @override
  void initState() {
    super.initState();
    _token = ++_callbackToken;
    final int token = _token;
    SystemChrome.setSystemUIChangeCallback((shown) async {
      // A newer frame took over the slot; this registration is stale.
      if (token != _callbackToken) return;
      ScaffoldFrameController controller = ScaffoldFrame.of(context);
      if (controller.visible != shown) {
        controller.toggleFrame(shown: shown);
      }
    });
  }

  @override
  void didPop() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  @override
  void dispose() {
    // Only the current registration may clear the slot; a stale one
    // must not wipe the callback a newer frame installed.
    if (_token == _callbackToken) {
      SystemChrome.setSystemUIChangeCallback(null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubListener(
      initialize: true,
      listenable: ScaffoldFrame.of(context),
      listener: () => toggleFrame(ScaffoldFrame.of(context).visible),
      builder: (context) => widget.child,
    );
  }
}
