import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

/// The account related tiles of the settings page.
class SettingsUserSection extends StatelessWidget {
  const SettingsUserSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // stretch keeps the section header pinned to the list edge instead
      // of letting the column center its narrower children.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          indent: SectionHeader.listTileIndent,
          title: AppLocalizations.of(context).sectionUser,
        ),
        Consumer<Client>(
          builder: (context, client, child) => ValueListenableBuilder(
            valueListenable: client.traits,
            builder: (context, traits, child) => ListTile(
              title: Text(AppLocalizations.of(context).settingsBlacklist),
              leading: const Icon(Icons.block),
              subtitle: traits.denylist.isNotEmpty
                  ? Text(
                      AppLocalizations.of(context).tagsBlocked(
                        traits.denylist
                            .join(' ')
                            .split(' ')
                            .trim()
                            .where((e) => e[0] != '-')
                            .length,
                      ),
                    )
                  : null,
              onTap: () => Navigator.pushNamed(context, '/blacklist'),
            ),
          ),
        ),
        Consumer<Client>(
          builder: (context, client, child) => SubStream<int>(
            create: () => client.follows.count().streamed,
            keys: [client],
            builder: (context, snapshot) => ListTile(
              title: Text(AppLocalizations.of(context).settingsFollows),
              subtitle: snapshot.data != null && snapshot.data != 0
                  ? Text(
                      AppLocalizations.of(
                        context,
                      ).searchesFollowed(snapshot.data!),
                    )
                  : null,
              leading: const Icon(Icons.person_add),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FollowEditor()),
              ),
            ),
          ),
        ),
        Consumer<Client>(
          builder: (context, client, child) => SubStream<int>(
            create: () => client.histories.count().streamed,
            keys: [client],
            builder: (context, countSnapshot) {
              int? count = countSnapshot.data;
              return ValueListenableBuilder(
                valueListenable: client.traits,
                builder: (context, traits, child) {
                  bool enabled = traits.writeHistory ?? true;
                  return DividerListTile(
                    title: Text(AppLocalizations.of(context).settingsHistory),
                    subtitle: enabled && count != null
                        ? Text(AppLocalizations.of(context).pagesVisited(count))
                        : null,
                    leading: const Icon(Icons.history),
                    onTap: () => Navigator.pushNamed(context, '/history'),
                    onTapSeparated: () => client.traits.value = client
                        .traits
                        .value
                        .copyWith(writeHistory: !enabled),
                    separated: Switch(
                      value: enabled,
                      onChanged: (value) => client.traits.value = client
                          .traits
                          .value
                          .copyWith(writeHistory: value),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
