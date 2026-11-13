import 'dart:async';

import 'package:async/async.dart';
import 'package:drift/drift.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class TraitsClient extends TraitsRepository with ChangeNotifier {
  TraitsClient({required GeneratedDatabase database, this.onCreate})
    : super(database);

  StreamSubscription<Traits?>? _subscription;

  final FutureOr<TraitsRequest?> Function(int identity)? onCreate;

  /// Counts every activate and dispose.
  ///
  /// An activate that lost a race against a newer activate or a dispose
  /// must not write its result back: the earlier caller's await can
  /// resume after a later one already installed different traits.
  int _generation = 0;

  Future<void> activate(int id) async {
    final int generation = ++_generation;
    _subscription?.cancel();
    Traits? result;
    Stream<Traits?>? stream;
    stream = _find(id);
    result = await stream.firstOrNull;
    if (_generation != generation) return;
    if (result == null) {
      if (onCreate == null) {
        throw StateError(
          'TraitsClient failed to activate because no traits '
          'were found and no onCreate callback was provided',
        );
      }
      TraitsRequest? request = await onCreate!(id);
      if (_generation != generation) return;
      if (request == null) return; // assuming the identity was deleted
      result = await add(request);
      if (_generation != generation) return;
    }
    _traits = result;
    _subscription = stream.listen(_onChanged);
    notifyListeners();
  }

  Stream<Traits?> _find(int id) => (select(
    traitsTable,
  )..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();

  Future<void> _onChanged(Traits? value) async {
    if (value == null) {
      if (_traits == null) return;
      return activate(_traits!.id);
    }
    if (value == _traits) return;
    _traits = value;
    notifyListeners();
  }

  Traits? _traits;

  Traits get traits {
    if (_traits == null) {
      throw StateError(
        'IdentitySettingsClient was not activated before accessing '
        'the traits property',
      );
    }
    return _traits!;
  }

  ValueNotifier<Traits> get notifier {
    Stream<Traits> stream = _find(traits.id).transform(
      StreamTransformer.fromHandlers(
        handleData: (value, sink) {
          // we drop null events. this is fine because [_onChanged] will
          // be called and repupulate the value in the database
          if (value == null) return;
          sink.add(value);
        },
      ),
    );
    final result = _StreamedValueNotifier<Traits>(
      initial: traits,
      stream: stream,
      onChanged: replace,
    );
    return result;
  }

  @override
  void dispose() {
    // Invalidate any in-flight activate: its completion must neither
    // write the traits back nor notify disposed listeners.
    _generation++;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

class _StreamedValueNotifier<T> extends ValueNotifier<T> {
  _StreamedValueNotifier({
    required T initial,
    required this.stream,
    required this.onChanged,
  }) : super(initial) {
    _subscription = stream.listen((value) => this.value = value);
  }

  final Stream<T> stream;
  final ValueSetter<T> onChanged;

  StreamSubscription<T>? _subscription;

  @override
  set value(T newValue) {
    if (newValue != value) {
      onChanged(newValue);
    }
    super.value = newValue;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
