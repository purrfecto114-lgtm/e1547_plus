import 'dart:async';
import 'dart:io';

import 'package:cached_query_flutter/cached_query_flutter.dart';

/// A [ConnectionStatus] stream that probes the app's own api hosts.
///
/// The default connectivity controller resolves `example.com`; on the
/// restricted networks this app's users are often on, that lookup is
/// poisoned or times out, the controller emits `unknown` instead of
/// `connected`, and queries that failed offline never retry — the
/// offline banner waits for a manual tap forever. Probing the hosts
/// the app actually talks to decides connectivity by the same network
/// path the requests themselves take.
Stream<ConnectionStatus> apiHostConnectionStream() {
  // ignore: close_sinks, the stream lives for the process lifetime
  final StreamController<ConnectionStatus> controller =
      StreamController.broadcast();
  ConnectionStatus last = ConnectionStatus.unknown;
  bool checking = false;

  // Both hosts are tried; either one resolving counts as online, since
  // accounts live on either and identity switching moves between them.
  Future<bool> probe() async {
    for (final host in ['e926.net', 'e621.net']) {
      try {
        final results = await InternetAddress.lookup(
          host,
        ).timeout(const Duration(seconds: 5));
        if (results.isNotEmpty && results.first.rawAddress.isNotEmpty) {
          return true;
        }
      } on Object {
        // A host that fails to resolve just means the probe moves on
        // to the next one; only all of them failing reads as offline.
      }
    }
    return false;
  }

  Future<void> check() async {
    if (checking) return;
    checking = true;
    try {
      final online = await probe();
      final status = online
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
  Timer.periodic(const Duration(seconds: 30), (_) => check());
  controller.onListen = check;

  return controller.stream;
}
