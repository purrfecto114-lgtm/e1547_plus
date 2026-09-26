// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'e1547';

  @override
  String get failedToLoad => '加载失败';

  @override
  String get nothingToSeeHere => '这里什么都没有';

  @override
  String get loading => '加载中…';

  @override
  String get actionCancel => '取消';

  @override
  String get actionOk => '确定';

  @override
  String get actionTryAgain => '重试';

  @override
  String get failedToLoadSuggestions => '建议加载失败';

  @override
  String selectionItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项',
    );
    return '$_temp0';
  }

  @override
  String get actionAbort => '中止';

  @override
  String get actionSelectAll => '全选';

  @override
  String fileSavedAs(String name) {
    return '文件已保存为 $name';
  }

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get saveFile => '保存文件';

  @override
  String get filterTooltip => '筛选';

  @override
  String itemProgress(num current, num total) {
    return '第 $current/$total 项';
  }

  @override
  String get taskCancelled => '已取消任务';

  @override
  String taskFailedAt(num index) {
    return '第 $index 项失败';
  }

  @override
  String get taskDone => '完成';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'e1547';

  @override
  String get failedToLoad => '載入失敗';

  @override
  String get nothingToSeeHere => '這裡什麼都沒有';

  @override
  String get loading => '載入中…';

  @override
  String get actionCancel => '取消';

  @override
  String get actionOk => '確定';

  @override
  String get actionTryAgain => '重試';

  @override
  String get failedToLoadSuggestions => '建議載入失敗';

  @override
  String selectionItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項',
    );
    return '$_temp0';
  }

  @override
  String get actionAbort => '中止';

  @override
  String get actionSelectAll => '全選';

  @override
  String fileSavedAs(String name) {
    return '檔案已儲存為 $name';
  }

  @override
  String get copiedToClipboard => '已複製到剪貼簿';

  @override
  String get saveFile => '儲存檔案';

  @override
  String get filterTooltip => '篩選';

  @override
  String itemProgress(num current, num total) {
    return '第 $current/$total 項';
  }

  @override
  String get taskCancelled => '已取消任務';

  @override
  String taskFailedAt(num index) {
    return '第 $index 項失敗';
  }

  @override
  String get taskDone => '完成';
}
