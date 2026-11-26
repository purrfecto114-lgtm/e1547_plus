import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/fixtures.dart';

void main() {
  group('E621Post.fromJson live schema', () {
    // Recorded straight from e621.net after its 2026-11 schema change, so
    // the parser cannot drift away from the real payload shape.
    final posts = loadFixtureList('posts_live.json')
        .map(E621Post.fromJson)
        .toList();

    test('parses a recorded video post', () {
      final post = posts[0];
      expect(post.ext, 'mp4');
      expect(post.file, isNotNull);
      expect(post.sample, isNotNull);
      expect(post.preview, isNotNull);
      expect(post.width, 1920);
      expect(post.height, 1080);
      expect(
        post.variants!.keys,
        containsAll(<String>{'1920x1080', '854x480', '1280x720'}),
      );
      expect(post.variants!['854x480'], contains('_480p.mp4'));
      expect(post.variants!['1280x720'], contains('_720p.mp4'));
      expect(post.score, 0);
      expect(post.rating, Rating.e);
    });

    test('parses a recorded pooled image post', () {
      final post = posts[1];
      expect(post.ext, 'png');
      expect(post.pools, isNotEmpty);
      expect(post.variants, isNull);
      // Without a category lookup every tag counts as general.
      expect(post.tags.keys, ['general']);
      expect(post.tags['general'], isNotEmpty);
    });
  });

  group('E621Post.fromJson video variants', () {
    final posts = loadFixtureList('posts.json').map(E621Post.fromJson).toList();

    test('posts without alternates have no variants', () {
      expect(posts[0].variants, isNull);
    });

    test('parses the sample and codec variant tiers', () {
      // post 1021: original 640x640 webm, variants.mp4 640x640 h264,
      // samples.480p is actually 480x480.
      expect(posts[1].variants, {
        '640x640':
            '{{host}}/data/sample/24/88/24881626424881626424881626424881.mp4',
        '480x480':
            '{{host}}/data/sample/43/07/43077983743077983743077983743077.mp4',
      });
      // post 1042: original 1280x720 webm, variants.mp4 1280x720 h264,
      // samples.480p is actually 960x540.
      expect(posts[2].variants, {
        '1280x720':
            '{{host}}/data/sample/61/53/61538337061538337061538337061538.mp4',
        '960x540':
            '{{host}}/data/sample/19/41/19418725519418725519418725519418.mp4',
      });
    });

    test('a codec re-encode overrides the original of the same size', () {
      // Both video posts re-encode their original resolution as mp4;
      // the parsed url of that key must be the re-encode, not the file.
      for (final post in posts.skip(1)) {
        final key = '${post.width}x${post.height}';
        expect(post.variants!.keys, contains(key));
        expect(post.variants![key], isNot(post.file));
        expect(post.variants![key], endsWith('.mp4'));
      }
    });

    test('the acceptance post selects its 1280x720 mp4 variant', () {
      expect(
        posts[2].videoUrl(VideoResolution.medium),
        '{{host}}/data/sample/61/53/61538337061538337061538337061538.mp4',
      );
      expect(
        posts[2].videoUrl(VideoResolution.high),
        '{{host}}/data/sample/61/53/61538337061538337061538337061538.mp4',
      );
      expect(
        posts[2].videoUrl(VideoResolution.low),
        '{{host}}/data/sample/19/41/19418725519418725519418725519418.mp4',
      );
    });
  });

  group('E621Post.fromJson extended tags', () {
    // Recorded from e621.net with the `mode=extended` query the client
    // sends: the server answers with tags grouped by category instead
    // of the flat list, and the parser must read both shapes.
    final posts = loadFixtureList('posts_extended.json')
        .map(E621Post.fromJson)
        .toList();

    test('parses tags grouped by the server itself', () {
      final post = posts[0];
      final raw = loadFixtureList('posts_extended.json').first;
      final grouped = (raw['tags']! as Map<String, dynamic>);
      // Without a category lookup, the parser copies the server's own
      // grouping: every category carrying names stays under its key.
      // The server also lists categories this post has none of — the
      // parser drops those, so a lookup regrouping the same names
      // produces the exact same shape.
      for (final entry in grouped.entries) {
        if ((entry.value as List).isEmpty) continue;
        expect(post.tags[entry.key], entry.value);
      }
      expect(post.tags.values, everyElement(isNotEmpty));
    });

    test('groups a flat list through the category lookup', () {
      // The extended shape already carries groups; a lookup must keep
      // the same names in the same groups.
      final flat =
          (loadFixtureList('posts_extended.json').first['tags']!
                  as Map<String, dynamic>)
              .values
              .expand((list) => list as List)
              .cast<String>()
              .toList();
      final regrouped = E621Post.groupTags(flat, const {'annaleigh': 1});
      expect(regrouped['artist'], contains('annaleigh'));
      expect(regrouped.values.expand((tags) => tags).toSet(), flat.toSet());
    });

    test('parses partial summaries from the extended shape', () {
      final raw = loadFixtureList('posts_extended.json').first;
      final partial = E621Post.partialFromJson(raw);
      expect(partial.id, raw['id']);
      final flat = (raw['tags']! as Map<String, dynamic>).values
          .expand((list) => list as List)
          .cast<String>()
          .toList();
      expect(partial.allTags, containsAll(flat));
      expect(partial.allTags.length, flat.length);
    });
  });

  group('E621Post.partialFromJson artist recommendations', () {
    // Recorded straight from the live similar/artist endpoint: unlike
    // every other posts endpoint, its post_data summaries still carry
    // the legacy flat layout (file_url and friends, space-separated
    // tags and flag words), and the parser must read that shape too.
    final recs =
        loadFixture('artist_recommendations_live.json')!
            as Map<String, Object?>;
    final List<Map<String, Object?>> postData = [
      for (final post in recs['post_data']! as List)
        post! as Map<String, Object?>,
    ];
    final List<Map<String, Object?>> results = [
      for (final result in recs['results']! as List)
        result! as Map<String, Object?>,
    ];
    final partials = [
      for (final Map<String, Object?> post in postData)
        E621Post.partialFromJson(post),
    ];

    test('parses every recorded summary', () {
      // The live endpoint answers with the legacy shape; one throwing
      // entry would empty the whole recommendations row in production.
      expect(partials, hasLength(6));
      expect(partials.map((e) => e.id), [
        for (final Map<String, Object?> post in postData) post['id']! as int,
      ]);
      // post_data arrives sorted by id, results carries the actual
      // recommendation order — which is why the client reorders.
      expect([
        for (final Map<String, Object?> result in results)
          result['post_id']! as int,
      ], isNot(partials.map((e) => e.id).toList()));
    });

    test('reads the flat file fields', () {
      final partial = partials[0];
      final raw = postData.first;
      expect(partial.file, raw['file_url']);
      expect(partial.sample, raw['sample_url']);
      expect(partial.preview, raw['preview_url']);
      expect(partial.width, raw['width']);
      expect(partial.height, raw['height']);
      expect(partial.ext, raw['file_ext']);
      expect(partial.size, raw['size']);
      expect(partial.rating, Rating.e);
      expect(partial.isDeleted, isFalse);
    });

    test('splits the space-separated tags and flag words', () {
      final partial = partials[0];
      final raw = postData.first;
      expect(partial.allTags.toList(), (raw['tags']! as String).split(' '));
      expect(partial.pools, isEmpty);
      // The recorded posts carry no deleted flag word.
      expect(partial.isDeleted, isFalse);
    });

    test('reads the flat counts and uploader', () {
      final partial = partials[0];
      final raw = postData.first;
      expect(partial.score, raw['score']);
      expect(partial.favCount, raw['fav_count']);
      expect(partial.uploaderName, raw['uploader']);
      expect(partial.uploaderId, raw['uploader_id']);
      expect(partial.vote, raw['vote']);
      expect(partial.commentCount, raw['comment_count']);
      expect(partial.isFavorited, raw['is_favorited']);
      expect(partial.createdAt.toIso8601String(), isNotEmpty);
    });
  });

  group('E621Post.fromJson tolerance', () {
    // A server that stops carrying one file tier (a post removed from the
    // cdn, a replacement in flight) must not fail the whole page of posts.
    test('a post whose original file is absent still parses', () {
      final post = loadFixtureList('posts.json')[0];
      final stripped = {
        ...post,
        'files': {
          ...(post['files']! as Map<String, dynamic>)..remove('original'),
        },
      };
      final parsed = E621Post.fromJson(stripped);
      expect(parsed.file, isNull);
      expect(parsed.ext, 'jpg');
    });

    test('a missing original falls back to the sample dimensions', () {
      // Zero dimensions divide into NaN aspect ratios, which trip the
      // framework's own asserts in debug builds; the sample tier the
      // post actually displays is the honest fallback.
      final post = loadFixtureList('posts.json')[0];
      final sample =
          (post['files']! as Map<String, dynamic>)['sample']!
              as Map<String, dynamic>;
      final stripped = {
        ...post,
        'files': {
          ...(post['files']! as Map<String, dynamic>)..remove('original'),
        },
      };
      final parsed = E621Post.fromJson(stripped);
      expect(parsed.width, sample['width']);
      expect(parsed.height, sample['height']);
    });
  });
}
