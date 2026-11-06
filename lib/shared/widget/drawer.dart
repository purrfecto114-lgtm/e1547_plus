import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class ContextDrawer extends StatelessWidget {
  const ContextDrawer({super.key, this.title, required this.children});

  final Widget? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListTileTheme(
        style: ListTileStyle.list,
        child: SafeArea(
          child: ListView(
            primary: false,
            padding: EdgeInsets.only(bottom: defaultActionListPadding.bottom),
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: title!,
                  ),
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class ContextDrawerButton extends StatelessWidget {
  const ContextDrawerButton({super.key, this.icon, this.tooltip, this.count});

  final IconData? icon;
  final String? tooltip;

  /// A count of noteworthy content behind the drawer, e.g. blacklisted
  /// posts on the current page.
  ///
  /// While above zero, the button lights up in the primary color and
  /// carries a dot badge, hinting that the drawer holds something to
  /// look at even when its contents stay unchanged.
  final int? count;

  @override
  Widget build(BuildContext context) {
    if (!Scaffold.of(context).hasEndDrawer) return const SizedBox();
    bool active = (count ?? 0) > 0;
    return IconButton(
      tooltip: tooltip ?? AppLocalizations.of(context).filterTooltip,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon ?? Icons.tune,
            color: active ? Theme.of(context).colorScheme.primary : null,
          ),
          if (active)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                key: const Key('ContextDrawerButton/Badge'),
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.error,
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: () => Scaffold.of(context).openEndDrawer(),
    );
  }
}
