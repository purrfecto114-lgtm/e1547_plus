import 'dart:async';

import 'package:async/async.dart';
import 'package:drift/drift.dart';
import 'package:e1547/identity/identity.dart';
import 'package:flutter/foundation.dart';

class IdentityClient extends IdentityRepository with ChangeNotifier {
  IdentityClient({required GeneratedDatabase database, this.onCreate})
    : super(database);

  StreamSubscription<Identity?>? _subscription;

  final FutureOr<IdentityRequest> Function()? onCreate;

  /// Counts every activate and dispose.
  ///
  /// An activate that lost a race against a newer activate or a dispose
  /// must not write its result back: the earlier caller's await can
  /// resume after a later one already installed a different identity.
  int _generation = 0;

  Future<void> activate(int? id) async {
    final int generation = ++_generation;
    _subscription?.cancel();
    Identity? result;
    Stream<Identity?>? stream;
    if (id != null) {
      stream = _find(id);
      result = await stream.firstOrNull;
      if (_generation != generation) return;
    }
    if (result == null) {
      result = (await page(page: 1, limit: 1)).singleOrNull;
      if (_generation != generation) return;
      stream = _find(result?.id);
    }
    if (result == null) {
      if (onCreate == null) {
        throw StateError(
          'IdentitiesClient failed to activate because no identity '
          'was found and no onCreate callback was provided',
        );
      }
      result = await add(await onCreate!());
      if (_generation != generation) return;
      stream = _find(result.id);
    }
    _identity = result;
    _subscription = stream!.listen(_onChanged);
    notifyListeners();
  }

  Stream<Identity?> _find(int? id) => id == null
      ? Stream.value(null)
      : (select(
          identitiesTable,
        )..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();

  Future<void> _onChanged(Identity? value) async {
    if (value == null) return activate(null);
    if (value == _identity) return;
    _identity = value;
    notifyListeners();
  }

  Identity? _identity;

  Identity get identity {
    if (_identity == null) {
      throw StateError(
        'IdentityClient was not activated before accessing '
        'the identity property',
      );
    }
    return _identity!;
  }

  @override
  void dispose() {
    // Invalidate any in-flight activate: its completion must neither
    // write the identity back nor notify disposed listeners.
    _generation++;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
