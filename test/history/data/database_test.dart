import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase sqlite;
  late HistoryRepository repository;
  late int identity;

  Future<void> visit(String link) => repository.add(
    HistoryRequest(
      visitedAt: DateTime.utc(2020),
      link: link,
      category: HistoryCategory.items,
      type: HistoryType.posts,
    ),
    identity,
  );

  setUp(() async {
    sqlite = AppDatabase(NativeDatabase.memory());
    repository = HistoryRepository(database: sqlite);
    identity = (await IdentityRepository(
      sqlite,
    ).add(const IdentityRequest(host: 'e621.net', username: 'tester'))).id;
  });

  tearDown(() => sqlite.close());

  group('HistoryRepository.removeAll', () {
    test('clears every entry when given no ids', () async {
      await visit('/posts/1');
      await visit('/posts/2');

      await repository.removeAll(null, identity: identity);

      expect(await repository.length(identity: identity), 0);
    });

    test('clears only the given ids', () async {
      await visit('/posts/1');
      await visit('/posts/2');
      final entries = await repository.page(identity: identity);

      await repository.removeAll([entries.first.id], identity: identity);

      final remaining = await repository.page(identity: identity);
      expect(remaining.map((e) => e.link), [entries.last.link]);
    });
  });

  group('HistoryRepository.isDuplicate', () {
    test('the same visit in two identities is not a duplicate', () async {
      final other = (await IdentityRepository(
        sqlite,
      ).add(const IdentityRequest(host: 'e621.net', username: 'other'))).id;
      // The dedup window only spans the last three minutes, so the
      // visit has to carry a fresh timestamp to fall inside it.
      final request = HistoryRequest(
        visitedAt: DateTime.now(),
        link: '/posts/1',
        category: HistoryCategory.items,
        type: HistoryType.posts,
      );

      // The dedup window is per identity: another account's visit of the
      // same link must not swallow this one's history entry.
      expect(
        await repository.isDuplicate(request, identity: identity),
        isFalse,
      );
      await repository.add(request, identity);
      expect(await repository.isDuplicate(request, identity: identity), isTrue);
      expect(await repository.isDuplicate(request, identity: other), isFalse);

      await repository.add(request, other);
      expect(await repository.length(identity: identity), 1);
      expect(await repository.length(identity: other), 1);
    });
  });
}
