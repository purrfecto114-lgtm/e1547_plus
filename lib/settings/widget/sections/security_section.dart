import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:local_auth/local_auth.dart';

/// The tiles that guard the app against curious eyes.
class SettingsSecuritySection extends StatelessWidget {
  const SettingsSecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SectionHeader(
          indent: SectionHeader.listTileIndent,
          title: l10n.sectionSecurity,
        ),
        if (PlatformCapabilities.hasSecureDisplay)
          ValueListenableBuilder<bool>(
            valueListenable: settings.secureDisplay,
            builder: (context, value, child) => SwitchListTile(
              title: Text(l10n.settingsSecureDisplay),
              subtitle: Text(
                value ? l10n.secureDisplayOn : l10n.secureDisplayOff,
              ),
              secondary: const Icon(Icons.stop_screen_share_outlined),
              value: value,
              onChanged: (value) => settings.secureDisplay.value = value,
            ),
          ),
        if (Platform.isAndroid)
          ValueListenableBuilder<bool>(
            valueListenable: settings.incognitoKeyboard,
            builder: (context, value, child) => SwitchListTile(
              title: Text(l10n.settingsIncognitoKeyboard),
              subtitle: Text(value ? l10n.enabled : l10n.disabled),
              secondary: const Icon(Icons.keyboard),
              value: value,
              onChanged: (value) => settings.incognitoKeyboard.value = value,
            ),
          ),
        ValueListenableBuilder<String?>(
          valueListenable: settings.appPin,
          builder: (context, value, child) => SwitchListTile(
            title: Text(l10n.settingsPinLock),
            subtitle: Text(value != null ? l10n.pinEnabled : l10n.pinDisabled),
            secondary: const Icon(Icons.pin),
            value: value != null,
            onChanged: (value) async {
              if (value) {
                String? pin = await registerPin(context);
                if (pin != null) {
                  settings.appPin.value = pin;
                }
              } else {
                settings.appPin.value = null;
              }
            },
          ),
        ),
        SubFuture<bool>(
          create: () => LocalAuthentication().getAvailableBiometrics().then(
            (e) => e.isNotEmpty,
          ),
          builder: (context, snapshot) => ValueListenableBuilder<bool>(
            valueListenable: settings.biometricAuth,
            builder: (context, value, child) => SwitchListTile(
              title: Text(l10n.settingsBiometricLock),
              subtitle: Text(
                // Without enrolled or detectable biometrics the switch
                // stays off and the reason is spelled out, instead of
                // a dead toggle without explanation.
                snapshot.data == false
                    ? l10n.biometricsUnavailable
                    : value
                    ? l10n.biometricsEnabled
                    : l10n.biometricsDisabled,
              ),
              secondary: const Icon(Icons.fingerprint),
              value: value,
              onChanged: (snapshot.data ?? false)
                  ? (value) => settings.biometricAuth.value = value
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
