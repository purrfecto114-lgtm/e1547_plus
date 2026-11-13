import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A value type whose content can change while its identity must not.
@immutable
class _Item {
  const _Item(this.id, this.status);

  final int id;
  final String status;

  @override
  bool operator ==(Object other) =>
      other is _Item && other.id == id && other.status == status;

  @override
  int get hashCode => Object.hash(id, status);
}

Object _itemKey(_Item item) => item.id;

void main() {
  late SelectionLayoutData<_Item> data;

  Future<void> pumpItems(
    WidgetTester tester,
    List<_Item> items, {
    SelectionKeyOf<_Item>? keyOf,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SelectionLayout<_Item>(
          items: items,
          keyOf: keyOf ?? _itemKey,
          child: Builder(
            builder: (context) {
              data = SelectionLayout.of<_Item>(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a selected item stays selected when its content changes', (
    tester,
  ) async {
    await pumpItems(tester, const [_Item(1, 'running'), _Item(2, 'running')]);
    data.select(data.items.first);
    await tester.pump();

    expect(data.selections, {const _Item(1, 'running')});

    // Item 1 reports a new status; only its content changed.
    await pumpItems(tester, const [_Item(1, 'completed'), _Item(2, 'running')]);

    // The selection survives onto the updated item...
    expect(data.selections, {const _Item(1, 'completed')});
    // ...and an outdated copy of it still counts as selected.
    expect(data.isSelected(const _Item(1, 'running')), isTrue);
    expect(data.isSelected(const _Item(1, 'completed')), isTrue);
    expect(data.isSelected(const _Item(2, 'running')), isFalse);
  });

  testWidgets('a selection is dropped when its item leaves the items', (
    tester,
  ) async {
    await pumpItems(tester, const [_Item(1, 'running'), _Item(2, 'running')]);
    data.select(const _Item(2, 'running'));
    await tester.pump();
    expect(data.selections, {const _Item(2, 'running')});

    await pumpItems(tester, const [_Item(1, 'running')]);

    expect(data.selections, isEmpty);
  });

  testWidgets('an outdated copy deselects its current item', (tester) async {
    await pumpItems(tester, const [_Item(1, 'running')]);
    data.select(const _Item(1, 'running'));
    await tester.pump();

    // The item's content changed after the copy was made.
    await pumpItems(tester, const [_Item(1, 'completed')]);
    expect(data.selections, {const _Item(1, 'completed')});

    data.deselect(const _Item(1, 'running'));
    await tester.pump();

    expect(data.selections, isEmpty);
  });

  testWidgets('an item which is not part of the layout is rejected', (
    tester,
  ) async {
    await pumpItems(tester, const [_Item(1, 'running')]);

    expect(() => data.select(const _Item(2, 'running')), throwsStateError);
  });

  testWidgets('selecting all of a large list survives a full update', (
    tester,
  ) async {
    final List<_Item> items = List.generate(
      2000,
      (index) => _Item(index, 'pending'),
    );
    await pumpItems(tester, items);
    data.selectAll();
    await tester.pump();

    expect(data.selections.length, 2000);

    // Every item reports a new status; the ids, and with them the
    // selections, all stay.
    final List<_Item> updated = [
      for (final item in items) _Item(item.id, 'completed'),
    ];
    await pumpItems(tester, updated);

    expect(data.selections.length, 2000);
    expect(data.isSelected(const _Item(1999, 'completed')), isTrue);
    expect(data.isSelected(const _Item(0, 'pending')), isTrue);
  });

  testWidgets('selecting all resolves in passes over the items, not pairs', (
    tester,
  ) async {
    // Key lookups stand in for membership checks: resolving the selection
    // of every item costs a handful of full passes over the list, never
    // one lookup per selected item.
    int keyCalls = 0;
    final List<_Item> items = List.generate(
      2000,
      (index) => _Item(index, 'pending'),
    );
    await pumpItems(
      tester,
      items,
      keyOf: (_Item item) {
        keyCalls++;
        return item.id;
      },
    );
    data.selectAll();
    await tester.pump();

    expect(data.selections.length, 2000);

    await pumpItems(
      tester,
      [for (final item in items) _Item(item.id, 'completed')],
      keyOf: (_Item item) {
        keyCalls++;
        return item.id;
      },
    );

    expect(data.selections.length, 2000);
    expect(keyCalls, lessThan(items.length * 10));
  });
}
