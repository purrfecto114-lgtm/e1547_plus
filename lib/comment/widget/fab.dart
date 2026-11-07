import 'package:e1547/comment/comment.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CommentCreateFab extends StatelessWidget {
  const CommentCreateFab({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    heroTag: 'float',
    backgroundColor: Theme.of(context).cardColor,
    tooltip: AppLocalizations.of(context).menuComment,
    child: Icon(Icons.comment, color: Theme.of(context).iconTheme.color),
    onPressed: () => writeComment(context: context, postId: postId),
  );
}
