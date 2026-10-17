import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/post/post.dart';

abstract final class E621Post {
  static Post fromJson(dynamic json) => pick(json).letOrThrow(
    (post) => Post(
      id: post('id').asIntOrThrow(),
      file: post('file').letOrThrow((file) => file('url').asStringOrNull()),
      sample: post(
        'sample',
      ).letOrThrow((sample) => sample('url').asStringOrNull()),
      preview: post(
        'preview',
      ).letOrThrow((preview) => preview('url').asStringOrNull()),
      width: post('file').letOrThrow((file) => file('width').asIntOrThrow()),
      height: post('file').letOrThrow((file) => file('height').asIntOrThrow()),
      ext: post('file').letOrThrow((file) => file('ext').asStringOrThrow()),
      size: post('file').letOrThrow((file) => file('size').asIntOrThrow()),
      variants: post('sample', 'alternates').letOrNull((alternates) {
        if (alternates.asMapOrNull()?.isEmpty ?? true) return null;

        // Every tier holds entries of the same shape: width, height and url.
        // Entries missing any of those are skipped.
        Map<String, String?> foldEntries(Iterable<dynamic> entries) =>
            entries.fold<Map<String, String?>>({}, (acc, entry) {
              final w = pick(entry, 'width').asIntOrNull();
              final h = pick(entry, 'height').asIntOrNull();
              final url = pick(entry, 'url').asStringOrNull();
              if (w != null && h != null && url != null) {
                acc['${w}x$h'] = url;
              }
              return acc;
            });

        // The tiers are folded original, then samples, then codec variants,
        // so a per-codec re-encode of the same size wins over the original:
        // it is the data-efficient pick for an identical resolution.
        return {
          '${alternates('original', 'width').asIntOrThrow()}x${alternates('original', 'height').asIntOrThrow()}':
              alternates('original', 'url').asStringOrNull(),
          ...foldEntries(alternates('samples').asMapOrEmpty().values),
          ...foldEntries(alternates('variants').asMapOrEmpty().values),
        };
      }),
      tags: post('tags').letOrThrow(
        (pick) => pick.asMapOrThrow<String, List<dynamic>>().map(
          (key, value) => MapEntry(key, List.from(value)),
        ),
      ),
      uploaderId: post('uploader_id').asIntOrThrow(),
      uploaderName: post('uploader_name').asStringOrNull(),
      createdAt: post('created_at').asDateTimeOrThrow(),
      updatedAt: post('updated_at').asDateTimeOrNull(),
      score: post('score').letOrThrow((pick) => pick('total').asIntOrThrow()),
      vote: post('vote').asIntOrNull(),
      isDeleted: post(
        'flags',
      ).letOrThrow((pick) => pick('deleted').asBoolOrThrow()),
      rating: post(
        'rating',
      ).letOrThrow((pick) => Rating.values.asNameMap()[pick.asString()]!),
      favCount: post('fav_count').asIntOrThrow(),
      isFavorited: post('is_favorited').asBoolOrThrow(),
      commentCount: post('comment_count').asIntOrThrow(),
      description: post('description').asStringOrThrow(),
      sources: post('sources').asListOrThrow((pick) => pick.asStringOrThrow()),
      pools: post('pools').asListOrThrow((pick) => pick.asIntOrThrow()),
      relationships: post('relationships').letOrThrow(
        (pick) => Relationships.fromJson(pick.asMapOrThrow<String, dynamic>()),
      ),
    ),
  );
}
