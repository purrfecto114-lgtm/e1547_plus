import 'package:e1547/client/client.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

class DenyListPage extends StatefulWidget {
  const DenyListPage({super.key});

  @override
  State<DenyListPage> createState() => _DenyListPageState();
}

class _DenyListPageState extends State<DenyListPage> {
  String filter = '';

  @override
  Widget build(BuildContext context) {
    return PromptActions(
      child: LimitedWidthLayout(
        child: Consumer<Client>(
          builder: (context, client, child) => ValueListenableBuilder(
            valueListenable: client.traits,
            builder: (context, traits, child) {
              List<String> denylist = traits.denylist.toList();
              // The filter narrows what the list shows, not what the
              // actions touch: every tile keeps its index in the full
              // denylist, so edit and delete operate on the entry the
              // user sees no matter what the filter is hiding.
              final String query = filter.trim().toLowerCase();
              final List<(int, String)> visible = [
                for (int i = 0; i < denylist.length; i++)
                  if (query.isEmpty ||
                      denylist[i].toLowerCase().contains(query))
                    (i, denylist[i]),
              ];
              final insets = LimitedWidthLayout.of(context).padding;
              return AdaptiveScaffold(
                appBar: DefaultAppBar(
                  title: Text(AppLocalizations.of(context).settingsBlacklist),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DenyListEditor(),
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: PromptFab(
                  builder: (context) => buildEditTextField(
                    context,
                    title: AppLocalizations.of(context).blacklistAddTag,
                    submit: (value) async {
                      // Resolved up front, the context must not cross async
                      // gaps.
                      final l10n = AppLocalizations.of(context);
                      value = value.trim();
                      if (value.isEmpty) return;
                      try {
                        await client.accounts.push(
                          traits: traits.copyWith(
                            denylist: denylist..add(value),
                          ),
                        );
                      } on ClientException {
                        throw ActionControllerException(
                          message: l10n.blacklistUpdateFailed,
                        );
                      }
                    },
                  ),
                  icon: const Icon(Icons.add),
                ),
                body: denylist.isEmpty
                    ? PullToRefresh(
                        onRefresh: () async {
                          try {
                            await client.accounts.pull();
                          } on ClientException {
                            // the pull failed; the next refresh retries.
                          }
                          return null;
                        },
                        child: Center(
                          child: IconMessage(
                            icon: const Icon(Icons.check),
                            title: Text(
                              AppLocalizations.of(context).blacklistEmpty,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: insets.add(
                              const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            ),
                            child: TextField(
                              onChanged: (value) =>
                                  setState(() => filter = value),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: filter.isEmpty
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () =>
                                            setState(() => filter = ''),
                                      ),
                                border: const OutlineInputBorder(),
                                labelText: AppLocalizations.of(
                                  context,
                                ).blacklistFilterHint,
                              ),
                              // The field survives the rebuilds the
                              // filter triggers; it owns its text.
                            ),
                          ),
                          Expanded(
                            child: visible.isEmpty
                                ? Center(
                                    child: IconMessage(
                                      icon: const Icon(Icons.search_off),
                                      title: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).blacklistNoMatch,
                                      ),
                                    ),
                                  )
                                : PullToRefresh(
                                    onRefresh: () async {
                                      try {
                                        await client.accounts.pull();
                                      } on ClientException {
                                        // the pull failed; retry on the next refresh.
                                      }
                                      return null;
                                    },
                                    child: ListView.builder(
                                      primary: true,
                                      padding: defaultActionListPadding.add(
                                        insets,
                                      ),
                                      itemCount: visible.length,
                                      itemBuilder: (context, index) => DenylistTile(
                                        tag: visible[index].$2,
                                        onEdit: () {
                                          String tag = visible[index].$2;
                                          PromptActions.of(context).show(
                                            context,
                                            buildEditTextField(
                                              context,
                                              value: tag,
                                              title: AppLocalizations.of(
                                                context,
                                              ).blacklistEditTag,
                                              submit: (value) async {
                                                // Resolved up front, the
                                                // context must not cross
                                                // async gaps.
                                                final l10n =
                                                    AppLocalizations.of(
                                                      context,
                                                    );
                                                value = value.trim();
                                                try {
                                                  if (value.isEmpty) {
                                                    await client.accounts.push(
                                                      traits: traits.copyWith(
                                                        denylist: List.of(
                                                          denylist,
                                                        )..remove(tag),
                                                      ),
                                                    );
                                                  } else {
                                                    await client.accounts.push(
                                                      traits: traits.copyWith(
                                                        denylist:
                                                            List.of(denylist)
                                                              ..[denylist
                                                                      .indexOf(
                                                                        tag,
                                                                      )] =
                                                                  value,
                                                      ),
                                                    );
                                                  }
                                                } on ClientException {
                                                  throw ActionControllerException(
                                                    message: l10n
                                                        .blacklistUpdateFailed,
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                        onDelete: () {
                                          final l10n = AppLocalizations.of(
                                            context,
                                          );
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          final tag = visible[index].$2;
                                          final position = visible[index].$1;
                                          final remaining = List.of(denylist)
                                            ..removeAt(position);
                                          client.accounts
                                              .push(
                                                traits: traits.copyWith(
                                                  denylist: remaining,
                                                ),
                                              )
                                              .then((_) {
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.denylistEntryDeleted,
                                                    ),
                                                    action: SnackBarAction(
                                                      label: l10n.actionUndo,
                                                      onPressed: () {
                                                        // Read the current
                                                        // traits: other
                                                        // deletions since
                                                        // this snackbar was
                                                        // shown must not be
                                                        // rolled back.
                                                        final current =
                                                            client.traits.value;
                                                        if (current.denylist
                                                            .contains(tag)) {
                                                          return;
                                                        }
                                                        client.accounts.push(
                                                          traits: current.copyWith(
                                                            denylist:
                                                                List.of(
                                                                  current
                                                                      .denylist,
                                                                )..insert(
                                                                  position.clamp(
                                                                    0,
                                                                    current
                                                                        .denylist
                                                                        .length,
                                                                  ),
                                                                  tag,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildEditTextField(
    BuildContext context, {
    required String title,
    required SubmitString submit,
    String? value,
  }) => Material(
    child: ControlledTextWrapper(
      textController: TextEditingController(text: value),
      submit: submit,
      builder: (context, controller, submit) => TagInput(
        controller: controller,
        decoration: const InputDecoration(suffix: PromptTextFieldSuffix()),
        textInputAction: TextInputAction.done,
        direction: VerticalDirection.up,
        labelText: title,
        submit: submit,
        readOnly: PromptActions.of(context).isLoading,
      ),
    ),
  );
}
