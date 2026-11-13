import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/harness.dart';

void main() {
  setUpAll(initializeTestApp);

  test('the media client carries no credentials', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final identity = await IdentityRepository(db).add(
      const IdentityRequest(
        host: 'e621.net',
        username: 'tester',
        headers: {
          'authorization': 'Basic dXNlcjprZXk=',
          'cookie': 'session=secret',
        },
      ),
    );

    final api = createDefaultDio(identity);
    final media = createMediaDio();

    // The account's client sends its credentials to its own host.
    final apiKeys = api.options.headers.keys.map((k) => k.toLowerCase());
    expect(apiKeys, containsAll(['authorization', 'cookie']));

    // The media client deliberately travels without them: media URLs
    // come from API responses and may point at any host, so the
    // account's secrets must never reach another origin through them.
    final mediaKeys = media.options.headers.keys.map((k) => k.toLowerCase());
    expect(mediaKeys, isNot(contains('authorization')));
    expect(mediaKeys, isNot(contains('cookie')));
    expect(mediaKeys, contains('user-agent'));

    // The account's client also has a base URL of its own host; the media
    // client has none, so absolute URLs stay absolute.
    expect(api.options.baseUrl, isNotEmpty);
    expect(media.options.baseUrl, isEmpty);
  });
}
