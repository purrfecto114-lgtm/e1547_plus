// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'e1547';

  @override
  String get failedToLoad => 'Failed to load';

  @override
  String get nothingToSeeHere => 'Nothing to see here';

  @override
  String get loading => 'Loading...';

  @override
  String get actionCancel => 'CANCEL';

  @override
  String get actionOk => 'OK';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get failedToLoadSuggestions => 'Failed to load suggestions';

  @override
  String selectionItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get actionAbort => 'Abort';

  @override
  String get actionSelectAll => 'Select all';

  @override
  String fileSavedAs(String name) {
    return 'File saved as $name';
  }

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get saveFile => 'Save file';

  @override
  String get filterTooltip => 'Filter';

  @override
  String itemProgress(num current, num total) {
    return 'Item $current/$total';
  }

  @override
  String get taskCancelled => 'Cancelled task';

  @override
  String taskFailedAt(num index) {
    return 'Failed at item $index';
  }

  @override
  String get taskDone => 'Done';
}
