import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relative_time/relative_time.dart';

/// Localized variant of [DateFormatting.named].
///
/// Translates the Today/Yesterday labels and formats weekday names with the
/// app language instead of the platform default.
String localizedDateName(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context);
  final today = DateUtils.dateOnly(DateTime.now());
  if (today.isAtSameMomentAs(DateUtils.dateOnly(date))) {
    return l10n.dateToday;
  }
  if (today
      .subtract(const Duration(days: 1))
      .isAtSameMomentAs(DateUtils.dateOnly(date))) {
    return l10n.dateYesterday;
  }
  if (today.subtract(const Duration(days: 7)).isBefore(date)) {
    final locale = Localizations.localeOf(context);
    // intl has no separate zh_Hant date symbols; weekday names are shared
    // between the scripts, so both map to the base zh symbols.
    final intlLocale = locale.languageCode == 'zh' ? 'zh' : locale.toString();
    return DateFormat.EEEE(intlLocale).format(date);
  }
  return DateFormatting.date(date);
}

class TimedText extends StatelessWidget {
  const TimedText({
    super.key,
    required this.child,
    required this.created,
    this.updated,
  });

  final Widget child;
  final DateTime created;
  final DateTime? updated;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Flexible(child: child),
        Text(
          ' • ${created.relativeTime(context)}'
          '${updated != null && updated!.isAfter(created) ? ' (edited)' : ''}',
          maxLines: 1,
          style: TextStyle(fontSize: 12, color: dimTextColor(context)),
        ),
      ],
    );
  }
}
