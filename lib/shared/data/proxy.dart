import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:e1547/shared/data/roots.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

/// The system proxy configuration, as the clients resolve it.
typedef ProxyConfig = ({String host, int port});

/// The proxy the app has resolved, when one is set.
///
/// Every network path the app opens reads this when its client is
/// built and picks the http adapter through [proxyAwareAdapter]. The
/// value is re-resolved on a slow cadence by the connection probe, so
/// a proxy switched on after app start reaches the app within one
/// probe cycle instead of requiring a restart; assigning the same
/// value does not notify, so unchanged cycles rebuild nothing.
final ValueNotifier<ProxyConfig?> systemProxy = ValueNotifier(null);

/// Reads the android system proxy into [systemProxy].
///
/// Called once during app initialization, before the first client
/// exists, and re-read by the connection probe's cycle; failures leave
/// the null (no proxy) default. A resolved proxy whose host lives on the
/// local network also triggers the local network permission request,
/// because android 17 makes that access a runtime permission for apps
/// targeting it.
Future<void> resolveSystemProxy() async {
  final proxy = await systemHttpProxy();
  systemProxy.value = proxy;
  if (proxy != null) {
    // The answer is intentionally not surfaced here: a denial shows up
    // as connection failures through the proxy, which the existing
    // error surfaces already render, and on releases before android 17
    // the helper answers null and the proxy just works.
    await requestLocalNetworkPermission(proxy.host);
  }
}

/// Whether [host] names a host the app connects to on the local network.
///
/// Android 17 (API level 37) gates local network access behind the
/// ACCESS_LOCAL_NETWORK runtime permission for apps targeting it, and a
/// proxy resolved from the system settings can sit on that network: a
/// router, or a local proxy app publishing itself on the loopback. The
/// match covers the loopback and link-local ranges, the private ipv4
/// ranges and the ipv6 unique-local range; hostnames are never matched,
/// since reaching them goes through the resolver's unicast path.
bool isLocalNetworkHost(String host) {
  final address = InternetAddress.tryParse(host);
  if (address == null) {
    return false;
  }
  if (address.isLoopback || address.isLinkLocal) {
    return true;
  }
  if (address.type == InternetAddressType.IPv4) {
    final octets = address.rawAddress;
    return octets[0] == 10 ||
        (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) ||
        (octets[0] == 192 && octets[1] == 168);
  }
  // The ipv6 unique-local range (fc00::/7), where LAN services live
  // alongside the link-local addresses already matched above.
  return address.rawAddress[0] & 0xfe == 0xfc;
}

/// Asks android for the local network permission when [host] needs it.
///
/// Returns whether the permission is granted, or null when the platform
/// has nothing to answer with: not android, a host off the local
/// network, no such permission (releases before android 17), no plugin
/// (tests), or the probe failed. A null must read as "not known", not
/// as "denied" — before android 17 the local network is simply
/// reachable.
Future<bool?> requestLocalNetworkPermission(String host) async {
  if (!Platform.isAndroid || !isLocalNetworkHost(host)) {
    return null;
  }
  try {
    return await const MethodChannel(
      'e1547/biometrics',
    ).invokeMethod<bool>('requestLocalNetworkPermission', host);
  } on PlatformException {
    return null;
  } on MissingPluginException {
    return null;
  }
}

/// The Android system proxy, when one is set.
///
/// The cronet engine the native adapter uses on Android ignores the
/// system proxy: users whose network only reaches certain hosts through
/// the proxy (the common arrangement in regions that filter the web)
/// get connection failures for those hosts even with the proxy up,
/// which reads as "the app is offline" though every other app works.
/// A VPN-mode tunnel still works, since it catches traffic below cronet.
///
/// Returns null when no proxy is set, on platforms without the channel
/// (iOS follows the system proxy natively), or when the probe fails.
Future<ProxyConfig?> systemHttpProxy() async {
  try {
    final proxy = await const MethodChannel(
      'e1547/biometrics',
    ).invokeMapMethod<String, Object?>('systemProxy');
    final host = proxy?['host'] as String?;
    final port = proxy?['port'] as int?;
    if (host == null || port == null || port <= 0 || port > 65535) {
      return null;
    }
    return (host: host, port: port);
  } on PlatformException {
    return null;
  } on MissingPluginException {
    return null;
  }
}

/// The http adapter a client should use for [proxy].
///
/// The cronet engine of the native adapter ignores the android system
/// proxy, so a known proxy switches the client onto the dart http
/// stack, whose findProxy honours it. Every client factory in the app
/// picks its adapter through this helper: a client that skips it sends
/// hosts only reachable through the proxy into connection failures
/// while every other app on the device works.
HttpClientAdapter proxyAwareAdapter(ProxyConfig? proxy) => proxy == null
    ? NativeAdapter()
    : IOHttpClientAdapter(
        createHttpClient: () =>
            HttpClient()
              ..findProxy = (uri) => 'PROXY ${proxy.host}:${proxy.port}',
      );

/// The http adapter the media stack uses for [proxy].
///
/// Same proxy reasoning as [proxyAwareAdapter] — the cronet engine
/// ignores the system proxy — but this path always rides the dart http
/// stack, because it also carries the certificate story: the media
/// hosts rotate their certificate authorities under the app, and the
/// cronet engine validates against the device's frozen system store,
/// which predates some of those authorities (Android 7 has no ISRG
/// Root X1, so a cdn host moving to a Let's Encrypt chain failed every
/// media request on it with ERR_CERT_AUTHORITY_INVALID). The dart stack
/// validates against the bundled modern roots through [trustedRoots],
/// falling back to the system store until the bundle has loaded.
HttpClientAdapter mediaAdapter(ProxyConfig? proxy) => IOHttpClientAdapter(
  createHttpClient: () {
    final HttpClient client = HttpClient(context: trustedRoots);
    if (proxy != null) {
      client.findProxy = (uri) => 'PROXY ${proxy.host}:${proxy.port}';
    }
    return client;
  },
);
