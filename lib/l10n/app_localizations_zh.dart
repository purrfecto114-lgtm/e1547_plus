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
  String get settingsTileSize => '格子大小';

  @override
  String get settingsQuilt => '布局';

  @override
  String get gridTitle => '网格';

  @override
  String get quiltSquare => '方形格子';

  @override
  String get quiltVertical => '纵向扩展的格子';

  @override
  String get settingsPostInfo => '帖子信息';

  @override
  String get postInfoShown => '在格子上显示信息';

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
  String get videoResUltra => '超高清 (4K)';

  @override
  String get videoResSource => '原始画质';

  @override
  String get settingsSecureDisplay => '屏幕内容保护';

  @override
  String get secureDisplayOn => '隐藏屏幕内容';

  @override
  String get secureDisplayOff => '不隐藏屏幕内容';

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
  String get databaseRestartBody => '需要重启应用以使更改生效。';

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
    return 'e621 讨论帖 #$id';
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
  String get actionSubtract => '排除';

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

  @override
  String postsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已屏蔽 $count 个帖子',
    );
    return '$_temp0';
  }

  @override
  String get blacklistUpdateFailed => '黑名单更新失败！';

  @override
  String get blacklistAddTag => '添加标签';

  @override
  String get blacklistEditTag => '编辑标签';

  @override
  String get blacklistEmpty => '你的黑名单为空';

  @override
  String get menuDelete => '删除';

  @override
  String get filterScore => '评分';

  @override
  String get filterFavoriteCount => '收藏数';

  @override
  String get filterSortBy => '排序方式';

  @override
  String get filterNew => '最新';

  @override
  String get filterFavorites => '收藏';

  @override
  String get filterRank => '排名';

  @override
  String get filterRandom => '随机';

  @override
  String get filterDefault => '默认';

  @override
  String get filterRating => '分级';

  @override
  String get filterSafe => '安全';

  @override
  String get filterQuestionable => '存疑';

  @override
  String get filterExplicit => '露骨';

  @override
  String get filterAll => '全部';

  @override
  String get filterPool => '图集';

  @override
  String get filterHasPool => '含图集';

  @override
  String get filterChild => '子帖';

  @override
  String get filterIsChildPost => '是子帖';

  @override
  String get filterParent => '父帖';

  @override
  String get filterIsParentPost => '是父帖';

  @override
  String get filterUploadDate => '上传日期';

  @override
  String get filterLastDay => '最近一天';

  @override
  String get filterLastWeek => '最近一周';

  @override
  String get filterLastMonth => '最近一个月';

  @override
  String get filterLastYear => '最近一年';

  @override
  String get filterStatus => '状态';

  @override
  String get filterActive => '活跃';

  @override
  String get filterPending => '待处理';

  @override
  String get filterDeleted => '已删除';

  @override
  String get filterFlagged => '已标记';

  @override
  String get filterAny => '任意';

  @override
  String get filterTitleContains => '标题包含';

  @override
  String get filterCategory => '分类';

  @override
  String get filterGeneral => '综合';

  @override
  String get filterSiteBugReports => '站点问题反馈与功能请求';

  @override
  String get filterTagWikiProjects => '标签/维基项目与提问';

  @override
  String get filterTagAliasSuggestions => '标签别名与关联建议';

  @override
  String get filterArtTalk => '艺术交流';

  @override
  String get filterOffTopic => '跑题';

  @override
  String get filterE621Tools => 'e621 工具与应用';

  @override
  String get filterNewestFirst => '最新优先';

  @override
  String get filterOldestFirst => '最旧优先';

  @override
  String get filterSticky => '置顶';

  @override
  String get filterIsSticky => '已置顶';

  @override
  String get filterLocked => '已锁定';

  @override
  String get filterIsLocked => '已锁定';

  @override
  String get filterDescription => '描述';

  @override
  String get filterCreator => '创建者';

  @override
  String get filterIsActive => '活跃中';

  @override
  String get filterSeries => '系列';

  @override
  String get filterCollection => '合集';

  @override
  String get filterName => '名称';

  @override
  String get filterCreated => '创建时间';

  @override
  String get filterUpdated => '更新时间';

  @override
  String get filterPostCount => '帖子数';

  @override
  String postUpdateFailed(num id) {
    return '更新帖子 #$id 失败';
  }

  @override
  String postUpdated(num id) {
    return '已更新帖子 #$id';
  }

  @override
  String get failedToLoadPost => '帖子加载失败';

  @override
  String get postNotFound => '找不到帖子';

  @override
  String get commentsTitle => '评论';

  @override
  String commentsOfPost(num postId) {
    return '帖子 #$postId 的评论';
  }

  @override
  String get commentOrder => '评论排序';

  @override
  String get noComments => '没有评论';

  @override
  String get failedToLoadComments => '评论加载失败';

  @override
  String commentTitle(num id) {
    return '评论 #$id';
  }

  @override
  String get failedToLoadComment => '评论加载失败';

  @override
  String get commentNotFound => '找不到评论';

  @override
  String commentEditorTitle(num postId) {
    return '帖子 #$postId 的评论';
  }

  @override
  String get commentSendFailed => '评论发送失败！';

  @override
  String get commentSent => '评论已发送！';

  @override
  String get commentHidden => '此评论已隐藏';

  @override
  String commentUpvoteFailed(num id) {
    return '评论 #$id 点赞失败';
  }

  @override
  String commentDownvoteFailed(num id) {
    return '评论 #$id 点踩失败';
  }

  @override
  String get commentLoginRequiredEdit => '必须登录才能编辑评论！';

  @override
  String get commentLoginRequiredReply => '必须登录才能回复评论！';

  @override
  String get commentLoginRequiredReport => '必须登录才能举报评论！';

  @override
  String commentCopiedId(num id) {
    return '已复制评论 ID #$id';
  }

  @override
  String get warningUserWarned => '用户因这条消息收到警告';

  @override
  String get warningUserRecorded => '用户因这条消息被记过';

  @override
  String get warningUserBanned => '用户因这条消息被封禁';

  @override
  String get repliesTitle => '回复';

  @override
  String get replyOrder => '回复排序';

  @override
  String get noReplies => '没有回复';

  @override
  String get failedToLoadReplies => '回复加载失败';

  @override
  String replyTitle(num id) {
    return '回复 #$id';
  }

  @override
  String get failedToLoadReply => '回复加载失败';

  @override
  String get replyNotFound => '找不到回复';

  @override
  String replyEditorTitle(num topicId) {
    return '讨论帖 #$topicId 的回复';
  }

  @override
  String get replySendFailed => '回复发送失败！';

  @override
  String get replySent => '回复已发送！';

  @override
  String get replyHidden => '此回复已隐藏';

  @override
  String get replyLoginRequiredEdit => '必须登录才能编辑回复！';

  @override
  String get replyLoginRequiredReply => '必须登录才能回复！';

  @override
  String get replyLoginRequiredReport => '必须登录才能举报回复！';

  @override
  String replyCopiedId(num id) {
    return '已复制回复 ID #$id';
  }

  @override
  String get menuReply => '回复';

  @override
  String get menuCopyId => '复制 ID';

  @override
  String get menuRefresh => '刷新';

  @override
  String get actionCopy => '复制';

  @override
  String get actionSave => '保存';

  @override
  String get actionShow => '显示';

  @override
  String get actionHide => '隐藏';

  @override
  String get actionCannotBeUndone => '此操作无法撤销。';

  @override
  String get info => '信息';

  @override
  String wikiTitle(String idOrTitle) {
    return '维基 $idOrTitle';
  }

  @override
  String get failedToLoadWiki => '维基加载失败';

  @override
  String get wikiNotFound => '找不到维基';

  @override
  String wikiCopiedId(num id) {
    return '已复制维基 ID #$id';
  }

  @override
  String get wikiInfoId => 'ID';

  @override
  String get wikiInfoAlias => '别名';

  @override
  String get wikiInfoCreated => '创建时间';

  @override
  String get wikiInfoUpdated => '更新时间';

  @override
  String get wikiInfoLocked => '锁定';

  @override
  String get wikiInfoYes => '是';

  @override
  String get wikiInfoNo => '否';

  @override
  String userTitle(String idOrName) {
    return '用户 $idOrName';
  }

  @override
  String get failedToLoadUser => '用户加载失败';

  @override
  String get userNotFound => '找不到用户';

  @override
  String get userUploads => '上传';

  @override
  String get userLoginRequiredReport => '必须登录才能举报用户！';

  @override
  String get userComission => '约稿';

  @override
  String get userId => 'ID';

  @override
  String get userJoined => '加入时间';

  @override
  String get userRank => '等级';

  @override
  String get userPosts => '帖子';

  @override
  String get userEdits => '编辑';

  @override
  String get userFavorites => '收藏';

  @override
  String get userComments => '评论';

  @override
  String get userForum => '论坛';

  @override
  String userCopiedId(num id) {
    return '已复制用户 ID #$id';
  }

  @override
  String get logsTitle => '日志';

  @override
  String logsTitleDate(String date) {
    return '日志 - $date';
  }

  @override
  String selectionLogsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条日志',
    );
    return '$_temp0';
  }

  @override
  String selectionLogsFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个日志文件',
    );
    return '$_temp0';
  }

  @override
  String get logsLevels => '级别';

  @override
  String get logsRecording => '记录';

  @override
  String get logsVerbose => '详细日志';

  @override
  String get logsVerboseAll => '记录所有级别';

  @override
  String logsVerboseMinimum(String level) {
    return '$level 及以上';
  }

  @override
  String get logFilesTitle => '日志文件';

  @override
  String get failedToLoadLogFiles => '日志文件加载失败！';

  @override
  String get noLogFiles => '没有可用的日志文件！';

  @override
  String get logsLive => '实时';

  @override
  String get noLogs => '没有日志';

  @override
  String get failedToReadLog => '日志读取失败';

  @override
  String get noErrorsLogged => '没有已记录的错误';

  @override
  String logsErrorsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个错误',
    );
    return '$_temp0';
  }

  @override
  String get logsAll => '所有日志';

  @override
  String get logsDismissAll => '全部清除';

  @override
  String logsDeleteTitle(num count) {
    return '删除 $count 个日志文件？';
  }

  @override
  String get identityAccounts => '账户';

  @override
  String get identityAdd => '添加账户';

  @override
  String get identityEdit => '编辑账户';

  @override
  String get identityRemoveTitle => '移除账户？';

  @override
  String get identityRemoveBody => '其所有数据将被永久移除，包括历史和关注。';

  @override
  String get identityAnonymous => '匿名';

  @override
  String get identityDuplicate => '此站点和用户名下已存在账户。';

  @override
  String identityLoginFailed(String reason) {
    return '登录失败。\n$reason';
  }

  @override
  String get identityLoginCheckDetails => '请检查网络连接和登录信息';

  @override
  String get identitySite => '站点';

  @override
  String get identityHostRequired => '请输入站点地址。';

  @override
  String get identityHostInvalid => '站点地址无效';

  @override
  String get identityHostReadOnly => '无法更改站点。如需使用其他站点，请添加新账户。';

  @override
  String get identityUsernameLabel => '用户名';

  @override
  String get identityUsernameRequired => '请输入用户名。';

  @override
  String get identityApikeyLabel => 'API 密钥';

  @override
  String get identityApikeyHelp => '在哪里能找到我的 API 密钥？';

  @override
  String get identityApikeyRequired =>
      '必须提供 API 密钥。\n例如 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identityApikeyInvalid =>
      'API 密钥是由 A-z 和 0-9 中的 24 或 32 个字符组成的序列\n例如 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identitySignupPrompt => '还没有账户？在这里注册';

  @override
  String get identityHostHint => '你的账户和帖子所在的站点。';

  @override
  String get identitySignIn => '登录';

  @override
  String get identityGuest => '访客';

  @override
  String get identityLogin => '登录';

  @override
  String get identityBrowseAnonymously => '匿名浏览';

  @override
  String identityConnecting(String host, String username) {
    return '正在以 $username 身份连接 $host…';
  }

  @override
  String get failedToLoadIdentities => '账户加载失败';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingBack => '上一步';

  @override
  String get onboardingNext => '下一步';

  @override
  String onboardingWelcomeTitle(String app) {
    return '欢迎使用 $app';
  }

  @override
  String get onboardingWelcomeBody => '一款精致的 booru 浏览器。';

  @override
  String get onboardingThemeTitle => '选个外观';

  @override
  String get onboardingThemeBody => '先试试看。以后随时可以更换。';

  @override
  String get onboardingLoginTitle => '连接账户';

  @override
  String get followAddToSubscriptions => '添加到订阅';

  @override
  String get followNoSubscriptions => '没有订阅';

  @override
  String get followFailedToLoadSubscriptions => '订阅加载失败';

  @override
  String get followAddToBookmarks => '添加到书签';

  @override
  String get followNoBookmarks => '没有书签';

  @override
  String get followFailedToLoadBookmarks => '书签加载失败';

  @override
  String get followUnseenPosts => '未读帖子';

  @override
  String followMarkPostsSeen(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将 $count 个帖子标记为已读',
    );
    return '$_temp0';
  }

  @override
  String get followNoUnseenPosts => '没有未读帖子';

  @override
  String get followShowUnseenFirst => '优先显示未读';

  @override
  String get followFilteringUnseen => '正在筛选未读';

  @override
  String get followAllPostsShown => '显示全部帖子';

  @override
  String get followForceSync => '强制同步';

  @override
  String get followSyncAllFollows => '同步全部关注';

  @override
  String followSyncingFollows(String progress) {
    return '正在同步关注… $progress';
  }

  @override
  String get followEditorTitle => '编辑关注';

  @override
  String get followSubscribe => '订阅';

  @override
  String get followEditPrompt => '编辑关注';

  @override
  String get followTitlePrompt => '关注标题';

  @override
  String get followMarkAsRead => '标记为已读';

  @override
  String get followDisableNotifications => '关闭通知';

  @override
  String get followEnableNotifications => '开启通知';

  @override
  String get followRename => '重命名';

  @override
  String followNewPosts(num count, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label 条新帖子',
    );
    return '$_temp0';
  }

  @override
  String followSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个关注',
    );
    return '$_temp0';
  }

  @override
  String followAlias(String? alias) {
    return '别名 $alias';
  }

  @override
  String historySelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个条目',
    );
    return '$_temp0';
  }

  @override
  String get historyClear => '清空历史';

  @override
  String get historyClearSubtitle => '删除所有条目';

  @override
  String get historyClearConfirm => '清空历史？';

  @override
  String get historyClearConfirmBody => '所有历史条目将被永久删除，此操作无法撤销。';

  @override
  String get historyClearAction => '清空';

  @override
  String get historyLimit => '历史上限';

  @override
  String historyLimitEnableBody(String amount, num months) {
    return '启用历史上限后，超过 $amount 条或早于 $months 个月的条目将被自动删除。';
  }

  @override
  String get historyLimitTitle => '限制历史';

  @override
  String historyLimitOn(String amount, num months) {
    return '仅保留最近 $months 个月内且不超过 $amount 条的记录。';
  }

  @override
  String get historyLimitOff => '历史无上限';

  @override
  String get historyEntries => '条目';

  @override
  String get historyType => '类型';

  @override
  String get historyItems => '浏览';

  @override
  String get historySearches => '搜索';

  @override
  String get historyWikis => '维基';

  @override
  String get historyUsers => '用户';

  @override
  String get historyEmpty => '历史记录为空';

  @override
  String get historyFailedToLoad => '历史加载失败';

  @override
  String get historyDescription => '描述';

  @override
  String get historyNoDescription => '暂无描述';

  @override
  String get historyHotPosts => '热门帖子';

  @override
  String historyLinkPost(num id) {
    return '帖子 #$id';
  }

  @override
  String historyLinkUser(num id) {
    return '用户 #$id';
  }

  @override
  String historyLinkWiki(num id) {
    return '维基 #$id';
  }

  @override
  String historyLinkUserByName(String id) {
    return '用户 $id';
  }

  @override
  String historyLinkWikiByName(String id) {
    return '维基 $id';
  }

  @override
  String historySearchQuery(String type, String query) {
    return '$type - $query';
  }

  @override
  String get historyWiki => '维基';

  @override
  String get poolEmpty => '没有图集';

  @override
  String get poolFailedToLoadPools => '图集加载失败';

  @override
  String get poolTitle => '图集标题';

  @override
  String get poolInfoPosts => '帖子';

  @override
  String get poolInfoId => 'ID';

  @override
  String get poolInfoActivity => '活跃状态';

  @override
  String get poolInfoActive => '活跃';

  @override
  String get poolInfoInactive => '不活跃';

  @override
  String get poolInfoCreated => '创建时间';

  @override
  String get poolInfoUpdated => '更新时间';

  @override
  String poolCopiedId(num id) {
    return '已复制图集 ID #$id';
  }

  @override
  String poolLink(num id) {
    return '图集 #$id';
  }

  @override
  String get poolFailedToLoadPool => '图集加载失败';

  @override
  String get poolNotFound => '找不到图集';

  @override
  String get poolOrder => '图集排序';

  @override
  String get poolOldestFirst => '最旧优先';

  @override
  String get poolNewestFirst => '最新优先';

  @override
  String get poolReaderMode => '图集阅读模式';

  @override
  String get poolReaderLargeImages => '大图';

  @override
  String get poolReaderNormalGrid => '普通网格';

  @override
  String get topicsTitle => '讨论';

  @override
  String get topicHideTagEdits => '隐藏标签编辑帖';

  @override
  String get topicTagEditsHidden => '已隐藏';

  @override
  String get topicTagEditsVisible => '已显示';

  @override
  String topicLink(num id) {
    return '讨论帖 #$id';
  }

  @override
  String get topicFailedToLoadTopic => '讨论帖加载失败';

  @override
  String get topicNotFound => '找不到讨论帖';

  @override
  String get topicEmpty => '没有讨论帖';

  @override
  String get topicFailedToLoadTopics => '讨论帖加载失败';

  @override
  String get topicInfoReplies => '回复';

  @override
  String get topicInfoId => 'ID';

  @override
  String topicCopiedId(num id) {
    return '已复制讨论帖 ID #$id';
  }

  @override
  String get topicInfoLocked => '已锁定';

  @override
  String get topicInfoYes => '是';

  @override
  String get topicInfoNo => '否';

  @override
  String get topicInfoCreated => '创建时间';

  @override
  String get topicInfoUpdated => '更新时间';

  @override
  String get filterTags => '标签';

  @override
  String get loginRequired => '必须登录才能执行此操作！';

  @override
  String get actionChooseIdentity => '选择账户';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';
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
  String get settingsTheme => '主題';

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
  String get settingsTileSize => '格子大小';

  @override
  String get settingsQuilt => '版面';

  @override
  String get gridTitle => '網格';

  @override
  String get quiltSquare => '方形格子';

  @override
  String get quiltVertical => '縱向延伸的格子';

  @override
  String get settingsPostInfo => '貼文資訊';

  @override
  String get postInfoShown => '在格子上顯示資訊';

  @override
  String get postInfoHidden => '僅顯示圖片';

  @override
  String get settingsDownloadLocation => '下載位置';

  @override
  String get settingsUpvoteFavorites => '收藏時按讚';

  @override
  String get upvoteFavoritesOn => '按讚並收藏';

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
  String get videoResFull => '全高畫質 (1080p)';

  @override
  String get videoResUltra => '超高畫質 (4K)';

  @override
  String get videoResSource => '原始畫質';

  @override
  String get settingsSecureDisplay => '螢幕內容保護';

  @override
  String get secureDisplayOn => '隱藏螢幕內容';

  @override
  String get secureDisplayOff => '不隱藏螢幕內容';

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
  String get actionSubtract => '排除';

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

  @override
  String postsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已封鎖 $count 則貼文',
    );
    return '$_temp0';
  }

  @override
  String get blacklistUpdateFailed => '黑名單更新失敗！';

  @override
  String get blacklistAddTag => '新增標籤';

  @override
  String get blacklistEditTag => '編輯標籤';

  @override
  String get blacklistEmpty => '你的黑名單是空的';

  @override
  String get menuDelete => '刪除';

  @override
  String get filterScore => '評分';

  @override
  String get filterFavoriteCount => '收藏數';

  @override
  String get filterSortBy => '排序方式';

  @override
  String get filterNew => '最新';

  @override
  String get filterFavorites => '收藏';

  @override
  String get filterRank => '排名';

  @override
  String get filterRandom => '隨機';

  @override
  String get filterDefault => '預設';

  @override
  String get filterRating => '分級';

  @override
  String get filterSafe => '安全';

  @override
  String get filterQuestionable => '存疑';

  @override
  String get filterExplicit => '露骨';

  @override
  String get filterAll => '全部';

  @override
  String get filterPool => '圖集';

  @override
  String get filterHasPool => '含圖集';

  @override
  String get filterChild => '子貼文';

  @override
  String get filterIsChildPost => '是子貼文';

  @override
  String get filterParent => '父貼文';

  @override
  String get filterIsParentPost => '是父貼文';

  @override
  String get filterUploadDate => '上傳日期';

  @override
  String get filterLastDay => '最近一天';

  @override
  String get filterLastWeek => '最近一週';

  @override
  String get filterLastMonth => '最近一個月';

  @override
  String get filterLastYear => '最近一年';

  @override
  String get filterStatus => '狀態';

  @override
  String get filterActive => '活躍';

  @override
  String get filterPending => '待處理';

  @override
  String get filterDeleted => '已刪除';

  @override
  String get filterFlagged => '已標記';

  @override
  String get filterAny => '任意';

  @override
  String get filterTitleContains => '標題包含';

  @override
  String get filterCategory => '分類';

  @override
  String get filterGeneral => '一般';

  @override
  String get filterSiteBugReports => '網站問題與功能請求';

  @override
  String get filterTagWikiProjects => '標籤/維基專案與提問';

  @override
  String get filterTagAliasSuggestions => '標籤別名與關聯建議';

  @override
  String get filterArtTalk => '藝術交流';

  @override
  String get filterOffTopic => '離題';

  @override
  String get filterE621Tools => 'e621 工具與應用程式';

  @override
  String get filterNewestFirst => '最新優先';

  @override
  String get filterOldestFirst => '最舊優先';

  @override
  String get filterSticky => '置頂';

  @override
  String get filterIsSticky => '已置頂';

  @override
  String get filterLocked => '已鎖定';

  @override
  String get filterIsLocked => '已鎖定';

  @override
  String get filterDescription => '描述';

  @override
  String get filterCreator => '建立者';

  @override
  String get filterIsActive => '活躍中';

  @override
  String get filterSeries => '系列';

  @override
  String get filterCollection => '合輯';

  @override
  String get filterName => '名稱';

  @override
  String get filterCreated => '建立時間';

  @override
  String get filterUpdated => '更新時間';

  @override
  String get filterPostCount => '貼文數';

  @override
  String postUpdateFailed(num id) {
    return '更新貼文 #$id 失敗';
  }

  @override
  String postUpdated(num id) {
    return '已更新貼文 #$id';
  }

  @override
  String get failedToLoadPost => '貼文載入失敗';

  @override
  String get postNotFound => '找不到貼文';

  @override
  String get commentsTitle => '評論';

  @override
  String commentsOfPost(num postId) {
    return '貼文 #$postId 的評論';
  }

  @override
  String get commentOrder => '評論排序';

  @override
  String get noComments => '沒有評論';

  @override
  String get failedToLoadComments => '評論載入失敗';

  @override
  String commentTitle(num id) {
    return '評論 #$id';
  }

  @override
  String get failedToLoadComment => '評論載入失敗';

  @override
  String get commentNotFound => '找不到評論';

  @override
  String commentEditorTitle(num postId) {
    return '貼文 #$postId 的評論';
  }

  @override
  String get commentSendFailed => '評論傳送失敗！';

  @override
  String get commentSent => '評論已傳送！';

  @override
  String get commentHidden => '此評論已隱藏';

  @override
  String commentUpvoteFailed(num id) {
    return '評論 #$id 按讚失敗';
  }

  @override
  String commentDownvoteFailed(num id) {
    return '評論 #$id 倒讚失敗';
  }

  @override
  String get commentLoginRequiredEdit => '必須登入才能編輯評論！';

  @override
  String get commentLoginRequiredReply => '必須登入才能回覆評論！';

  @override
  String get commentLoginRequiredReport => '必須登入才能檢舉評論！';

  @override
  String commentCopiedId(num id) {
    return '已複製評論 ID #$id';
  }

  @override
  String get warningUserWarned => '使用者因這則訊息收到警告';

  @override
  String get warningUserRecorded => '使用者因這則訊息被記過';

  @override
  String get warningUserBanned => '使用者因這則訊息被停權';

  @override
  String get repliesTitle => '回覆';

  @override
  String get replyOrder => '回覆排序';

  @override
  String get noReplies => '沒有回覆';

  @override
  String get failedToLoadReplies => '回覆載入失敗';

  @override
  String replyTitle(num id) {
    return '回覆 #$id';
  }

  @override
  String get failedToLoadReply => '回覆載入失敗';

  @override
  String get replyNotFound => '找不到回覆';

  @override
  String replyEditorTitle(num topicId) {
    return '討論串 #$topicId 的回覆';
  }

  @override
  String get replySendFailed => '回覆傳送失敗！';

  @override
  String get replySent => '回覆已傳送！';

  @override
  String get replyHidden => '此回覆已隱藏';

  @override
  String get replyLoginRequiredEdit => '必須登入才能編輯回覆！';

  @override
  String get replyLoginRequiredReply => '必須登入才能回覆！';

  @override
  String get replyLoginRequiredReport => '必須登入才能檢舉回覆！';

  @override
  String replyCopiedId(num id) {
    return '已複製回覆 ID #$id';
  }

  @override
  String get menuReply => '回覆';

  @override
  String get menuCopyId => '複製 ID';

  @override
  String get menuRefresh => '重新整理';

  @override
  String get actionCopy => '複製';

  @override
  String get actionSave => '儲存';

  @override
  String get actionShow => '顯示';

  @override
  String get actionHide => '隱藏';

  @override
  String get actionCannotBeUndone => '此操作無法復原。';

  @override
  String get info => '資訊';

  @override
  String wikiTitle(String idOrTitle) {
    return '維基 $idOrTitle';
  }

  @override
  String get failedToLoadWiki => '維基載入失敗';

  @override
  String get wikiNotFound => '找不到維基';

  @override
  String wikiCopiedId(num id) {
    return '已複製維基 ID #$id';
  }

  @override
  String get wikiInfoId => 'ID';

  @override
  String get wikiInfoAlias => '別名';

  @override
  String get wikiInfoCreated => '建立時間';

  @override
  String get wikiInfoUpdated => '更新時間';

  @override
  String get wikiInfoLocked => '鎖定';

  @override
  String get wikiInfoYes => '是';

  @override
  String get wikiInfoNo => '否';

  @override
  String userTitle(String idOrName) {
    return '使用者 $idOrName';
  }

  @override
  String get failedToLoadUser => '使用者載入失敗';

  @override
  String get userNotFound => '找不到使用者';

  @override
  String get userUploads => '上傳';

  @override
  String get userLoginRequiredReport => '必須登入才能檢舉使用者！';

  @override
  String get userComission => '委託';

  @override
  String get userId => 'ID';

  @override
  String get userJoined => '加入時間';

  @override
  String get userRank => '等級';

  @override
  String get userPosts => '貼文';

  @override
  String get userEdits => '編輯';

  @override
  String get userFavorites => '收藏';

  @override
  String get userComments => '評論';

  @override
  String get userForum => '論壇';

  @override
  String userCopiedId(num id) {
    return '已複製使用者 ID #$id';
  }

  @override
  String get logsTitle => '記錄檔';

  @override
  String logsTitleDate(String date) {
    return '記錄檔 - $date';
  }

  @override
  String selectionLogsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆記錄',
    );
    return '$_temp0';
  }

  @override
  String selectionLogsFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個記錄檔案',
    );
    return '$_temp0';
  }

  @override
  String get logsLevels => '層級';

  @override
  String get logsRecording => '記錄';

  @override
  String get logsVerbose => '詳細記錄';

  @override
  String get logsVerboseAll => '記錄所有層級';

  @override
  String logsVerboseMinimum(String level) {
    return '$level 及以上';
  }

  @override
  String get logFilesTitle => '記錄檔案';

  @override
  String get failedToLoadLogFiles => '記錄檔案載入失敗！';

  @override
  String get noLogFiles => '沒有可用的記錄檔案！';

  @override
  String get logsLive => '即時';

  @override
  String get noLogs => '沒有記錄';

  @override
  String get failedToReadLog => '記錄檔讀取失敗';

  @override
  String get noErrorsLogged => '沒有已記錄的錯誤';

  @override
  String logsErrorsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個錯誤',
    );
    return '$_temp0';
  }

  @override
  String get logsAll => '所有記錄檔';

  @override
  String get logsDismissAll => '全部清除';

  @override
  String logsDeleteTitle(num count) {
    return '刪除 $count 個記錄檔案？';
  }

  @override
  String get identityAccounts => '帳戶';

  @override
  String get identityAdd => '新增帳戶';

  @override
  String get identityEdit => '編輯帳戶';

  @override
  String get identityRemoveTitle => '移除帳戶？';

  @override
  String get identityRemoveBody => '其所有資料將被永久移除，包括歷史和追蹤。';

  @override
  String get identityAnonymous => '匿名';

  @override
  String get identityDuplicate => '此網站和使用者名稱下已存在帳戶。';

  @override
  String identityLoginFailed(String reason) {
    return '登入失敗。\n$reason';
  }

  @override
  String get identityLoginCheckDetails => '請檢查網路連線和登入資訊';

  @override
  String get identitySite => '網站';

  @override
  String get identityHostRequired => '請輸入網站地址。';

  @override
  String get identityHostInvalid => '網站地址無效';

  @override
  String get identityHostReadOnly => '無法變更網站。如需使用其他網站，請新增帳戶。';

  @override
  String get identityUsernameLabel => '使用者名稱';

  @override
  String get identityUsernameRequired => '請輸入使用者名稱。';

  @override
  String get identityApikeyLabel => 'API 金鑰';

  @override
  String get identityApikeyHelp => '在哪裡能找到我的 API 金鑰？';

  @override
  String get identityApikeyRequired =>
      '必須提供 API 金鑰。\n例如 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identityApikeyInvalid =>
      'API 金鑰是由 A-z 和 0-9 中的 24 或 32 個字元組成的序列\n例如 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identitySignupPrompt => '還沒有帳戶？在這裡註冊';

  @override
  String get identityHostHint => '你的帳戶和貼文所在的網站。';

  @override
  String get identitySignIn => '登入';

  @override
  String get identityGuest => '訪客';

  @override
  String get identityLogin => '登入';

  @override
  String get identityBrowseAnonymously => '匿名瀏覽';

  @override
  String identityConnecting(String host, String username) {
    return '正在以 $username 身分連線 $host…';
  }

  @override
  String get failedToLoadIdentities => '帳戶載入失敗';

  @override
  String get onboardingSkip => '略過';

  @override
  String get onboardingBack => '上一步';

  @override
  String get onboardingNext => '下一步';

  @override
  String onboardingWelcomeTitle(String app) {
    return '歡迎使用 $app';
  }

  @override
  String get onboardingWelcomeBody => '一款精緻的 booru 瀏覽器。';

  @override
  String get onboardingThemeTitle => '挑個外觀';

  @override
  String get onboardingThemeBody => '先試試看。之後隨時可以更換。';

  @override
  String get onboardingLoginTitle => '連結帳戶';

  @override
  String get followAddToSubscriptions => '加入訂閱';

  @override
  String get followNoSubscriptions => '沒有訂閱';

  @override
  String get followFailedToLoadSubscriptions => '訂閱載入失敗';

  @override
  String get followAddToBookmarks => '加入書籤';

  @override
  String get followNoBookmarks => '沒有書籤';

  @override
  String get followFailedToLoadBookmarks => '書籤載入失敗';

  @override
  String get followUnseenPosts => '未讀貼文';

  @override
  String followMarkPostsSeen(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '將 $count 個貼文標記為已讀',
    );
    return '$_temp0';
  }

  @override
  String get followNoUnseenPosts => '沒有未讀貼文';

  @override
  String get followShowUnseenFirst => '優先顯示未讀';

  @override
  String get followFilteringUnseen => '正在篩選未讀';

  @override
  String get followAllPostsShown => '顯示全部貼文';

  @override
  String get followForceSync => '強制同步';

  @override
  String get followSyncAllFollows => '同步全部追蹤';

  @override
  String followSyncingFollows(String progress) {
    return '正在同步追蹤… $progress';
  }

  @override
  String get followEditorTitle => '編輯追蹤';

  @override
  String get followSubscribe => '訂閱';

  @override
  String get followEditPrompt => '編輯追蹤';

  @override
  String get followTitlePrompt => '追蹤標題';

  @override
  String get followMarkAsRead => '標記為已讀';

  @override
  String get followDisableNotifications => '關閉通知';

  @override
  String get followEnableNotifications => '開啟通知';

  @override
  String get followRename => '重新命名';

  @override
  String followNewPosts(num count, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label 則新貼文',
    );
    return '$_temp0';
  }

  @override
  String followSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個追蹤',
    );
    return '$_temp0';
  }

  @override
  String followAlias(String? alias) {
    return '別名 $alias';
  }

  @override
  String historySelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個條目',
    );
    return '$_temp0';
  }

  @override
  String get historyClear => '清空歷史';

  @override
  String get historyClearSubtitle => '刪除所有條目';

  @override
  String get historyClearConfirm => '清空歷史？';

  @override
  String get historyClearConfirmBody => '所有歷史條目將被永久刪除，此操作無法復原。';

  @override
  String get historyClearAction => '清空';

  @override
  String get historyLimit => '歷史上限';

  @override
  String historyLimitEnableBody(String amount, num months) {
    return '啟用歷史上限後，超過 $amount 條或早於 $months 個月的條目將被自動刪除。';
  }

  @override
  String get historyLimitTitle => '限制歷史';

  @override
  String historyLimitOn(String amount, num months) {
    return '僅保留最近 $months 個月內且不超過 $amount 條的記錄。';
  }

  @override
  String get historyLimitOff => '歷史無上限';

  @override
  String get historyEntries => '條目';

  @override
  String get historyType => '類型';

  @override
  String get historyItems => '瀏覽';

  @override
  String get historySearches => '搜尋';

  @override
  String get historyWikis => '維基';

  @override
  String get historyUsers => '使用者';

  @override
  String get historyEmpty => '歷史記錄為空';

  @override
  String get historyFailedToLoad => '歷史載入失敗';

  @override
  String get historyDescription => '描述';

  @override
  String get historyNoDescription => '暫無描述';

  @override
  String get historyHotPosts => '熱門貼文';

  @override
  String historyLinkPost(num id) {
    return '貼文 #$id';
  }

  @override
  String historyLinkUser(num id) {
    return '使用者 #$id';
  }

  @override
  String historyLinkWiki(num id) {
    return '維基 #$id';
  }

  @override
  String historyLinkUserByName(String id) {
    return '使用者 $id';
  }

  @override
  String historyLinkWikiByName(String id) {
    return '維基 $id';
  }

  @override
  String historySearchQuery(String type, String query) {
    return '$type - $query';
  }

  @override
  String get historyWiki => '維基';

  @override
  String get poolEmpty => '沒有圖集';

  @override
  String get poolFailedToLoadPools => '圖集載入失敗';

  @override
  String get poolTitle => '圖集標題';

  @override
  String get poolInfoPosts => '貼文';

  @override
  String get poolInfoId => 'ID';

  @override
  String get poolInfoActivity => '活躍狀態';

  @override
  String get poolInfoActive => '活躍';

  @override
  String get poolInfoInactive => '不活躍';

  @override
  String get poolInfoCreated => '建立時間';

  @override
  String get poolInfoUpdated => '更新時間';

  @override
  String poolCopiedId(num id) {
    return '已複製圖集 ID #$id';
  }

  @override
  String poolLink(num id) {
    return '圖集 #$id';
  }

  @override
  String get poolFailedToLoadPool => '圖集載入失敗';

  @override
  String get poolNotFound => '找不到圖集';

  @override
  String get poolOrder => '圖集排序';

  @override
  String get poolOldestFirst => '最舊優先';

  @override
  String get poolNewestFirst => '最新優先';

  @override
  String get poolReaderMode => '圖集閱讀模式';

  @override
  String get poolReaderLargeImages => '大圖';

  @override
  String get poolReaderNormalGrid => '普通網格';

  @override
  String get topicsTitle => '討論';

  @override
  String get topicHideTagEdits => '隱藏標籤編輯討論串';

  @override
  String get topicTagEditsHidden => '已隱藏';

  @override
  String get topicTagEditsVisible => '已顯示';

  @override
  String topicLink(num id) {
    return '討論串 #$id';
  }

  @override
  String get topicFailedToLoadTopic => '討論串載入失敗';

  @override
  String get topicNotFound => '找不到討論串';

  @override
  String get topicEmpty => '沒有討論串';

  @override
  String get topicFailedToLoadTopics => '討論串載入失敗';

  @override
  String get topicInfoReplies => '回覆';

  @override
  String get topicInfoId => 'ID';

  @override
  String topicCopiedId(num id) {
    return '已複製討論串 ID #$id';
  }

  @override
  String get topicInfoLocked => '已鎖定';

  @override
  String get topicInfoYes => '是';

  @override
  String get topicInfoNo => '否';

  @override
  String get topicInfoCreated => '建立時間';

  @override
  String get topicInfoUpdated => '更新時間';

  @override
  String get filterTags => '標籤';

  @override
  String get loginRequired => '必須登入才能執行此操作！';

  @override
  String get actionChooseIdentity => '選擇帳戶';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';
}
