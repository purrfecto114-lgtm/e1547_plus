import 'package:e1547/query/query.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal item whose id and deny-state are observable.
class _Item {
  const _Item(this.id, {this.denied = false});
  final int id;
  final bool denied;

  @override
  // Mutable in principle, but the tests only build fixed instances;
  // value equality is what listEquals-driven notify suppression needs.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is _Item && other.id == id && other.denied == denied;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(id, denied);

  @override
  String toString() => '_Item($id${denied ? ', denied' : ''})';
}

class _Filter extends FilterController<_Item> {
  int filterCalls = 0;

  @override
  Object idOf(_Item item) => item.id;

  @override
  bool filter(_Item item) {
    filterCalls++;
    return !item.denied;
  }
}

void main() {
  // FilterController notifies through SchedulerBinding post-frame callbacks,
  // which need an initialized test binding even in plain tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FilterController.track', () {
    test('returns only allowed items', () {
      final controller = _Filter();
      addTearDown(controller.dispose);
      final out = controller.track('k', const [
        _Item(1),
        _Item(2, denied: true),
      ]);
      expect(out, [const _Item(1)]);
    });

    test('notifies only when the denied set actually changes', () async {
      final controller = _Filter();
      addTearDown(controller.dispose);
      final items = [const _Item(1), const _Item(2, denied: true)];

      controller.track('k', items);
      // The first track of a new key schedules a notify; drain it before
      // counting, so only the tracks below are observed.
      await _pumpFrame();

      int notifies = 0;
      controller.addListener(() => notifies++);

      // Same list instance again: neither content nor membership changed.
      controller.track('k', items);
      await _pumpFrame();
      expect(notifies, 0, reason: 'identical input must not re-notify');

      // Same content in a fresh list: the denied set is unchanged.
      controller.track('k', List.of(items));
      await _pumpFrame();
      expect(notifies, 0, reason: 'equal content must not re-notify');

      // A new allowed item flips the denied set's complement.
      controller.track('k', [...items, const _Item(3)]);
      await _pumpFrame();
      expect(notifies, 1, reason: 'membership change must notify');
    });

    test('does not re-run filter for unchanged tracked items', () {
      final controller = _Filter();
      addTearDown(controller.dispose);
      final items = [const _Item(1), const _Item(2, denied: true)];

      controller.track('k', items);
      final firstPass = controller.filterCalls;

      // The same list tracked again (a rebuild with identical data)
      // must not run filter() over every item again.
      controller.track('k', items);
      expect(controller.filterCalls, firstPass);

      // New content runs filter again, but only for the new list.
      final before = controller.filterCalls;
      controller.track('k', [...items, const _Item(3)]);
      expect(controller.filterCalls, greaterThan(before));
    });

    test('blockedCount is served from the tracked filtered cache', () {
      final controller = _Filter();
      addTearDown(controller.dispose);
      controller.track('k', [
        const _Item(1),
        const _Item(2, denied: true),
        const _Item(3, denied: true),
      ]);
      expect(controller.blockedCount, 2);

      // The filter() calls of a blockedCount read must not grow:
      final before = controller.filterCalls;
      expect(controller.blockedCount, 2);
      expect(controller.blockedCount, 2);
      expect(controller.filterCalls, before);
    });

    test('untrack forgets the cache and notifies', () {
      final controller = _Filter();
      addTearDown(controller.dispose);
      controller.track('k', [const _Item(1)]);
      controller.untrack('k');
      expect(controller.blockedCount, 0);
      expect(controller.tracked, isEmpty);
    });
  });
}

Future<void> _pumpFrame() async {
  // FilterController schedules notifies through addPostFrameCallback.
  // In a plain test there is no live frame loop, so drive the scheduler
  // with a scheduled frame tick instead.
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.scheduleFrame();
  await Future<void>.delayed(Duration.zero);
  // Let the post-frame callbacks registered for this tick run.
  SchedulerBinding.instance.handleBeginFrame(Duration.zero);
  SchedulerBinding.instance.handleDrawFrame();
}
