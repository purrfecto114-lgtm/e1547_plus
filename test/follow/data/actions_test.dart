import 'package:e1547/follow/follow.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/posts.dart';

void main() {
  const bookmark = Follow(
    id: 1,
    tags: 'canine',
    title: null,
    alias: null,
    type: FollowType.bookmark,
    latest: null,
    unseen: null,
    thumbnail: null,
    updated: null,
  );

  group('Follow.withUnseen', () {
    test('takes the thumbnail of an older post when the newest has none', () {
      final updated = bookmark.withUnseen([
        samplePost(id: 2, preview: '/preview/2'),
        samplePost(id: 3),
      ]);

      expect(updated.latest, 3);
      expect(updated.thumbnail, '/preview/2');
    });

    test('prefers the newest post that has a thumbnail', () {
      final updated = bookmark.withUnseen([
        samplePost(id: 2, preview: '/preview/2'),
        samplePost(id: 3, preview: '/preview/3'),
      ]);

      expect(updated.thumbnail, '/preview/3');
    });

    test('keeps the previous thumbnail when no post has one', () {
      final updated = bookmark
          .copyWith(thumbnail: '/preview/1', latest: 1, unseen: 0)
          .withUnseen([samplePost(id: 3)]);

      expect(updated.latest, 3);
      expect(updated.thumbnail, '/preview/1');
    });

    test('counts unseen posts even when the batch is not sorted', () {
      // The sync's assign() hands a follow its posts in api order, which
      // is newest-first today but not guaranteed; takeWhile on an
      // unsorted batch would stop at the first old post and drop the
      // newer ones after it.
      final updated = bookmark.copyWith(latest: 1, unseen: 0).withUnseen([
        samplePost(id: 2, preview: '/preview/2'),
        samplePost(id: 5, preview: '/preview/5'),
        samplePost(id: 3, preview: '/preview/3'),
      ]);

      // latest is 1, so every post in the batch (2, 5, 3) counts as new;
      // the order they arrived in must not matter.
      expect(updated.latest, 5);
      expect(updated.unseen, 3);
    });

    test('does not count the previously latest post as unseen', () {
      final updated = bookmark.copyWith(latest: 3, unseen: 0).withUnseen([
        samplePost(id: 3, preview: '/preview/3'),
        samplePost(id: 2, preview: '/preview/2'),
      ]);

      expect(updated.unseen, 0);
      expect(updated.latest, 3);
    });
  });
}
