import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The classic header resolves its strings from the package's bundled
  // localizations, so the assertions match the English defaults.
  Future<void> pumpList(
    WidgetTester tester,
    Future<bool> Function() onRefresh,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PullToRefresh(
            onRefresh: onRefresh,
            child: ListView(
              children: const [
                SizedBox(height: 400, child: Center(child: Text('content'))),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // The refresh is triggered like the widget itself triggers it on
  // desktop: through the F5 shortcut, which drives the same controller
  // as a pull gesture would.
  Future<void> triggerRefresh(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.f5);
    // Let the header appear and the refresh future run before the
    // header's completion timeout collapses it back to idle.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('reports a completed refresh on success', (tester) async {
    await pumpList(tester, () async => true);
    await triggerRefresh(tester);

    expect(find.textContaining('ompleted'), findsOneWidget);
    expect(find.textContaining('ailed'), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('reports a failed refresh when the callback returns false', (
    tester,
  ) async {
    await pumpList(tester, () async => false);
    await triggerRefresh(tester);

    expect(find.textContaining('ailed'), findsOneWidget);
    expect(find.textContaining('ompleted'), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('reports a failed refresh when the callback throws', (
    tester,
  ) async {
    await pumpList(tester, () async => throw Exception('offline'));
    await triggerRefresh(tester);

    expect(find.textContaining('ailed'), findsOneWidget);
    expect(find.textContaining('ompleted'), findsNothing);
    await tester.pumpAndSettle();
  });
}
