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
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(l10n.settingsTheme),
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: AppTheme.values
                          .map(
                            (theme) => ListTile(
                              title: Text(localizedThemeName(context, theme)),
                              trailing: Container(
                                height: 28,
                                width: 28,
                                decoration: theme.swatch.copyWith(
                                  border: Border.all(
                                    color: Theme.of(context).iconTheme.color!,
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (popDialog(context)) {
                                  settings.theme.value = theme;
                                }
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              );
            },
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
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(l10n.settingsLanguage),
                  children: [
                    ListTile(
                      title: Text(l10n.languageSystemDefault),
                      trailing: value == null ? const Icon(Icons.check) : null,
                      onTap: () {
                        if (popDialog(context)) {
                          settings.language.value = null;
                        }
                      },
                    ),
                    ...appLanguages.map(
                      (language) => ListTile(
                        title: Text(language.label),
                        trailing: value == language.value
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          if (popDialog(context)) {
                            settings.language.value = language.value;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ValueListenableBuilder<TileSize>(
          valueListenable: settings.tileSize,
          builder: (context, value, child) => ListTile(
            title: Text(l10n.thumbnailQuality),
            subtitle: Text(value.localizedTitle(context)),
            leading: const Icon(Icons.image_outlined),
            onTap: () => showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text(l10n.thumbnailQuality),
                children: [
                  ...TileSize.values.map(
                    (size) => ListTile(
                      title: Text(size.localizedTitle(context)),
                      trailing: value == size ? const Icon(Icons.check) : null,
                      onTap: () {
                        if (popDialog(context)) {
                          settings.tileSize.value = size;
                        }
                      },
                    ),
                  ),
                ],
              ),
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
