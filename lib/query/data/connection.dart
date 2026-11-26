import 'dart:async';
import 'dart:io';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart';

/// A single connectivity probe against one host.
///
/// Returns true when the host answered over HTTP at all — any status
/// counts, because a Cloudflare challenge or a 401 proves the transport
/// path works, which is the only thing connectivity means here.
typedef HostProbe =
    Future<bool> Function(Uri url, ({String host, int port})? proxy);

/// The default [HostProbe].
///
/// A bare HEAD to the host's post list endpoint through a one-shot
/// [HttpClient]. Unlike a DNS lookup — the old probe — this crosses the
/// same path the app's requests take: it honours the proxy, and a
/// poisoned DNS answer cannot fake success because the connection
/// itself still has to succeed. The client is closed after every probe
/// so idle sockets do not pile up across the stream's lifetime.
Future<bool> defaultHostProbe(Uri url, ({String host, int port})? proxy) async {
  final HttpClient client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);
  if (proxy != null) {
    client.findProxy = (uri) => 'PROXY ${proxy.host}:${proxy.port}';
  }
  try {
    final HttpClientRequest request = await client.headUrl(url);
    // close() completing means an HTTP answer arrived — any status the
    // server picked proves the transport path works, which is all
    // connectivity means here.
    await request.close();
    return true;
  } on Object {
    // Everything that throws is a transport failure — unreachable host,
    // refused proxy, timeout — and reads as offline.
    return false;
  } finally {
    client.close(force: true);
  }
}

/// A [ConnectionStatus] stream that probes the host the user browses.
///
/// The default connectivity controller resolves `example.com`; on the
/// restricted networks this app's users are often on, that lookup is
/// poisoned or times out, the controller emits `unknown` instead of
/// `connected`, and queries that failed offline never retry — the
/// offline banner waits for a manual tap forever.
///
/// The replacement probe must answer for the site the account in use
/// talks to, not for any host of the e621 family: users behind
/// region blocks reach e926 directly but e621 only through a proxy, so
/// a probe that stops at the first reachable family host reports
/// "connected" forever to an e621 account whose every request fails.
/// [activeHost] supplies the browsed host per cycle; with no active
/// identity it may return null, and the probe then falls back to
/// trying either family host.
///
/// The probe itself is an HTTP request, not a DNS lookup, so it honours
/// the proxy [resolveProxy] returns. Both sources are consulted fresh
/// every cycle: a proxy switched on after app start — previously
/// requiring a restart — reaches the next probe and, through the
/// client layer's rebuild on the shared proxy notifier, the real
/// requests too, and an identity switch moves the probe to the new
/// host within one cycle.
Stream<ConnectionStatus> apiHostConnectionStream({
  required Future<({String host, int port})?> Function() resolveProxy,
  required Future<String?> Function() activeHost,
  HostProbe? probe,
  Duration period = const Duration(seconds: 30),
}) {
  final HostProbe hostProbe = probe ?? defaultHostProbe;
  // ignore: close_sinks, the stream lives for the process lifetime
  final StreamController<ConnectionStatus> controller =
      StreamController.broadcast();
  ConnectionStatus last = ConnectionStatus.unknown;
  bool checking = false;

  Future<bool> probeHost(String host, ({String host, int port})? proxy) =>
      hostProbe(Uri.parse('$host/posts.json'), proxy);

  Future<bool> probeCycle(({String host, int port})? proxy) async {
    final String? host = await activeHost();
    if (host != null) {
      return probeHost(host, proxy);
    }
    // No active identity: either host answering is the best available
    // answer, since accounts live on either and identity switching
    // moves between them.
    for (final String host in ['https://e926.net', 'https://e621.net']) {
      if (await probeHost(host, proxy)) {
        return true;
      }
    }
    return false;
  }

  Future<void> check() async {
    if (checking) return;
    checking = true;
    try {
      final ({String host, int port})? proxy = await resolveProxy();
      final bool online = await probeCycle(proxy);
      final ConnectionStatus status = online
          ? ConnectionStatus.connected
          : ConnectionStatus.disconnected;
      if (status != last) {
        last = status;
        controller.add(status);
      }
    } finally {
      checking = false;
    }
  }

  // The probe repeats on a slow cadence: platform connectivity events
  // only say a network interface exists, not that it reaches the api,
  // and a network that comes and goes between probes without an
  // interface change ( captive portal login, proxy toggling ) would
  // otherwise be invisible to the retry path.
  Timer.periodic(period, (_) => check());
  controller.onListen = check;

  return controller.stream;
}

/// Refetches listener queries that latched a connection error whenever
/// the host probe reports connectivity.
///
/// cached_query refetches `refetchOnConnection` queries when the probe
/// stream flips from disconnected to connected. A network disturbance
/// shorter than the probe's period never produces that flip — switching
/// accounts re-keys every identity-scoped query and refetches at once,
/// and hopping VPNs tears the tunnel mid-flight — so the queries that
/// failed during the switch would hold their "offline" verdict until a
/// manual pull. Sweeping them on every successful probe closes that
/// gap: within one cycle after the network settles, the errors clear
/// themselves the same way a transition would.
class ConnectionErrorSweeper {
  ConnectionErrorSweeper({required CachedQuery cache}) : _cache = cache;

  final CachedQuery _cache;

  StreamSubscription<ConnectionStatus>? _subscription;

  /// Whether [query] should be retried by [sweep].
  @visibleForTesting
  bool shouldRetry(Cacheable<dynamic> query) {
    if (!query.hasListener) return false;
    final config = switch (query) {
      Query() => query.config,
      InfiniteQuery() => query.config,
    };
    // The same switch the transition refetch applies; a query opted out
    // of it wants no automatic traffic either way.
    if (!config.refetchOnConnection) return false;
    return isConnectionError(query.state.error);
  }

  /// Retries every listener query whose error reads as a connection
  /// failure. Queries already fetching coalesce into their in-flight
  /// fetch; the rest refetch from their next page or first page.
  void sweep() {
    for (final Cacheable<dynamic> query in _cache.whereQuery(shouldRetry)) {
      unawaited(query.invalidate());
    }
  }

  /// Subscribes [stream] and sweeps on every connected report.
  void attach(Stream<ConnectionStatus> stream) {
    _subscription?.cancel();
    _subscription = stream.listen((status) {
      if (status.isConnected) sweep();
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
