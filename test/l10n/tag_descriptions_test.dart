import 'package:e1547/l10n/tag_descriptions.dart';
import 'package:e1547/l10n/tag_descriptions_ja.dart';
import 'package:e1547/l10n/tag_descriptions_zh.dart';
import 'package:e1547/l10n/tag_descriptions_zh_hant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('describes common tags for chinese users', () {
    expect(
      localizedTagDescription('canid', const Locale('zh')),
      contains('犬科'),
    );
    expect(
      localizedTagDescription('gynomorph', const Locale('zh')),
      isNotEmpty,
    );
  });

  test('describes tags from the imported community dictionary', () {
    // from the GPL dictionary's full-tag tables, one per source category
    expect(
      localizedTagDescription('german_shepherd', const Locale('zh')),
      contains('德国牧羊犬'),
    );
    expect(
      localizedTagDescription('renamon', const Locale('zh')),
      contains('妖狐兽'),
    );
    expect(
      localizedTagDescription('pokemon', const Locale('zh')),
      contains('宝可梦'),
    );
    // curated entries win over differing community translations
    expect(
      localizedTagDescription('jackal', const Locale('zh')),
      contains('胡狼'),
    );
  });

  test('describes common tags for japanese users', () {
    expect(
      localizedTagDescription('canid', const Locale('ja')),
      contains('イヌ科'),
    );
    expect(
      localizedTagDescription('gynomorph', const Locale('ja')),
      isNotEmpty,
    );
  });

  test('serves each chinese script from its own list', () {
    final simplified = localizedTagDescription(
      'wolf',
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
    final traditional = localizedTagDescription(
      'wolf',
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    expect(simplified, isNotNull);
    expect(traditional, isNotNull);
    // the traditional list is generated from the simplified one, so it
    // covers the same tags; characters that share a form stay identical
    expect(traditional, contains('狼'));
    // simplified entries use simplified wording
    expect(
      localizedTagDescription(
        'german_shepherd',
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ),
      '德国牧羊犬。',
    );
    expect(
      localizedTagDescription(
        'german_shepherd',
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ),
      '德國牧羊犬。',
    );
    // a generic chinese locale is simplified by default
    expect(
      localizedTagDescription('wolf', const Locale('zh')),
      localizedTagDescription(
        'wolf',
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ),
    );
  });

  test('returns nothing for languages without a dictionary', () {
    expect(localizedTagDescription('canid', const Locale('en')), isNull);
    expect(localizedTagDescription('canid', const Locale('de')), isNull);
    expect(localizedTagDescription('canid', const Locale('fr')), isNull);
  });

  test('returns nothing for unknown tags', () {
    expect(
      localizedTagDescription(
        'definitely_not_a_curated_tag',
        const Locale('zh'),
      ),
      isNull,
    );
  });

  test('the dictionaries use concise clinical wording', () {
    for (final entry in tagDescriptionsZh.entries) {
      expect(entry.key, isNotEmpty);
      // curated descriptions stay short; wikis can be pages long
      expect(entry.value.length, lessThan(60));
      // every entry ends with a full stop, like the site's short summaries
      expect(
        entry.value.endsWith('。'),
        isTrue,
        reason: '${entry.key} misses its full stop',
      );
    }
    for (final entry in tagDescriptionsZhHant.entries) {
      expect(entry.key, isNotEmpty);
      expect(entry.value.length, lessThan(60));
      expect(
        entry.value.endsWith('。'),
        isTrue,
        reason: '${entry.key} misses its full stop',
      );
      // the traditional list covers exactly the simplified list's tags
      expect(tagDescriptionsZh.containsKey(entry.key), isTrue);
    }
    expect(tagDescriptionsZhHant.length, tagDescriptionsZh.length);
    for (final entry in tagDescriptionsJa.entries) {
      expect(entry.key, isNotEmpty);
      expect(entry.value.length, lessThan(60));
      expect(
        entry.value.endsWith('。'),
        isTrue,
        reason: '${entry.key} misses its full stop',
      );
    }
  });
}
