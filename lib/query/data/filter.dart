import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

abstract class FilterController<T> extends ChangeNotifier {
  FilterController();

  // The last list each key tracked, paired with its filter result. A
  // rebuild that hands over the same list instance (the common case:
  // the query data did not change) must not re-run the filter.
  final Map<Object, (List<T>, List<T>)> _tracked = {};

  bool _notifyScheduled = false;
  bool _disposed = false;

  Object idOf(T item);

  bool filter(T item);

  List<T> track(Object key, List<T> items) {
    final previous = _tracked[key];
    if (previous != null && identical(previous.$1, items)) {
      return previous.$2;
    }
    final result = items.where(filter).toList();
    _tracked[key] = (items, result);
    if (previous == null || !listEquals(previous.$1, items)) {
      _scheduleNotify();
    }
    return result;
  }

  void untrack(Object key) {
    if (_tracked.remove(key) != null) {
      _scheduleNotify();
    }
  }

  Iterable<T> get tracked {
    final seen = <Object>{};
    return _tracked.values
        .expand((entry) => entry.$1)
        .where((item) => seen.add(idOf(item)));
  }

  int get blockedCount {
    // Every tracked key's stored filtered list is exact, so counting the
    // blocked items is a sum over per-key (total, allowed) pairs — no
    // per-item filtering, no idOf dedup pass over the corpus.
    var blocked = 0;
    for (final entry in _tracked.values) {
      blocked += entry.$1.length - entry.$2.length;
    }
    return blocked;
  }

  void _scheduleNotify() {
    if (_notifyScheduled || _disposed) return;
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (_disposed) return;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
