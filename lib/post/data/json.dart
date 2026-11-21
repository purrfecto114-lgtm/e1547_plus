import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/post/post.dart';

/// The server's tag category ids and the category names they map to
/// (TagCategory.id in lib/tag). The post payload no longer groups tags by
/// category, so posts carry this table to rebuild that map.
const Map<int, String> e621TagCategoryNames = {
  0: 'general',
  1: 'artist',
  2: 'contributor',
  3: 'copyright',
  4: 'character',
  5: 'species',
  6: 'invalid',
  7: 'meta',
  8: 'lore',
};

abstract final class E621Post {
  /// [tagCategories] maps tag names to the server's category ids. Names
  /// missing from it (a failed or partial lookup) count as general.
  static Post fromJson(
    dynamic json, {
    Map<String, int> tagCategories = const {},
  }) => pick(json).letOrThrow((post) {
    final tags = post('tags').asListOrThrow((pick) => pick.asStringOrThrow());
    return Post(
      id: post('id').asIntOrThrow(),
      file: post('files', 'original', 'url').asStringOrNull(),
      sample: post('files', 'sample', 'jpg').asStringOrNull(),
      preview: post('files', 'preview', 'jpg').asStringOrNull(),
      // A post whose original tier is gone (removed from the cdn, a
      // replacement in flight) must not fail the whole post. The
      // dimensions fall back to the tiers the post actually displays,
      // because zero would divide into a NaN aspect ratio that trips
      // the framework's own asserts in debug builds.
      width:
          post('files', 'original', 'width').asIntOrNull() ??
          post('files', 'sample', 'width').asIntOrNull() ??
          post('files', 'preview', 'width').asIntOrNull() ??
          0,
      height:
          post('files', 'original', 'height').asIntOrNull() ??
          post('files', 'sample', 'height').asIntOrNull() ??
          post('files', 'preview', 'height').asIntOrNull() ??
          0,
      ext: post('files', 'meta', 'ext').asStringOrThrow(),
      size: post('files', 'meta', 'size').asIntOrThrow(),
      variants: post('files', 'video').letOrNull(_variants),
      tags: groupTags(tags, tagCategories),
      // Anonymous or unknown uploaders must not fail the whole
      // post; 0 is no real user id on the server.
      uploaderId: post('uploader_id').asIntOrNull() ?? 0,
      uploaderName: post('uploader_name').asStringOrNull(),
      createdAt: post('created_at').asDateTimeOrThrow(),
      updatedAt: post('updated_at').asDateTimeOrNull(),
      score: post('stats', 'score', 'total').asIntOrThrow(),
      vote: post('stats', 'vote').asIntOrNull(),
      isDeleted: post('flags', 'deleted').asBoolOrThrow(),
      // An unknown rating must not fail the whole post; unparseable
      // or missing values fall back to the server's upload default.
      rating:
          Rating.values.asNameMap()[post('rating').asStringOrNull()] ??
          Rating.q,
      favCount: post('stats', 'fav_count').asIntOrThrow(),
      isFavorited: post('stats', 'is_favorited').asBoolOrThrow(),
      commentCount: post('stats', 'comment_count').asIntOrThrow(),
      description: post('description').asStringOrThrow(),
      sources: post('sources').asListOrThrow((pick) => pick.asStringOrThrow()),
      pools: post('pools').asListOrThrow((pick) => pick.asIntOrThrow()),
      relationships: Relationships(
        parentId: post('relationships', 'parent_id').asIntOrNull(),
        hasChildren: post('has', 'children').asBoolOrThrow(),
        hasActiveChildren: post('has', 'active_children').asBoolOrNull(),
        children: post(
          'relationships',
          'children',
        ).asListOrThrow((pick) => pick.asIntOrThrow()),
      ),
    );
  });

  /// Groups flat tag names by their category name. Unknown category ids
  /// count as general, and names missing from [tagCategories] too.
  static Map<String, List<String>> groupTags(
    List<String> tags,
    Map<String, int> tagCategories,
  ) {
    final result = <String, List<String>>{};
    for (final tag in tags) {
      final category =
          e621TagCategoryNames[tagCategories[tag] ?? 0] ?? 'general';
      (result[category] ??= []).add(tag);
    }
    return result;
  }

  /// The video tiers folded into a size→url table, mirroring the old
  /// `sample.alternates`: the original first, then per-size samples, then
  /// codec variants, so a same-size re-encode wins over the original.
  static Map<String, String?>? _variants(Pick video) {
    if (video('has').asBoolOrNull() != true) return null;
    final original = video('original');
    final width = original('width').asIntOrNull();
    final height = original('height').asIntOrNull();
    return {
      if (width != null && height != null)
        '${width}x$height': original('url').asStringOrNull(),
      ..._foldTier(video('samples')),
      ..._foldTier(video('variants')),
    };
  }

  /// Tiers are maps of name → entry (width, height and url). Entries
  /// missing any of those are skipped.
  static Map<String, String?> _foldTier(Pick tier) =>
      tier.asMapOrNull<String, dynamic>()?.values.fold<Map<String, String?>>(
        <String, String?>{},
        (Map<String, String?> acc, entry) {
          final width = pick(entry, 'width').asIntOrNull();
          final height = pick(entry, 'height').asIntOrNull();
          final url = pick(entry, 'url').asStringOrNull();
          if (width != null && height != null && url != null) {
            acc['${width}x$height'] = url;
          }
          return acc;
        },
      ) ??
      const {};
}
