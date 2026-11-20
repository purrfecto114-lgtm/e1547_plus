import 'dart:async';

import 'package:flutter/material.dart';

typedef ActionControllerCallback = FutureOr<void> Function();

class ActionControllerException implements Exception {
  const ActionControllerException({required this.message});

  final String message;
}

class ActionController extends ChangeNotifier {
  ActionControllerCallback? action;
  ActionControllerException? error;
  bool isLoading = false;
  bool isForgiven = false;
  bool get isError => error != null;
  Duration errorTimeout = const Duration(seconds: 3);
  Timer? errorTimer;
  bool _disposed = false;

  /// Listeners are gone once disposed, and every notification here can
  /// land after that: an action's submit keeps running past a dispose,
  /// and the forgive timer outlives it unless dispose cancels it first.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @mustCallSuper
  @protected
  void forgive() {
    errorTimer?.cancel();
    errorTimer = Timer(errorTimeout, () {
      isForgiven = true;
      _notify();
    });
  }

  @mustCallSuper
  @protected
  void reset() {
    isLoading = false;
    isForgiven = false;
    error = null;
    action = null;
    _notify();
  }

  @mustCallSuper
  @protected
  Future<void> execute(ActionControllerCallback submit) async {
    error = null;
    isForgiven = false;
    isLoading = true;
    _notify();
    try {
      await submit();
      onSuccess();
    } on ActionControllerException catch (e) {
      error = e;
      forgive();
    }
    isLoading = false;
    _notify();
  }

  @protected
  void onSuccess() {}

  @protected
  void onForgive() {}

  @mustCallSuper
  void setAction(ActionControllerCallback submit) {
    isLoading = false;
    error = null;
    action = () => execute(submit);
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    errorTimer?.cancel();
    super.dispose();
  }
}
