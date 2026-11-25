import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

import '../../_support/environment.dart';
import '../../_support/harness.dart';

void main() {
  setUpAll(initializeTestApp);

  test('the media client carries no credentials', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final identity = await IdentityRepository(db).add(
      const IdentityRequest(
        host: 'e621.net',
        username: 'tester',
        headers: {
          'authorization': 'Basic dXNlcjprZXk=',
          'cookie': 'session=secret',
        },
      ),
    );

    final api = createDefaultDio(identity);
    final media = createMediaDio();

    // The account's client sends its credentials to its own host.
    final apiKeys = api.options.headers.keys.map((k) => k.toLowerCase());
    expect(apiKeys, containsAll(['authorization', 'cookie']));

    // The media client deliberately travels without them: media URLs
    // come from API responses and may point at any host, so the
    // account's secrets must never reach another origin through them.
    final mediaKeys = media.options.headers.keys.map((k) => k.toLowerCase());
    expect(mediaKeys, isNot(contains('authorization')));
    expect(mediaKeys, isNot(contains('cookie')));
    expect(mediaKeys, contains('user-agent'));

    // The account's client also has a base URL of its own host; the media
    // client has none, so absolute URLs stay absolute.
    expect(api.options.baseUrl, isNotEmpty);
    expect(media.options.baseUrl, isEmpty);
  });

  test('every dio the app creates tracks its in-flight requests', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const IdentityRequest identity = IdentityRequest(host: 'e621.net');
    final api = createDefaultDio(await IdentityRepository(db).add(identity));
    final media = createMediaDio();

    for (final dio in [api, media]) {
      expect(
        dio.interceptors.whereType<InFlightInterceptor>(),
        isNotEmpty,
        reason:
            'every dio must be able to cancel its in-flight requests '
            'before its engine closes',
      );
    }
  });

  test('disposing a client cancels its in-flight requests', () async {
    final env = await TestEnvironment.start();
    addTearDown(env.dispose);

    // The posts page is the request the follow sync would have running
    // when an identity switch happens; the fake server holds it back,
    // so it is genuinely in flight while the client goes away.
    env.fake.stallFor = const Duration(seconds: 30);

    final Completer<Object?> outcome = Completer<Object?>();
    unawaited(
      env.client.posts.page().then(
        outcome.complete,
        onError: (Object e) => outcome.complete(e),
      ),
    );
    // Let the request start travelling before the client goes away.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(env.client.inFlight.count, greaterThan(0));

    // Disposing the client must cancel the request through its own
    // cancellation path instead of closing the engine under it.
    env.client.dispose();

    final Object? error = await outcome.future;
    expect(error, isA<DioException>());
    expect(CancelToken.isCancel(error! as DioException), isTrue);
    expect(env.client.inFlight.count, 0);
  });

  group('the resolved proxy decides the http adapter', () {
    ({String host, int port})? saved;

    setUp(() {
      saved = systemProxy.value;
      addTearDown(() => systemProxy.value = saved);
    });

    test('the api client honours the proxy it is given', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final identity = await IdentityRepository(
        db,
      ).add(const IdentityRequest(host: 'e621.net'));
      expect(
        createDefaultDio(
          identity,
          proxy: (host: '127.0.0.1', port: 7890),
        ).httpClientAdapter,
        isA<IOHttpClientAdapter>(),
      );
      expect(
        createDefaultDio(identity).httpClientAdapter,
        isA<NativeAdapter>(),
      );
    });

    test('the media client honours the proxy known at creation', () {
      systemProxy.value = (host: '127.0.0.1', port: 7890);
      expect(createMediaDio().httpClientAdapter, isA<IOHttpClientAdapter>());
      systemProxy.value = null;
      expect(createMediaDio().httpClientAdapter, isA<NativeAdapter>());
    });
  });
}
