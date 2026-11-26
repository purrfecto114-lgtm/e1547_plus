import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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
/// the null (no proxy) default.
Future<void> resolveSystemProxy() async {
  systemProxy.value = await systemHttpProxy();
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
    final proxy = await const MethodChannel('e1547/biometrics')
        .invokeMapMethod<String, Object?>('systemProxy');
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
