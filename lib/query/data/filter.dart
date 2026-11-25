import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Tracks the filter verdicts of every post the visible routes feed in,
/// keyed by identity rather than by route.
///
/// Routes share one controller: the list keeps tracking beneath the
/// detail page pushed over it, and the gallery pushed over that. A post
/// therefore arrives through several keys at once — once per route, as
/// distinct instances from each route's own cache. Counting per key
/// counted it once per route and the drawer's total climbed with every
/// pushed page while the visible content stayed the same.
///
/// This controller keeps one verdict per distinct id instead. Whichever
/// key wrote the id last owns the verdict, so refreshed data (the
/// detail query re-fetching the post the list cached earlier) wins over
/// the stale instance, and every consumer — the total, the per-entry
/// counters, the tracked view — reads the same single source.
abstract class FilterController<T> extends ChangeNotifier {
  FilterController();

  /// The verdict per distinct id. One entry per post, no matter how
  /// many routes track it.
  final Map<Object, bool> _verdicts = {};

  /// The item each id is judged by: the per-entry counters need the
  /// post behind the id, not just its verdict.
  final Map<Object, T> _items = {};

  /// The ids each key contributes. Untracking a key removes exactly the
  /// ids no other key still holds.
  final Map<Object, Set<Object>> _keys = {};

  /// The filtered list per key, reused on identical re-tracks (the
  /// common rebuild hands over the same list instance).
  final Map<Object, List<T>> _sources = {};
  final Map<Object, List<T>> _results = {};

  /// The invalidation generation. [invalidate] bumps it: every track
  /// recorded under an older generation re-runs the filter, even over
  /// an identical list, because the predicate's inputs changed under
  /// it (denylist edits, allowlists, the denying switch).
  int _generation = 0;
  final Map<Object, int> _trackedGeneration = {};

  bool _notifyScheduled = false;
  bool _disposed = false;

  Object idOf(T item);

  bool filter(T item);

  /// Marks every tracked verdict stale and re-judges it right away.
  ///
  /// It fires from user actions (a denylist edit, an allowlist
  /// checkbox, the denying switch), and the consumers rebuilt by this
  /// notify read their numbers before the query filter beneath them
  /// re-tracks — the app bar's badge sits in the scaffold's appBar
  /// slot, which builds ahead of the body. Recomputing here keeps
  /// every consumer of the same frame on one consistent set of
  /// verdicts. The cost is one full predicate pass over the tracked
  /// posts, per user action, which is what the old per-track pass
  /// paid on every rebuild instead.
  void invalidate() {
    _generation++;
    if (_disposed) return;
    for (final id in _verdicts.keys) {
      _verdicts[id] = filter(_items[id] as T);
    }
    notifyListeners();
  }

  /// Registers [items] under [key] and returns the allowed subset.
  ///
  /// Every id the key carries gets its verdict (re)written: tracking is
  /// the write, and the last write owns the id. Ids the key dropped and
  /// no other key holds are forgotten.
  List<T> track(Object key, List<T> items) {
    final previousSource = _sources[key];
    final previousResult = _results[key];
    final bool stale = _trackedGeneration[key] != _generation;
    if (previousSource != null &&
        previousResult != null &&
        identical(previousSource, items) &&
        !stale) {
      return previousResult;
    }

    final result = <T>[];
    final ids = <Object>{};
    for (final item in items) {
      final allowed = filter(item);
      if (allowed) result.add(item);
      final id = idOf(item);
      ids.add(id);
      _items[id] = item;
      _verdicts[id] = allowed;
    }

    // Ids this key owned alone and no longer offers are gone for good;
    // ids another key still carries keep their verdict.
    for (final id in (_keys[key] ?? const <Object>{}).difference(ids)) {
      if (!_keys.values.any((owned) => owned.contains(id))) {
        _verdicts.remove(id);
        _items.remove(id);
      }
    }
    _keys[key] = ids;
    _sources[key] = items;
    _results[key] = result;
    _trackedGeneration[key] = _generation;

    // Content changes notify as before. A re-run forced by invalidate()
    // notifies too: the verdicts were silently rewritten against the
    // new predicate inputs, and consumers that rebuilt ahead of this
    // track (the app bar reads its badge before the query filter
    // re-tracks beneath it) must read the fresh verdicts next frame.
    if (previousResult == null || !listEquals(previousSource, items) || stale) {
      _scheduleNotify();
    }
    return result;
  }

  /// Forgets everything [key] tracked that no other key still carries.
  void untrack(Object key) {
    final ids = _keys.remove(key);
    _sources.remove(key);
    _results.remove(key);
    if (ids == null) return;
    var changed = false;
    for (final id in ids) {
      if (_keys.values.any((owned) => owned.contains(id))) continue;
      _verdicts.remove(id);
      _items.remove(id);
      changed = true;
    }
    if (changed) _scheduleNotify();
  }

  /// The distinct posts across every tracking key, one instance per id.
  Iterable<T> get tracked => _items.values;

  /// How many distinct tracked posts the filter currently drops.
  int get blockedCount {
    var blocked = 0;
    for (final verdict in _verdicts.values) {
      if (verdict) continue;
      blocked++;
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
