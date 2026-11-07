import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:relative_time/relative_time.dart';

import '../_support/fake_e621.dart';
import '../_support/harness.dart';
import '../_support/images.dart';

/// Renders the settings page and the pin lock at a phone sized surface and
/// stores golden images, so reported layout regressions can be compared
/// against real device screenshots pixel by pixel.
void main() {
  late FakeE621 fake;
  late Client client;
  late ValueNotifier<Traits> traits;
  late AppDatabase sqlite;
  late Settings settings;
  late IdentityClient identities;
  late TraitsClient identityTraits;

  setUpAll(() => initializeTestApp());

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/local_auth'),
          (call) async => call.method == 'getAvailableBiometrics'
              ? <String>['fingerprint']
              : null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('e1547/biometrics'),
          (call) async => call.method == 'fingerprintState'
              ? {'hardware': true, 'enrolled': true}
              : null,
        );
    SharedPreferences.setMockInitialValues({});
    sqlite = AppDatabase(NativeDatabase.memory());
    fake = await FakeE621.start();
    identities = IdentityClient(database: sqlite);
    final identity = await identities.add(IdentityRequest(host: fake.url));
    await identities.activate(identity.id);
    identityTraits = TraitsClient(database: sqlite);
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
    client = Client(
      identity: Identity(id: 1, host: fake.url, username: null, headers: null),
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
    client.dio.options.connectTimeout = null;
    client.dio.options.receiveTimeout = null;
    settings = Settings(await SharedPreferences.getInstance());
  });

  tearDown(() async {
    traits.dispose();
    identities.dispose();
    identityTraits.dispose();
    client.dispose();
    await fake.stop();
    await sqlite.close();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    required Widget home,
    required Size size,
    required double dpr,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = dpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<Client>.value(value: client),
            Provider<Settings>.value(value: settings),
            ChangeNotifierProvider<IdentityClient>.value(value: identities),
            ChangeNotifierProvider<TraitsClient>.value(value: identityTraits),
            Provider<BaseCacheManager>.value(
              value: const NoImageCacheManager(),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              GlobalCupertinoLocalizations.delegate,
              RelativeTimeLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: RepaintBoundary(child: home),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  void reportHeaders(WidgetTester tester) {
    final headers = tester.widgetList<SectionHeader>(
      find.byType(SectionHeader),
    );
    int i = 0;
    for (final header in find.byType(SectionHeader).evaluate()) {
      final box = header.renderObject! as RenderBox;
      final pos = box.localToGlobal(Offset.zero);
      // ignore: avoid_print
      print(
        'header[$i] "${headers.elementAt(i).title}" '
        'left=${pos.dx.toStringAsFixed(1)} top=${pos.dy.toStringAsFixed(1)} '
        'width=${box.size.width.toStringAsFixed(1)}',
      );
      i++;
    }
  }

  Future<void> golden(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('_goldens/$name.png'),
    );
  }

  testWidgets('settings page matches device geometry', (tester) async {
    await pumpApp(
      tester,
      home: const SettingsPage(),
      size: const Size(1080, 1920),
      dpr: 3,
    );
    reportHeaders(tester);
    await golden(tester, 'settings_zh_1080x1920_dpr3');
  });

  testWidgets('pin lock matches device geometry', (tester) async {
    await pumpApp(
      tester,
      home: Builder(
        builder: (context) => PinLock(
          title: AppLocalizations.of(context).lockEnterNewPin,
          confirmTitle: AppLocalizations.of(context).lockConfirmNewPin,
          onCompleted: (_) {},
          onCancelled: () {},
        ),
      ),
      size: const Size(1080, 1920),
      dpr: 3,
    );
    await golden(tester, 'pinlock_zh_1080x1920_dpr3');
  });
}
