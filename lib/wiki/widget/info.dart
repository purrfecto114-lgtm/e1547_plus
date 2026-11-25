import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

class WikiInfo extends StatelessWidget {
  const WikiInfo({super.key, required this.wiki});

  final Wiki wiki;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.wikiInfoId),
              InkWell(
                child: Text('#${wiki.id}'),
                onLongPress: () async {
                  final NavigatorState navigator = Navigator.of(context);
                  await Share.clipboard(
                    context,
                    wiki.id.toString(),
                    message: l10n.wikiCopiedId(wiki.id),
                  );
                  navigator.maybePop();
                },
              ),
            ],
          ),
          if (wiki.otherNames case final otherNames?)
            textInfoRow(l10n.wikiInfoAlias, otherNames.join(', ')),
          textInfoRow(
            l10n.wikiInfoCreated,
            localizedDateTime(context, wiki.createdAt.toLocal()),
          ),
          textInfoRow(
            l10n.wikiInfoUpdated,
            localizedDateTime(
              context,
              (wiki.updatedAt ?? wiki.createdAt).toLocal(),
            ),
          ),
          if (wiki.isLocked case final isLocked?)
            textInfoRow(
              l10n.wikiInfoLocked,
              isLocked ? l10n.wikiInfoYes : l10n.wikiInfoNo,
            ),
        ],
      ),
    );
  }
}
