import 'package:e1547/history/history.dart';
import 'package:flutter/material.dart';

extension HistorySearchFilterDisplaying on HistoryCategory {
  Widget? get icon {
    switch (this) {
      case HistoryCategory.items:
        return const Icon(Icons.article);
      case HistoryCategory.searches:
        return const Icon(Icons.search);
    }
  }
}

extension HistoryTypeFilterDisplaying on HistoryType {
  Widget? get icon => switch (this) {
    HistoryType.posts => const Icon(Icons.image),
    HistoryType.pools => const Icon(Icons.collections),
    HistoryType.topics => const Icon(Icons.forum),
    HistoryType.users => const Icon(Icons.person),
    HistoryType.wikis => const Icon(Icons.info_outline),
  };
}
