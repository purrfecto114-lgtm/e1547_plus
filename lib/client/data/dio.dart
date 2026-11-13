import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

/// Create a default [Dio] instance for the given [Identity].
Dio createDefaultDio(Identity identity, {CachedQuery? queryCache}) {
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
  dio.httpClientAdapter = NativeAdapter();
  dio.interceptors.add(NewlineReplaceInterceptor());
  dio.interceptors.add(LoggingDioInterceptor());
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
  dio.httpClientAdapter = NativeAdapter();
  dio.interceptors.add(LoggingDioInterceptor());
  return dio;
}
