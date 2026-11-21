import 'package:e1547/markup/data/data.dart';
import 'package:flutter_test/flutter_test.dart';

// Block containers ([quote], [section], [spoiler]) recurse through
// _withActiveClose; without a cap a hostile description nests the parser
// deep enough to overflow the UI isolate's stack.

void main() {
  group('DTextGrammar block depth limit', () {
    test('deeply nested quotes degrade to text instead of overflowing', () {
      // 10k quotes overflow the isolate stack without a cap (probed:
      // 2k is fine, 10k dies in _withActiveClose's recursion).
      final input = '${'[quote]' * 10000}text${'[/quote]' * 10000}';
      final doc = DTextGrammar().parse(input);
      expect(doc.children, isNotEmpty);
    });

    test('quotes nested within the cap still nest', () {
      final input = '${'[quote]' * 10}text${'[/quote]' * 10}';
      final doc = DTextGrammar().parse(input);
      DTextQuote node = doc.children.single as DTextQuote;
      for (var i = 0; i < 9; i++) {
        node = node.children.single as DTextQuote;
      }
      expect(node.children.single, isA<DTextParagraph>());
    });

    test('deeply nested sections degrade to text instead of overflowing', () {
      final input = '${'[section]' * 10000}text${'[/section]' * 10000}';
      final doc = DTextGrammar().parse(input);
      expect(doc.children, isNotEmpty);
    });
  });
}
