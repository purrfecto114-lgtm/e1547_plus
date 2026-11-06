import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _HomeStub extends StatelessWidget {
  const _HomeStub();

  @override
  Widget build(BuildContext context) {
    return const RouterDrawerEntry<_HomeStub>(
      child: Scaffold(
        appBar: DefaultAppBar(title: Text('home-title')),
        drawer: RouterDrawer(),
        body: Text('home-body'),
      ),
    );
  }
}

class _HotStub extends StatelessWidget {
  const _HotStub();

  @override
  Widget build(BuildContext context) {
    return const RouterDrawerEntry<_HotStub>(
      child: Scaffold(
        appBar: DefaultAppBar(title: Text('hot-title')),
        drawer: RouterDrawer(),
        body: Text('hot-body'),
      ),
    );
  }
}

/// Opens the drawer of the page on top of the stack and taps the
/// destination named [name].
Future<void> openDestination(WidgetTester tester, String name) async {
  tester.state<ScaffoldState>(find.byType(Scaffold).last).openDrawer();
  await tester.pumpAndSettle();
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      NavigationProvider(
        destinations: [
          NamedRouterDrawerDestination<_HomeStub>(
            name: 'Home',
            icon: const Icon(Icons.home),
            path: '/',
            builder: (_) => const _HomeStub(),
            unique: true,
          ),
          NamedRouterDrawerDestination<_HotStub>(
            name: 'Hot',
            icon: const Icon(Icons.local_fire_department),
            path: '/hot',
            builder: (_) => const _HotStub(),
            unique: true,
          ),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routes: context.watch<RouterDrawerController>().routes,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'backing out of a drawer section returns home instead of leaving the app',
    (tester) async {
      await pumpApp(tester);
      expect(find.text('home-body'), findsOneWidget);

      await openDestination(tester, 'Hot');
      expect(find.text('hot-body'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('home-body'), findsOneWidget);
      expect(find.text('hot-body'), findsNothing);
    },
  );

  testWidgets('tapping the current section keeps the app rooted', (
    tester,
  ) async {
    await pumpApp(tester);

    await openDestination(tester, 'Home');
    expect(find.text('home-body'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('home-body'), findsOneWidget);
  });

  testWidgets('the drawer highlights the section on top of the stack', (
    tester,
  ) async {
    await pumpApp(tester);

    await openDestination(tester, 'Hot');
    // Open the drawer of the hot page; its tile is selected.
    tester.state<ScaffoldState>(find.byType(Scaffold).last).openDrawer();
    await tester.pumpAndSettle();
    ListTile hotTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Hot'),
    );
    expect(hotTile.selected, isTrue);

    // The open drawer takes the first pop; the page takes the second.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    // Back on home, the drawer highlights home again.
    tester.state<ScaffoldState>(find.byType(Scaffold).last).openDrawer();
    await tester.pumpAndSettle();
    hotTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Hot'));
    expect(hotTile.selected, isFalse);
  });
}
