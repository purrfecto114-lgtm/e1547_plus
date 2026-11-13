import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;

  /// Refreshes the content and reports whether it succeeded.
  ///
  /// The boolean return value is what lets the header tell a failed
  /// refresh from a completed one: cached_query swallows fetch errors
  /// into the query state instead of throwing them, so a bare await
  /// cannot signal failure and the indicator would claim success even
  /// while offline.
  final Future<bool> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return SubValue(
      create: () => RefreshController(),
      builder: (context, refreshController) => SubEffect(
        effect: () {
          bool handler(KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.f5) {
              // Hardware handlers fire for every PullToRefresh in the
              // tree, so only the top-most route's indicator may
              // refresh; without this check, a page buried below the
              // current one would refresh as well.
              if (ModalRoute.of(context)?.isCurrent ?? false) {
                refreshController.requestRefresh(
                  duration: const Duration(milliseconds: 100),
                );
                return true;
              }
            }
            return false;
          }

          HardwareKeyboard.instance.addHandler(handler);
          return () => HardwareKeyboard.instance.removeHandler(handler);
        },
        keys: const [],
        child: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            bool success = false;
            try {
              success = await onRefresh();
            } on Object {
              success = false;
            }
            success
                ? refreshController.refreshCompleted()
                : refreshController.refreshFailed();
          },
          header: const ClassicHeader(),
          child: child,
        ),
      ),
    );
  }
}
