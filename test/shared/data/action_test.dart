import 'dart:async';

import 'package:e1547/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // execute is protected: every test drives the controller the way the
  // widgets do, through setAction and the action callback it installs.
  Future<void> run(
    ActionController controller,
    ActionControllerCallback s,
  ) async {
    controller.setAction(s);
    await controller.action!();
  }

  test('an action finishing after a dispose stays quiet', () async {
    final controller = ActionController();
    final gate = Completer<void>();

    unawaited(run(controller, () => gate.future));
    controller.dispose();
    gate.complete();
    // The trailing notification runs a few microtasks after the submit
    // resolves; give them all a chance to throw.
    await gate.future;
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  });

  test('a forgiven error after a dispose stays quiet', () async {
    final controller = ActionController()
      ..errorTimeout = const Duration(milliseconds: 10);

    unawaited(
      run(
        controller,
        () => Future.error(const ActionControllerException(message: 'boom')),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    controller.dispose();
    // Outlive the forgive timer: firing into a disposed controller used
    // to throw a "used after being disposed" error.
    await Future<void>.delayed(const Duration(milliseconds: 30));
  });

  test('an action reports failure and forgives it', () async {
    final controller = ActionController()
      ..errorTimeout = const Duration(milliseconds: 10);

    unawaited(
      run(
        controller,
        () => Future.error(const ActionControllerException(message: 'boom')),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.isError, isTrue);
    expect(controller.isLoading, isFalse);

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(controller.isForgiven, isTrue);
  });

  test('a successful action clears its loading state', () async {
    final controller = ActionController();

    unawaited(run(controller, () async {}));
    await Future<void>.delayed(Duration.zero);

    expect(controller.isError, isFalse);
    expect(controller.isLoading, isFalse);
  });
}
