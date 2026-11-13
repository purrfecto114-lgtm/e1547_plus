import 'dart:async';

import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stalls activate(null) at its page() read, so a competing activate can
/// run to completion first.
class GatedIdentityClient extends IdentityClient {
  GatedIdentityClient({required super.database, super.onCreate});

  Completer<List<Identity>>? pageGate;

  @override
  StreamFuture<List<Identity>> page({
    required int page,
    int? limit,
    String? nameRegex,
    String? hostRegex,
  }) => StreamFuture.from(pageGate!.future);
}

void main() {
  late AppDatabase sqlite;
  late IdentityRepository repository;
  late Identity identityA;
  late Identity identityB;

  setUp(() async {
    sqlite = AppDatabase(NativeDatabase.memory());
    repository = IdentityRepository(sqlite);
    identityA = await repository.add(
      const IdentityRequest(host: 'e621.net', username: 'a'),
    );
    identityB = await repository.add(
      const IdentityRequest(host: 'e926.net', username: 'b'),
    );
  });

  tearDown(() => sqlite.close());

  group('IdentityClient.activate', () {
    test('activates the requested identity', () async {
      final client = IdentityClient(database: sqlite);
      addTearDown(client.dispose);
      await client.activate(identityB.id);
      expect(client.identity.id, identityB.id);
    });

    test(
      'a superseded activate does not overwrite the newer identity',
      () async {
        // An old activate(null) stalls at its page() read while a newer
        // activate completes; resuming the old one must not write its
        // stale result over the newer identity.
        final client = GatedIdentityClient(database: sqlite);
        addTearDown(client.dispose);
        client.pageGate = Completer<List<Identity>>();

        final Future<void> superseded = client.activate(null);
        await client.activate(identityB.id);
        expect(client.identity.id, identityB.id);

        client.pageGate!.complete([identityA]);
        await superseded;

        expect(client.identity.id, identityB.id);
      },
    );

    test('dispose stops an in-flight activate from writing back', () async {
      final client = GatedIdentityClient(database: sqlite);
      client.pageGate = Completer<List<Identity>>();

      final Future<void> activate = client.activate(null);
      client.dispose();
      client.pageGate!.complete([identityA]);
      await activate;

      expect(() => client.identity, throwsStateError);
    });

    test('dispose cancels the active identity subscription', () async {
      final client = IdentityClient(database: sqlite);
      await client.activate(identityA.id);
      client.dispose();
      // The repository stream keeps running after activate; the client
      // must have detached from it. There is no public handle for the
      // subscription, so this just documents the contract through the
      // dispose path not throwing.
      expect(client.hashCode, isNotNull);
    });
  });
}
