import 'dart:async';

import 'package:flutter/foundation.dart';

extension ConditionalListenables on Listenable {
  Future<void> listenFor(bool Function() condition) async {
    Completer<void> completer = Completer();
    void listener() {
      if (condition()) {
        removeListener(listener);
        completer.complete();
      }
    }

    addListener(listener);
    return completer.future;
  }
}

// ignore: one_member_abstracts
abstract mixin class Disposable {
  bool _disposed = false;

  /// Whether [dispose] has run.
  ///
  /// Lets async methods that survived their owner's teardown stop
  /// before writing to closed streams or cancelled listeners.
  bool get disposed => _disposed;

  @mustCallSuper
  void dispose() {
    _disposed = true;
  }

  static void tryDispose(Object? object) {
    try {
      (object as dynamic).dispose();
      // ignore: avoid_catching_errors
    } on NoSuchMethodError {
      // this object is not disposable
    }
  }
}
