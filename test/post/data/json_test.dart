import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/fixtures.dart';

void main() {
  group('E621Post.fromJson live schema', () {
    // Recorded straight from e621.net after its 2026-11 schema change, so
    // the parser cannot drift away from the real payload shape.
    final posts = loadFixtureList(
      'posts_live.json',
    ).map(E621Post.fromJson).toList();

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
      expect(parsed.width, 0);
      expect(parsed.height, 0);
      expect(parsed.ext, 'jpg');
    });
  });
}
