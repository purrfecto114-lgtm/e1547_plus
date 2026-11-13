import 'dart:async';

import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase sqlite;
  late IdentityRepository identities;
  late TraitsRepository traits;
  late Identity identityA;
  late Identity identityB;

  setUp(() async {
    sqlite = AppDatabase(NativeDatabase.memory());
    identities = IdentityRepository(sqlite);
    traits = TraitsRepository(sqlite);
    identityA = await identities.add(
      const IdentityRequest(host: 'e621.net', username: 'a'),
    );
    identityB = await identities.add(
      const IdentityRequest(host: 'e926.net', username: 'b'),
    );
    // A has traits, B does not, so activating B goes through onCreate.
    await traits.add(TraitsRequest(identity: identityA.id));
  });

  tearDown(() => sqlite.close());

  group('TraitsClient.activate', () {
    test('activates the stored traits', () async {
      final client = TraitsClient(database: sqlite);
      addTearDown(client.dispose);
      await client.activate(identityA.id);
      expect(client.traits.id, identityA.id);
    });

    test('a superseded activate does not overwrite the newer traits', () async {
      // The old activate stalls inside onCreate while a newer activate
      // completes; resuming the old one must not write its result back.
      final Completer<TraitsRequest?> gate = Completer<TraitsRequest?>();
      final client = TraitsClient(
        database: sqlite,
        onCreate: (_) => gate.future,
      );
      addTearDown(client.dispose);

      final Future<void> superseded = client.activate(identityB.id);
      await client.activate(identityA.id);
      expect(client.traits.id, identityA.id);

      gate.complete(TraitsRequest(identity: identityB.id));
      await superseded;

      expect(client.traits.id, identityA.id);
    });

    test('dispose stops an in-flight activate from writing back', () async {
      final Completer<TraitsRequest?> gate = Completer<TraitsRequest?>();
      final client = TraitsClient(
        database: sqlite,
        onCreate: (_) => gate.future,
      );

      final Future<void> activate = client.activate(identityB.id);
      client.dispose();
      gate.complete(TraitsRequest(identity: identityB.id));
      await activate;

      expect(() => client.traits, throwsStateError);
    });
  });
}
