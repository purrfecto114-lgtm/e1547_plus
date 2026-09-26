import 'dart:ui';

/// Languages selectable in the settings.
///
/// Labels are the languages' native names and are never translated.
const List<({String value, String label})> appLanguages = [
  (value: 'en', label: 'English'),
  (value: 'zh', label: '简体中文'),
  (value: 'zh_Hant', label: '繁體中文'),
];

/// Parses a stored language value into a locale.
///
/// Returns null for a null value, meaning the system language.
Locale? parseLanguage(String? value) {
  if (value == null) return null;
  List<String> parts = value.split('_');
  return Locale.fromSubtags(
    languageCode: parts.first,
    scriptCode: parts.length > 1 ? parts[1] : null,
  );
}
