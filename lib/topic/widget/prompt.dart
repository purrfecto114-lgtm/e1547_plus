import 'package:e1547/client/client.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

Future<void> showTopicPrompt({
  required BuildContext context,
  required Topic topic,
}) => showPrompt<void>(
  context,
  dialogWidth: 800,
  header: (context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    child: OverflowBar(
      alignment: MainAxisAlignment.spaceBetween,
      overflowSpacing: 8,
      children: [
        Text(
          tagToRaw(topic.title),
          style: Theme.of(context).textTheme.titleLarge,
          softWrap: true,
        ),
        ActionButton(
          icon: const Icon(Icons.share),
          onTap: () async =>
              Share.text(context, context.read<Client>().withHost(topic.link)),
          label: Text(AppLocalizations.of(context).menuShare),
        ),
      ],
    ),
  ),
  body: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TopicInfo(topic: topic),
      ),
    ],
  ),
);

class TopicInfo extends StatelessWidget {
  const TopicInfo({super.key, required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    Widget textInfoRow(String label, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      );
    }

    return DefaultTextStyle(
      style: TextStyle(color: dimTextColor(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textInfoRow(
            AppLocalizations.of(context).topicInfoReplies,
            topic.responseCount.toString(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).topicInfoId),
              InkWell(
                child: Text('#${topic.id}'),
                onLongPress: () async {
                  final l10n = AppLocalizations.of(context);
                  final NavigatorState navigator = Navigator.of(context);
                  await Share.clipboard(
                    context,
                    topic.id.toString(),
                    message: l10n.topicCopiedId(topic.id),
                  );
                  navigator.maybePop();
                },
              ),
            ],
          ),
          textInfoRow(
            AppLocalizations.of(context).topicInfoLocked,
            topic.locked
                ? AppLocalizations.of(context).topicInfoYes
                : AppLocalizations.of(context).topicInfoNo,
          ),
          textInfoRow(
            AppLocalizations.of(context).topicInfoCreated,
            localizedDateTime(context, topic.createdAt.toLocal()),
          ),
          textInfoRow(
            AppLocalizations.of(context).topicInfoUpdated,
            localizedDateTime(context, topic.updatedAt.toLocal()),
          ),
        ],
      ),
    );
  }
}
