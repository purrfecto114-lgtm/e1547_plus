import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

class TagDisplay extends StatelessWidget {
  const TagDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final Client client = context.watch<Client>();
    return QueryBuilder(
      query: client.follows.useAll(),
      builder: (context, follows) => ValueListenableBuilder<Traits>(
        valueListenable: client.traits,
        builder: (context, traits, child) => buildTags(
          context,
          follows: follows.data ?? const [],
          denylist: traits.denylist,
        ),
      ),
    );
  }

  Widget buildTags(
    BuildContext context, {
    required List<Follow> follows,
    required List<String> denylist,
  }) {
    Widget tagCategory(String category) {
      return Wrap(
        children: [
          ...post.tags[category]!.map(
            (tag) => TagCard(
              tag: tag,
              category: category,
              icon: denylist.contains(tag)
                  ? Icons.block
                  : follows.firstWhereOrNull((e) => e.tags == tag)?.type.icon,
            ),
          ),
        ],
      );
    }

    Widget categoryTile(String category) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              localizedTagCategoryName(context, category),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Row(children: [Expanded(child: tagCategory(category))]),
          const Divider(),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: post.tags.keys
          .where((category) => post.tags[category]?.isNotEmpty ?? false)
          .map((category) => categoryTile(category))
          .toList(),
    );
  }
}

/// Tag category names double as stable keys.
///
/// This maps them to their localized display names.
String localizedTagCategoryName(BuildContext context, String category) {
  final l10n = AppLocalizations.of(context);
  return switch (category.toLowerCase()) {
    'general' => l10n.tagCategoryGeneral,
    'species' => l10n.tagCategorySpecies,
    'character' => l10n.tagCategoryCharacter,
    'copyright' => l10n.tagCategoryCopyright,
    'meta' => l10n.tagCategoryMeta,
    'lore' => l10n.tagCategoryLore,
    'artist' => l10n.tagCategoryArtist,
    'contributor' => l10n.tagCategoryContributor,
    'invalid' => l10n.tagCategoryInvalid,
    _ => '${category[0].toUpperCase()}${category.substring(1)}',
  };
}
