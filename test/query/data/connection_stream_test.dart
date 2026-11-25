import 'dart:async';
import 'dart:io';

import 'package:e1547/query/query.dart';
import 'package:flutter_test/flutter_test.dart';

/// The connection stream must answer for the host the user is actually
/// browsing, not for "some e621 family host".
///
/// The account in use decides which host matters: a user on e621 whose
/// network only reaches it through a proxy is offline as long as e621
/// itself is unreachable, even though e926 answers — the old DNS probe
/// accepted any family host and reported "connected" forever, so failed
/// e621 queries were never retried and the offline banner never showed.
/// These tests pin the per-host truthfulness, the proxy awareness of
/// the probe and the re-probe on proxy or host changes.
void main() {
  const Duration period = Duration(milliseconds: 10);

  /// Waits long enough for several probe cycles to run.
  Future<void> cycles([int n = 1]) => Future<void>.delayed(period * (n * 3));

  /// A probe that records every call and answers from [answers].
  ({
    Future<bool> Function(Uri url, ({String host, int port})? proxy) probe,
    List<Uri> hosts,
    List<({String host, int port})?> proxies,
  })
  recordingProbe(bool Function(Uri url) answers) {
    final List<Uri> hosts = <Uri>[];
    final List<({String host, int port})?> proxies =
        <({String host, int port})?>[];
    Future<bool> probe(Uri url, ({String host, int port})? proxy) async {
      hosts.add(url);
      proxies.add(proxy);
      return answers(url);
    }

    return (probe: probe, hosts: hosts, proxies: proxies);
  }

  /// Attaches the status collector the way the query cache does: the
  /// vendor subscribes as soon as the stream is handed over, before
  /// any cycle runs, and the collected events are what it sees.
  ({
    List<ConnectionStatus> events,
    StreamSubscription<ConnectionStatus> subscription,
  })
  collect(Stream<ConnectionStatus> stream) {
    final List<ConnectionStatus> events = <ConnectionStatus>[];
    // The subscription is handed back to the caller, which cancels it
    // through its own teardown.
    // ignore: cancel_subscriptions
    final StreamSubscription<ConnectionStatus> subscription = stream.listen(
      events.add,
    );
    return (events: events, subscription: subscription);
  }

  test('the active host alone decides connectivity', () async {
    // e926 answers, e621 does not; the active identity is on e621.
    final recorder = recordingProbe((url) => url.host.contains('e926'));
    final Stream<ConnectionStatus> stream = apiHostConnectionStream(
      resolveProxy: () async => null,
      activeHost: () async => 'https://e621.net',
      probe: recorder.probe,
      period: period,
    );
    final collected = collect(stream);
    addTearDown(collected.subscription.cancel);

    await cycles();
    expect(collected.events, [ConnectionStatus.disconnected]);
    expect(recorder.hosts, isNotEmpty);
    expect(recorder.hosts.map((uri) => uri.host), everyElement('e621.net'));
  });

  test('a reachable active host reads as connected', () async {
    final recorder = recordingProbe((url) => url.host.contains('e926'));
    final Stream<ConnectionStatus> stream = apiHostConnectionStream(
      resolveProxy: () async => null,
      activeHost: () async => 'https://e926.net',
      probe: recorder.probe,
      period: period,
    );
    final collected = collect(stream);
    addTearDown(collected.subscription.cancel);

    await cycles();
    expect(collected.events, [ConnectionStatus.connected]);
    expect(recorder.hosts, isNotEmpty);
    expect(recorder.hosts.map((uri) => uri.host), everyElement('e926.net'));
  });

  test('without an active host, both family hosts get a chance', () async {
    // The fallback keeps the round-19 rationale: accounts live on
    // either host, so with no active identity any of them reaching
    // the network is the best available answer. e926 stays down here
    // so the probe has to move on to e621 to find the network.
    final recorder = recordingProbe((url) => url.host.contains('e621'));
    final Stream<ConnectionStatus> stream = apiHostConnectionStream(
      resolveProxy: () async => null,
      activeHost: () async => null,
      probe: recorder.probe,
      period: period,
    );
    final collected = collect(stream);
    addTearDown(collected.subscription.cancel);

    await cycles();
    expect(collected.events, [ConnectionStatus.connected]);
    expect(recorder.hosts.map((uri) => uri.host), contains('e926.net'));
    expect(recorder.hosts.map((uri) => uri.host), contains('e621.net'));
  });

  test('a proxy resolved between cycles reaches the probe', () async {
    bool proxyUp = false;
    final recorder = recordingProbe((url) => true);
    final Stream<ConnectionStatus> stream = apiHostConnectionStream(
      resolveProxy: () async =>
          proxyUp ? (host: '127.0.0.1', port: 7890) : null,
      activeHost: () async => 'https://e621.net',
      probe: recorder.probe,
      period: period,
    );
    final collected = collect(stream);
    addTearDown(collected.subscription.cancel);

    await cycles();
    expect(recorder.proxies, everyElement(isNull));

    proxyUp = true;
    await cycles();
    expect(recorder.proxies.last, (host: '127.0.0.1', port: 7890));
    expect(collected.events, [ConnectionStatus.connected]);
  });

  test(
    'a host change between cycles moves the probe to the new host',
    () async {
      String host = 'https://e926.net';
      final recorder = recordingProbe((url) => true);
      final Stream<ConnectionStatus> stream = apiHostConnectionStream(
        resolveProxy: () async => null,
        activeHost: () async => host,
        probe: recorder.probe,
        period: period,
      );
      final collected = collect(stream);
      addTearDown(collected.subscription.cancel);

      await cycles();
      expect(recorder.hosts.first.host, 'e926.net');
      host = 'https://e621.net';
      await cycles();
      expect(recorder.hosts.last.host, 'e621.net');
      expect(collected.events, [ConnectionStatus.connected]);
    },
  );

  test('a failing active host is retried on the same host', () async {
    final recorder = recordingProbe((url) => false);
    final Stream<ConnectionStatus> stream = apiHostConnectionStream(
      resolveProxy: () async => null,
      activeHost: () async => 'https://e621.net',
      probe: recorder.probe,
      period: period,
    );
    final collected = collect(stream);
    addTearDown(collected.subscription.cancel);

    await cycles(2);
    expect(collected.events, [ConnectionStatus.disconnected]);
    expect(recorder.hosts.length, greaterThanOrEqualTo(2));
    expect(recorder.hosts.map((uri) => uri.host), everyElement('e621.net'));
  });

  test('unchanged status is not re-emitted', () async {
    final recorder = recordingProbe((url) => true);
    final Stream<ConnectionStatus> stream = apiHostConnectionStream(
      resolveProxy: () async => null,
      activeHost: () async => 'https://e926.net',
      probe: recorder.probe,
      period: period,
    );
    final collected = collect(stream);
    addTearDown(collected.subscription.cancel);

    await cycles(3);
    expect(collected.events, [ConnectionStatus.connected]);
  });

  test('the default probe accepts any HTTP answer as reachable', () async {
    // Any status the server returns proves the transport path works;
    // a Cloudflare challenge or a 401 is a reachable host, not a dead
    // one. The test binds a real socket so the probe's own timeout,
    // error swallowing and client teardown are exercised.
    final HttpServer server = await HttpServer.bind('127.0.0.1', 0);
    server.listen((request) async {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
    });
    addTearDown(server.close);

    final Uri url = Uri.parse('http://127.0.0.1:${server.port}/posts.json');
    expect(await defaultHostProbe(url, null), isTrue);
  });

  test('the default probe reports transport failures as unreachable', () async {
    final Uri url = Uri.parse('http://127.0.0.1:1/posts.json');
    expect(await defaultHostProbe(url, null), isFalse);
  });

  test('the default probe routes through the given proxy', () async {
    // A proxy target that accepts connections and answers, proving the
    // probe actually dialled through it instead of ignoring it.
    final HttpServer proxy = await HttpServer.bind('127.0.0.1', 0);
    proxy.listen((request) async {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
    });
    addTearDown(proxy.close);

    final Uri url = Uri.parse('http://e621.net/posts.json');
    expect(
      await defaultHostProbe(url, (host: '127.0.0.1', port: proxy.port)),
      isTrue,
    );
  });
}
