import 'package:e1547/l10n/tag_descriptions.dart';
import 'package:e1547/l10n/tag_descriptions_ja.dart';
import 'package:e1547/l10n/tag_descriptions_zh.dart';
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

  test('serves both chinese scripts from the simplified list', () {
    final simplified = localizedTagDescription(
      'wolf',
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
    final traditional = localizedTagDescription(
      'wolf',
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    expect(simplified, isNotNull);
    expect(traditional, simplified);
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
