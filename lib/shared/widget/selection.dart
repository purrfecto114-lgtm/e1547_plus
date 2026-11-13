import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

/// Returns the stable key which identifies an item of a [SelectionLayout].
///
/// Keys outlive content changes of their item: a selection is only dropped
/// when its key leaves the current items, not when an equal-but-updated
/// item replaces the selected one.
typedef SelectionKeyOf<T> = Object Function(T item);

class SelectionLayoutData<T> extends InheritedWidget {
  /// Provides selection actions for a [SelectionLayout] to its subtree.
  const SelectionLayoutData({
    super.key,
    required super.child,
    required this.selections,
    required this.onChanged,
    required this.items,
    required this.keyOf,
    required this.itemsByKey,
    required this.selectedKeys,
  });

  /// All selected items.
  ///
  /// Resolved from stable keys against the current [items], so a selected
  /// item stays selected while its content changes.
  final Set<T> selections;

  /// All items that can be selected.
  final List<T> items;

  /// Returns the stable key of an item of this [SelectionLayout].
  final SelectionKeyOf<T> keyOf;

  /// All current items by their stable keys.
  ///
  /// Part of the key-based selection bookkeeping; widgets should prefer
  /// [items] and [selections].
  final Map<Object, T> itemsByKey;

  /// The stable keys of all selected items.
  ///
  /// Part of the key-based selection bookkeeping; widgets should prefer
  /// [selections].
  final Set<Object> selectedKeys;

  /// Called when the selection is changed.
  final ValueChanged<Set<T>> onChanged;

  /// Ensures that an item is part of this [SelectionLayout].
  void _assertItemOwnership(T item) {
    if (!itemsByKey.containsKey(keyOf(item))) {
      throw StateError('Cannot select an item which is not part of items!');
    }
  }

  /// Clears the selection.
  void clear() => onChanged(const {});

  /// Selects all items.
  void selectAll() => onChanged(items.toSet());

  /// Returns whether an item is currently selected.
  ///
  /// Compares by stable key, so an outdated copy of a selected item still
  /// reports as selected.
  bool isSelected(T item) {
    _assertItemOwnership(item);
    return selectedKeys.contains(keyOf(item));
  }

  /// Selects an item.
  /// Does nothing if the item is already selected.
  void select(T item) {
    _assertItemOwnership(item);
    if (!isSelected(item)) {
      onChanged(Set.of(selections)..add(item));
    }
  }

  /// Deselects an item.
  /// Does nothing if the item is not selected.
  void deselect(T item) {
    _assertItemOwnership(item);
    final Object key = keyOf(item);
    if (selectedKeys.contains(key)) {
      onChanged({
        for (final selection in selections)
          if (keyOf(selection) != key) selection,
      });
    }
  }

  /// Sets the selection of an item.
  /// Does nothing if already in correct state.
  void setSelection(T item, bool selected) {
    if (selected) {
      select(item);
    } else {
      deselect(item);
    }
  }

  /// Toggles the selection state of an item.
  void toggleSelection(T item) => setSelection(item, !isSelected(item));

  @override
  bool updateShouldNotify(covariant SelectionLayoutData<T> oldWidget) =>
      !setEquals(oldWidget.selections, selections) ||
      !identical(oldWidget.items, items) ||
      oldWidget.onChanged != onChanged;
}

class SelectionLayout<T> extends StatefulWidget {
  /// Provides item selection for a subtree.
  const SelectionLayout({
    super.key,
    required this.child,
    required this.items,
    required this.keyOf,
    this.enabled = true,
  });

  /// The widget below this one on the tree.
  final Widget child;

  /// All items which can be selected.
  final List<T>? items;

  /// Returns the stable key of an item.
  ///
  /// The same item must keep the same key while its content changes; a
  /// selection is only dropped when its key leaves [items].
  final SelectionKeyOf<T> keyOf;

  /// Whether items can currently be selected.
  final bool enabled;

  /// Returns the [SelectionLayoutData] of the current context.
  /// Throws an error if there is none.
  static SelectionLayoutData<T> of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SelectionLayoutData<T>>()!;

  /// Returns the [SelectionLayoutData] of the current context or null, if there is none.
  static SelectionLayoutData<T>? maybeOf<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SelectionLayoutData<T>>();

  @override
  State<SelectionLayout<T>> createState() => _SelectionLayoutState<T>();
}

class _SelectionLayoutState<T> extends State<SelectionLayout<T>> {
  /// The stable keys of all selected items.
  ///
  /// Keys, not items: a task changing status or a post changing score
  /// replaces the item instance, but keeps its key and its selection.
  Set<Object> selectedKeys = {};

  @override
  void didUpdateWidget(covariant SelectionLayout<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      // Keys which left the current items drop their selection; keys whose
      // items only changed content keep theirs.
      final Map<Object, T> itemsByKey = {
        for (final item in widget.items ?? <T>[])
          widget.keyOf(item): item,
      };
      final Set<Object> updated = selectedKeys
          .where(itemsByKey.containsKey)
          .toSet();
      if (updated.length != selectedKeys.length) {
        onSelectionKeysChanged(updated);
      }
    }
  }

  void onSelectionChanged(Set<T> selections) {
    onSelectionKeysChanged(selections.map(widget.keyOf).toSet());
  }

  void onSelectionKeysChanged(Set<Object> keys) {
    setState(() {
      selectedKeys = keys;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final List<T> items = widget.items ?? <T>[];
    final Map<Object, T> itemsByKey = {
      for (final item in items) widget.keyOf(item): item,
    };
    // Resolving through keys maps a selection onto the current item which
    // owns its key, whatever happened to the item's content.
    final Set<Object> visibleKeys = selectedKeys
        .where(itemsByKey.containsKey)
        .toSet();
    final Set<T> selections = {
      for (final key in visibleKeys) itemsByKey[key]!,
    };

    return PopScope(
      canPop: selections.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onSelectionChanged({});
      },
      child: SelectionLayoutData<T>(
        items: items,
        itemsByKey: itemsByKey,
        selections: selections,
        selectedKeys: visibleKeys,
        onChanged: onSelectionChanged,
        keyOf: widget.keyOf,
        child: widget.child,
      ),
    );
  }
}

class SelectionAppBar<T> extends StatelessWidget with AppBarBuilderWidget {
  /// Provides an appbar for handling the selection of items.
  /// Replaces the normal appbar as soon as a selection starts.
  const SelectionAppBar({
    super.key,
    required this.child,
    required this.actionBuilder,
    this.titleBuilder,
  });

  /// The list of actions for the selection appbar.
  /// Automatically contains an action to select all items.
  final List<Widget> Function(
    BuildContext context,
    SelectionLayoutData<T> layoutData,
  )
  actionBuilder;

  /// Called to display the title for the selection appbar.
  /// Defaults to '<count> items'.
  final Widget Function(
    BuildContext context,
    SelectionLayoutData<T> layoutData,
  )?
  titleBuilder;

  /// The appbar that is shown when no selection is taking place.
  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    SelectionLayoutData<T>? layoutData = SelectionLayout.maybeOf<T>(context);
    return CrossFade.builder(
      showChild: layoutData != null && layoutData.selections.isNotEmpty,
      builder: (context) => DefaultAppBar(
        title:
            titleBuilder?.call(context, layoutData!) ??
            Text(
              AppLocalizations.of(
                context,
              ).selectionItemCount(layoutData!.selections.length),
            ),
        leading: IconButton(
          icon: const Icon(Icons.clear),
          tooltip: AppLocalizations.of(context).actionAbort,
          onPressed: layoutData!.clear,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: AppLocalizations.of(context).actionSelectAll,
            onPressed: layoutData.selectAll,
          ),
          ...actionBuilder(context, layoutData),
        ],
      ),
      secondChild: child,
    );
  }
}

class SelectionItemOverlay<T> extends StatelessWidget {
  /// Alows long press actions to start selecting items.
  const SelectionItemOverlay({
    super.key,
    required this.child,
    required this.item,
    this.padding,
  });

  /// The widget below this one in the tree.
  final Widget child;

  /// The item that can be selected.
  final T item;

  /// Padding of this widget.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    SelectionLayoutData<T>? layoutData = SelectionLayout.maybeOf<T>(context);
    if (layoutData != null) {
      // Resolved through the stable key instead of value equality: a
      // tile can hold an outdated copy of its item until it rebuilds,
      // and the checkmark must not disagree with isSelected. The raw
      // key set is read directly because the overlay's item may also
      // have left the current items already, which isSelected treats
      // as an error.
      final bool selected = layoutData.selectedKeys.contains(
        layoutData.keyOf(item),
      );
      return Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned.fill(
            child: Semantics(
              // The overlay toggles the selection of its item. Exposing
              // the toggled state, and the actions behind it, keeps
              // screen readers informed and operable without gestures.
              button: true,
              selected: selected,
              onTap: layoutData.selections.isNotEmpty
                  ? () => layoutData.toggleSelection(item)
                  : null,
              onLongPress: () => layoutData.toggleSelection(item),
              child: MouseCursorRegion(
                behavior: HitTestBehavior.translucent,
                onTap: layoutData.selections.isNotEmpty
                    ? () => layoutData.toggleSelection(item)
                    : null,
                onLongPress: () => layoutData.toggleSelection(item),
                onSecondaryTap: () => layoutData.toggleSelection(item),
                child: ExcludeFocus(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: defaultAnimationDuration,
                      opacity: selected ? 1 : 0,
                      child: Container(
                        margin: padding,
                        color: Colors.black38,
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return child;
    }
  }
}
