import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

/// The tiles that guard the app against curious eyes.
class SettingsSecuritySection extends StatelessWidget {
  const SettingsSecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    final l10n = AppLocalizations.of(context);
    return Column(
      // stretch keeps the section header pinned to the list edge instead
      // of letting the column center its narrower children.
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  // Stored salted, not plain text: the settings store
                  // must not hand out the unlock code itself.
                  settings.appPin.value = await hashPin(pin);
                }
              } else {
                settings.appPin.value = null;
                // A fresh registration starts without the old streak.
                settings.appPinFailures.value = 0;
                settings.appPinLockedUntil.value = 0;
                // Without the pin the biometric lock is a dead end: its
                // screen only offers retries, so a sensor that stops
                // working would lock the user out for good.
                settings.biometricAuth.value = false;
              }
            },
          ),
        ),
        SubFuture<BiometricAvailability>(
          create: biometricAvailability,
          builder: (context, snapshot) => ValueListenableBuilder<bool>(
            valueListenable: settings.biometricAuth,
            builder: (context, value, child) {
              final BiometricAvailability? availability = snapshot.data;
              final bool ready = availability == BiometricAvailability.ready;
              return SwitchListTile(
                title: Text(l10n.settingsBiometricLock),
                subtitle: Text(
                  // The three hardware states spell out why the switch
                  // may be dead: absent hardware, hardware without an
                  // enrolled print, or a usable biometric lock.
                  switch (availability) {
                    BiometricAvailability.ready =>
                      value ? l10n.biometricsEnabled : l10n.biometricsDisabled,
                    BiometricAvailability.unenrolled =>
                      l10n.biometricsNotEnrolled,
                    BiometricAvailability.none => l10n.biometricsUnavailable,
                    null =>
                      value ? l10n.biometricsEnabled : l10n.biometricsDisabled,
                  },
                ),
                secondary: const Icon(Icons.fingerprint),
                value: value,
                onChanged: ready
                    ? (value) {
                        if (value &&
                            context.read<Settings>().appPin.value == null) {
                          // Without a pin the biometric lock is a dead
                          // end: the screen below only offers retries,
                          // so a sensor that stops working locks the
                          // user out for good. A pin always leaves a
                          // way back in.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.biometricsRequiresPin)),
                          );
                          return;
                        }
                        settings.biometricAuth.value = value;
                      }
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
