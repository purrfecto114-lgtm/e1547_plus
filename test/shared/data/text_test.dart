import 'package:e1547/shared/shared.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LowercaseTextInputFormatter', () {
    test('lowercases committed text', () {
      final formatter = LowercaseTextInputFormatter();
      const value = TextEditingValue(
        text: 'OrDeR:rAnK',
        selection: TextSelection.collapsed(offset: 10),
      );
      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, value),
        const TextEditingValue(
          text: 'order:rank',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );
    });

    test('leaves composing text alone', () {
      final formatter = LowercaseTextInputFormatter();
      // A pinyin or romaji keyboard holds its uncommitted candidate in the
      // composing region; rewriting it would disturb the composition.
      const value = TextEditingValue(
        text: 'wolf Nihao',
        selection: TextSelection.collapsed(offset: 10),
        composing: TextRange(start: 5, end: 10),
      );
      expect(formatter.formatEditUpdate(TextEditingValue.empty, value), value);
    });

    test('lowercases text once its composition commits', () {
      final formatter = LowercaseTextInputFormatter();
      const composing = TextEditingValue(
        text: 'wolf Nihao',
        selection: TextSelection.collapsed(offset: 10),
        composing: TextRange(start: 5, end: 10),
      );
      // The commit itself still carries the uncommitted capital, which
      // the formatter then lowercases.
      const committed = TextEditingValue(
        text: 'wolf Nihao',
        selection: TextSelection.collapsed(offset: 10),
      );
      expect(
        formatter.formatEditUpdate(composing, committed),
        const TextEditingValue(
          text: 'wolf nihao',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );
    });
  });
}
