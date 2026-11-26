import 'package:collection/collection.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouterDrawerDestination {
  const RouterDrawerDestination({
    required this.path,
    required this.builder,
    this.unique = false,
    this.tab = false,
  });

  final String path;
  final WidgetBuilder builder;
  final bool unique;

  /// A section that behaves like a tab: switching to it swaps the whole
  /// navigation stack in place, without a back button — the drawer button
  /// stays. The swap still enters the new section with the app's standard
  /// page transition: the replaced stack is removed only once the enter
  /// animation has covered it, so switching sections reads as a
  /// transition while a duplicate entry of the section on screen does
  /// nothing at all.
  ///
  /// Set [unique] alongside it so the drawer highlights the section while
  /// it is on screen.
  final bool tab;
}

typedef RouterDrawerSettingCallback = bool Function(BuildContext context);

class NamedRouterDrawerDestination<T extends Widget>
    extends RouterDrawerDestination {
  const NamedRouterDrawerDestination({
    required this.name,
    this.icon,
    this.group,
    this.visible,
    this.enabled,
    required super.path,
    required T Function(BuildContext context) builder,
    super.unique,
    super.tab,
  }) : super(builder: builder);

  final String name;
  final RouterDrawerSettingCallback? visible;
  final RouterDrawerSettingCallback? enabled;
  final Widget? icon;
  final String? group;
}

class RouterDrawerController extends ChangeNotifier {
  RouterDrawerController({required this.destinations, this.drawerHeader}) {
    routes = {for (final e in destinations) e.path: e.builder};
  }

  final List<RouterDrawerDestination> destinations;
  late final Map<String, WidgetBuilder> routes;

  final WidgetBuilder? drawerHeader;

  String? _drawerSelection;

  String? get drawerSelection => _drawerSelection;

  void setDrawerSelection<T extends Widget>({required String? routeName}) {
    NamedRouterDrawerDestination? target = destinations
        .whereType<NamedRouterDrawerDestination<T>>()
        .firstWhereOrNull((e) => e.unique);
    // A section claims the highlight only from its own route: Hot embeds
    // a PostsPage of its own, and that inner page's entry must not flip
    // the highlight to Search from underneath the Hot tab.
    if (target == null || routeName != target.path) return;
    if (_drawerSelection != target.path) {
      _drawerSelection = target.path;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }
}

class NavigationProvider
    extends ChangeNotifierProvider<RouterDrawerController> {
  NavigationProvider({
    super.key,
    required List<RouterDrawerDestination> destinations,
    WidgetBuilder? drawerHeader,
    super.child,
    super.builder,
  }) : super(
         create: (context) => RouterDrawerController(
           destinations: destinations,
           drawerHeader: drawerHeader,
         ),
       );
}

class RouterDrawer extends StatefulWidget {
  const RouterDrawer({super.key});

  @override
  State<RouterDrawer> createState() => _RouterDrawerState();
}

class _RouterDrawerState extends State<RouterDrawer> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  List<NamedRouterDrawerDestination> getDrawerDestinations(
    List<RouterDrawerDestination> destinations,
  ) {
    return destinations
        .whereType<NamedRouterDrawerDestination>()
        .toList()
        .cast<NamedRouterDrawerDestination>();
  }

  @override
  Widget build(BuildContext context) {
    final RouterDrawerController controller = context
        .watch<RouterDrawerController>();

    List<Widget> children = [];
    if (controller.drawerHeader != null) {
      children.add(controller.drawerHeader!(context));
    }

    List<NamedRouterDrawerDestination> destinations = getDrawerDestinations(
      controller.destinations,
    );

    String? currentGroup = destinations.first.group;

    for (final destination in destinations) {
      if (!(destination.visible?.call(context) ?? true)) {
        continue;
      }
      if (destination.group != currentGroup) {
        currentGroup = destination.group;
        children.add(const Divider());
      }
      children.add(
        ListTile(
          enabled: destination.enabled?.call(context) ?? true,
          selected:
              destination.unique &&
              destination.path == controller.drawerSelection,
          title: Text(localizedDestinationName(context, destination.name)),
          leading: destination.icon,
          onTap: () {
            // The section that is already on screen must not be entered
            // again: a duplicate push replayed the enter animation and
            // stacked a second copy of the page on every tap.
            if (ModalRoute.of(context)?.settings.name == destination.path) {
              Scaffold.maybeOf(context)?.closeDrawer();
              return;
            }
            if (destination.tab) {
              Scaffold.maybeOf(context)?.closeDrawer();
              // The swap must not cut the switch to a hard splice: push the
              // section like any other page and let the navigator handle the
              // transition. Everything below is removed without an exit
              // animation, but the navigator defers that removal until the
              // enter animation has covered the old stack — the replaced
              // section stays on screen for the duration of the transition.
              Navigator.of(context).pushNamedAndRemoveUntil(
                destination.path,
                // A tab is the first route: system back on it exits the
                // app, and the appbar keeps the drawer button instead of
                // a back arrow.
                (route) => false,
              );
            } else if (destination.unique) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                destination.path,
                (route) => route.isFirst,
              );
            } else {
              Scaffold.maybeOf(context)?.closeDrawer();
              Navigator.of(context).pushNamed(destination.path);
            }
          },
        ),
      );
    }

    return Drawer(
      child: PrimaryScrollController(
        controller: scrollController,
        child: ListView(children: children),
      ),
    );
  }
}

mixin RouterDrawerEntryWidget<T extends StatefulWidget> on State<T> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isCurrent) {
      context.watch<RouterDrawerController?>()?.setDrawerSelection<T>(
        routeName: ModalRoute.of(context)?.settings.name,
      );
    }
  }
}

class RouterDrawerEntry<T extends Widget> extends StatefulWidget {
  const RouterDrawerEntry({super.key, required this.child});

  final Widget child;

  @override
  State<RouterDrawerEntry<T>> createState() => _RouterDrawerEntryState<T>();
}

class _RouterDrawerEntryState<T extends Widget>
    extends State<RouterDrawerEntry<T>> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isCurrent) {
      context.watch<RouterDrawerController?>()?.setDrawerSelection<T>(
        routeName: ModalRoute.of(context)?.settings.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AnyRouteObserver extends RouteObserver<Route<Object?>> {}

class DefaultRouteObserver extends Provider<AnyRouteObserver> {
  DefaultRouteObserver({super.key, super.child})
    : super(create: (context) => AnyRouteObserver());
}

mixin DefaultRouteAware<T extends StatefulWidget> on State<T>
    implements RouteAware {
  AnyRouteObserver? _routeObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver?.unsubscribe(this);
    _routeObserver = context.watch<AnyRouteObserver>();
    _routeObserver!.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void reassemble() {
    super.reassemble();
    _routeObserver?.unsubscribe(this);
    _routeObserver = context.read<AnyRouteObserver>();
    _routeObserver!.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {}

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}
}

/// Drawer destination names double as stable keys.
///
/// This maps them to their localized display names.
String localizedDestinationName(BuildContext context, String name) =>
    switch (name) {
      'Home' => AppLocalizations.of(context).navHome,
      'Hot' => AppLocalizations.of(context).navHot,
      'Search' => AppLocalizations.of(context).navSearch,
      'Favorites' => AppLocalizations.of(context).navFavorites,
      'Timeline' => AppLocalizations.of(context).navTimeline,
      'Subscriptions' => AppLocalizations.of(context).navSubscriptions,
      'Bookmarks' => AppLocalizations.of(context).navBookmarks,
      'Pools' => AppLocalizations.of(context).navPools,
      'Forum' => AppLocalizations.of(context).navForum,
      'History' => AppLocalizations.of(context).navHistory,
      'Tasks' => AppLocalizations.of(context).navTasks,
      'Settings' => AppLocalizations.of(context).navSettings,
      'About' => AppLocalizations.of(context).navAbout,
      _ => name,
    };
