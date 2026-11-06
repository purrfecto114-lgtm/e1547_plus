import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

/// Opens the filter prompt of a posts page.
///
/// A prompt opens in its own route, so the page's controller is out of
/// scope, and is handed over again.
Future<void> showPostsFilterPrompt({required BuildContext context}) {
  final controller = context.read<PostParamsController>();
  return showPrompt<void>(
    context,
    pinnedHeader: true,
    parentBuilder: (context, child) =>
        ChangeNotifierProvider<PostParamsController>.value(
          value: controller,
          child: child,
        ),
    header: (context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        AppLocalizations.of(context).searchFilterTitle,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
    body: const PostsFilterPanel(),
  );
}

/// A button that edits the filter tags of the current posts search.
///
/// Highlights itself while any filter tag is in use.
class PostsPageFilterButton extends StatelessWidget {
  const PostsPageFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PostParamsController>();
    final map = TagMap(controller.value.tags);
    final active =
        PostParams.tagsFilter.filters.whereType<FilterTag>().any(
          (filter) => map.containsKey(filter.tag),
        ) ||
        // The file type filter writes its family of tags as one group
        // token, which no plain filter tag carries.
        hasFileTypeTokens(map);

    return IconButton(
      tooltip: AppLocalizations.of(context).searchFilterTitle,
      icon: Icon(
        Icons.filter_list,
        color: active ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: () => showPostsFilterPrompt(context: context),
    );
  }
}

/// The filter prompt body of a posts page.
///
/// Edits the filter tags of the search the prompt was opened from, and
/// previews the query syntax they produce.
///
/// The filters are laid out in labeled sections, each carrying a count
/// of the filters it holds that are currently active, so a long panel
/// stays scannable and it is visible at a glance which parts of the
/// search a change touches. A reset action clears every filter owned by
/// the panel while leaving plain search tags untouched.
///
/// Changes are debounced: every filter control feeds FilterList.onChanged
/// on each interaction, and some controls, like the uploader filter, edit
/// free text. Feeding that straight into the controller refetches the
/// search on every keystroke.
class PostsFilterPanel extends StatefulWidget {
  const PostsFilterPanel({super.key});

  @override
  State<PostsFilterPanel> createState() => _PostsFilterPanelState();
}

class _PostsFilterPanelState extends State<PostsFilterPanel> {
  final Debouncer _apply = Debouncer();

  /// The filter sections in display order.
  ///
  /// Each section owns the filter tags listed here; the file type filter
  /// is owned through its `type` tag plus the group tokens it writes,
  /// which no single key carries.
  ///
  /// Media specs lead over content attributes: what a post is made of
  /// narrows a search faster than what it depicts, so the file type,
  /// size and tag count filters come first.
  static final List<_PostsFilterSection> _sections = [
    _PostsFilterSection(
      title: (l10n) => l10n.filterSectionSort,
      tags: {'order', 'score', 'favcount'},
    ),
    _PostsFilterSection(
      title: (l10n) => l10n.filterSectionMedia,
      tags: {'type', 'width', 'height', 'tagcount'},
    ),
    _PostsFilterSection(
      title: (l10n) => l10n.filterSectionTime,
      tags: {'date', 'status'},
    ),
    _PostsFilterSection(
      title: (l10n) => l10n.filterSectionContent,
      tags: {'rating', 'inpool', 'ischild', 'isparent'},
    ),
    _PostsFilterSection(
      title: (l10n) => l10n.filterSectionOther,
      tags: {'user'},
    ),
  ];

  @override
  void dispose() {
    // Closing the prompt applies whatever the user just entered,
    // keeping the panel's live apply semantics intact.
    _apply.flush();
    _apply.dispose();
    super.dispose();
  }

  /// Applies an edited tag map to the search, debounced.
  void _update(PostParamsController controller, TagMap map) {
    final tags = map.toString();
    _apply(
      () => controller.update(
        (params) => params.copyWith(tags: tags.isEmpty ? null : tags),
      ),
    );
  }

  /// Removes every tag the filter panel owns, keeping plain search tags.
  void _reset(PostParamsController controller) {
    // A pending change would otherwise re-add the tags this clears.
    _apply.flush();
    TagMap map = withFileType(TagMap(controller.value.tags), PostFileType.none);
    for (final section in _sections) {
      for (final tag in section.tags) {
        map.remove(tag);
      }
    }
    controller.update(
      (params) => params.copyWith(tags: map.isEmpty ? null : map.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<PostParamsController>();
    final map = TagMap(controller.value.tags);
    final query = map.toString();
    final filters = PostParams.tagsFilter.filters;
    final active = _sections.any((section) => section.activeCount(map) > 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, section) in _sections.indexed) ...[
                if (index > 0) const SizedBox(height: 20),
                _PostsFilterSectionHeader(
                  title: section.title(l10n),
                  count: section.activeCount(map),
                ),
                const SizedBox(height: 12),
                FilterList(
                  tags: map,
                  onChanged: (value) => _update(controller, TagMap.from(value)),
                  filters: filters.where(section.owns).toList(),
                ),
              ],
            ],
          ),
        ),
        const Divider(indent: 4, endIndent: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  l10n.searchFilterQueryLabel,
                  style: TextStyle(color: dimTextColor(context)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  key: const Key('PostsFilterPanel/Query'),
                  query.isEmpty ? '—' : query,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('PostsFilterPanel/Reset'),
              onPressed: active ? () => _reset(controller) : null,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: Text(l10n.searchFilterReset),
            ),
          ),
        ),
      ],
    );
  }
}

/// A labeled group of related filters in the posts filter panel.
class _PostsFilterSection {
  const _PostsFilterSection({required this.title, required this.tags});

  final String Function(AppLocalizations l10n) title;
  final Set<String> tags;

  /// Whether this section renders [config].
  bool owns(FilterConfig config) => switch (config) {
    FilterTag() => tags.contains(config.tag),
    _ => false,
  };

  /// The number of this section's filters that are active in [map].
  ///
  /// The file type filter counts once, whether it is set through its
  /// plain `type` tag or the group tokens it normally writes.
  int activeCount(TagMap map) {
    final owned = tags.where((tag) => tag != 'type' && map.containsKey(tag));
    final typed = map.containsKey('type') || hasFileTypeTokens(map) ? 1 : 0;
    return owned.length + typed;
  }
}

/// The header of a filter section, showing its active filter count.
class _PostsFilterSectionHeader extends StatelessWidget {
  const _PostsFilterSectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: count > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.colorScheme.primaryContainer,
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
