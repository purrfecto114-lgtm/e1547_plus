import 'dart:io';

import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/fake_e621.dart';
import '../../_support/harness.dart';

void main() {
  setUpAll(initializeTestApp);

  group('checkCredentials', () {
    test('accepts credentials the host accepts', () async {
      final fake = await FakeE621.start();
      addTearDown(() => fake.stop());

      final result = await checkCredentials(
        host: fake.url,
        headers: {
          'authorization': const Credentials(
            username: 'user_34',
            password: 'key',
          ).basicAuth,
        },
      );

      expect(result, CredentialCheckResult.ok);
    });

    test('rejects credentials the host rejects', () async {
      final fake = await FakeE621.start();
      addTearDown(() => fake.stop());

      final result = await checkCredentials(
        host: fake.url,
        headers: {
          'authorization': const Credentials(
            username: 'user_34',
            password: 'wrong-key',
          ).basicAuth,
        },
      );

      expect(result, CredentialCheckResult.rejected);
    });

    test('guest requests need no credentials', () async {
      final fake = await FakeE621.start();
      addTearDown(() => fake.stop());

      final result = await checkCredentials(host: fake.url);

      expect(result, CredentialCheckResult.ok);
    });

    test('an unreachable host leaves credentials unverified', () async {
      // Bind and close a socket to find a port nothing listens on.
      final socket = await ServerSocket.bind('127.0.0.1', 0);
      final port = socket.port;
      await socket.close();

      final result = await checkCredentials(
        host: 'http://127.0.0.1:$port',
        headers: {'authorization': 'Basic dXNlcjprZXk='},
      );

      expect(result, CredentialCheckResult.unavailable);
    });
  });
}
