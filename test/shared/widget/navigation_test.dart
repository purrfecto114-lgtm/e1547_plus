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
    // Mirrors the real HotPage, which embeds a PostsPage of its own: the
    // inner page's drawer entry must not steal Hot's highlight.
    return const RouterDrawerEntry<_HotStub>(child: _SearchStub());
  }
}

class _SearchStub extends StatelessWidget {
  const _SearchStub();

  @override
  Widget build(BuildContext context) {
    // Mirrors the real PostsPage, whose drawer entry lives inside the
    // page itself.
    return const RouterDrawerEntry<_SearchStub>(
      child: Scaffold(
        appBar: DefaultAppBar(title: Text('search-title')),
        drawer: RouterDrawer(),
        body: Text('search-body'),
      ),
    );
  }
}

class _DetailStub extends StatelessWidget {
  const _DetailStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: DefaultAppBar(title: Text('detail-title')),
      drawer: RouterDrawer(),
      body: Text('detail-body'),
    );
  }
}

class _PushCounter extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
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
  late _PushCounter observer;

  Future<void> pumpApp(WidgetTester tester) async {
    observer = _PushCounter();
    await tester.pumpWidget(
      NavigationProvider(
        destinations: [
          // No explicit type arguments: the destinations infer their
          // type from the builder's page, exactly like the real ones do.
          // Home and Hot here keep the non-tab unique shape that the
          // follow sections (Favorites, Pools, ...) still use.
          NamedRouterDrawerDestination(
            name: 'Home',
            icon: const Icon(Icons.home),
            path: '/',
            builder: (_) => const _HomeStub(),
            unique: true,
          ),
          NamedRouterDrawerDestination(
            name: 'Hot',
            icon: const Icon(Icons.local_fire_department),
            path: '/hot',
            builder: (_) => const _HotStub(),
            unique: true,
          ),
          NamedRouterDrawerDestination(
            name: 'Search',
            icon: const Icon(Icons.search),
            path: '/search',
            builder: (_) => const _SearchStub(),
            unique: true,
            tab: true,
          ),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorObservers: [observer],
            routes: {
              ...context.watch<RouterDrawerController>().routes,
              '/detail': (_) => const _DetailStub(),
            },
          ),
        ),
      ),
    );
    await tester.pump();
  }

  NavigatorState navigatorOf(WidgetTester tester) =>
      tester.state<NavigatorState>(find.byType(Navigator).first);

  testWidgets(
    'backing out of a drawer section returns home instead of leaving the app',
    (tester) async {
      await pumpApp(tester);
      expect(find.text('home-body'), findsOneWidget);

      await openDestination(tester, 'Hot');
      expect(find.text('search-body'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('home-body'), findsOneWidget);
      expect(find.text('search-body'), findsNothing);
    },
  );

  testWidgets('tapping the current section does not stack a duplicate', (
    tester,
  ) async {
    await pumpApp(tester);

    await openDestination(tester, 'Home');
    expect(find.text('home-body'), findsOneWidget);

    // Re-tapping the section on screen must not enter it again: every
    // duplicate push replayed the enter animation and left the page one
    // pop deeper than before.
    final pushes = observer.pushes;
    await openDestination(tester, 'Home');
    expect(observer.pushes, pushes);
    expect(navigatorOf(tester).canPop(), isFalse);
    expect(find.text('home-body'), findsOneWidget);
  });

  testWidgets('a tab section swaps the stack and keeps the drawer button', (
    tester,
  ) async {
    await pumpApp(tester);

    await openDestination(tester, 'Search');
    expect(find.text('search-body'), findsOneWidget);
    // The tab is the first route: nothing to pop back to, so the appbar
    // keeps the drawer button instead of a back arrow.
    expect(navigatorOf(tester).canPop(), isFalse);
    expect(find.byType(BackButton), findsNothing);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('re-tapping a tab section does not replay the swap', (
    tester,
  ) async {
    await pumpApp(tester);

    await openDestination(tester, 'Search');
    final pushes = observer.pushes;
    await openDestination(tester, 'Search');

    expect(observer.pushes, pushes);
    expect(navigatorOf(tester).canPop(), isFalse);
    expect(find.text('search-body'), findsOneWidget);
  });

  testWidgets('tapping a tab section over a pushed page returns to it', (
    tester,
  ) async {
    await pumpApp(tester);

    await openDestination(tester, 'Search');
    navigatorOf(tester).pushNamed('/detail');
    await tester.pumpAndSettle();
    expect(find.text('detail-body'), findsOneWidget);

    await openDestination(tester, 'Search');
    expect(find.text('search-body'), findsOneWidget);
    expect(find.text('detail-body'), findsNothing);
    expect(navigatorOf(tester).canPop(), isFalse);
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

  testWidgets('a tab section is highlighted while it is on screen', (
    tester,
  ) async {
    await pumpApp(tester);

    await openDestination(tester, 'Search');
    tester.state<ScaffoldState>(find.byType(Scaffold).last).openDrawer();
    await tester.pumpAndSettle();
    final searchTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Search'),
    );
    expect(searchTile.selected, isTrue);
  });
}
