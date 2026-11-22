import 'dart:async';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.child,
    required FutureOr<Object?> Function() this.onRefresh,
  }) : onNotedRefresh = null;

  const PullToRefresh.noted({
    super.key,
    required this.child,
    required Future<Widget?> Function() onRefresh,
  }) : onNotedRefresh = onRefresh,
       onRefresh = null;

  final Widget child;
  final FutureOr<Object?> Function()? onRefresh;
  final Future<Widget?> Function()? onNotedRefresh;

  @override
  Widget build(BuildContext context) {
    return SubValue<ValueNotifier<Widget?>>(
      create: () => ValueNotifier(null),
      dispose: (value) => value.dispose(),
      builder: (context, note) => SubValue(
        create: () => RefreshController(),
        builder: (context, refreshController) => SubEffect(
          effect: () {
            bool handler(KeyEvent event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.f5) {
                refreshController.requestRefresh(
                  duration: const Duration(milliseconds: 100),
                );
                return true;
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
              bool succeeded = true;
              try {
                if (onNotedRefresh case final noted?) {
                  note.value = await noted();
                } else if (onRefresh case final refresh?) {
                  // A void callback gives no verdict; a bool one is the
                  // honest outcome of the refresh (the offline verdicts
                  // fix), and the header must report it either way.
                  final AppLocalizations l10n = AppLocalizations.of(context);
                  final Object? result = await refresh();
                  if (result == false) {
                    succeeded = false;
                    note.value = Text(l10n.refreshFailed);
                  } else if (result == true) {
                    note.value = Text(l10n.refreshCompleted);
                  }
                }
                if (note.value != null) {
                  await WidgetsBinding.instance.endOfFrame;
                }
                if (succeeded) {
                  refreshController.refreshCompleted();
                } else {
                  refreshController.refreshFailed();
                }
              } on Object {
                note.value = Text(AppLocalizations.of(context).refreshFailed);
                await WidgetsBinding.instance.endOfFrame;
                refreshController.refreshFailed();
              }
            },
            header: HexagonRefreshHeader(note: note),
            child: child,
          ),
        ),
      ),
    );
  }
}

const double _refreshExtent = 64;

class HexagonRefreshHeader extends StatefulWidget {
  const HexagonRefreshHeader({super.key, this.note});

  final ValueListenable<Widget?>? note;

  @override
  State<HexagonRefreshHeader> createState() => _HexagonRefreshHeaderState();
}

class _HexagonRefreshHeaderState extends State<HexagonRefreshHeader> {
  final ValueNotifier<double> pull = ValueNotifier(0);

  @override
  void dispose() {
    pull.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Widget?>(
    valueListenable: widget.note ?? const AlwaysStoppedAnimation(null),
    builder: (context, note, child) => CustomHeader(
      height: _refreshExtent,
      completeDuration: Duration(milliseconds: note == null ? 600 : 1400),
      onOffsetChange: (offset) => pull.value = offset,
      builder: (context, status) => SizedBox(
        height: _refreshExtent,
        child: Center(
          child: switch (status) {
            RefreshStatus.completed ||
            RefreshStatus.failed when note != null => note,
            _ => ValueListenableBuilder<double>(
              valueListenable: pull,
              builder: (context, offset, child) => HexagonalLoadingIndicator(
                state: switch (status) {
                  RefreshStatus.refreshing => HexagonState.loading,
                  RefreshStatus.canRefresh ||
                  RefreshStatus.completed ||
                  RefreshStatus.failed => HexagonState.armed,
                  _ => HexagonState.tracing,
                },
                progress: (offset / _refreshExtent).clamp(0, 1),
              ),
            ),
          },
        ),
      ),
    ),
  );
}

class RefreshNote extends StatelessWidget {
  const RefreshNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 14, color: dimTextColor(context)));
}
