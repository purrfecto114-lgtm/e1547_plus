import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LowercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // A non-empty composing region is text the keyboard has not committed
    // yet, like a pinyin or romaji candidate mid-composition. Rewriting it
    // would disturb the keyboard's own state, so the region is left alone;
    // the update that commits the composition runs through the
    // lowercasing here.
    if (newValue.composing != TextRange.empty) {
      return newValue;
    }
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}

extension TextEditingSelectionMovement on TextEditingController {
  void setFocusToStart() =>
      selection = const TextSelection(baseOffset: 0, extentOffset: 0);

  void setFocusToEnd() => selection = TextSelection(
    baseOffset: text.length,
    extentOffset: text.length,
  );
}

extension StringEllipsing on String {
  /// Truncates this string to [limit] code points and appends an ellipsis.
  ///
  /// Counting code points instead of UTF-16 code units keeps surrogate
  /// pairs intact: cutting an emoji in half at a code unit boundary
  /// would produce an invalid string.
  String ellipse(int limit) {
    if (runes.length > limit) {
      return '${String.fromCharCodes(runes.take(limit))}...';
    } else {
      return this;
    }
  }
}

extension StringNullifying on String {
  String? get nullWhenEmpty {
    if (trim().isEmpty) return null;
    return this;
  }
}

extension StringListTrimming on List<String> {
  /// Trims all strings in the list and removes empty strings.
  List<String> trim() =>
      map((e) => e.trim()).toList()..removeWhere((element) => element.isEmpty);
}

extension StringInfixRegexing on String {
  String get infixRegex => '.*${RegExp.escape(this)}.*';
}

String linkToDisplay(String link) {
  Uri? url = Uri.tryParse(link.trim());
  if (url == null) return link;
  List<String> allowed = ['v'];
  Map<String, dynamic> parameters = Map.of(url.queryParameters);
  parameters.removeWhere((key, value) => !allowed.contains(key));
  Uri newUrl = Uri(
    host: url.host,
    port: switch (url.port) {
      0 || 80 || 443 => null,
      _ => url.port,
    },
    path: url.path,
    queryParameters: parameters.isNotEmpty ? parameters : null,
  );
  String display = newUrl.toString();
  List<String> removed = [r'^///?', r'^www.', r'/$'];
  for (String pattern in removed) {
    display = display.replaceFirst(RegExp(pattern), '');
  }
  return display;
}
