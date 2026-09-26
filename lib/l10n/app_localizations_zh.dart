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
  String get actionDownload => '下载';

  @override
  String get actionImport => '导入';

  @override
  String get actionRestartNow => '立即重启';

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

  @override
  String get failedToInitialize => '初始化失败';

  @override
  String get navHome => '首页';

  @override
  String get navHot => '热门';

  @override
  String get navSearch => '搜索';

  @override
  String get navFavorites => '收藏';

  @override
  String get navTimeline => '时间线';

  @override
  String get navSubscriptions => '订阅';

  @override
  String get navBookmarks => '书签';

  @override
  String get navPools => '图集';

  @override
  String get navForum => '论坛';

  @override
  String get navHistory => '历史';

  @override
  String get navTasks => '任务';

  @override
  String get navSettings => '设置';

  @override
  String get navAbout => '关于';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionAccount => '账户';

  @override
  String get sectionUser => '用户';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionInteractions => '交互';

  @override
  String get sectionSecurity => '安全';

  @override
  String get sectionDevelopment => '开发';

  @override
  String get settingsBlacklist => '黑名单';

  @override
  String tagsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已屏蔽 $count 个标签',
    );
    return '$_temp0';
  }

  @override
  String get settingsFollows => '关注';

  @override
  String searchesFollowed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已关注 $count 个搜索',
    );
    return '$_temp0';
  }

  @override
  String get settingsHistory => '历史';

  @override
  String pagesVisited(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已浏览 $count 个页面',
    );
    return '$_temp0';
  }

  @override
  String get settingsTheme => '主题';

  @override
  String get themeDark => '深色';

  @override
  String get themeAmoled => '纯黑';

  @override
  String get themeLight => '浅色';

  @override
  String get themeBlue => '蓝色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageSystemDefault => '跟随系统';

  @override
  String get settingsTileSize => '磁贴大小';

  @override
  String get settingsQuilt => '布局';

  @override
  String get gridTitle => '网格';

  @override
  String get quiltSquare => '正方形磁贴';

  @override
  String get quiltVertical => '纵向拉伸磁贴';

  @override
  String get settingsPostInfo => '帖子信息';

  @override
  String get postInfoShown => '磁贴显示信息';

  @override
  String get postInfoHidden => '仅显示图片';

  @override
  String get settingsDownloadLocation => '下载位置';

  @override
  String get settingsUpvoteFavorites => '收藏时点赞';

  @override
  String get upvoteFavoritesOn => '点赞并收藏';

  @override
  String get upvoteFavoritesOff => '仅收藏';

  @override
  String get settingsVideoVolume => '视频音量';

  @override
  String get videoMuted => '静音';

  @override
  String get videoWithSound => '有声音';

  @override
  String get settingsVideoResolution => '视频分辨率';

  @override
  String get videoResStandard => '标准 (480p)';

  @override
  String get videoResHigh => '高 (720p)';

  @override
  String get videoResFull => '全高清 (1080p)';

  @override
  String get videoResUltra => '超清 (4K)';

  @override
  String get videoResSource => '原始';

  @override
  String get settingsSecureDisplay => '屏幕保护';

  @override
  String get secureDisplayOn => '屏幕受保护';

  @override
  String get secureDisplayOff => '屏幕可见';

  @override
  String get settingsIncognitoKeyboard => '无痕键盘';

  @override
  String get enabled => '已启用';

  @override
  String get disabled => '已禁用';

  @override
  String get settingsPinLock => 'PIN 锁';

  @override
  String get pinEnabled => 'PIN 已启用';

  @override
  String get pinDisabled => 'PIN 已禁用';

  @override
  String get settingsBiometricLock => '生物识别锁';

  @override
  String get biometricsEnabled => '生物识别已启用';

  @override
  String get biometricsDisabled => '生物识别已禁用';

  @override
  String get settingsDeveloperMode => '开发者模式';

  @override
  String get devOptionsShown => '显示开发者选项';

  @override
  String get devOptionsHidden => '隐藏开发者选项';

  @override
  String get settingsLogs => '日志';

  @override
  String errorsLogged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已记录 $count 个错误',
    );
    return '$_temp0';
  }

  @override
  String get settingsDatabase => '数据库';

  @override
  String get databaseExporting => '正在导出数据库…';

  @override
  String get databaseExported => '数据库导出成功';

  @override
  String get databaseExportFailed => '导出失败';

  @override
  String get databaseExport => '导出';

  @override
  String get databaseImporting => '正在导入数据库…';

  @override
  String databaseInvalidFile(String error) {
    return '无效的数据库文件：$error';
  }

  @override
  String databaseImportFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get databaseImportTitle => '导入数据库';

  @override
  String get databaseRestartTitle => '需要重启';

  @override
  String get databaseRestartBody => '应用需要重启以应用更改。';

  @override
  String get databaseImport => '导入';

  @override
  String get lockEnterPin => '输入 PIN';

  @override
  String get lockEnterNewPin => '输入新 PIN';

  @override
  String get lockConfirmNewPin => '确认新 PIN';

  @override
  String get lockFailedAuth => '验证失败';

  @override
  String get lockPleaseAuth => '请验证身份';

  @override
  String get lockRetry => '重试';

  @override
  String get lockBiometricReason => '验证以解锁。';

  @override
  String get lockBiometricFailure => '生物识别验证出现严重错误';

  @override
  String get aboutVersion => '版本';

  @override
  String get updaterFetching => '正在检查更新…';

  @override
  String get updaterCheckFailed => '检查更新失败';

  @override
  String get updaterNewest => '已是最新版本';

  @override
  String updaterNewer(String version) {
    return '有新版本可用：$version';
  }

  @override
  String get updaterNewerHeader => '有新版本可用：';

  @override
  String get aboutExperimentalPlatform => '实验性平台';

  @override
  String get aboutExperimentalBody => '此平台不受支持，可能存在缺陷和功能缺失。';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutUpstream => '上游项目';

  @override
  String get aboutUpstreamBody => '本应用是 clragon/e1547 的分支';

  @override
  String get aboutDiscord => 'Discord';

  @override
  String get aboutForum => '论坛';

  @override
  String aboutForumTopic(num id) {
    return 'e621 帖子 #$id';
  }

  @override
  String get aboutWebsite => '网站';

  @override
  String get aboutKofi => 'Ko-fi';

  @override
  String get aboutEmail => '电子邮件';

  @override
  String get aboutPlaystore => 'Play 商店';

  @override
  String get aboutDonors => '捐赠者';

  @override
  String get aboutDonorsThanks => '感谢你们支持本项目的开发！';

  @override
  String get aboutNoDonors => '暂无捐赠者';

  @override
  String get aboutDonorsFailed => '获取捐赠者失败';

  @override
  String get developerUnlocked => '你已成为开发者！';

  @override
  String get databaseErrorLoading => '数据库加载出错';

  @override
  String get databaseUnknownSize => '未知';

  @override
  String get databaseExportTitle => '导出数据库';

  @override
  String get databaseExportSubtitle => '保存数据库备份副本';

  @override
  String get databaseImportSubtitle => '用导入的数据库替换当前数据库';

  @override
  String get databaseImportWarning => '这将替换你当前的数据库。\n所有数据都会丢失，且无法撤销！';

  @override
  String get postsTitle => '帖子';

  @override
  String favoritesOf(String user) {
    return '$user 的收藏';
  }

  @override
  String get favoritesUnavailable => '未登录用户无法使用收藏';

  @override
  String get favoriteOrder => '收藏排序';

  @override
  String get orderAdded => '添加顺序';

  @override
  String get orderId => 'ID 顺序';

  @override
  String get postStateDeleted => '已删除';

  @override
  String get postStateUnsupported => '不支持的类型';

  @override
  String get postStateUnavailable => '不可用';

  @override
  String get menuShare => '分享';

  @override
  String get menuDownload => '下载';

  @override
  String get menuBrowse => '在浏览器中打开';

  @override
  String get menuEdit => '编辑';

  @override
  String get menuComment => '评论';

  @override
  String get menuReport => '举报';

  @override
  String get menuFlag => '标记';

  @override
  String get actionOpen => '打开';

  @override
  String get actionFollow => '关注';

  @override
  String get actionUnfollow => '取消关注';

  @override
  String get actionMute => '静音';

  @override
  String get actionNotify => '通知';

  @override
  String get actionBookmark => '加书签';

  @override
  String get actionUnbookmark => '移除书签';

  @override
  String get actionBlock => '屏蔽';

  @override
  String get actionUnblock => '取消屏蔽';

  @override
  String get actionRemove => '移除';

  @override
  String get actionAdd => '添加';

  @override
  String get actionSubtract => '减少';

  @override
  String selectionPost(num id) {
    return '帖子 #$id';
  }

  @override
  String selectionPostsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个帖子',
    );
    return '$_temp0';
  }

  @override
  String get noPosts => '没有帖子';

  @override
  String get failedToLoadPosts => '帖子加载失败';

  @override
  String get postDeletedOverlay => '帖子已被删除';

  @override
  String get postUnavailableOverlay => '帖子不可用';

  @override
  String get postBlacklistedOverlay => '帖子已被屏蔽';

  @override
  String unsupportedFileType(String ext) {
    return '不支持 $ext 文件';
  }

  @override
  String get loginRequiredEdit => '必须登录才能编辑帖子！';

  @override
  String get loginRequiredComment => '必须登录才能评论！';

  @override
  String get loginRequiredReport => '必须登录才能举报帖子！';

  @override
  String get loginRequiredFlag => '必须登录才能标记帖子！';
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
  String get actionDownload => '下載';

  @override
  String get actionImport => '匯入';

  @override
  String get actionRestartNow => '立即重新啟動';

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

  @override
  String get failedToInitialize => '初始化失敗';

  @override
  String get navHome => '首頁';

  @override
  String get navHot => '熱門';

  @override
  String get navSearch => '搜尋';

  @override
  String get navFavorites => '收藏';

  @override
  String get navTimeline => '時間軸';

  @override
  String get navSubscriptions => '訂閱';

  @override
  String get navBookmarks => '書籤';

  @override
  String get navPools => '圖集';

  @override
  String get navForum => '論壇';

  @override
  String get navHistory => '歷史';

  @override
  String get navTasks => '任務';

  @override
  String get navSettings => '設定';

  @override
  String get navAbout => '關於';

  @override
  String get settingsTitle => '設定';

  @override
  String get sectionAccount => '帳戶';

  @override
  String get sectionUser => '使用者';

  @override
  String get sectionAppearance => '外觀';

  @override
  String get sectionInteractions => '互動';

  @override
  String get sectionSecurity => '安全性';

  @override
  String get sectionDevelopment => '開發';

  @override
  String get settingsBlacklist => '黑名單';

  @override
  String tagsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已封鎖 $count 個標籤',
    );
    return '$_temp0';
  }

  @override
  String get settingsFollows => '追蹤';

  @override
  String searchesFollowed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已追蹤 $count 個搜尋',
    );
    return '$_temp0';
  }

  @override
  String get settingsHistory => '歷史';

  @override
  String pagesVisited(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已瀏覽 $count 個頁面',
    );
    return '$_temp0';
  }

  @override
  String get settingsTheme => '佈景主題';

  @override
  String get themeDark => '深色';

  @override
  String get themeAmoled => '純黑';

  @override
  String get themeLight => '淺色';

  @override
  String get themeBlue => '藍色';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get settingsLanguage => '語言';

  @override
  String get languageSystemDefault => '跟隨系統';

  @override
  String get settingsTileSize => '磚塊大小';

  @override
  String get settingsQuilt => '版面';

  @override
  String get gridTitle => '網格';

  @override
  String get quiltSquare => '正方形磚塊';

  @override
  String get quiltVertical => '縱向延伸磚塊';

  @override
  String get settingsPostInfo => '貼文資訊';

  @override
  String get postInfoShown => '磚塊顯示資訊';

  @override
  String get postInfoHidden => '僅顯示圖片';

  @override
  String get settingsDownloadLocation => '下載位置';

  @override
  String get settingsUpvoteFavorites => '收藏時投票';

  @override
  String get upvoteFavoritesOn => '投票並收藏';

  @override
  String get upvoteFavoritesOff => '僅收藏';

  @override
  String get settingsVideoVolume => '影片音量';

  @override
  String get videoMuted => '靜音';

  @override
  String get videoWithSound => '有聲音';

  @override
  String get settingsVideoResolution => '影片解析度';

  @override
  String get videoResStandard => '標準 (480p)';

  @override
  String get videoResHigh => '高 (720p)';

  @override
  String get videoResFull => '全高清 (1080p)';

  @override
  String get videoResUltra => '超高 (4K)';

  @override
  String get videoResSource => '原始';

  @override
  String get settingsSecureDisplay => '螢幕保護';

  @override
  String get secureDisplayOn => '螢幕受保護';

  @override
  String get secureDisplayOff => '螢幕可見';

  @override
  String get settingsIncognitoKeyboard => '無痕鍵盤';

  @override
  String get enabled => '已啟用';

  @override
  String get disabled => '已停用';

  @override
  String get settingsPinLock => 'PIN 鎖';

  @override
  String get pinEnabled => 'PIN 已啟用';

  @override
  String get pinDisabled => 'PIN 已停用';

  @override
  String get settingsBiometricLock => '生物辨識鎖';

  @override
  String get biometricsEnabled => '生物辨識已啟用';

  @override
  String get biometricsDisabled => '生物辨識已停用';

  @override
  String get settingsDeveloperMode => '開發者模式';

  @override
  String get devOptionsShown => '顯示開發者選項';

  @override
  String get devOptionsHidden => '隱藏開發者選項';

  @override
  String get settingsLogs => '記錄檔';

  @override
  String errorsLogged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已記錄 $count 個錯誤',
    );
    return '$_temp0';
  }

  @override
  String get settingsDatabase => '資料庫';

  @override
  String get databaseExporting => '正在匯出資料庫…';

  @override
  String get databaseExported => '資料庫匯出成功';

  @override
  String get databaseExportFailed => '匯出失敗';

  @override
  String get databaseExport => '匯出';

  @override
  String get databaseImporting => '正在匯入資料庫…';

  @override
  String databaseInvalidFile(String error) {
    return '無效的資料庫檔案：$error';
  }

  @override
  String databaseImportFailed(String error) {
    return '匯入失敗：$error';
  }

  @override
  String get databaseImportTitle => '匯入資料庫';

  @override
  String get databaseRestartTitle => '需要重新啟動';

  @override
  String get databaseRestartBody => '應用程式需要重新啟動以套用變更。';

  @override
  String get databaseImport => '匯入';

  @override
  String get lockEnterPin => '輸入 PIN';

  @override
  String get lockEnterNewPin => '輸入新 PIN';

  @override
  String get lockConfirmNewPin => '確認新 PIN';

  @override
  String get lockFailedAuth => '驗證失敗';

  @override
  String get lockPleaseAuth => '請驗證身分';

  @override
  String get lockRetry => '重試';

  @override
  String get lockBiometricReason => '驗證以解鎖。';

  @override
  String get lockBiometricFailure => '生物辨識驗證發生嚴重錯誤';

  @override
  String get aboutVersion => '版本';

  @override
  String get updaterFetching => '正在檢查更新…';

  @override
  String get updaterCheckFailed => '檢查更新失敗';

  @override
  String get updaterNewest => '已是最新版本';

  @override
  String updaterNewer(String version) {
    return '有新版本可用：$version';
  }

  @override
  String get updaterNewerHeader => '有新版本可用：';

  @override
  String get aboutExperimentalPlatform => '實驗性平台';

  @override
  String get aboutExperimentalBody => '此平台不受支援，可能存在缺陷和功能缺失。';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutUpstream => '上游專案';

  @override
  String get aboutUpstreamBody => '本應用程式是 clragon/e1547 的分支';

  @override
  String get aboutDiscord => 'Discord';

  @override
  String get aboutForum => '論壇';

  @override
  String aboutForumTopic(num id) {
    return 'e621 討論串 #$id';
  }

  @override
  String get aboutWebsite => '網站';

  @override
  String get aboutKofi => 'Ko-fi';

  @override
  String get aboutEmail => '電子郵件';

  @override
  String get aboutPlaystore => 'Play 商店';

  @override
  String get aboutDonors => '捐贈者';

  @override
  String get aboutDonorsThanks => '感謝你們支持本專案的開發！';

  @override
  String get aboutNoDonors => '目前沒有捐贈者';

  @override
  String get aboutDonorsFailed => '取得捐贈者失敗';

  @override
  String get developerUnlocked => '你已成為開發者！';

  @override
  String get databaseErrorLoading => '資料庫載入錯誤';

  @override
  String get databaseUnknownSize => '未知';

  @override
  String get databaseExportTitle => '匯出資料庫';

  @override
  String get databaseExportSubtitle => '儲存資料庫備份副本';

  @override
  String get databaseImportSubtitle => '以匯入的資料庫取代目前資料庫';

  @override
  String get databaseImportWarning => '這將取代你目前的資料庫。\n所有資料都會遺失，且無法復原！';

  @override
  String get postsTitle => '貼文';

  @override
  String favoritesOf(String user) {
    return '$user 的收藏';
  }

  @override
  String get favoritesUnavailable => '未登入使用者無法使用收藏';

  @override
  String get favoriteOrder => '收藏排序';

  @override
  String get orderAdded => '新增順序';

  @override
  String get orderId => 'ID 順序';

  @override
  String get postStateDeleted => '已刪除';

  @override
  String get postStateUnsupported => '不支援的類型';

  @override
  String get postStateUnavailable => '無法使用';

  @override
  String get menuShare => '分享';

  @override
  String get menuDownload => '下載';

  @override
  String get menuBrowse => '在瀏覽器中開啟';

  @override
  String get menuEdit => '編輯';

  @override
  String get menuComment => '評論';

  @override
  String get menuReport => '檢舉';

  @override
  String get menuFlag => '標記';

  @override
  String get actionOpen => '開啟';

  @override
  String get actionFollow => '追蹤';

  @override
  String get actionUnfollow => '取消追蹤';

  @override
  String get actionMute => '靜音';

  @override
  String get actionNotify => '通知';

  @override
  String get actionBookmark => '加入書籤';

  @override
  String get actionUnbookmark => '移除書籤';

  @override
  String get actionBlock => '封鎖';

  @override
  String get actionUnblock => '取消封鎖';

  @override
  String get actionRemove => '移除';

  @override
  String get actionAdd => '新增';

  @override
  String get actionSubtract => '減少';

  @override
  String selectionPost(num id) {
    return '貼文 #$id';
  }

  @override
  String selectionPostsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 則貼文',
    );
    return '$_temp0';
  }

  @override
  String get noPosts => '沒有貼文';

  @override
  String get failedToLoadPosts => '貼文載入失敗';

  @override
  String get postDeletedOverlay => '貼文已被刪除';

  @override
  String get postUnavailableOverlay => '貼文無法使用';

  @override
  String get postBlacklistedOverlay => '貼文已被封鎖';

  @override
  String unsupportedFileType(String ext) {
    return '不支援 $ext 檔案';
  }

  @override
  String get loginRequiredEdit => '必須登入才能編輯貼文！';

  @override
  String get loginRequiredComment => '必須登入才能評論！';

  @override
  String get loginRequiredReport => '必須登入才能檢舉貼文！';

  @override
  String get loginRequiredFlag => '必須登入才能標記貼文！';
}
