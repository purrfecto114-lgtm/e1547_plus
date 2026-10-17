import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

/// Lets the user toggle whether browsing silently downloads videos.
///
/// Turning the setting on asks for confirmation first: it changes how much
/// data the app uses while browsing. Turning it off is always safe.
///
/// The change reaches players without an app restart: covered routes
/// re-activate once the settings page pops, and [VideoService.getVideo]
/// backfills deferred players then.
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
