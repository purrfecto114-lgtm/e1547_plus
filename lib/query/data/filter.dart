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
    // Distinct ids decide the count, not the per-key sums. Routes share
    // one controller (a list keeps tracking beneath the detail page and
    // the gallery pushed over it), so the same post can sit in several
    // tracked lists; summing each key's blocked total counts it once
    // per route and the drawer's total climbs with every pushed page
    // while the visible content stays the same. An id blocked by the
    // occurrence the dedup pass below first saw counts once.
    final seen = <Object>{};
    var blocked = 0;
    for (final entry in _tracked.values) {
      final (List<T> items, List<T> allowed) = entry;
      // track() built the filtered list with a plain where over items,
      // so allowed is a subsequence of items in order holding the same
      // instances: a two-pointer walk pairs every item with its verdict
      // without touching the map caches again.
      int cursor = 0;
      for (final item in items) {
        final bool isBlocked =
            !(cursor < allowed.length && identical(allowed[cursor], item));
        if (!isBlocked) cursor++;
        // The first occurrence of an id decides its verdict, in the
        // same map order the tracked getter dedups by, so this total
        // and the per-entry counts below it stay one consistent scope.
        if (seen.add(idOf(item)) && isBlocked) blocked++;
      }
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
