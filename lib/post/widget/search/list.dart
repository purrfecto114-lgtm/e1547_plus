import 'dart:math';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

/// The resolved paged state of a posts search.
typedef PostPageState = InfiniteQueryStatus<List<Post>, Object>;

/// The id query backing a [PostPageState].
typedef PostPageQuery = InfiniteQuery<List<Object>, Object>;

class PostList extends StatelessWidget {
  const PostList({super.key, this.displayType, this.state, this.query});

  final PostDisplayType? displayType;

  /// A prebuilt resolved paged state of the posts to show.
  ///
  /// When this and [query] are given, they are used directly, so the route
  /// shares a single set of query subscriptions instead of every layer
  /// resolving its own; otherwise this widget builds its own
  /// [PostPageQueryBuilder]. Both must be passed together.
  final PostPageState? state;

  /// The query backing [state].
  final PostPageQuery? query;

  @override
  Widget build(BuildContext context) {
    Widget buildList(
      BuildContext context,
      PostPageState state,
      PostPageQuery query,
    ) {
      // The scroll view shadows the primary scroll controller from the
      // footer inside it, so it is handed in from out here.
      final scrollController = PrimaryScrollController.of(context);
      return PullToRefresh(
        onRefresh: query.revalidate,
        child: CustomScrollView(
          primary: true,
          slivers: [
            if (state.error case final error?
                when isConnectionError(error) &&
                    (state.data?.pages.isNotEmpty ?? false))
              SliverToBoxAdapter(
                child: _OfflineBanner(onRetry: query.invalidate),
              ),
            SliverPadding(
              padding: defaultListPadding,
              sliver: SliverPostList(
                displayType: displayType,
                state: state,
                query: query,
              ),
            ),
            // The footer carries the bottom clearance of the list, so the
            // posts end flush above it.
            SliverPadding(
              padding: defaultListPadding.copyWith(
                bottom: defaultActionListPadding.bottom,
              ),
              sliver: SliverToBoxAdapter(
                child: PostListFooter(
                  state: state,
                  query: query,
                  scrollController: scrollController,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final PostPageState? state = this.state;
    final PostPageQuery? query = this.query;
    if (state != null && query != null) {
      return buildList(context, state, query);
    }
    return PostPageQueryBuilder(
      builder: (context, state, query) => buildList(context, state, query),
    );
  }
}

class SliverPostList extends StatelessWidget {
  const SliverPostList({super.key, this.displayType, this.state, this.query});

  final PostDisplayType? displayType;

  /// A prebuilt resolved paged state of the posts to show.
  ///
  /// When this and [query] are given, they are used directly; otherwise
  /// this widget builds its own [PostPageQueryBuilder]. Both must be
  /// passed together.
  final PostPageState? state;

  /// The query backing [state].
  final PostPageQuery? query;

  @override
  Widget build(BuildContext context) {
    Widget buildSliver(
      BuildContext context,
      PostPageState state,
      PostPageQuery query,
    ) => switch (displayType ??
        context.watch<PostDisplayController?>()?.value ??
        PostDisplayType.grid) {
      PostDisplayType.grid => PostGridSliver(
        state: state.paging,
        fetchNextPage: query.getNextPage,
      ),
      PostDisplayType.comic => PostComicSliver(
        state: state.paging,
        fetchNextPage: query.getNextPage,
      ),
      PostDisplayType.timeline => PostTimelineSliver(
        state: state.paging,
        fetchNextPage: query.getNextPage,
      ),
    };

    final PostPageState? state = this.state;
    final PostPageQuery? query = this.query;
    if (state != null && query != null) {
      return buildSliver(context, state, query);
    }
    return PostPageQueryBuilder(
      builder: (context, state, query) => buildSliver(context, state, query),
    );
  }
}

class PostGridSliver extends StatelessWidget {
  const PostGridSliver({
    super.key,
    required this.state,
    required this.fetchNextPage,
  });

  final PagingState<Object, Post> state;
  final VoidCallback fetchNextPage;

  @override
  Widget build(BuildContext context) {
    PagedChildBuilderDelegate<Post> buildBuilderDelegate(
      ItemWidgetBuilder<Post> itemBuilder,
    ) => defaultPagedChildBuilderDelegate<Post>(
      onRetry: fetchNextPage,
      onEmpty: Text(AppLocalizations.of(context).noPosts),
      onError: switch (state.error) {
        final error? when isConnectionError(error) => Text(
          AppLocalizations.of(context).offlineNoData,
        ),
        _ => Text(AppLocalizations.of(context).failedToLoadPosts),
      },
      itemBuilder: itemBuilder,
    );

    Widget itemBuilder(context, item, index) => ImageCacheSizeProvider(
      // Grid tiles decode their images at twice the tile size, which
      // only stays sharp on high density screens when the cap also
      // scales with the device pixel ratio. The upper bound keeps very
      // dense screens from decoding thumbnails like fullscreen images.
      size: min(
        (TileLayout.of(context).tileSize *
                2 *
                MediaQuery.devicePixelRatioOf(context))
            .round(),
        1080,
      ),
      child: PostTile(post: item),
    );

    return switch (TileLayout.of(context).stagger) {
      GridQuilt.square => PagedSliverGrid<Object, Post>(
        showNewPageErrorIndicatorAsGridChild: false,
        showNewPageProgressIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: buildBuilderDelegate(itemBuilder),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: TileLayout.of(context).crossAxisCount,
          childAspectRatio: 1 / TileLayout.of(context).tileHeightFactor,
        ),
      ),
      GridQuilt.vertical => PagedSliverMasonryGrid<Object, Post>.count(
        showNewPageErrorIndicatorAsGridChild: false,
        showNewPageProgressIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: buildBuilderDelegate(
          (context, item, index) => AspectRatio(
            aspectRatio: 1 / (item.height / item.width),
            child: itemBuilder(context, item, index),
          ),
        ),
        crossAxisCount: TileLayout.of(context).crossAxisCount,
      ),
    };
  }
}

class PostComicSliver extends StatelessWidget {
  const PostComicSliver({
    super.key,
    required this.state,
    required this.fetchNextPage,
  });

  final PagingState<Object, Post> state;
  final VoidCallback fetchNextPage;

  @override
  Widget build(BuildContext context) {
    return PagedSliverList(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: defaultPagedChildBuilderDelegate<Post>(
        onRetry: fetchNextPage,
        onEmpty: Text(AppLocalizations.of(context).noPosts),
        onError: Text(AppLocalizations.of(context).failedToLoadPosts),
        itemBuilder: (context, item, index) => Padding(
          padding:
              LimitedWidthLayout.maybeOf(context)?.padding ?? EdgeInsets.zero,
          child: ImageCacheSizeProvider(
            size: 800,
            child: PostComicTile(post: item),
          ),
        ),
      ),
    );
  }
}

class PostTimelineSliver extends StatelessWidget {
  const PostTimelineSliver({
    super.key,
    required this.state,
    required this.fetchNextPage,
  });

  final PagingState<Object, Post> state;
  final VoidCallback fetchNextPage;

  @override
  Widget build(BuildContext context) {
    return PagedSliverList(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: defaultPagedChildBuilderDelegate<Post>(
        onRetry: fetchNextPage,
        onEmpty: Text(AppLocalizations.of(context).noPosts),
        onError: Text(AppLocalizations.of(context).failedToLoadPosts),
        itemBuilder: (context, item, index) => Padding(
          padding:
              LimitedWidthLayout.maybeOf(context)?.padding ?? EdgeInsets.zero,
          child: ImageCacheSizeProvider(
            size: 800,
            child: PostFeedTile(post: item),
          ),
        ),
      ),
    );
  }
}

/// A dismissible banner shown while a post list shows cached data offline.
class _OfflineBanner extends StatefulWidget {
  const _OfflineBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  State<_OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<_OfflineBanner> {
  bool dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (dismissed) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return MaterialBanner(
      content: Text(l10n.offlineBanner),
      actions: [
        TextButton(onPressed: widget.onRetry, child: Text(l10n.actionTryAgain)),
        TextButton(
          onPressed: () => setState(() => dismissed = true),
          child: Text(l10n.actionCancel),
        ),
      ],
    );
  }
}
