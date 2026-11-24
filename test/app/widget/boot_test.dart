import 'dart:async';

import 'package:e1547/app/app.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locks in the boot path the 22.9.5 release broke: the loading shell
/// must let its child build while the overlay is up, because the very
/// widget that clears the overlay's loading state lives inside that
/// child. A shell that hides its child until loading clears boots into
/// an un-dismissable spinner.
void main() {
  testWidgets('the loading shell clears its overlay while booting', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoadingShell(child: LoadingCore(child: Text('booted content'))),
      ),
    );

    // The shell starts in its loading state, with the overlay showing.
    expect(find.byType(HexagonalLoadingIndicator), findsOneWidget);

    // Boot proceeds: the LoadingCore below the overlay clears the
    // loading state after the first frame, and the overlay gives way
    // to the content. A shell that refuses to build its child while
    // loading never reaches this — the test hangs on the first pump.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(HexagonalLoadingIndicator), findsNothing);
    expect(find.text('booted content'), findsOneWidget);
  });

  testWidgets('a loading layer under the shell still shows its content', (
    tester,
  ) async {
    // The identity and traits providers wrap their activation futures
    // in loading layers; each layer drives the same shell. Resolving
    // one layer must expose the subtree it was waiting for.
    final completer = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: LoadingShell(
          child: LoadingCore(
            child: LoadingLayer<void>(
              future: completer.future,
              builder: (context, _) => const Text('activated content'),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(HexagonalLoadingIndicator), findsOneWidget);

    completer.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The content builds as soon as the future resolves — even while
    // the shell's overlay is still up above it. Starving the child
    // here is what made 22.9.5 boot into a spinner forever.
    expect(find.text('activated content'), findsOneWidget);
  });
}
