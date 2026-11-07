import 'package:e1547/history/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('history type icons are distinct per type', () {
    // The icons double as the visual language of the history drawer: two
    // types sharing a glyph would read as the same entry kind.
    final icons = [
      HistoryType.posts.icon,
      HistoryType.pools.icon,
      HistoryType.topics.icon,
      HistoryType.users.icon,
      HistoryType.wikis.icon,
    ];
    expect(icons.every((icon) => icon != null), isTrue);
    expect(
      icons.map((icon) => (icon! as Icon).icon).toSet().length,
      icons.length,
    );
  });

  test('wikis use the same info glyph as the history menu', () {
    // The wiki entry menu and the wiki history type once showed two
    // different info glyphs; they must stay the same icon.
    expect(
      HistoryType.wikis.icon,
      isA<Icon>().having((i) => i.icon, 'icon', Icons.info_outline),
    );
  });

  test('category icons are distinct per category', () {
    final icons = [HistoryCategory.items.icon, HistoryCategory.searches.icon];
    expect(
      icons.map((icon) => (icon! as Icon).icon).toSet().length,
      icons.length,
    );
  });
}
