import 'package:dio/io.dart';
import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:notified_preferences/notified_preferences.dart';

import '../../_support/harness.dart';

/// Locks in the round 21 proxy rebuild: the proxy a client is built for
/// is a provider dependency, so a proxy switched on after boot rebuilds
/// every client onto the proxied stack without a restart — and an
/// unchanged proxy rebuilds nothing.
///
/// The identity and traits layers wrap database roundtrips that only
/// complete in real time, so the boot alternates real-time waits with
/// the frames that advance the loading layers (the pattern documented
/// in test/identity/widget/loading_test.dart).
void main() {
  late AppStorage storage;
  late Settings settings;

  setUpAll(() async {
    await initializeTestApp();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = AppStorage(
      preferences: await SharedPreferences.getInstance(),
      temporaryFiles: '.',
      queryCache: CachedQuery.asNewInstance(),
      sqlite: AppDatabase(NativeDatabase.memory()),
    );
    settings = Settings(storage.preferences);
  });

  tearDown(() async {
    systemProxy.value = null;
    await storage.close();
  });

  Widget clientTree(List<Client> built) => MaterialApp(
    localizationsDelegates: testLocalizations,
    home: LoadingShell(
      child: LoadingCore(
        child: MultiProvider(
          providers: [
            Provider<AppStorage>.value(value: storage),
            Provider<Settings>.value(value: settings),
            Provider<ClientFactory>.value(value: ClientFactory()),
            IdentityClientProvider(),
            TraitsClientProvider(),
            // The resolved system proxy as a dependency of the client:
            // this is the piece round 21 wired in, and the rebuild below
            // is the behavior it promised.
            ValueListenableProvider<ProxyConfig?>.value(value: systemProxy),
            ClientProvider(),
          ],
          child: Scaffold(
            body: Builder(
              builder: (context) {
                built.add(context.watch<Client>());
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    ),
  );

  // The providers only build below the loading layers once identity and
  // traits have activated; each layer needs its own frames to settle.
  Future<void> pumpUntilBuilt(WidgetTester tester, List<Client> built) async {
    for (var round = 0; round < 10 && built.isEmpty; round++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(built, isNotEmpty, reason: 'the client tree never finished booting');
  }

  displayTest('a proxy switched on after boot rebuilds the client onto it', (
    tester,
  ) async {
    final List<Client> built = [];
    await tester.pumpWidget(clientTree(built));
    await pumpUntilBuilt(tester, built);

    final Client initial = built.last;
    expect(initial.disposed, isFalse);
    // No proxy at boot: the api dio rides the native (cronet) stack.
    expect(initial.dio.httpClientAdapter, isA<NativeAdapter>());

    systemProxy.value = (host: '127.0.0.1', port: 7890);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The client is a new instance, on the proxied stack, with the same
    // identity — and the one built for the proxyless stack is retired.
    expect(built.last, isNot(same(initial)));
    expect(built.last.dio.httpClientAdapter, isA<IOHttpClientAdapter>());
    expect(built.last.identity.id, initial.identity.id);
    expect(initial.disposed, isTrue);

    // Re-assigning the same proxy notifies nobody: no rebuild, no swap.
    final Client proxied = built.last;
    final int builds = built.length;
    systemProxy.value = (host: '127.0.0.1', port: 7890);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(built.length, builds);
    expect(built.last, same(proxied));
    expect(proxied.disposed, isFalse);

    // Losing the proxy again rebuilds back onto the direct stack.
    systemProxy.value = null;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(built.last, isNot(same(proxied)));
    expect(built.last.dio.httpClientAdapter, isA<NativeAdapter>());
    expect(proxied.disposed, isTrue);
  });
}
