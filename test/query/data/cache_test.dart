import 'dart:async';

import 'package:e1547/query/query.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal cache item: records compare by value, which the bridge
/// relies on to skip no-op updates.
typedef Item = ({int id, int votes, bool faved});

void main() {
  late CachedQuery cache;
  late QueryBridge<Item, int> bridge;

  setUp(() {
    cache = CachedQuery.asNewInstance();
    addTearDown(() => cache.dispose());
    bridge = QueryBridge<Item, int>(
      cache: cache,
      baseKey: ['test'],
      getId: (item) => item.id,
    );
    cache.setQueryData<Item>(
      key: ['test', 1],
      data: (id: 1, votes: 0, faved: false),
    );
  });

  group('QueryBridge.optimistic', () {
    test('applies the update and keeps it on success', () async {
      await bridge.optimistic(
        1,
        (item) => (id: item.id, votes: item.votes + 1, faved: item.faved),
        () async {},
      );

      expect(bridge.get(1)!.votes, 1);
    });

    test('restores the previous state on failure', () async {
      await expectLater(
        bridge.optimistic(
          1,
          (item) => (id: item.id, votes: item.votes + 1, faved: item.faved),
          () async => throw Exception('rejected'),
        ),
        throwsA(isA<Exception>()),
      );

      expect(bridge.get(1)!.votes, 0);
    });

    test("a failing vote's rollback keeps a concurrent favorite", () async {
      // Two widgets with independent loading states can start a vote and
      // a favorite on the same post at the same time. The vote fails;
      // its rollback must not revert the favorite that succeeded.
      final Completer<void> voteFails = Completer<void>();

      final Future<void> vote = bridge.optimistic(
        1,
        (item) => (id: item.id, votes: item.votes + 1, faved: item.faved),
        () async {
          await voteFails.future;
          throw Exception('vote rejected');
        },
      );
      // Let the vote's optimistic update land before the favorite starts.
      await Future<void>.delayed(Duration.zero);

      final Future<void> favorite = bridge.optimistic(
        1,
        (item) => (id: item.id, votes: item.votes, faved: true),
        () async {},
      );

      voteFails.complete();
      await vote.catchError((_) {});
      await favorite;

      // The cache ends up consistent with the server: the favorite
      // survived, the vote was rolled back.
      expect(bridge.get(1)!.faved, isTrue);
      expect(bridge.get(1)!.votes, 0);
    });

    test("a failing favorite's rollback keeps a concurrent vote", () async {
      // The same race with the roles reversed.
      final Completer<void> favoriteFails = Completer<void>();

      final Future<void> favorite = bridge.optimistic(
        1,
        (item) => (id: item.id, votes: item.votes, faved: true),
        () async {
          await favoriteFails.future;
          throw Exception('favorite rejected');
        },
      );
      await Future<void>.delayed(Duration.zero);

      final Future<void> vote = bridge.optimistic(
        1,
        (item) => (id: item.id, votes: item.votes + 1, faved: item.faved),
        () async {},
      );

      favoriteFails.complete();
      await favorite.catchError((_) {});
      await vote;

      expect(bridge.get(1)!.faved, isFalse);
      expect(bridge.get(1)!.votes, 1);
    });

    test('mutations on different items do not wait for each other', () async {
      cache.setQueryData<Item>(
        key: ['test', 2],
        data: (id: 2, votes: 0, faved: false),
      );

      final Completer<void> gate = Completer<void>();
      // A slow mutation on item 1 must not block one on item 2.
      final Future<void> slow = bridge.optimistic(
        1,
        (item) => (id: item.id, votes: item.votes + 1, faved: item.faved),
        () async => gate.future,
      );

      final Completer<void> otherDone = Completer<void>();
      final Future<void> other = bridge.optimistic(
        2,
        (item) => (id: item.id, votes: item.votes + 1, faved: item.faved),
        () async => otherDone.complete(),
      );
      await other;

      gate.complete();
      await slow;

      expect(bridge.get(2)!.votes, 1);
    });
  });
}
