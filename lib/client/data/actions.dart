import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class NoUserLoginException implements Exception {
  NoUserLoginException();

  @override
  String toString() => 'NoUserLoginException';
}

Future<void> guardWithLogin({
  required BuildContext context,
  required VoidCallback callback,
  String? error,
}) async {
  if (context.read<Client>().hasLogin) {
    callback();
  } else {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(error ?? l10n.loginRequired),
        action: SnackBarAction(
          label: l10n.actionChooseIdentity,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const IdentitiesPage()),
          ),
        ),
      ),
    );
  }
}
