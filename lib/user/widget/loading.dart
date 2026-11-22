import 'package:e1547/client/client.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class UserLoadingPage extends StatelessWidget {
  const UserLoadingPage(int this.id, {super.key}) : name = null;

  const UserLoadingPage.name(String this.name, {super.key}) : id = null;

  final int? id;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final users = context.watch<Client>().users;
    final id = this.id;
    final l10n = AppLocalizations.of(context);
    final user = id != null
        ? users.useGet(id: id)
        : users.useGetByName(name: name!);
    return QueryBuilder(
      query: user,
      builder: (context, state) => LoadingPage(
        isLoading: state.isLoading || state.isInitial,
        isError: state.isError,
        isEmpty: state.data == null,
        loadingBuilder: (context, child) => Scaffold(
          appBar: AppBar(
            leading: const CloseButton(),
            title: Text(l10n.userTitle(id != null ? '#$id' : name!)),
          ),
          body: child(context),
        ),
        skeleton: (context) => UserPage(
          user: const UserGhost(),
          summary: id == null ? null : users.partialUserCache.get(id),
        ),
        onError: Text(l10n.failedToLoadUser),
        onEmpty: Text(l10n.userNotFound),
        onRetry: () => user.refetch(),
        child: (context) => UserPage(user: state.data!),
      ),
    );
  }
}
