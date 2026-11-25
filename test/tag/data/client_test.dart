import 'package:e1547/tag/tag.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/client.dart';
import '../../_support/fake_e621.dart';
import '../../_support/fixtures.dart';
import '../../_support/harness.dart';

void main() {
  late FakeE621 fake;
  late TagClient client;

  setUpAll(initializeTestApp);

  setUp(() async {
    fake = await FakeE621.start();
    client = TagClient(dio: dioFor(fake));
  });

  tearDown(() => fake.stop());

  test('maps a recorded tag onto the model', () async {
    final recorded = loadFixtureList('tags.json').first;

    final tag = (await client.page()).first;

    expect(tag.id, recorded['id']);
    expect(tag.name, recorded['name']);
    expect(tag.count, recorded['post_count']);
    expect(tag.category, recorded['category']);
  });

  test('resolves an alias to its consequent', () async {
    final recorded = loadFixtureList(
      'tag_aliases.json',
    ).firstWhere((e) => e['status'] != 'deleted');

    final alias = await client.aliases(
      query: {
        'search[antecedent_name]': recorded['antecedent_name']! as String,
      },
    );

    expect(alias, recorded['consequent_name']);
  });

  test('previews the tags an edit would apply', () async {
    final recorded = loadFixtureList('tags.json').first;
    final known = recorded['name']! as String;
    const unknown = 'made_up_tag';

    final previews = await client.preview(tags: '$known $unknown');

    // Every posted name is answered, in the posted order.
    expect(previews.map((e) => e.name), [known, unknown]);

    final preview = previews.first;
    expect(preview.id, recorded['id']);
    expect(preview.category, recorded['category']);
    expect(preview.postCount, recorded['post_count']);

    // A name the server has no record of comes back bare — no id —
    // which the tag editor renders as a new tag instead of failing
    // the whole preview.
    final bare = previews.last;
    expect(bare.id, isNull);
    expect(bare.category, isNull);
    expect(bare.postCount, isNull);
  });
}
