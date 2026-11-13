import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a disposed preview provider removes its overlay entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) =>
                const Scaffold(body: Center(child: Text('root'))),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(LinkOverlay), findsNothing);

    // Opening and closing routes with link preview providers must not
    // accumulate overlay entries: every recycled DText leaves its
    // preview behind otherwise.
    for (var i = 0; i < 5; i++) {
      final NavigatorState navigator = tester.state(
        find.byType(Navigator).first,
      );
      navigator.push(
        MaterialPageRoute(
          builder: (context) =>
              Scaffold(body: LinkPreviewProvider(child: Text('page $i'))),
        ),
      );
      await tester.pumpAndSettle();

      // Exactly one preview entry: this page's.
      expect(find.byType(LinkOverlay), findsOneWidget);

      navigator.pop();
      await tester.pumpAndSettle();

      // The popped page's entry left the overlay with it.
      expect(find.byType(LinkOverlay), findsNothing);
    }
  });
}
