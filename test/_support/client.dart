import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';

import 'fake_e621.dart';

Dio dioFor(FakeE621 fake, {Credentials? credentials}) => createDefaultDio(
  Identity(
    id: 1,
    host: fake.url,
    username: credentials?.username,
    headers: credentials == null
        ? null
        : {'authorization': credentials.basicAuth},
  ),
);

/// Tunes a client's dio for the fake clock of a widget test.
///
/// The fake clock would otherwise leave dio's timeout timers pending on
/// requests that are still in flight when a test ends. Connections need
/// no tuning of their own: the fake server closes every response, so no
/// keepalive connection is ever pooled.
void tuneTestClientDio(Client client) {
  client.dio.options.connectTimeout = null;
  client.dio.options.receiveTimeout = null;
}
