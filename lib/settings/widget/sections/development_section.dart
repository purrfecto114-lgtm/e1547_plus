import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

/// The tiles for developers and the curious.
///
/// Only the developer mode switch hides itself until it is unlocked from
/// the about page; the rest of the section stays reachable.
class SettingsDevelopmentSection extends StatelessWidget {
  const SettingsDevelopmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SectionHeader(
          indent: SectionHeader.listTileIndent,
          title: l10n.sectionDevelopment,
        ),
        ValueListenableBuilder<bool>(
          valueListenable: settings.showDev,
          builder: (context, value, child) {
            if (!value) return const SizedBox();
            return SwitchListTile(
              title: Text(l10n.settingsDeveloperMode),
              subtitle: Text(
                value ? l10n.devOptionsShown : l10n.devOptionsHidden,
              ),
              secondary: const Icon(Icons.bug_report),
              value: value,
              onChanged: (value) => settings.showDev.value = value,
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: settings.updaterBeta,
          builder: (context, value, child) => SwitchListTile(
            title: Text(l10n.settingsUpdaterBeta),
            subtitle: Text(value ? l10n.updaterBetaOn : l10n.updaterBetaOff),
            secondary: const Icon(Icons.update),
            value: value,
            onChanged: (value) => settings.updaterBeta.value = value,
          ),
        ),
        if (context.watch<Logs?>() != null) ...[
          Consumer<LogErrors>(
            builder: (context, errors, child) => ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: Text(l10n.logsTitle),
              subtitle: errors.isEmpty
                  ? null
                  : Text(l10n.errorsLogged(errors.length)),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const LogsPage())),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: Text(l10n.settingsDatabase),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DatabaseManagementPage(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
