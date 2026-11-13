import 'dart:io';

import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../_support/harness.dart';

void main() {
  late AppDatabase sqlite;
  late IdentityClient client;

  setUpAll(() => initializeTestApp());

  setUp(() async {
    sqlite = AppDatabase(NativeDatabase.memory());
    client = IdentityClient(database: sqlite);
  });

  tearDown(() async {
    client.dispose();
    await sqlite.close();
  });

  /// Database calls only complete in real time, so every read and write
  /// below is wrapped in tester.runAsync like the login dialog tests do.
  Future<List<Identity>> identities(WidgetTester tester) async =>
      await tester.runAsync(() => client.page(page: 1, limit: 9999)) ??
      const [];

  /// Pumps an [AccountForm] and returns the localizations resolved below
  /// it, so assertions can use the same strings the form displays.
  Future<AppLocalizations> pumpForm(
    WidgetTester tester, {
    Identity? identity,
    String initialHost = 'e621.net',
    VoidCallback? onSubmitted,
    Future<CredentialCheckResult> Function({
      required String host,
      Map<String, String>? headers,
    })?
    verifier,
  }) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ClientFactory>.value(value: ClientFactory()),
          ChangeNotifierProvider<IdentityClient>.value(value: client),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                l10n = AppLocalizations.of(context);
                return SingleChildScrollView(
                  child: AccountForm(
                    identity: identity,
                    initialHost: initialHost,
                    onSubmitted: onSubmitted,
                    verifier: verifier ?? checkCredentials,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return l10n;
  }

  /// Lets the login chain of a mounted [LoginLoadingDialog] run to
  /// completion in real time.
  Future<void> runLoginChain(WidgetTester tester) async {
    await tester.pump(); // the gate pops, the loading dialog mounts
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('creating a guest identity confirms the age gate', (
    tester,
  ) async {
    final l10n = await pumpForm(tester);

    await tester.tap(find.text(l10n.identityGuest));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.identityBrowseAnonymously));
    await tester.pumpAndSettle();

    // The gate stands between the form and the login, guests included.
    expect(find.text(l10n.adultGateTitle), findsOneWidget);
    expect(find.text(l10n.adultGateBody), findsOneWidget);

    // Denying returns to the form without creating anything.
    await tester.tap(find.text(l10n.adultGateDeny));
    await tester.pumpAndSettle();
    expect(find.text(l10n.adultGateTitle), findsNothing);
    expect(find.text(l10n.identityBrowseAnonymously), findsOneWidget);
    expect(await identities(tester), isEmpty);
  });

  testWidgets('a confirmed gate continues into the guest login', (
    tester,
  ) async {
    var done = false;
    final l10n = await pumpForm(tester, onSubmitted: () => done = true);

    await tester.tap(find.text(l10n.identityGuest));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.identityBrowseAnonymously));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.adultGateConfirm));
    await runLoginChain(tester);

    expect(done, isTrue);
    List<Identity> all = await identities(tester);
    expect(all, hasLength(1));
    expect(all.single.username, isNull);
    expect(client.identity.id, all.single.id);
  });

  testWidgets('a signed-in identity confirms the age gate before its login', (
    tester,
  ) async {
    var done = false;
    final l10n = await pumpForm(
      tester,
      onSubmitted: () => done = true,
      verifier: ({required host, headers}) async => CredentialCheckResult.ok,
    );

    await tester.tap(find.text(l10n.identitySignIn));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), 'user_34');
    await tester.enterText(find.byType(TextFormField).at(2), 'a' * 24);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.identityLogin));
    await tester.pumpAndSettle();

    expect(find.text(l10n.adultGateTitle), findsOneWidget);

    // Denying aborts before any credential verification runs.
    await tester.tap(find.text(l10n.adultGateDeny));
    await tester.pumpAndSettle();
    expect(find.byType(LoginLoadingDialog), findsNothing);
    expect(await identities(tester), isEmpty);

    // Confirming continues into the login and stores the credentials.
    await tester.tap(find.text(l10n.identityLogin));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.adultGateConfirm));
    await runLoginChain(tester);

    expect(done, isTrue);
    List<Identity> all = await identities(tester);
    expect(all, hasLength(1));
    expect(all.single.username, 'user_34');
    expect(all.single.headers?[HttpHeaders.authorizationHeader], isNotNull);
    expect(client.identity.id, all.single.id);
  });

  testWidgets('editing an existing identity skips the age gate', (
    tester,
  ) async {
    late Identity existing;
    await tester.runAsync(() async {
      existing = await client.add(const IdentityRequest(host: 'e621.net'));
    });
    var done = false;
    final l10n = await pumpForm(
      tester,
      identity: existing,
      onSubmitted: () => done = true,
    );

    await tester.tap(find.text(l10n.actionSave));
    await runLoginChain(tester);

    expect(find.text(l10n.adultGateTitle), findsNothing);
    expect(done, isTrue);
    expect(await identities(tester), hasLength(1));
  });
}
