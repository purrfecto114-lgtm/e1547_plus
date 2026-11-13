import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:intl/intl.dart';

/// Locates the tag word a cursor offset points at.
///
/// Returns the word's index among [tags], the offset of its first
/// character and the offset just past its last character, all in the
/// space-joined text. The cursor belongs to the word it sits in or right
/// behind, so completing a repeated word replaces the occurrence the
/// cursor points at, not the first one that equals it. A cursor past the
/// last word points at that word.
(int, int, int) _findTag(List<String> tags, int offset) {
  int start = 0;
  for (var index = 0; index < tags.length; index++) {
    final end = start + tags[index].length;
    if (end >= offset || index == tags.length - 1) {
      return (index, start, end);
    }
    start = end + 1;
  }
  // Only an empty word list gets here, which has no word to point at.
  return (0, 0, 0);
}

class TagInput extends StatelessWidget {
  const TagInput({
    super.key,
    required this.controller,
    this.submit,
    this.multiInput = true,
    this.category,
    this.direction,
    this.readOnly = false,
    this.autofocus,
    this.labelText,
    this.decoration,
    this.textInputAction,
    this.focusNode,
    this.maxLines = 1,
    this.cutoutForFab,
    this.metatagSuggestions = false,
  });

  final SubmitString? submit;
  final TextEditingController? controller;
  final bool multiInput;
  final int? category;
  final VerticalDirection? direction;
  final bool readOnly;
  final bool? autofocus;
  final String? labelText;
  final InputDecoration? decoration;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final int? maxLines;
  final bool? cutoutForFab;

  /// Whether to suggest fixed metatag values for inputs like `order:`.
  ///
  /// The server's autocomplete rejects searches that contain a colon, so
  /// these suggestions are served from a local directory instead. Only inputs
  /// whose tags reach the server should enable this; tag inputs that match
  /// locally (like the denylist) must keep it off.
  final bool metatagSuggestions;

  @override
  Widget build(BuildContext context) {
    return SubDefault<TextEditingController>(
      value: controller,
      create: TextEditingController.new,
      builder: (context, controller) => SubValue(
        create: () {
          if (controller.text.isNotEmpty) {
            controller.text = controller.text.trimRight();
            controller.text += ' ';
          }
          return controller;
        },
        keys: [controller],
        builder: (context, controller) => AutocompleteTextField<TagSuggestion>(
          controller: controller,
          submit: submit,
          direction: direction,
          readOnly: readOnly,
          autofocus: autofocus ?? true,
          labelText: labelText,
          decoration: decoration,
          inputFormatters: [
            LowercaseTextInputFormatter(),
            if (!multiInput) FilteringTextInputFormatter.deny(' '),
          ],
          private: PrivateTextFields.of(context),
          textInputAction: textInputAction,
          focusNode: focusNode,
          maxLines: maxLines,
          cutoutForFab: cutoutForFab ?? true,
          onSelected: (suggestion) {
            List<String> tags = controller.text.split(' ');
            final (selection, start, _) = _findTag(
              tags,
              controller.selection.extent.offset,
            );
            String tag = tags[selection];
            // A stale suggestion can outlive the text it belonged to, like
            // after picking one suggestion right after another, which leaves
            // the current tag empty.
            if (tag.isEmpty) return;
            String operator = tag[0];
            if (!['-', '~'].contains(operator)) {
              operator = '';
            }
            tags[selection] = operator + suggestion.insertText;
            // A trailing empty token from the split would double the
            // closing space when the text already ends in one.
            controller.text = '${tags.join(' ').trimRight()} ';
            // The completed word takes the place of the one it replaced,
            // and the cursor stays at its end instead of the end of the
            // whole text.
            controller.selection = TextSelection.collapsed(
              offset: start + tags[selection].length,
            );
          },
          itemBuilder: (context, suggestion) => switch (suggestion) {
            TagNameSuggestion(:final tag) => Row(
              children: [
                Container(
                  color: TagCategory.values
                      .firstWhereOrNull((e) => e.id == tag.category)
                      ?.color,
                  height: 54,
                  width: 5,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      tag.name,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    NumberFormat.compact().format(tag.count),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            MetatagValueSuggestion() => Row(
              children: [
                Container(color: TagCategory.meta.color, height: 54, width: 5),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      suggestion.insertText,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    localizedFilterName(context, suggestion.name),
                    style: TextStyle(
                      fontSize: 16,
                      color: dimTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
          },
          suggestionsCallback: (pattern) async {
            List<String> tags = controller.text.split(' ');
            final (selection, _, _) = _findTag(
              tags,
              controller.selection.extent.offset,
            );
            String tag = tags[selection];
            if (tag.isEmpty) return [];
            final raw = tagToRaw(tag);
            // The server's autocomplete rejects colons, so metatags get their
            // values from the local directory instead.
            if (metatagSuggestions && raw.contains(':')) {
              return suggestMetatagValues(raw);
            }
            final client = context.read<Client>();
            return [
              for (final tag in await client.tags.autocomplete(
                search: raw,
                category: category,
                limit: 3,
              ))
                TagNameSuggestion(tag),
            ];
          },
        ),
      ),
    );
  }
}
