import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/posts.dart';

void main() {
  Post videoPost({
    String file = 'https://example.com/file.webm',
    Map<String, String?>? variants,
  }) => samplePost(ext: 'webm', file: file, variants: variants);

  group('PostVideoPlaying.videoVariants', () {
    test('drops null and non-video entries', () {
      final post = videoPost(
        variants: {
          '640x640': null,
          '1000x1000': 'https://example.com/image.jpg',
          '960x540': 'https://example.com/sample.mp4',
          '640x360': 'https://example.com/alt.webm',
        },
      );
      expect(post.videoVariants, {
        '960x540': 'https://example.com/sample.mp4',
        '640x360': 'https://example.com/alt.webm',
      });
    });

    test('has no variants without alternates', () {
      expect(videoPost().videoVariants, isEmpty);
    });
  });

  group('PostVideoPlaying.videoUrl', () {
    test('falls back to the source file', () {
      expect(
        videoPost().videoUrl(VideoResolution.source),
        'https://example.com/file.webm',
      );
      expect(
        videoPost(variants: {'640x640': null}).videoUrl(VideoResolution.high),
        'https://example.com/file.webm',
      );
    });

    test('selects the variant closest to the target', () {
      final post = videoPost(
        variants: {
          '1280x720': 'https://example.com/hi.mp4',
          '960x540': 'https://example.com/lo.mp4',
        },
      );
      // 960x540 is nearer to 480p than 1280x720 is.
      expect(
        post.videoUrl(VideoResolution.standard),
        'https://example.com/lo.mp4',
      );
      expect(post.videoUrl(VideoResolution.high), 'https://example.com/hi.mp4');
      // The largest variant wins for source quality.
      expect(
        post.videoUrl(VideoResolution.source),
        'https://example.com/hi.mp4',
      );
    });
  });

  group('PostVideoPlaying.hasVideoQualities', () {
    test('is true with a distinct variant', () {
      final post = videoPost(
        variants: {'1280x720': 'https://example.com/hi.mp4'},
      );
      expect(post.hasVideoQualities, isTrue);
    });

    test('a variant serving the source file is not a choice', () {
      // Original-tier mp4 posts re-list the untouched file under its size;
      // the source row alone is not a choice, so no picker is offered.
      final post = videoPost(
        variants: {'1280x720': 'https://example.com/file.webm'},
      );
      expect(post.hasVideoQualities, isFalse);
    });

    test('is false without variants', () {
      expect(videoPost().hasVideoQualities, isFalse);
    });
  });
}
