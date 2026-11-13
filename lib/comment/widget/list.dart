import 'package:e1547/comment/comment.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  const CommentList({super.key});

  @override
  Widget build(BuildContext context) => CommentPageQueryBuilder(
    builder: (context, state, query) => PullToRefresh(
      onRefresh: query.revalidate,
      child: CustomScrollView(
        primary: true,
        slivers: [
          SliverPadding(
            padding: defaultActionListPadding,
            sliver: const SliverCommentList(),
          ),
        ],
      ),
    ),
  );
}

class SliverCommentList extends StatelessWidget {
  const SliverCommentList({super.key});

  @override
  Widget build(BuildContext context) => CommentPageQueryBuilder(
    builder: (context, state, query) => PagedSliverList<int, Comment>(
      state: state.paging,
      fetchNextPage: query.getNextPage,
      // Comment tiles do not use keep-alive, so wrapping them only
      // costs state; the follow lists disable it the same way.
      addAutomaticKeepAlives: false,
      builderDelegate: defaultPagedChildBuilderDelegate(
        onRetry: query.getNextPage,
        itemBuilder: (context, item, index) => CommentTile(comment: item),
        onEmpty: Text(AppLocalizations.of(context).noComments),
        onError: Text(AppLocalizations.of(context).failedToLoadComments),
      ),
    ),
  );
}
