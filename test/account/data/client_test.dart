import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

import '../../_support/client.dart';
import '../../_support/fake_e621.dart';
import '../../_support/harness.dart';

void main() {
  late FakeE621 fake;
  late Client client;
  late ValueNotifier<Traits> traits;
  late AppDatabase sqlite;

  setUpAll(() async {
    await initializeTestApp();
    sqlite = AppDatabase(NativeDatabase.memory());
  });

  tearDownAll(() => sqlite.close());

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fake = await FakeE621.start();
    traits = ValueNotifier(
      const Traits(
        id: 1,
        userId: null,
        denylist: ['spoiler'],
        homeTags: '',
        avatar: null,
        perPage: null,
      ),
    );
    client = Client(
      identity: Identity(
        id: 1,
        host: fake.url,
        username: 'user_34',
        headers: null,
      ),
      traits: traits,
      storage: AppStorage(
        preferences: await SharedPreferences.getInstance(),
        temporaryFiles: '.',
        queryCache: CachedQuery.asNewInstance(),
        sqlite: sqlite,
      ),
    );
    tuneTestClientDio(client);
  });

  tearDown(() async {
    traits.dispose();
    await fake.stop();
  });

  group('AccountClient denylist', () {
    test('keeps the local denylist when the payload omits the field', () async {
      // Since the november 2026 server update the user payload carries
      // no blacklisted_tags at all; an absent field must not read as an
      // empty blacklist, or every pull would wipe the local denylist.
      await client.accounts.get();

      expect(traits.value.denylist, ['spoiler']);
    });

    test('applies the server denylist when the payload has one', () async {
      fake.state.user['blacklisted_tags'] = 'vore\nscat';

      await client.accounts.get();

      expect(traits.value.denylist, ['vore', 'scat']);
    });

    test('keeps the local edit when the sync is refused', () async {
      // The fake serves no PUT route for users, so the sync answers
      // with a client error: the edit still stands locally.
      final edited = traits.value.copyWith(denylist: ['gore']);

      await client.accounts.push(traits: edited);

      expect(traits.value.denylist, ['gore']);
    });
  });
}
