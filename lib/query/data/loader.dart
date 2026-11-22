import 'dart:async';

class QueryMissingException implements Exception {
  const QueryMissingException(this.key);

  final Object? key;

  @override
  String toString() => 'QueryMissingException($key)';
}

class QueryLoader<K, V> {
  QueryLoader(this.load, {this.limit});

  final Future<Map<K, V>> Function(List<K> keys) load;
  final int? limit;

  /// How long arriving keys collect into one batch before it is sent.
  ///
  /// A plain microtask window (the previous design) only coalesced
  /// requires that happened to run in the same event-loop turn, which
  /// widget-driven callers miss: their subscriptions each land one
  /// frame apart, so every key became its own request. A short time
  /// window still batches a burst of arrivals while keeping the first
  /// result snappy.
  static const Duration coalesceWindow = Duration(milliseconds: 50);

  final Set<K> _missing = {};
  List<K>? _queued;
  Future<Map<K, V>>? _next;
  Timer? _window;

  Future<V?> fetch(K key) {
    if (_missing.contains(key)) return Future.value();
    return _queue(key);
  }

  Future<V> require(K key) async =>
      await fetch(key) ?? (throw QueryMissingException(key));

  Future<V?> _queue(K key) async {
    final List<K> keys = _queued ??= [];
    keys.add(key);
    final Future<Map<K, V>> batch = _next ??= _schedule();
    if (limit case final int limit when keys.length >= limit) _flush();
    return (await batch)[key];
  }

  Future<Map<K, V>> _schedule() {
    final completer = Completer<Map<K, V>>();
    _window = Timer(coalesceWindow, () {
      _window = null;
      final List<K>? keys = _queued;
      if (keys == null) {
        completer.complete(const {});
        return;
      }
      _flush();
      load(keys)
          .then((loaded) {
            _missing.addAll(keys.where((key) => !loaded.containsKey(key)));
            completer.complete(loaded);
          })
          .catchError(completer.completeError);
    });
    return completer.future;
  }

  void _flush() {
    _queued = null;
    _next = null;
    _window?.cancel();
    _window = null;
  }
}
