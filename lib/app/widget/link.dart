import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:e1547/app/app.dart';
import 'package:flutter/material.dart';

class AppLinkHandler extends StatefulWidget {
  const AppLinkHandler({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<AppLinkHandler> createState() => _AppLinkHandlerState();
}

class _AppLinkHandlerState extends State<AppLinkHandler> {
  late AppLinks appLinks;
  StreamSubscription<Uri>? linkListener;
  final LinkDeduplicator deduplicator = LinkDeduplicator();

  /// Handles a link from any entry point exactly once.
  ///
  /// The cold start link arrives through both the initial-link getter and
  /// the first stream subscription on Android; the deduplicator collapses
  /// that into one handling. [coldStart] links replace the route stack,
  /// hot links push onto it.
  Future<void> _dispatch(Uri? url, {bool coldStart = false}) async {
    if (url == null) return;
    // Reserving before any await collapses duplicate deliveries of one
    // link into a single handling. The reservation is only committed
    // once the link was actually opened; a dispatch that fails rolls
    // it back, so the link is not swallowed for the rest of the
    // window.
    if (!deduplicator.check(url)) return;
    bool handled = false;
    try {
      // A link can arrive before the first frame attached the
      // navigator; its context only exists once built. Waiting for it
      // keeps a cold start link from being dropped when the first
      // frame was not enough.
      while (widget.navigatorKey.currentContext == null) {
        if (!mounted) return;
        await WidgetsBinding.instance.endOfFrame;
      }
      if (coldStart) {
        // The first route stays rooted, so backing out of the linked
        // page returns somewhere instead of leaving the app.
        widget.navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
      if (!const E621LinkParser().open(
        widget.navigatorKey.currentContext!,
        url.toString(),
      )) {
        await launch(url.toString());
      }
      handled = true;
    } finally {
      if (handled) {
        deduplicator.consume(url);
      } else {
        deduplicator.release(url);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (PlatformCapabilities.hasDeepLinks) {
      appLinks = AppLinks();
      appLinks.getInitialLink().then((url) => _dispatch(url, coldStart: true));
      linkListener = appLinks.uriLinkStream.listen(_dispatch);
    }
  }

  @override
  void dispose() {
    linkListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
