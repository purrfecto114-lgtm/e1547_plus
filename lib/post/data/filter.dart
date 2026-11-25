import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter.freezed.dart';

class PostFilter extends FilterController<Post>
    implements ValueNotifier<PostFilterValue> {
  PostFilter(this.client, [PostFilterValue? value])
    : _value = value ?? const PostFilterValue() {
    client.traits.addListener(_updateDenyList);
  }

  final Client client;

  PostFilterValue _value;

  final Map<int, _PostFilterCache> _filterCache = {};

  static const Duration _staleAfter = Duration(minutes: 5);

  DateTime _evictedAt = DateTime.now();

  void _updateDenyList() {
    // ignore: avoid_print
    print('UDL denylist=${client.traits.value.denylist}');
    _filterCache.clear();
    // The verdicts the tracked posts hold were computed against the old
    // denylist: mark them stale, so the next track over any route
    // re-judges them. The scheduled notify rides along.
    invalidate();
  }

  @override
  Object idOf(Post post) => post.id;

  // An undisplayable post (flash, censored) is filtered regardless of
  // the denylist; letting it through here would show a broken tile.
  @override
  bool filter(Post post) => post.isDisplayable && allows(post);

  bool allows(PostSummary post) => !denies(post);

  /// How many tracked posts the denylist currently hides.
  ///
  /// Undisplayable posts are not denylist blocks and must not inflate
  /// this count. The base class blockedCount counts everything the
  /// filter drops; this override subtracts the undisplayable ones,
  /// which track() has already filtered away, without re-running the
  /// denylist predicates over the corpus.
  @override
  int get blockedCount => super.blockedCount - _undisplayableTrackedCount;

  int get _undisplayableTrackedCount {
    var count = 0;
    for (final post in tracked) {
      if (!post.isDisplayable) count++;
    }
    return count;
  }

  @override
  PostFilterValue get value => _value;

  @override
  set value(PostFilterValue value) {
    if (_value == value) return;
    _value = value;
    _allowedEntriesView = null;
    _allowedPostsView = null;
    // allowedEntries, allowedPosts and the denying switch all ride
    // through here; every tracked verdict was computed against the old
    // value and must re-run.
    invalidate();
  }

  bool get denying => value.denying;
  set denying(bool enabled) => value = value.copyWith(denying: enabled);

  List<String> get allowedEntries => value.allowedEntries;
  set allowedEntries(List<String> entries) {
    final newValue = value.copyWith(allowedEntries: entries);
    if (value == newValue) return;
    _filterCache.clear();
    value = newValue;
  }

  List<int> get allowedPosts => value.allowedPosts;
  set allowedPosts(List<int> posts) =>
      value = value.copyWith(allowedPosts: posts);

  void allow(int postId) {
    if (!allowedPosts.contains(postId)) {
      allowedPosts = [...allowedPosts, postId];
    }
  }

  void disallow(int postId) {
    allowedPosts = allowedPosts.where((id) => id != postId).toList();
  }

  void enable(String entry) {
    if (!allowedEntries.contains(entry)) {
      allowedEntries = [...allowedEntries, entry];
    }
  }

  void disable(String entry) {
    if (allowedEntries.contains(entry)) {
      allowedEntries = allowedEntries.where((e) => e != entry).toList();
    }
  }

  void toggle(String entry) {
    if (allowedEntries.contains(entry)) {
      disable(entry);
    } else {
      enable(entry);
    }
  }

  Map<String, int> get blockedCountsByEntry {
    if (!denying) return const {};
    final counts = <String, int>{};
    // Set views cached per value; the drawer reads this getter on every
    // notify, and the entriesFor cache below is keyed by denylist
    // changes, so membership must stay O(1).
    final allowedPostIds = _allowedPostSet;
    final allowedEntrySet = _allowedEntrySet;
    for (final post in tracked) {
      // Undisplayable posts must not inflate any denylist entry count.
      if (!post.isDisplayable) continue;
      if (allowedPostIds.contains(post.id)) continue;
      for (final entry in entriesFor(post)) {
        if (allowedEntrySet.contains(entry)) continue;
        counts[entry] = (counts[entry] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<String> entriesFor(PostSummary post) {
    final now = DateTime.now();
    _evictStaleEntries(now);

    final cached = _filterCache[post.id];

    if (cached == null ||
        (!identical(cached.post, post) && cached.hash != post.hashCode)) {
      final deniers = post.getDeniers(client.traits.value.denylist).toList();
      _filterCache[post.id] = (
        post: post,
        hash: post.hashCode,
        entries: deniers,
        lastAccessed: now,
      );
      return deniers;
    }

    // Warm hit: the cached verdict is still keyed to this exact post.
    // Skipping the refresh write keeps the getter side-effect free on
    // the hot path — re-reading it repeatedly must not rewrite 500 map
    // entries per call. Stale entries still age out through the
    // eviction sweep above.
    if (cached.lastAccessed.isBefore(now)) {
      _filterCache[post.id] = (
        post: cached.post,
        hash: cached.hash,
        entries: cached.entries,
        lastAccessed: now,
      );
    }
    return cached.entries;
  }

  void _evictStaleEntries(DateTime now) {
    if (now.difference(_evictedAt) < _staleAfter) return;
    _evictedAt = now;
    final cutoff = now.subtract(_staleAfter);
    _filterCache.removeWhere((_, entry) => entry.lastAccessed.isBefore(cutoff));
  }

  bool blocks(PostSummary post) {
    if (!denying) return false;
    // Membership against the value's lists must not scan them linearly
    // per entry; keep Set views that refresh when the value changes.
    final allowed = _allowedEntrySet;
    return entriesFor(post).any((entry) => !allowed.contains(entry));
  }

  bool denies(PostSummary post) {
    if (_allowedPostSet.contains(post.id)) return false;
    return blocks(post);
  }

  Set<String> get _allowedEntrySet =>
      _allowedEntriesView ??= Set.of(allowedEntries);
  Set<String>? _allowedEntriesView;

  Set<int> get _allowedPostSet => _allowedPostsView ??= Set.of(allowedPosts);
  Set<int>? _allowedPostsView;

  @override
  void dispose() {
    client.traits.removeListener(_updateDenyList);
    super.dispose();
  }
}

class FavoritePostFilter extends PostFilter {
  FavoritePostFilter(super.client, [super.value]);

  @override
  bool allows(PostSummary post) {
    if (post.isFavorited) return true;
    return super.allows(post);
  }
}

typedef _PostFilterCache = ({
  PostSummary post,
  int hash,
  List<String> entries,
  DateTime lastAccessed,
});

@freezed
abstract class PostFilterValue with _$PostFilterValue {
  const factory PostFilterValue({
    @Default(true) bool denying,
    @Default([]) List<String> allowedEntries,
    @Default([]) List<int> allowedPosts,
  }) = _PostFilterValue;
}
