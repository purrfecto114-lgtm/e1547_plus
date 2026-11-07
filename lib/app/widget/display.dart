import 'dart:io';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:secure_app_switcher/secure_app_switcher.dart';

/// The native android cover armed through [SecureDisplay].
const MethodChannel _secureDisplayChannel = MethodChannel(
  'e1547/secure_display',
);

/// Keeps the app switcher from showing the app's content.
///
/// On android the switcher screenshot of a plain window shows whatever
/// the app happens to render, and the system placeholder for secured
/// windows is a generic warning tile. Instead, the native side draws
/// its own dedicated cover the moment the user leaves the app: the
/// switcher card then shows a themed shield, and the content never
/// leaves the foreground. iOS keeps the native blur the
/// secure_app_switcher package applies, which fits its conventions.
class SecureDisplay extends StatelessWidget {
  const SecureDisplay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SubValueListener(
      initialize: true,
      listenable: context.watch<Settings>().secureDisplay,
      listener: (value) {
        if (Platform.isIOS) {
          if (value) {
            SecureAppSwitcher.on();
          } else {
            SecureAppSwitcher.off();
          }
          return;
        }
        if (!Platform.isAndroid) return;
        final scheme = Theme.of(context).colorScheme;
        _secureDisplayChannel
            .invokeMethod('arm', {
              'enabled': value,
              'background': scheme.surface.toARGB32(),
              'badge': scheme.secondaryContainer.toARGB32(),
              'onBadge': scheme.onSecondaryContainer.toARGB32(),
              'foreground': scheme.onSurfaceVariant.toARGB32(),
              'text': AppLocalizations.of(context).secureDisplayCover,
            })
            .catchError((_) => null);
      },
      builder: (context, value) => child,
    );
  }
}
