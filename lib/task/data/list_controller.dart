import 'dart:async';

import 'package:e1547/app/app.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/task/task.dart';
import 'package:flutter/foundation.dart';

class TasksListController extends ChangeNotifier {
  TasksListController({required this.repository, required this.identity}) {
    _listen();
  }

  final TaskRepository repository;
  final int identity;

  StreamSubscription<List<Task>>? _subscription;

  List<Task>? _items;
  List<Task>? get items => _items;

  Object? _error;
  Object? get error => _error;

  PagingState<int, Task> get state => PagingState(
    pages: _items != null ? [_items!] : null,
    keys: _items != null ? [1] : null,
    error: _error,
    hasNextPage: false,
    isLoading: _items == null && _error == null,
  );

  void _listen() {
    _subscription = repository
        .all(identity: identity)
        .stream
        .listen(
          (items) {
            _items = items;
            _error = null;
            notifyListeners();
          },
          onError: (Object error) {
            _error = error;
            notifyListeners();
          },
        );
  }

  /// Re-subscribes to the task stream, e.g. after a database failure
  /// left the list in an error state.
  void retry() {
    _subscription?.cancel();
    _items = null;
    _error = null;
    notifyListeners();
    _listen();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class TasksListProvider
    extends
        SubChangeNotifierProvider2<
          AppStorage,
          IdentityClient,
          TasksListController
        > {
  TasksListProvider({super.child, super.builder})
    : super(
        create: (context, storage, identity) => TasksListController(
          repository: TaskRepository(database: storage.sqlite),
          identity: identity.identity.id,
        ),
      );
}
