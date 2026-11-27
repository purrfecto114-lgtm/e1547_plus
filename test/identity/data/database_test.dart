import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/task/task.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter_test/flutter_test.dart';

/// Decodes file bytes 1:1 so byte substrings become string substrings.
String asBytesString(List<int> bytes) => latin1.decode(bytes);

void main() {
  late AppDatabase sqlite;
  late IdentityRepository repository;

  Future<void> addIdentity(
    String host,
    String? username,
    Map<String, String>? headers,
  ) => repository.add(
    IdentityRequest(host: host, username: username, headers: headers),
  );

  setUp(() async {
    sqlite = AppDatabase(NativeDatabase.memory());
    repository = IdentityRepository(sqlite);
  });

  tearDown(() => sqlite.close());

  group('IdentityRepository.removeCredentials', () {
    test('strips secret headers and keeps the rest', () async {
      await addIdentity('e621.net', 'tester', {
        'authorization': 'Basic secret',
        'cookie': 'cf_clearance=dead',
        'x-api-key': 'hunter2',
        'user-agent': 'e1547/1.0',
      });

      final changed = await repository.removeCredentials();

      expect(changed, 1);
      final identity = (await repository.all()).single;
      expect(identity.headers, {'user-agent': 'e1547/1.0'});
      // The username goes with the credentials: keeping it would show
      // a logged-in account whose every write the server bounces.
      expect(identity.username, isNull);
    });

    test('writes an empty map instead of null', () async {
      await addIdentity('e621.net', 'tester', {
        'authorization': 'Basic secret',
      });

      await repository.removeCredentials();

      final identity = (await repository.all()).single;
      expect(identity.headers, isNotNull);
      expect(identity.headers, isEmpty);
    });

    test('counts only rows that change', () async {
      await addIdentity('e621.net', 'tester', {'authorization': 'Basic a'});
      await addIdentity('e621.net', null, null);
      // Exportable headers alone do not make the row exportable: its
      // username is a credential too, so clearing it counts as a change.
      await addIdentity('e926.net', 'other', {'user-agent': 'x'});

      final changed = await repository.removeCredentials();

      expect(changed, 2);
      final identities = await repository.all();
      expect(
        identities.where((e) => e.username != null),
        isEmpty,
      );
    });

    test(
      "moves an account's data to the anonymous sibling instead of failing",
      () async {
        await addIdentity('e621.net', 'tester', {'authorization': 'Basic a'});
        await addIdentity('e621.net', null, null);
        final seeded = await repository.all();
        final credential = seeded.firstWhere((e) => e.username != null);
        final anonymous = seeded.firstWhere((e) => e.username == null);

        // A real backup hangs the account's data off the credential row:
        // a follow, a history entry, a download task and the traits.
        await FollowRepository(
          database: sqlite,
        ).add(const FollowRequest(tags: 'canine'), credential.id);
        await HistoryRepository(database: sqlite).add(
          HistoryRequest(
            visitedAt: DateTime(2026),
            link: 'https://e621.net/posts?tags=canine',
            category: HistoryCategory.searches,
            type: HistoryType.posts,
          ),
          credential.id,
        );
        await TaskRepository(database: sqlite).add(
          const TaskRequest(action: TaskAction.download, postId: 42),
          credential.id,
        );
        await sqlite.customStatement(
          'INSERT INTO traits_table (id, denylist, home_tags) '
          "VALUES (${credential.id}, '[\"young\"]', '')",
        );

        final changed = await repository.removeCredentials();

        expect(changed, 1);
        final identities = await repository.all();
        expect(identities.map((e) => e.id), [
          anonymous.id,
        ], reason: 'the credential row is gone, the anonymous one remains');
        // The account's data is reachable through the anonymous row.
        final follows = await FollowRepository(
          database: sqlite,
        ).all(identity: anonymous.id);
        expect(follows.single.tags, 'canine');
        final histories = await HistoryRepository(
          database: sqlite,
        ).page(identity: anonymous.id);
        expect(histories.single.link, 'https://e621.net/posts?tags=canine');
        final tasks = await TaskRepository(
          database: sqlite,
        ).all(identity: anonymous.id);
        expect(tasks.single.postId, 42);
        final traits = await TraitsRepository(sqlite).get(anonymous.id);
        expect(traits.denylist, ['young']);
      },
    );

    test('merges two accounts on one host into the first slot', () async {
      await addIdentity('e621.net', 'alice', {'authorization': 'Basic a'});
      await addIdentity('e621.net', 'bob', {'authorization': 'Basic b'});
      final seeded = await repository.all();
      final alice = seeded.firstWhere((e) => e.username == 'alice');
      final bob = seeded.firstWhere((e) => e.username == 'bob');
      await FollowRepository(
        database: sqlite,
      ).add(const FollowRequest(tags: 'canine'), alice.id);
      await FollowRepository(
        database: sqlite,
      ).add(const FollowRequest(tags: 'feline'), bob.id);

      final changed = await repository.removeCredentials();

      expect(changed, 2);
      final identities = await repository.all();
      expect(identities.length, 1);
      expect(identities.single.username, isNull);
      // both accounts' follows live on the surviving row
      final follows = await FollowRepository(
        database: sqlite,
      ).all(identity: identities.single.id);
      expect(follows.map((e) => e.tags), containsAll(['canine', 'feline']));
    });

    test('leaves null headers alone', () async {
      await addIdentity('e621.net', null, null);

      final changed = await repository.removeCredentials();

      expect(changed, 0);
    });

    test('strips legacy top-level cookie names', () async {
      // Older capture logic stored cookies as top-level headers.
      // A keyword blocklist misses these names, so the exporter
      // must use an explicit allowlist instead.
      await addIdentity('e621.net', 'tester', {
        'cf_clearance': 'legacy-challenge-token',
        '__cf_bm': 'legacy-bm-token',
        '__cfduid': 'legacy-duid-token',
        'authorization': 'Basic secret',
        'user-agent': 'e1547/1.0',
      });

      final changed = await repository.removeCredentials();

      expect(changed, 1);
      final identity = (await repository.all()).single;
      expect(identity.headers, {'user-agent': 'e1547/1.0'});
    });

    test('drops unknown header names by default', () async {
      await addIdentity('e621.net', 'tester', {
        'x-custom-session': 'a',
        'x-future-header': 'b',
        'accept-language': 'en',
      });

      await repository.removeCredentials();

      final identity = (await repository.all()).single;
      expect(identity.headers, {'accept-language': 'en'});
    });
  });

  group('IdentityRepository.hosts', () {
    test('returns the normalized host set', () async {
      await addIdentity('e621.net', 'tester', null);
      await addIdentity('https://e926.net/', 'other', null);

      final hosts = await repository.hosts();

      expect(hosts, {'https://e621.net', 'https://e926.net'});
    });
  });

  group('credential remnants', () {
    test('a vacuumed rewrite leaves no recoverable bytes', () async {
      final dir = await Directory.systemTemp.createTemp('e1547_identity');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}${Platform.pathSeparator}app.db';

      final fileDb = AppDatabase(
        NativeDatabase(
          File(path),
          setup: (db) => db.execute('PRAGMA journal_mode = DELETE'),
        ),
      );
      await IdentityRepository(fileDb).add(
        const IdentityRequest(
          host: 'e621.net',
          username: 'tester',
          headers: {'authorization': 'Basic SUPERSECRETKEY'},
        ),
      );
      await fileDb.close();

      // A plain file copy must still contain the secret,
      // proving the marker is actually in the file.
      final rawBytes = await File(path).readAsBytes();
      expect(asBytesString(rawBytes), contains('SUPERSECRETKEY'));

      final rewriteDb = AppDatabase(NativeDatabase(File(path)));
      await IdentityRepository(rewriteDb).removeCredentials();
      await rewriteDb.customStatement('VACUUM');
      await rewriteDb.close();

      final rewritten = await File(path).readAsBytes();
      expect(asBytesString(rewritten), isNot(contains('SUPERSECRETKEY')));
    });
  });
}
