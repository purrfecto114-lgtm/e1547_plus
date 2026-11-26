import 'package:e1547/client/client.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicLoadingPage extends StatelessWidget {
  const TopicLoadingPage(this.id, {super.key, this.orderByOldest});

  final int id;
  final bool? orderByOldest;

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    final query = client.topics.useGet(id: id);
    return QueryBuilder(
      query: query,
      builder: (context, state) => LoadingPage(
        // A query with no outcome yet is still loading, not ready.
        isLoading: state.isLoading || state.isInitial,
        isError: state.isError,
        isEmpty: state.data == null,
        loadingBuilder: (context, child) => Scaffold(
          appBar: AppBar(
            leading: const CloseButton(),
            title: Text(AppLocalizations.of(context).topicLink(id)),
          ),
          body: child(context),
        ),
        skeleton: (context) => TopicRepliesPage(
          topic: const TopicGhost(),
          orderByOldest: orderByOldest,
        ),
        onError: Text(AppLocalizations.of(context).topicFailedToLoadTopic),
        onRetry: query.invalidate,
        onEmpty: Text(AppLocalizations.of(context).topicNotFound),
        child: (context) =>
            TopicRepliesPage(topic: state.data!, orderByOldest: orderByOldest),
      ),
    );
  }
}
