import 'package:flutter/services.dart';

/// The resolved proxy shared by every client this session builds.
///
/// The lookup crosses a platform channel; clients are built
/// synchronously inside providers, so the first builder awaits this
/// once and later builders reuse the memo.
final Future<({String host, int port})?> systemProxyMemo = systemHttpProxy();

/// The Android system proxy, when one is set.
///
/// The cronet engine the app's http adapter uses on Android ignores the
/// system proxy: users whose network only reaches certain hosts through
/// the proxy (the common arrangement in regions that filter the web)
/// get connection failures for those hosts even with the proxy up,
/// which reads as "the app is offline" though every other app works.
/// A VPN-mode tunnel still works, since it catches traffic below cronet.
///
/// Returns null when no proxy is set, on platforms without the channel
/// (iOS follows the system proxy natively), or when the probe fails.
Future<({String host, int port})?> systemHttpProxy() async {
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
