import 'dart:async';

import 'package:dio/dio.dart';
import 'package:e1547/query/query.dart';
import 'package:flutter_test/flutter_test.dart';

/// The sweeper is the recovery path for disturbances shorter than the
/// probe's period: switching accounts re-keys every identity-scoped query
/// and refetches at once, hopping VPNs tears the tunnel mid-flight, and
/// neither produces the disconnected→connected flip cached_query's
/// transition refetch needs. A query that latched the failure must be
/// retried when the next successful probe reports, without a manual pull.
void main() {
  late CachedQuery cache;
  late StreamController<ConnectionStatus> connections;
  late ConnectionErrorSweeper sweeper;
  int networkCalls = 0;
  bool offline = false;
  bool serverDown = false;

  Query<String> makeQuery(String key, {bool refetchOnConnection = true}) =>
      Query(
        cache: cache,
        key: key,
        queryFn: () async {
          networkCalls++;
          if (offline) {
            throw DioException(
              requestOptions: RequestOptions(path: '/'),
              type: DioExceptionType.connectionTimeout,
            );
          }
          if (serverDown) {
            throw DioException(
              requestOptions: RequestOptions(path: '/'),
              type: DioExceptionType.badResponse,
            );
          }
          return 'online';
        },
        config: QueryConfig(refetchOnConnection: refetchOnConnection),
      );

  setUp(() {
    cache = CachedQuery.asNewInstance();
    connections = StreamController<ConnectionStatus>.broadcast();
    sweeper = ConnectionErrorSweeper(cache: cache)..attach(connections.stream);
    networkCalls = 0;
    offline = false;
    serverDown = false;
  });

  tearDown(() async {
    await sweeper.dispose();
    await connections.close();
    cache.deleteCache();
  });

  test('a connected probe report retries a latched connection error', () async {
    offline = true;
    final query = makeQuery('latched-offline');
    final sub = query.stream.listen((_) {});
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(query.state, isA<QueryError<String>>());
    expect(networkCalls, 1);

    offline = false;
    connections.add(ConnectionStatus.connected);
    await pumpEventQueue();

    expect(networkCalls, 2, reason: 'the sweep must retry the failed query');
    expect(query.state, isA<QuerySuccess<String>>());
  });

  test('a direct sweep retries without a transition on the stream', () async {
    offline = true;
    final query = makeQuery('direct-sweep');
    final sub = query.stream.listen((_) {});
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(query.state, isA<QueryError<String>>());

    // No stream event at all — the disturbance came and went between two
    // probe cycles, exactly the account-switch shape.
    offline = false;
    sweeper.sweep();
    await pumpEventQueue();

    expect(networkCalls, 2);
    expect(query.state, isA<QuerySuccess<String>>());
  });

  test('the sweep leaves server rejections alone', () async {
    serverDown = true;
    final query = makeQuery('server-rejected');
    final sub = query.stream.listen((_) {});
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(query.state, isA<QueryError<String>>());
    expect(networkCalls, 1);

    connections.add(ConnectionStatus.connected);
    await pumpEventQueue();

    // A 4xx/5xx is the server's answer; retrying it on every probe would
    // hammer the api with a request that keeps failing the same way.
    expect(networkCalls, 1);
    expect(query.state, isA<QueryError<String>>());
  });

  test('the sweep skips queries without a listener', () async {
    offline = true;
    final query = makeQuery('unwatched');
    await query.fetch();
    await pumpEventQueue();
    expect(query.state, isA<QueryError<String>>());
    expect(networkCalls, 1);

    offline = false;
    connections.add(ConnectionStatus.connected);
    await pumpEventQueue();

    // Nothing displays this query; refetching it would only spend traffic
    // on data nobody is looking at.
    expect(networkCalls, 1);
    expect(query.state, isA<QueryError<String>>());
  });

  test('the sweep skips queries opted out of refetchOnConnection', () async {
    offline = true;
    final query = makeQuery('opted-out', refetchOnConnection: false);
    final sub = query.stream.listen((_) {});
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(query.state, isA<QueryError<String>>());
    expect(networkCalls, 1);

    offline = false;
    connections.add(ConnectionStatus.connected);
    await pumpEventQueue();

    expect(networkCalls, 1);
    expect(query.state, isA<QueryError<String>>());
  });

  test('a disconnected probe report sweeps nothing', () async {
    offline = true;
    final query = makeQuery('still-offline');
    final sub = query.stream.listen((_) {});
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(networkCalls, 1);

    connections.add(ConnectionStatus.disconnected);
    await pumpEventQueue();
    expect(networkCalls, 1);
  });
}
