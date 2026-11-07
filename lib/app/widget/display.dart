import 'package:e1547/app/app.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:secure_app_switcher/secure_app_switcher.dart';

/// Keeps the app's content out of the app switcher.
///
/// On android this arms FLAG_SECURE, a plain window flag that every
/// android release supports and that needs no permission: the system
/// then refuses to capture the window, so screenshots and the switcher
/// snapshot show the platform's secured placeholder instead of whatever
/// the app happens to render. iOS keeps the native blur the
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
        if (!PlatformCapabilities.hasSecureDisplay) return;
        if (value) {
          SecureAppSwitcher.on();
        } else {
          SecureAppSwitcher.off();
        }
      },
      builder: (context, value) => child,
    );
  }
}
