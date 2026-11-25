import 'dart:async';
import 'dart:io';

import 'package:cached_query_flutter/cached_query_flutter.dart';

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
