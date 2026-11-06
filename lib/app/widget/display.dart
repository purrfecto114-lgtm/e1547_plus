import 'dart:io';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:secure_app_switcher/secure_app_switcher.dart';

/// Hides the app's content whenever it leaves the foreground.
///
/// Android ROMs replace the switcher snapshot of a FLAG_SECURE window
/// with a generic system placeholder, so this draws its own dedicated
/// cover over the app instead: the switcher then shows the cover, and
/// the app decides what it looks like. iOS keeps the native blur the
/// secure_app_switcher package applies, which fits its conventions.
class SecureDisplay extends StatefulWidget {
  const SecureDisplay({super.key, required this.child});

  final Widget child;

  @override
  State<SecureDisplay> createState() => _SecureDisplayState();
}

class _SecureDisplayState extends State<SecureDisplay>
    with WidgetsBindingObserver {
  bool _covered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Everything but the foreground app hides content: the app switcher,
    // system dialogs and the home screen all fall under the same cover.
    if (_covered == (state == AppLifecycleState.resumed)) {
      setState(() => _covered = state != AppLifecycleState.resumed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubValueListener(
      initialize: true,
      listenable: context.watch<Settings>().secureDisplay,
      listener: (value) {
        // The native blur stays an ios feature; android draws the cover
        // below, which the switcher snapshot then captures.
        if (!Platform.isIOS) return;
        if (value) {
          SecureAppSwitcher.on();
        } else {
          SecureAppSwitcher.off();
        }
      },
      builder: (context, value) => Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (Platform.isAndroid)
            Positioned.fill(
              child: Visibility(
                visible: value && _covered,
                // The cover is kept alive offstage, so switching it on
                // paints within the same frame the lifecycle announces.
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: const _PrivacyCover(),
              ),
            ),
        ],
      ),
    );
  }
}

/// The dedicated screen the app switcher shows instead of the content.
class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondaryContainer,
              ),
              child: Icon(
                Icons.shield_outlined,
                size: 48,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).secureDisplayCover,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
