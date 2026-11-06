import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/settings/widget/sections/widget.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

/// The app's main settings page.
///
/// Each section is its own widget under settings/widget/sections, so
/// this page only lays out their order and the dividers between them.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) => Scaffold(
        appBar: DefaultAppBar(
          title: Text(AppLocalizations.of(context).settingsTitle),
        ),
        body: LimitedWidthLayout.builder(
          builder: (context) => ListView(
            primary: true,
            padding: defaultActionListPadding.add(
              LimitedWidthLayout.of(context).padding,
            ),
            children: [
              SectionHeader(
                indent: SectionHeader.listTileIndent,
                title: AppLocalizations.of(context).sectionAccount,
              ),
              Consumer<IdentityClient>(
                builder: (context, client, child) => IdentityTile(
                  identity: client.identity,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IdentitiesPage(),
                    ),
                  ),
                  trailing: const Icon(Icons.swap_horiz),
                ),
              ),
              const Divider(),
              const SettingsUserSection(),
              const Divider(),
              const SettingsAppearanceSection(),
              const Divider(),
              const SettingsInteractionsSection(),
              const Divider(),
              const SettingsSecuritySection(),
              const Divider(),
              const SettingsDevelopmentSection(),
            ],
          ),
        ),
      ),
    );
  }
}
