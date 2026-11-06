import 'dart:async';
import 'dart:io';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

/// The tiles that shape how posts are loaded and interacted with.
class SettingsInteractionsSection extends StatelessWidget {
  const SettingsInteractionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SectionHeader(
          indent: SectionHeader.listTileIndent,
          title: l10n.sectionInteractions,
        ),
        if (!Platform.isIOS)
          ValueListenableBuilder<String?>(
            valueListenable: settings.downloadPath,
            builder: (context, value, child) => ListTile(
              title: Text(l10n.settingsDownloadLocation),
              subtitle: value != null
                  ? Text(Uri.decodeComponent(Uri.parse(value).path))
                  : null,
              leading: const Icon(Icons.folder),
              onTap: () async {
                String? result = await FileDownloader.pickDirectory(
                  initial: value,
                );
                if (result != null) {
                  unawaited(FileDownloader.forgetDirectory(value));
                  settings.downloadPath.value = result;
                }
              },
            ),
          ),
        ValueListenableBuilder<bool>(
          valueListenable: settings.upvoteFavs,
          builder: (context, value, child) => SwitchListTile(
            title: Text(l10n.settingsUpvoteFavorites),
            subtitle: Text(
              value ? l10n.upvoteFavoritesOn : l10n.upvoteFavoritesOff,
            ),
            secondary: const Icon(Icons.arrow_upward),
            value: value,
            onChanged: (value) => settings.upvoteFavs.value = value,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: settings.muteVideos,
          builder: (context, value, child) => SwitchListTile(
            title: Text(l10n.settingsVideoVolume),
            subtitle: Text(value ? l10n.videoMuted : l10n.videoWithSound),
            secondary: Icon(value ? Icons.volume_off : Icons.volume_up),
            value: value,
            onChanged: (value) => settings.muteVideos.value = value,
          ),
        ),
        ValueListenableBuilder<VideoResolution>(
          valueListenable: settings.videoResolution,
          builder: (context, value, child) => ListTile(
            title: Text(l10n.videoQuality),
            subtitle: Text(value.localizedTitle(context)),
            leading: const Icon(Icons.video_settings),
            onTap: () => showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text(l10n.videoQuality),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      l10n.videoResNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  ...VideoResolution.values.map(
                    (resolution) => ListTile(
                      title: Text(resolution.localizedTitle(context)),
                      trailing: value == resolution
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        if (popDialog(context)) {
                          settings.videoResolution.value = resolution;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const AutoLoadVideosTile(),
      ],
    );
  }
}
