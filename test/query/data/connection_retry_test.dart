import 'dart:async';

import 'package:cached_query/cached_query.dart' hide ConnectionStatus;
// The controller itself is not part of the package's public surface;
// the test drives it through the same file the app's cache pulls in,
// which also brings its own ConnectionStatus along.
import '../../../vendor/cached_query/lib/src/connection_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// The connection controller must retry queries whose last fetch failed
/// when the device comes back online. A plain fetch() bounces off the
/// staleness gate — an error state is fresh by duration — so failed
/// queries are invalidated into a full refetch on reconnect.
void main() {
  late CachedQuery cache;
  late StreamController<ConnectionStatus> connection;
  late ConnectionController controller;
  int networkCalls = 0;
  bool offline = false;

  Query<String> makeQuery() => Query(
    cache: cache,
    key: 'retry-on-reconnect',
    queryFn: () async {
      networkCalls++;
      if (offline) {
        throw Exception('offline');
      }
      return 'online';
    },
    config: const QueryConfig(
      // Long enough that an error state is never stale by duration; only
      // the reconnect path may trigger the retry.
      staleDuration: Duration(hours: 1),
    ),
  );

  setUp(() {
    cache = CachedQuery.asNewInstance();
    connection = StreamController<ConnectionStatus>.broadcast();
    controller = ConnectionController(cache: cache, connectionStream: connection.stream);
    networkCalls = 0;
    offline = false;
  });

  tearDown(() async {
    await controller.dispose();
    await connection.close();
    cache.deleteCache();
  });

  test('a query that failed offline refetches when the connection returns', () async {
    offline = true;
    final query = makeQuery();
    // The subscription's onListen performs the first fetch, which fails
    // offline and settles an error state.
    final states = <QueryStatus<String>>[];
    final sub = query.stream.listen(states.add);
    await pumpEventQueue();
    expect(query.state, isA<QueryError<String>>());
    expect(networkCalls, 1);

    // The device goes online. The error state is fresh by duration, so
    // only the reconnect path can produce a second network call.
    offline = false;
    connection.add(ConnectionStatus.connected);

    await pumpEventQueue();
    expect(networkCalls, 2, reason: 'the reconnect must retry the failed query');
    expect(query.state, isA<QuerySuccess<String>>());
    expect(query.state.data, 'online');

    await sub.cancel();
  });

  test('a successful query is not invalidated by a reconnect', () async {
    final query = makeQuery();
    final sub = query.stream.listen((_) {});

    await query.fetch();
    expect(networkCalls, 1);

    connection.add(ConnectionStatus.connected);
    await pumpEventQueue();

    expect(networkCalls, 1, reason: 'a fresh success needs no refetch');

    await sub.cancel();
  });

  test('a query without listeners is left alone by a reconnect', () async {
    offline = true;
    final query = makeQuery();
    await query.fetch();
    expect(query.state, isA<QueryError<String>>());

    connection.add(ConnectionStatus.connected);
    await pumpEventQueue();

    expect(networkCalls, 1, reason: 'nobody watches the query, so nothing retries');
  });
}
