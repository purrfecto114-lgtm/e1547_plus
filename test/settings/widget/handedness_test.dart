import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

void main() {
  late Settings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await Settings.getInstance();
  });

  Widget scoped(Widget child) => Provider<Settings>.value(
    value: settings,
    child: LayoutMirrorScope(
      child: HandednessScope(child: MaterialApp(home: child)),
    ),
  );

  Future<double> fabLeft(WidgetTester tester) async {
    await tester.pumpWidget(
      scoped(
        AdaptiveScaffold(
          body: const SizedBox.expand(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tester.getTopLeft(find.byType(FloatingActionButton)).dx;
  }

  testWidgets('the fab floats at the end for right handed use', (tester) async {
    final double screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(await fabLeft(tester), greaterThan(screenWidth / 2));
  });

  testWidgets('the fab floats at the start for left handed use', (
    tester,
  ) async {
    settings.handedness.value = Handedness.left;
    final double screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(await fabLeft(tester), lessThan(screenWidth / 2));
  });

  testWidgets('a bubble rests on the side of the preferred hand', (
    tester,
  ) async {
    Widget overlay(HorizontalDirection side) => MaterialApp(
      home: BubbleOverlay(
        side: side,
        bubbles: const [
          OverlayBubble(
            id: 'bubble',
            size: 40,
            child: SizedBox.square(dimension: 40, key: Key('bubble')),
          ),
        ],
        child: const SizedBox.expand(),
      ),
    );
    final double screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;

    await tester.pumpWidget(overlay(HorizontalDirection.right));
    expect(
      tester.getTopLeft(find.byKey(const Key('bubble'))).dx,
      greaterThan(screenWidth / 2),
    );

    await tester.pumpWidget(overlay(HorizontalDirection.left));
    expect(
      tester.getTopLeft(find.byKey(const Key('bubble'))).dx,
      lessThan(screenWidth / 2),
    );
  });

  testWidgets('the layout mirror switch flips the app direction', (
    tester,
  ) async {
    // The mirror scope sits inside the MaterialApp's builder in the app:
    // the app widget installs its own Directionality from the locale,
    // which would override a mirror above it.
    Widget app() => Provider<Settings>.value(
      value: settings,
      child: MaterialApp(
        builder: (context, child) => LayoutMirrorScope(child: child!),
        home: const Text('probe', key: Key('probe')),
      ),
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    // The switch defaults to off: the layout stays left-to-right.
    expect(
      Directionality.of(tester.element(find.byKey(const Key('probe')))),
      TextDirection.ltr,
    );

    settings.layoutMirror.value = true;
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byKey(const Key('probe')))),
      TextDirection.rtl,
    );
  });
}
