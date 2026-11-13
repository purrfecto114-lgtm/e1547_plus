import 'dart:async';

import 'package:e1547/account/account.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class AccountConnector extends StatelessWidget {
  const AccountConnector({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    return AvailabilityCheck(
      // Re-checking with every client switch needs a fresh state;
      // without the key, the old state would keep its checked client
      // and never re-run its check.
      key: ValueKey(client),
      navigatorKey: navigatorKey,
      child: SubEffect(
        effect: () {
          // A failed pull leaves the traits as they are until the
          // next refresh; it must not surface as an unhandled
          // exception at startup.
          unawaited(client.accounts.pull().catchError((_) {}));
          return null;
        },
        keys: [client],
        child: SubValueListener(
          listenable: client.traits,
          listener: (traits) => client.accounts.push(traits: traits),
          builder: (context, _) => child,
        ),
      ),
    );
  }
}
