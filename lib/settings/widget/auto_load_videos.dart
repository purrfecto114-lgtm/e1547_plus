import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

/// Lets the user toggle whether opening a video also prefetches the
/// videos next to it.
///
/// Turning the setting on asks for confirmation first: it downloads the
/// neighbouring videos in full ahead of time, which changes how much
/// data the app uses. Turning it off is always safe — videos then load
/// only when their own route opens.
class AutoLoadVideosTile extends StatelessWidget {
  const AutoLoadVideosTile({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    return ValueListenableBuilder<bool>(
      valueListenable: settings.autoLoadVideos,
      builder: (context, value, child) => SwitchListTile(
        title: Text(AppLocalizations.of(context).settingsAutoLoadVideos),
        subtitle: Text(
          value
              ? AppLocalizations.of(context).autoLoadVideosOn
              : AppLocalizations.of(context).autoLoadVideosOff,
        ),
        secondary: const Icon(Icons.video_library),
        value: value,
        onChanged: (value) {
          if (!value) {
            settings.autoLoadVideos.value = false;
            return;
          }
          _confirmEnable(context, settings);
        },
      ),
    );
  }

  Future<void> _confirmEnable(BuildContext context, Settings settings) async {
    bool result =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).autoLoadVideosDialogTitle),
            content: Text(
              AppLocalizations.of(context).autoLoadVideosDialogBody,
            ),
            actions: [
              TextButton(
                onPressed: () => popDialog(context, false),
                child: Text(AppLocalizations.of(context).actionCancel),
              ),
              TextButton(
                onPressed: () => popDialog(context, true),
                child: Text(AppLocalizations.of(context).actionOk),
              ),
            ],
          ),
        ) ??
        false;
    if (result) {
      settings.autoLoadVideos.value = true;
    }
  }
}
