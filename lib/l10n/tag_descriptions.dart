import 'dart:ui';

import 'package:e1547/l10n/tag_descriptions_ja.dart';
import 'package:e1547/l10n/tag_descriptions_zh.dart';

/// Returns the curated offline tag description for [rawTag] in the user's
/// language, or null when the tag has no curated entry or the language has
/// no offline dictionary.
///
/// The site's tag wikis are English only; these dictionaries give users a
/// short explanation for the tags they meet most often, without a network
/// round trip. Simplified Chinese entries serve both chinese scripts.
String? localizedTagDescription(String rawTag, Locale locale) {
  switch (locale.languageCode) {
    case 'zh':
      return tagDescriptionsZh[rawTag];
    case 'ja':
      return tagDescriptionsJa[rawTag];
    default:
      return null;
  }
}
