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
  String get actionDownload => 'DOWNLOAD';

  @override
  String get actionImport => 'IMPORT';

  @override
  String get actionRestartNow => 'RESTART NOW';

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

  @override
  String get failedToInitialize => 'Failed to initialize';

  @override
  String get navHome => 'Home';

  @override
  String get navHot => 'Hot';

  @override
  String get navSearch => 'Search';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navSubscriptions => 'Subscriptions';

  @override
  String get navBookmarks => 'Bookmarks';

  @override
  String get navPools => 'Pools';

  @override
  String get navForum => 'Forum';

  @override
  String get navHistory => 'History';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAbout => 'About';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionUser => 'User';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionInteractions => 'Interactions';

  @override
  String get sectionSecurity => 'Security';

  @override
  String get sectionDevelopment => 'Development';

  @override
  String get settingsBlacklist => 'Blacklist';

  @override
  String tagsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags blocked',
      one: '1 tag blocked',
    );
    return '$_temp0';
  }

  @override
  String get settingsFollows => 'Follows';

  @override
  String searchesFollowed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count searches followed',
      one: '1 search followed',
    );
    return '$_temp0';
  }

  @override
  String get settingsHistory => 'History';

  @override
  String pagesVisited(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages visited',
      one: '1 page visited',
    );
    return '$_temp0';
  }

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeDark => 'dark';

  @override
  String get themeAmoled => 'amoled';

  @override
  String get themeLight => 'light';

  @override
  String get themeBlue => 'blue';

  @override
  String get themeSystem => 'system';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get settingsTileSize => 'Tile size';

  @override
  String get settingsQuilt => 'Quilt';

  @override
  String get gridTitle => 'Grid';

  @override
  String get quiltSquare => 'tiles are quadratic';

  @override
  String get quiltVertical => 'tiles expand vertically';

  @override
  String get settingsPostInfo => 'Post info';

  @override
  String get postInfoShown => 'info on post tiles';

  @override
  String get postInfoHidden => 'image tiles only';

  @override
  String get settingsDownloadLocation => 'Download location';

  @override
  String get settingsUpvoteFavorites => 'Upvote favorites';

  @override
  String get upvoteFavoritesOn => 'upvote and favorite';

  @override
  String get upvoteFavoritesOff => 'favorite only';

  @override
  String get settingsVideoVolume => 'Video volume';

  @override
  String get videoMuted => 'muted';

  @override
  String get videoWithSound => 'with sound';

  @override
  String get settingsVideoResolution => 'Video resolution';

  @override
  String get videoResStandard => 'Standard (480p)';

  @override
  String get videoResHigh => 'High (720p)';

  @override
  String get videoResFull => 'Full (1080p)';

  @override
  String get videoResUltra => 'Ultra (4K)';

  @override
  String get videoResSource => 'Source';

  @override
  String get settingsSecureDisplay => 'Secure display';

  @override
  String get secureDisplayOn => 'screen protected';

  @override
  String get secureDisplayOff => 'screen visible';

  @override
  String get settingsIncognitoKeyboard => 'Incognito keyboard';

  @override
  String get enabled => 'enabled';

  @override
  String get disabled => 'disabled';

  @override
  String get settingsPinLock => 'PIN lock';

  @override
  String get pinEnabled => 'PIN enabled';

  @override
  String get pinDisabled => 'PIN disabled';

  @override
  String get settingsBiometricLock => 'Biometric lock';

  @override
  String get biometricsEnabled => 'biometrics enabled';

  @override
  String get biometricsDisabled => 'biometrics disabled';

  @override
  String get settingsDeveloperMode => 'Developer mode';

  @override
  String get devOptionsShown => 'options shown';

  @override
  String get devOptionsHidden => 'options hidden';

  @override
  String get settingsLogs => 'Logs';

  @override
  String errorsLogged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errors logged',
      one: '1 error logged',
    );
    return '$_temp0';
  }

  @override
  String get settingsDatabase => 'Database';

  @override
  String get databaseExporting => 'Exporting database...';

  @override
  String get databaseExported => 'Database exported successfully';

  @override
  String get databaseExportFailed => 'Export failed';

  @override
  String get databaseExport => 'Export';

  @override
  String get databaseImporting => 'Importing database...';

  @override
  String databaseInvalidFile(String error) {
    return 'Invalid database file: $error';
  }

  @override
  String databaseImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get databaseImportTitle => 'Import Database';

  @override
  String get databaseRestartTitle => 'Restart Required';

  @override
  String get databaseRestartBody =>
      'The app needs to restart to apply changes.';

  @override
  String get databaseImport => 'Import';

  @override
  String get lockEnterPin => 'Enter PIN';

  @override
  String get lockEnterNewPin => 'Enter new PIN';

  @override
  String get lockConfirmNewPin => 'Confirm new PIN';

  @override
  String get lockFailedAuth => 'Failed to authenticate';

  @override
  String get lockPleaseAuth => 'Please authenticate';

  @override
  String get lockRetry => 'Retry';

  @override
  String get lockBiometricReason => 'Authenticate to unlock.';

  @override
  String get lockBiometricFailure =>
      'Severe failure in biometric authentication';

  @override
  String get aboutVersion => 'Version';

  @override
  String get updaterFetching => 'Fetching updates...';

  @override
  String get updaterCheckFailed => 'Failed to check for updates';

  @override
  String get updaterNewest => 'You have the newest version';

  @override
  String updaterNewer(String version) {
    return 'A newer version is available: $version';
  }

  @override
  String get updaterNewerHeader => 'A newer version is available: ';

  @override
  String get aboutExperimentalPlatform => 'Experimental platform';

  @override
  String get aboutExperimentalBody =>
      'This platform is not supported. Expect bugs and missing features.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutUpstream => 'Upstream';

  @override
  String get aboutUpstreamBody => 'This app is a fork of clragon/e1547';

  @override
  String get aboutDiscord => 'Discord';

  @override
  String get aboutForum => 'Forum';

  @override
  String aboutForumTopic(num id) {
    return 'e621 thread #$id';
  }

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutKofi => 'Ko-fi';

  @override
  String get aboutEmail => 'Email';

  @override
  String get aboutPlaystore => 'Playstore';

  @override
  String get aboutDonors => 'Donors';

  @override
  String get aboutDonorsThanks => 'Thanks for helping me keep up development!';

  @override
  String get aboutNoDonors => 'No donors yet';

  @override
  String get aboutDonorsFailed => 'Failed to fetch donors';

  @override
  String get developerUnlocked => 'You are now a developer!';

  @override
  String get databaseErrorLoading => 'Error loading database';

  @override
  String get databaseUnknownSize => 'Unknown';

  @override
  String get databaseExportTitle => 'Export Database';

  @override
  String get databaseExportSubtitle => 'Save a backup copy of your database';

  @override
  String get databaseImportSubtitle =>
      'Replace current database with imported one';

  @override
  String get databaseImportWarning =>
      'This will replace your current database. \nAll data will be lost. This cannot be undone!';

  @override
  String get postsTitle => 'Posts';

  @override
  String favoritesOf(String user) {
    return '$user\'s Favorites';
  }

  @override
  String get favoritesUnavailable =>
      'Favorites are unavailable for anonymous users';

  @override
  String get favoriteOrder => 'Favorite order';

  @override
  String get orderAdded => 'added order';

  @override
  String get orderId => 'id order';

  @override
  String get postStateDeleted => 'deleted';

  @override
  String get postStateUnsupported => 'unsupported';

  @override
  String get postStateUnavailable => 'unavailable';

  @override
  String get menuShare => 'Share';

  @override
  String get menuDownload => 'Download';

  @override
  String get menuBrowse => 'Browse';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuComment => 'Comment';

  @override
  String get menuReport => 'Report';

  @override
  String get menuFlag => 'Flag';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionFollow => 'Follow';

  @override
  String get actionUnfollow => 'Unfollow';

  @override
  String get actionMute => 'Mute';

  @override
  String get actionNotify => 'Notify';

  @override
  String get actionBookmark => 'Bookmark';

  @override
  String get actionUnbookmark => 'Unbookmark';

  @override
  String get actionBlock => 'Block';

  @override
  String get actionUnblock => 'Unblock';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionSubtract => 'Subtract';

  @override
  String selectionPost(num id) {
    return 'post #$id';
  }

  @override
  String selectionPostsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
    );
    return '$_temp0';
  }

  @override
  String get noPosts => 'No posts';

  @override
  String get failedToLoadPosts => 'Failed to load posts';

  @override
  String get postDeletedOverlay => 'Post was deleted';

  @override
  String get postUnavailableOverlay => 'Post is unavailable';

  @override
  String get postBlacklistedOverlay => 'Post is blacklisted';

  @override
  String unsupportedFileType(String ext) {
    return '$ext files are not supported';
  }

  @override
  String get loginRequiredEdit => 'You must be logged in to edit posts!';

  @override
  String get loginRequiredComment => 'You must be logged in to comment!';

  @override
  String get loginRequiredReport => 'You must be logged in to report posts!';

  @override
  String get loginRequiredFlag => 'You must be logged in to flag posts!';

  @override
  String postsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'blocked $count posts',
      one: 'blocked 1 post',
    );
    return '$_temp0';
  }

  @override
  String get blacklistUpdateFailed => 'Failed to update blacklist!';

  @override
  String get blacklistAddTag => 'Add tag';

  @override
  String get blacklistEditTag => 'Edit tag';

  @override
  String get blacklistEmpty => 'Your blacklist is empty';

  @override
  String get menuDelete => 'Delete';

  @override
  String get filterScore => 'Score';

  @override
  String get filterFavoriteCount => 'Favorite count';

  @override
  String get filterSortBy => 'Sort by';

  @override
  String get filterNew => 'New';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get filterRank => 'Rank';

  @override
  String get filterRandom => 'Random';

  @override
  String get filterDefault => 'Default';

  @override
  String get filterRating => 'Rating';

  @override
  String get filterSafe => 'Safe';

  @override
  String get filterQuestionable => 'Questionable';

  @override
  String get filterExplicit => 'Explicit';

  @override
  String get filterAll => 'All';

  @override
  String get filterPool => 'Pool';

  @override
  String get filterHasPool => 'Has pool';

  @override
  String get filterChild => 'Child';

  @override
  String get filterIsChildPost => 'Is child post';

  @override
  String get filterParent => 'Parent';

  @override
  String get filterIsParentPost => 'Is parent post';

  @override
  String get filterUploadDate => 'Upload date';

  @override
  String get filterLastDay => 'Last day';

  @override
  String get filterLastWeek => 'Last week';

  @override
  String get filterLastMonth => 'Last Month';

  @override
  String get filterLastYear => 'Last Year';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterActive => 'Active';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterDeleted => 'Deleted';

  @override
  String get filterFlagged => 'Flagged';

  @override
  String get filterAny => 'Any';

  @override
  String get filterTitleContains => 'Title contains';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterGeneral => 'General';

  @override
  String get filterSiteBugReports => 'Site Bug Reports & Feature Requests';

  @override
  String get filterTagWikiProjects => 'Tag/Wiki Projects and Questions';

  @override
  String get filterTagAliasSuggestions =>
      'Tag Alias and Implication Suggestions';

  @override
  String get filterArtTalk => 'Art Talk';

  @override
  String get filterOffTopic => 'Off Topic';

  @override
  String get filterE621Tools => 'e621 Tools and Applications';

  @override
  String get filterNewestFirst => 'Newest first';

  @override
  String get filterOldestFirst => 'Oldest first';

  @override
  String get filterSticky => 'Sticky';

  @override
  String get filterIsSticky => 'Is sticky';

  @override
  String get filterLocked => 'Locked';

  @override
  String get filterIsLocked => 'Is locked';

  @override
  String get filterDescription => 'Description';

  @override
  String get filterCreator => 'Creator';

  @override
  String get filterIsActive => 'Is active';

  @override
  String get filterSeries => 'Series';

  @override
  String get filterCollection => 'Collection';

  @override
  String get filterName => 'Name';

  @override
  String get filterCreated => 'Created';

  @override
  String get filterUpdated => 'Updated';

  @override
  String get filterPostCount => 'Post count';

  @override
  String postUpdateFailed(num id) {
    return 'Failed to update post #$id';
  }

  @override
  String postUpdated(num id) {
    return 'Updated post #$id';
  }

  @override
  String get failedToLoadPost => 'Failed to load post';

  @override
  String get postNotFound => 'Post not found';
}
