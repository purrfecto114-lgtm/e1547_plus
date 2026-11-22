import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:provider/provider.dart';

import '../../_support/harness.dart';
import '../../_support/images.dart';

void main() {
  late ValueNotifier<Traits> traits;
  late AppDatabase sqlite;
  late Settings settings;

  setUpAll(() async {
    await initializeTestApp();
    sqlite = AppDatabase(NativeDatabase.memory());
  });

  tearDownAll(() => sqlite.close());

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    traits = ValueNotifier(
      const Traits(
        id: 1,
        userId: null,
        denylist: [],
        homeTags: '',
        avatar: null,
        perPage: null,
      ),
    );
    settings = Settings(await SharedPreferences.getInstance());
  });

  tearDown(() {
    traits.dispose();
  });

  Future<Client> offlineClient() async => Client(
    identity: const Identity(
      id: 1,
      host: 'https://example.invalid',
      username: null,
      headers: null,
    ),
    traits: traits,
    storage: AppStorage(
      preferences: await SharedPreferences.getInstance(),
      temporaryFiles: '.',
      queryCache: CachedQuery.asNewInstance()
        ..config(
          config: const GlobalQueryConfig(
            cacheDuration: Duration(milliseconds: 1),
          ),
        ),
      sqlite: sqlite,
    ),
  );

  Future<void> pumpPage(WidgetTester tester, Client client) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Client>.value(value: client),
          Provider<BaseCacheManager>.value(value: const NoImageCacheManager()),
          Provider<Settings>.value(value: settings),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PostsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  displayTest('a first load offline shows the offline state', (tester) async {
    final client = await offlineClient();
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException.connectionError(
              requestOptions: options,
              reason: 'The network is unavailable',
            ),
            true,
          );
        },
      ),
    );
    await pumpPage(tester, client);

    expect(find.text('当前离线'), findsOneWidget);
    expect(find.text('帖子加载失败'), findsNothing);
  });
}
