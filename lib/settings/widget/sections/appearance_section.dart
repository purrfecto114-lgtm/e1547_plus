import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

/// The look and feel tiles of the settings page.
class SettingsAppearanceSection extends StatelessWidget {
  const SettingsAppearanceSection({super.key});

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
          title: l10n.sectionAppearance,
        ),
        ValueListenableBuilder<AppTheme>(
          valueListenable: settings.theme,
          builder: (context, value, child) => ListTile(
            title: Text(l10n.settingsTheme),
            subtitle: Text(localizedThemeName(context, value)),
            leading: const Icon(Icons.brightness_6),
            onTap: () => showPickerDialog<AppTheme>(
              context: context,
              title: l10n.settingsTheme,
              // the swatches carry the state, so no check mark is drawn
              options: [
                for (final theme in AppTheme.values)
                  PickerOption(
                    value: theme,
                    label: localizedThemeName(context, theme),
                    trailing: Container(
                      height: 28,
                      width: 28,
                      decoration: theme.swatch.copyWith(
                        border: Border.all(
                          color: Theme.of(context).iconTheme.color!,
                        ),
                      ),
                    ),
                  ),
              ],
              onSelected: (theme) => settings.theme.value = theme,
            ),
          ),
        ),
        ValueListenableBuilder<String?>(
          valueListenable: settings.language,
          builder: (context, value, child) => ListTile(
            title: Text(l10n.settingsLanguage),
            subtitle: Text(
              value == null
                  ? l10n.languageSystemDefault
                  : appLanguages
                            .firstWhereOrNull((e) => e.value == value)
                            ?.label ??
                        value,
            ),
            leading: const Icon(Icons.translate),
            onTap: () => showPickerDialog<String?>(
              context: context,
              title: l10n.settingsLanguage,
              selected: value,
              options: [
                PickerOption(value: null, label: l10n.languageSystemDefault),
                for (final language in appLanguages)
                  PickerOption(value: language.value, label: language.label),
              ],
              // null is a legitimate pick here (system default), so the
              // assignment rides onSelected instead of the dismissible
              // future, where it would be indistinguishable from backing
              // out of the dialog.
              onSelected: (language) => settings.language.value = language,
            ),
          ),
        ),
        ValueListenableBuilder<TileSize>(
          valueListenable: settings.tileSize,
          builder: (context, value, child) => ListTile(
            title: Text(l10n.thumbnailQuality),
            subtitle: Text(value.localizedTitle(context)),
            leading: const Icon(Icons.image_outlined),
            onTap: () => showPickerDialog<TileSize>(
              context: context,
              title: l10n.thumbnailQuality,
              selected: value,
              options: [
                for (final size in TileSize.values)
                  PickerOption(
                    value: size,
                    label: size.localizedTitle(context),
                  ),
              ],
              onSelected: (size) => settings.tileSize.value = size,
            ),
          ),
        ),
        ValueListenableBuilder<VideoResolution>(
          valueListenable: settings.videoResolution,
          builder: (context, value, child) => ListTile(
            title: Text(l10n.videoQuality),
            subtitle: Text(value.localizedTitle(context)),
            leading: const Icon(Icons.video_settings),
            onTap: () => showPickerDialog<VideoResolution>(
              context: context,
              title: l10n.videoQuality,
              note: l10n.videoResNote,
              selected: value,
              options: [
                for (final resolution in VideoResolution.values)
                  PickerOption(
                    value: resolution,
                    label: resolution.localizedTitle(context),
                  ),
              ],
              onSelected: (resolution) =>
                  settings.videoResolution.value = resolution,
            ),
          ),
        ),
        ValueListenableBuilder<GridQuilt>(
          valueListenable: settings.quilt,
          builder: (context, value, child) => GridSettingsTile(
            state: value,
            onChange: (value) => settings.quilt.value = value,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: settings.showPostInfo,
          builder: (context, value, child) => SwitchListTile(
            title: Text(l10n.settingsPostInfo),
            subtitle: Text(value ? l10n.postInfoShown : l10n.postInfoHidden),
            secondary: const Icon(Icons.subtitles),
            value: value,
            onChanged: (value) => settings.showPostInfo.value = value,
          ),
        ),
        ValueListenableBuilder<Handedness>(
          valueListenable: settings.handedness,
          builder: (context, value, child) => HandednessSettingsTile(
            state: value,
            onChange: (value) => settings.handedness.value = value,
          ),
        ),
      ],
    );
  }
}
