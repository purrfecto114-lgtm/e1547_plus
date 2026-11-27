import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';

/// Tracks every request a [Dio] has in flight, so its owner can stop
/// them before tearing the network stack down.
///
/// The native adapters hand their requests to a platform engine —
/// Cronet on Android — that refuses to shut down while requests are
/// still running. Cancelling the tracked requests first lets every
/// one of them finish its teardown, so closing the engine afterwards
/// is clean instead of an exception.
class InFlightInterceptor extends Interceptor {
  final Set<CancelToken> _tokens = {};

  /// The requests this interceptor has seen start and not finish.
  int get count => _tokens.length;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // A request whose caller already holds a token is tracked through
    // it; everything else gets one of ours so it can still be stopped.
    final CancelToken token = options.cancelToken ??= CancelToken();
    if (_tokens.add(token)) {
      // dio unrolls the interceptor chain with copies of the options —
      // an error's requestOptions does not even carry the token — so a
      // cancelled request removes itself through its own token instead
      // of by what the chain hands back. The remaining bookkeeping for
      // requests that finish normally lives in onResponse/onError.
      token.whenCancel.then((_) => _tokens.remove(token));
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _remove(response.requestOptions.cancelToken);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _remove(err.requestOptions.cancelToken);
    handler.next(err);
  }

  void _remove(CancelToken? token) {
    // Null when the options copy an error unwound with dropped the
    // token; a token the caller replaced stays tracked by its own
    // request's completion or cancellation.
    if (token != null) _tokens.remove(token);
  }

  /// Cancels every tracked request.
  ///
  /// Called when the dio instance is about to close: the cancelled
  /// requests unwind through their own error paths, so callers see the
  /// cancellations they already know how to handle instead of the
  /// engine disappearing under them. Cancelling also removes each
  /// token from tracking, which is what brings [count] back to zero.
  void cancelAll() {
    for (final token in List.of(_tokens)) {
      token.cancel();
    }
  }
}

extension DioShutdown on Dio {
  /// Cancels every tracked request, waits for the cancellations to
  /// land, then closes the dio.
  ///
  /// Every owner closing a dio goes through this: the platform engine
  /// behind the native adapter — Cronet on Android — refuses to shut
  /// down while requests are still running. Cancelling alone is not
  /// enough: the cancellation unwinds asynchronously on the platform's
  /// network thread, and a shutdown issued right after it still finds
  /// the requests retiring (a connection-reset storm widens that
  /// window). Draining first — bounded, so a wedged request cannot
  /// hold the engine open forever — and swallowing a shutdown race
  /// that survives the drain keeps disposal a cleanup step instead of
  /// an uncaught exception.
  Future<void> shutdown() async {
    for (final InFlightInterceptor inFlight
        in interceptors.whereType<InFlightInterceptor>()) {
      inFlight.cancelAll();
    }
    const drain = Duration(seconds: 3);
    final deadline = DateTime.now().add(drain);
    while (interceptors.whereType<InFlightInterceptor>().any(
      (inFlight) => inFlight.count > 0,
    )) {
      if (DateTime.now().isAfter(deadline)) break;
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
    try {
      close();
    } on Object {
      // a request that slipped past the drain is still finishing its
      // teardown on the platform thread; the engine frees with it, and
      // swallowing here keeps a disposal race from surfacing as an
      // uncaught exception — the dio is going away either way
    }
  }
}

/// Create a default [Dio] instance for the given [Identity].
Dio createDefaultDio(
  Identity identity, {
  CachedQuery? queryCache,
  ({String host, int port})? proxy,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: normalizeHostUrl(identity.host),
      headers: {
        HttpHeaders.userAgentHeader: AppInfo.instance.userAgent,
        ...?identity.headers,
      },
      sendTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  // The cronet engine ignores the android system proxy; behind one, hosts
  // that only resolve through it fail as if the device were offline. When
  // a proxy is known, the io adapter routes through it instead.
  dio.httpClientAdapter = proxyAwareAdapter(proxy);
  dio.interceptors.add(InFlightInterceptor());
  dio.interceptors.add(NewlineReplaceInterceptor());
  dio.interceptors.add(LoggingDioInterceptor());
  dio.interceptors.add(ClientExceptionInterceptor());
  if (queryCache != null) {
    dio.queryCache = queryCache;
  }
  dio.queryIdentity = identity.id;
  return dio;
}

/// Create the [Dio] instance that downloads media files.
///
/// It deliberately carries no identity credentials: media URLs come from
/// API responses and may point at any host, so the account's
/// `Authorization` header or cookies must never travel to them. Only the
/// user agent rides along, which servers need for content negotiation.
Dio createMediaDio() {
  final dio = Dio(
    BaseOptions(
      headers: {HttpHeaders.userAgentHeader: AppInfo.instance.userAgent},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  // Media hosts sit behind the same region blocks as the api, so the
  // transfer honours the resolved proxy like every other client.
  dio.httpClientAdapter = proxyAwareAdapter(systemProxy.value);
  dio.interceptors.add(InFlightInterceptor());
  dio.interceptors.add(LoggingDioInterceptor());
  dio.interceptors.add(ClientExceptionInterceptor());
  return dio;
}
