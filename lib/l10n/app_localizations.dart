import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// The app name.
  ///
  /// In en, this message translates to:
  /// **'e1547'**
  String get appName;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// No description provided for @nothingToSeeHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing to see here'**
  String get nothingToSeeHere;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get actionCancel;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// No description provided for @actionDownload.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get actionDownload;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'IMPORT'**
  String get actionImport;

  /// No description provided for @actionRestartNow.
  ///
  /// In en, this message translates to:
  /// **'RESTART NOW'**
  String get actionRestartNow;

  /// No description provided for @failedToLoadSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggestions'**
  String get failedToLoadSuggestions;

  /// Number of selected items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String selectionItemCount(num count);

  /// No description provided for @actionAbort.
  ///
  /// In en, this message translates to:
  /// **'Abort'**
  String get actionAbort;

  /// No description provided for @actionSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get actionSelectAll;

  /// Confirmation after saving a file.
  ///
  /// In en, this message translates to:
  /// **'File saved as {name}'**
  String fileSavedAs(String name);

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @saveFile.
  ///
  /// In en, this message translates to:
  /// **'Save file'**
  String get saveFile;

  /// No description provided for @filterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTooltip;

  /// Progress of processing items.
  ///
  /// In en, this message translates to:
  /// **'Item {current}/{total}'**
  String itemProgress(num current, num total);

  /// No description provided for @taskCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled task'**
  String get taskCancelled;

  /// Item processing failure.
  ///
  /// In en, this message translates to:
  /// **'Failed at item {index}'**
  String taskFailedAt(num index);

  /// No description provided for @taskDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskDone;

  /// No description provided for @failedToInitialize.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize'**
  String get failedToInitialize;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get navHot;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get navTimeline;

  /// No description provided for @navSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get navSubscriptions;

  /// No description provided for @navBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get navBookmarks;

  /// No description provided for @navPools.
  ///
  /// In en, this message translates to:
  /// **'Pools'**
  String get navPools;

  /// No description provided for @navForum.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get navForum;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get sectionUser;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionInteractions.
  ///
  /// In en, this message translates to:
  /// **'Interactions'**
  String get sectionInteractions;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sectionSecurity;

  /// No description provided for @sectionDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get sectionDevelopment;

  /// No description provided for @settingsBlacklist.
  ///
  /// In en, this message translates to:
  /// **'Blacklist'**
  String get settingsBlacklist;

  /// No description provided for @tagsBlocked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tag blocked} other{{count} tags blocked}}'**
  String tagsBlocked(num count);

  /// No description provided for @settingsFollows.
  ///
  /// In en, this message translates to:
  /// **'Follows'**
  String get settingsFollows;

  /// No description provided for @searchesFollowed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 search followed} other{{count} searches followed}}'**
  String searchesFollowed(num count);

  /// No description provided for @settingsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get settingsHistory;

  /// No description provided for @pagesVisited.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page visited} other{{count} pages visited}}'**
  String pagesVisited(num count);

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'dark'**
  String get themeDark;

  /// No description provided for @themeAmoled.
  ///
  /// In en, this message translates to:
  /// **'amoled'**
  String get themeAmoled;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get themeLight;

  /// No description provided for @themeBlue.
  ///
  /// In en, this message translates to:
  /// **'blue'**
  String get themeBlue;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'system'**
  String get themeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @settingsTileSize.
  ///
  /// In en, this message translates to:
  /// **'Tile size'**
  String get settingsTileSize;

  /// No description provided for @settingsQuilt.
  ///
  /// In en, this message translates to:
  /// **'Quilt'**
  String get settingsQuilt;

  /// No description provided for @gridTitle.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get gridTitle;

  /// No description provided for @quiltSquare.
  ///
  /// In en, this message translates to:
  /// **'tiles are quadratic'**
  String get quiltSquare;

  /// No description provided for @quiltVertical.
  ///
  /// In en, this message translates to:
  /// **'tiles expand vertically'**
  String get quiltVertical;

  /// No description provided for @settingsPostInfo.
  ///
  /// In en, this message translates to:
  /// **'Post info'**
  String get settingsPostInfo;

  /// No description provided for @postInfoShown.
  ///
  /// In en, this message translates to:
  /// **'info on post tiles'**
  String get postInfoShown;

  /// No description provided for @postInfoHidden.
  ///
  /// In en, this message translates to:
  /// **'image tiles only'**
  String get postInfoHidden;

  /// No description provided for @settingsDownloadLocation.
  ///
  /// In en, this message translates to:
  /// **'Download location'**
  String get settingsDownloadLocation;

  /// No description provided for @settingsUpvoteFavorites.
  ///
  /// In en, this message translates to:
  /// **'Upvote favorites'**
  String get settingsUpvoteFavorites;

  /// No description provided for @upvoteFavoritesOn.
  ///
  /// In en, this message translates to:
  /// **'upvote and favorite'**
  String get upvoteFavoritesOn;

  /// No description provided for @upvoteFavoritesOff.
  ///
  /// In en, this message translates to:
  /// **'favorite only'**
  String get upvoteFavoritesOff;

  /// No description provided for @settingsVideoVolume.
  ///
  /// In en, this message translates to:
  /// **'Video volume'**
  String get settingsVideoVolume;

  /// No description provided for @videoMuted.
  ///
  /// In en, this message translates to:
  /// **'muted'**
  String get videoMuted;

  /// No description provided for @videoWithSound.
  ///
  /// In en, this message translates to:
  /// **'with sound'**
  String get videoWithSound;

  /// No description provided for @settingsVideoResolution.
  ///
  /// In en, this message translates to:
  /// **'Video resolution'**
  String get settingsVideoResolution;

  /// No description provided for @videoResStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard (480p)'**
  String get videoResStandard;

  /// No description provided for @videoResHigh.
  ///
  /// In en, this message translates to:
  /// **'High (720p)'**
  String get videoResHigh;

  /// No description provided for @videoResFull.
  ///
  /// In en, this message translates to:
  /// **'Full (1080p)'**
  String get videoResFull;

  /// No description provided for @videoResUltra.
  ///
  /// In en, this message translates to:
  /// **'Ultra (4K)'**
  String get videoResUltra;

  /// No description provided for @videoResSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get videoResSource;

  /// No description provided for @settingsSecureDisplay.
  ///
  /// In en, this message translates to:
  /// **'Secure display'**
  String get settingsSecureDisplay;

  /// No description provided for @secureDisplayOn.
  ///
  /// In en, this message translates to:
  /// **'screen protected'**
  String get secureDisplayOn;

  /// No description provided for @secureDisplayOff.
  ///
  /// In en, this message translates to:
  /// **'screen visible'**
  String get secureDisplayOff;

  /// No description provided for @settingsIncognitoKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Incognito keyboard'**
  String get settingsIncognitoKeyboard;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get disabled;

  /// No description provided for @settingsPinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN lock'**
  String get settingsPinLock;

  /// No description provided for @pinEnabled.
  ///
  /// In en, this message translates to:
  /// **'PIN enabled'**
  String get pinEnabled;

  /// No description provided for @pinDisabled.
  ///
  /// In en, this message translates to:
  /// **'PIN disabled'**
  String get pinDisabled;

  /// No description provided for @settingsBiometricLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric lock'**
  String get settingsBiometricLock;

  /// No description provided for @biometricsEnabled.
  ///
  /// In en, this message translates to:
  /// **'biometrics enabled'**
  String get biometricsEnabled;

  /// No description provided for @biometricsDisabled.
  ///
  /// In en, this message translates to:
  /// **'biometrics disabled'**
  String get biometricsDisabled;

  /// No description provided for @settingsDeveloperMode.
  ///
  /// In en, this message translates to:
  /// **'Developer mode'**
  String get settingsDeveloperMode;

  /// No description provided for @devOptionsShown.
  ///
  /// In en, this message translates to:
  /// **'options shown'**
  String get devOptionsShown;

  /// No description provided for @devOptionsHidden.
  ///
  /// In en, this message translates to:
  /// **'options hidden'**
  String get devOptionsHidden;

  /// No description provided for @settingsLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get settingsLogs;

  /// No description provided for @errorsLogged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 error logged} other{{count} errors logged}}'**
  String errorsLogged(num count);

  /// No description provided for @settingsDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get settingsDatabase;

  /// No description provided for @databaseExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting database...'**
  String get databaseExporting;

  /// No description provided for @databaseExported.
  ///
  /// In en, this message translates to:
  /// **'Database exported successfully'**
  String get databaseExported;

  /// No description provided for @databaseExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get databaseExportFailed;

  /// No description provided for @databaseExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get databaseExport;

  /// No description provided for @databaseImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing database...'**
  String get databaseImporting;

  /// No description provided for @databaseInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid database file: {error}'**
  String databaseInvalidFile(String error);

  /// No description provided for @databaseImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String databaseImportFailed(String error);

  /// No description provided for @databaseImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Database'**
  String get databaseImportTitle;

  /// No description provided for @databaseRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart Required'**
  String get databaseRestartTitle;

  /// No description provided for @databaseRestartBody.
  ///
  /// In en, this message translates to:
  /// **'The app needs to restart to apply changes.'**
  String get databaseRestartBody;

  /// No description provided for @databaseImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get databaseImport;

  /// No description provided for @lockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get lockEnterPin;

  /// No description provided for @lockEnterNewPin.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get lockEnterNewPin;

  /// No description provided for @lockConfirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get lockConfirmNewPin;

  /// No description provided for @lockFailedAuth.
  ///
  /// In en, this message translates to:
  /// **'Failed to authenticate'**
  String get lockFailedAuth;

  /// No description provided for @lockPleaseAuth.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate'**
  String get lockPleaseAuth;

  /// No description provided for @lockRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get lockRetry;

  /// No description provided for @lockBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock.'**
  String get lockBiometricReason;

  /// No description provided for @lockBiometricFailure.
  ///
  /// In en, this message translates to:
  /// **'Severe failure in biometric authentication'**
  String get lockBiometricFailure;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @updaterFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching updates...'**
  String get updaterFetching;

  /// No description provided for @updaterCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates'**
  String get updaterCheckFailed;

  /// No description provided for @updaterNewest.
  ///
  /// In en, this message translates to:
  /// **'You have the newest version'**
  String get updaterNewest;

  /// No description provided for @updaterNewer.
  ///
  /// In en, this message translates to:
  /// **'A newer version is available: {version}'**
  String updaterNewer(String version);

  /// No description provided for @updaterNewerHeader.
  ///
  /// In en, this message translates to:
  /// **'A newer version is available: '**
  String get updaterNewerHeader;

  /// No description provided for @aboutExperimentalPlatform.
  ///
  /// In en, this message translates to:
  /// **'Experimental platform'**
  String get aboutExperimentalPlatform;

  /// No description provided for @aboutExperimentalBody.
  ///
  /// In en, this message translates to:
  /// **'This platform is not supported. Expect bugs and missing features.'**
  String get aboutExperimentalBody;

  /// No description provided for @aboutGitHub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get aboutGitHub;

  /// No description provided for @aboutUpstream.
  ///
  /// In en, this message translates to:
  /// **'Upstream'**
  String get aboutUpstream;

  /// No description provided for @aboutUpstreamBody.
  ///
  /// In en, this message translates to:
  /// **'This app is a fork of clragon/e1547'**
  String get aboutUpstreamBody;

  /// No description provided for @aboutDiscord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get aboutDiscord;

  /// No description provided for @aboutForum.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get aboutForum;

  /// No description provided for @aboutForumTopic.
  ///
  /// In en, this message translates to:
  /// **'e621 thread #{id}'**
  String aboutForumTopic(num id);

  /// No description provided for @aboutWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutWebsite;

  /// No description provided for @aboutKofi.
  ///
  /// In en, this message translates to:
  /// **'Ko-fi'**
  String get aboutKofi;

  /// No description provided for @aboutEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutEmail;

  /// No description provided for @aboutPlaystore.
  ///
  /// In en, this message translates to:
  /// **'Playstore'**
  String get aboutPlaystore;

  /// No description provided for @aboutDonors.
  ///
  /// In en, this message translates to:
  /// **'Donors'**
  String get aboutDonors;

  /// No description provided for @aboutDonorsThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for helping me keep up development!'**
  String get aboutDonorsThanks;

  /// No description provided for @aboutNoDonors.
  ///
  /// In en, this message translates to:
  /// **'No donors yet'**
  String get aboutNoDonors;

  /// No description provided for @aboutDonorsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch donors'**
  String get aboutDonorsFailed;

  /// No description provided for @developerUnlocked.
  ///
  /// In en, this message translates to:
  /// **'You are now a developer!'**
  String get developerUnlocked;

  /// No description provided for @databaseErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading database'**
  String get databaseErrorLoading;

  /// No description provided for @databaseUnknownSize.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get databaseUnknownSize;

  /// No description provided for @databaseExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Database'**
  String get databaseExportTitle;

  /// No description provided for @databaseExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a backup copy of your database'**
  String get databaseExportSubtitle;

  /// No description provided for @databaseImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current database with imported one'**
  String get databaseImportSubtitle;

  /// No description provided for @databaseImportWarning.
  ///
  /// In en, this message translates to:
  /// **'This will replace your current database. \nAll data will be lost. This cannot be undone!'**
  String get databaseImportWarning;

  /// No description provided for @postsTitle.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsTitle;

  /// No description provided for @favoritesOf.
  ///
  /// In en, this message translates to:
  /// **'{user}\'s Favorites'**
  String favoritesOf(String user);

  /// No description provided for @favoritesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Favorites are unavailable for anonymous users'**
  String get favoritesUnavailable;

  /// No description provided for @favoriteOrder.
  ///
  /// In en, this message translates to:
  /// **'Favorite order'**
  String get favoriteOrder;

  /// No description provided for @orderAdded.
  ///
  /// In en, this message translates to:
  /// **'added order'**
  String get orderAdded;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'id order'**
  String get orderId;

  /// No description provided for @postStateDeleted.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get postStateDeleted;

  /// No description provided for @postStateUnsupported.
  ///
  /// In en, this message translates to:
  /// **'unsupported'**
  String get postStateUnsupported;

  /// No description provided for @postStateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'unavailable'**
  String get postStateUnavailable;

  /// No description provided for @menuShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get menuShare;

  /// No description provided for @menuDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get menuDownload;

  /// No description provided for @menuBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get menuBrowse;

  /// No description provided for @menuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// No description provided for @menuComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get menuComment;

  /// No description provided for @menuReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get menuReport;

  /// No description provided for @menuFlag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get menuFlag;

  /// No description provided for @actionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// No description provided for @actionFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get actionFollow;

  /// No description provided for @actionUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get actionUnfollow;

  /// No description provided for @actionMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get actionMute;

  /// No description provided for @actionNotify.
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get actionNotify;

  /// No description provided for @actionBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get actionBookmark;

  /// No description provided for @actionUnbookmark.
  ///
  /// In en, this message translates to:
  /// **'Unbookmark'**
  String get actionUnbookmark;

  /// No description provided for @actionBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get actionBlock;

  /// No description provided for @actionUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get actionUnblock;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionSubtract.
  ///
  /// In en, this message translates to:
  /// **'Subtract'**
  String get actionSubtract;

  /// No description provided for @selectionPost.
  ///
  /// In en, this message translates to:
  /// **'post #{id}'**
  String selectionPost(num id);

  /// No description provided for @selectionPostsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} posts}}'**
  String selectionPostsCount(num count);

  /// No description provided for @noPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts'**
  String get noPosts;

  /// No description provided for @failedToLoadPosts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load posts'**
  String get failedToLoadPosts;

  /// No description provided for @postDeletedOverlay.
  ///
  /// In en, this message translates to:
  /// **'Post was deleted'**
  String get postDeletedOverlay;

  /// No description provided for @postUnavailableOverlay.
  ///
  /// In en, this message translates to:
  /// **'Post is unavailable'**
  String get postUnavailableOverlay;

  /// No description provided for @postBlacklistedOverlay.
  ///
  /// In en, this message translates to:
  /// **'Post is blacklisted'**
  String get postBlacklistedOverlay;

  /// No description provided for @unsupportedFileType.
  ///
  /// In en, this message translates to:
  /// **'{ext} files are not supported'**
  String unsupportedFileType(String ext);

  /// No description provided for @loginRequiredEdit.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to edit posts!'**
  String get loginRequiredEdit;

  /// No description provided for @loginRequiredComment.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to comment!'**
  String get loginRequiredComment;

  /// No description provided for @loginRequiredReport.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to report posts!'**
  String get loginRequiredReport;

  /// No description provided for @loginRequiredFlag.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to flag posts!'**
  String get loginRequiredFlag;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
