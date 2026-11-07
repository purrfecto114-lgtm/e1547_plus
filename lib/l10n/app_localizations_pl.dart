// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'e1547';

  @override
  String get failedToLoad => 'Nie udało się załadować';

  @override
  String get nothingToSeeHere => 'Tu nic nie ma';

  @override
  String get loading => 'Ładowanie...';

  @override
  String get actionCancel => 'ANULUJ';

  @override
  String get actionOk => 'OK';

  @override
  String get actionTryAgain => 'Spróbuj ponownie';

  @override
  String get actionDownload => 'POBIERZ';

  @override
  String get actionImport => 'IMPORTUJ';

  @override
  String get actionExport => 'EKSPORTUJ';

  @override
  String get actionUndo => 'Cofnij';

  @override
  String get actionRestartNow => 'URUCHOM PONOWNIE';

  @override
  String get failedToLoadSuggestions => 'Nie udało się załadować sugestii';

  @override
  String selectionItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementów',
      many: '$count elementów',
      few: '$count elementy',
      one: '1 element',
    );
    return '$_temp0';
  }

  @override
  String get actionAbort => 'Przerwij';

  @override
  String get actionSelectAll => 'Zaznacz wszystko';

  @override
  String fileSavedAs(String name) {
    return 'Plik zapisany jako $name';
  }

  @override
  String get copiedToClipboard => 'Skopiowano do schowka';

  @override
  String get saveFile => 'Zapisz plik';

  @override
  String get filterTooltip => 'Filtr';

  @override
  String get rangeInvalidFormat => 'Nieprawidłowy format';

  @override
  String itemProgress(num current, num total) {
    return 'Element $current/$total';
  }

  @override
  String get taskCancelled => 'Zadanie anulowane';

  @override
  String taskFailedAt(num index) {
    return 'Niepowodzenie przy elemencie $index';
  }

  @override
  String get taskDone => 'Zakończono';

  @override
  String get failedToInitialize => 'Nie udało się zainicjować';

  @override
  String get navHome => 'Strona główna';

  @override
  String get navHot => 'Popularne';

  @override
  String get navSearch => 'Szukaj';

  @override
  String get navFavorites => 'Ulubione';

  @override
  String get navTimeline => 'Ostatnie';

  @override
  String get navSubscriptions => 'Subskrypcje';

  @override
  String get navBookmarks => 'Zakładki';

  @override
  String get navPools => 'Zbiory';

  @override
  String get navForum => 'Forum';

  @override
  String get navHistory => 'Historia';

  @override
  String get navTasks => 'Zadania';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get navAbout => 'O aplikacji';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get sectionAccount => 'Konto';

  @override
  String get sectionUser => 'Użytkownik';

  @override
  String get sectionAppearance => 'Wygląd';

  @override
  String get sectionInteractions => 'Interakcje';

  @override
  String get sectionSecurity => 'Bezpieczeństwo';

  @override
  String get sectionDevelopment => 'Rozwój';

  @override
  String get settingsBlacklist => 'Czarna lista';

  @override
  String tagsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tagów zablokowanych',
      many: '$count tagów zablokowanych',
      few: '$count tagi zablokowane',
      one: '1 tag zablokowany',
    );
    return '$_temp0';
  }

  @override
  String get settingsFollows => 'Obserwowane';

  @override
  String searchesFollowed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wyszukiwań obserwowanych',
      many: '$count wyszukiwań obserwowanych',
      few: '$count wyszukiwania obserwowane',
      one: '1 wyszukiwanie obserwowane',
    );
    return '$_temp0';
  }

  @override
  String get settingsHistory => 'Historia';

  @override
  String pagesVisited(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stron odwiedzonych',
      many: '$count stron odwiedzonych',
      few: '$count strony odwiedzone',
      one: '1 strona odwiedzona',
    );
    return '$_temp0';
  }

  @override
  String get settingsTheme => 'Motyw';

  @override
  String get themeDark => 'ciemny';

  @override
  String get themeAmoled => 'amoled';

  @override
  String get themeLight => 'jasny';

  @override
  String get themeBlue => 'niebieski';

  @override
  String get themeSystem => 'systemowy';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get languageSystemDefault => 'Domyślny systemu';

  @override
  String get settingsHandedness => 'Preferowana ręka';

  @override
  String get handRight => 'Prawa';

  @override
  String get handLeft => 'Lewa';

  @override
  String get settingsHandednessHint =>
      'Przyciski i szybkie akcje przesuwane są w zasięg tej ręki.';

  @override
  String get settingsTileSize => 'Rozmiar kafelków';

  @override
  String get settingsQuilt => 'Kafelki';

  @override
  String get gridTitle => 'Siatka';

  @override
  String get quiltSquare => 'kwadratowe kafelki';

  @override
  String get quiltVertical => 'kafelki rozciągane pionowo';

  @override
  String get settingsPostInfo => 'Informacje o poście';

  @override
  String get postInfoShown => 'informacje na kafelkach';

  @override
  String get postInfoHidden => 'tylko obrazki';

  @override
  String get settingsDownloadLocation => 'Lokalizacja pobierania';

  @override
  String get settingsUpvoteFavorites => 'Ocena ulubionych';

  @override
  String get upvoteFavoritesOn => 'ocenianie i dodawanie do ulubionych';

  @override
  String get upvoteFavoritesOff => 'tylko dodawanie do ulubionych';

  @override
  String get settingsVideoVolume => 'Głośność wideo';

  @override
  String get videoMuted => 'wyciszone';

  @override
  String get videoWithSound => 'z dźwiękiem';

  @override
  String videoSeekSeconds(Object seconds) {
    return '$seconds sekund';
  }

  @override
  String get videoResSource => 'Źródłowa';

  @override
  String get videoResNote =>
      'Wideo nie zawsze są dostępne w standardowych rozmiarach; używany jest najbliższy wybranemu.';

  @override
  String get qualityLow => 'Niska';

  @override
  String get qualityMedium => 'Średnia';

  @override
  String get qualityHigh => 'Wysoka';

  @override
  String get settingsAutoLoadVideos => 'Automatyczne ładowanie wideo';

  @override
  String get autoLoadVideosOn => 'wideo ładują się podczas przeglądania';

  @override
  String get autoLoadVideosOff => 'wideo ładują się podczas odtwarzania';

  @override
  String get autoLoadVideosDialogTitle => 'Ładować wideo automatycznie?';

  @override
  String get autoLoadVideosDialogBody =>
      'Wideo zostaną pobrane w całości podczas przeglądania i wyszukiwania. Może to zużyć dużo danych na połączeniach z limitem transferu.';

  @override
  String get videoQuality => 'Jakość wideo';

  @override
  String get settingsSecureDisplay => 'Bezpieczny ekran';

  @override
  String get secureDisplayOn => 'ekran chroniony';

  @override
  String get secureDisplayOff => 'ekran widoczny';

  @override
  String get secureDisplayCover => 'Ukryto zawartość';

  @override
  String get settingsIncognitoKeyboard => 'Klawiatura incognito';

  @override
  String get enabled => 'włączone';

  @override
  String get disabled => 'wyłączone';

  @override
  String get settingsPinLock => 'Blokada PIN';

  @override
  String get pinEnabled => 'PIN włączony';

  @override
  String get pinDisabled => 'PIN wyłączony';

  @override
  String get settingsBiometricLock => 'Blokada biometryczna';

  @override
  String get biometricsEnabled => 'biometria włączona';

  @override
  String get biometricsDisabled => 'biometria wyłączona';

  @override
  String get biometricsUnavailable =>
      'na tym urządzeniu nie znaleziono biometrii';

  @override
  String get settingsUpdaterBeta => 'Najnowsze aktualizacje';

  @override
  String get updaterBetaOn => 'Wersje stabilne i przedpremierowe';

  @override
  String get updaterBetaOff => 'Tylko wersje stabilne';

  @override
  String get settingsDeveloperMode => 'Tryb deweloperski';

  @override
  String get devOptionsShown => 'opcje widoczne';

  @override
  String get devOptionsHidden => 'opcje ukryte';

  @override
  String errorsLogged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count błędów zapisanych',
      many: '$count błędów zapisanych',
      few: '$count błędy zapisane',
      one: '1 błąd zapisany',
    );
    return '$_temp0';
  }

  @override
  String get settingsDatabase => 'Baza danych';

  @override
  String get databaseExporting => 'Eksportowanie bazy danych...';

  @override
  String get databaseExported => 'Baza danych wyeksportowana pomyślnie';

  @override
  String get databaseExportFailed => 'Eksport nieudany';

  @override
  String get databaseExport => 'Eksportuj';

  @override
  String get databaseImporting => 'Importowanie bazy danych...';

  @override
  String databaseInvalidFile(String error) {
    return 'Nieprawidłowy plik bazy danych: $error';
  }

  @override
  String databaseImportFailed(String error) {
    return 'Import nieudany: $error';
  }

  @override
  String get databaseImportTitle => 'Importuj bazę danych';

  @override
  String get databaseRestartTitle => 'Wymagane ponowne uruchomienie';

  @override
  String get databaseRestartBody =>
      'Aplikacja musi zostać uruchomiona ponownie, aby zastosować zmiany.';

  @override
  String get databaseImport => 'Importuj';

  @override
  String get lockEnterPin => 'Wprowadź PIN';

  @override
  String get lockEnterNewPin => 'Wprowadź nowy PIN';

  @override
  String get lockConfirmNewPin => 'Potwierdź nowy PIN';

  @override
  String get lockFailedAuth => 'Uwierzytelnienie nieudane';

  @override
  String get lockPleaseAuth => 'Proszę uwierzytelnić się';

  @override
  String get lockRetry => 'Spróbuj ponownie';

  @override
  String get lockBiometricReason => 'Uwierzytelnij się, aby odblokować.';

  @override
  String get lockBiometricFailure =>
      'Poważny błąd uwierzytelniania biometrycznego';

  @override
  String get lockWrongPin => 'Nieprawidłowy PIN';

  @override
  String get lockPinMismatch => 'Kody PIN nie są zgodne';

  @override
  String get aboutVersion => 'Wersja';

  @override
  String get updaterFetching => 'Sprawdzanie aktualizacji...';

  @override
  String get updaterCheckFailed => 'Nie udało się sprawdzić aktualizacji';

  @override
  String get updaterNewest => 'Masz najnowszą wersję';

  @override
  String updaterNewer(String version) {
    return 'Dostępna jest nowsza wersja: $version';
  }

  @override
  String get updaterNewerHeader => 'Dostępna jest nowsza wersja: ';

  @override
  String get aboutExperimentalPlatform => 'Platforma eksperymentalna';

  @override
  String get aboutExperimentalBody =>
      'Ta platforma nie jest wspierana. Spodziewaj się błędów i brakujących funkcji.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutUpstream => 'Główny projekt';

  @override
  String get aboutUpstreamBody => 'Ta aplikacja to fork clragon/e1547';

  @override
  String get aboutDiscord => 'Discord';

  @override
  String get aboutForum => 'Forum';

  @override
  String aboutForumTopic(num id) {
    return 'wątek e621 #$id';
  }

  @override
  String get aboutWebsite => 'Strona internetowa';

  @override
  String get aboutKofi => 'Ko-fi';

  @override
  String get aboutEmail => 'Email';

  @override
  String get aboutPlaystore => 'Playstore';

  @override
  String get aboutDonors => 'Darczyńcy';

  @override
  String get aboutDonorsThanks => 'Dzięki za pomoc w dalszym rozwoju!';

  @override
  String get aboutNoDonors => 'Brak darczyńców';

  @override
  String get aboutDonorsFailed => 'Nie udało się pobrać listy darczyńców';

  @override
  String get aboutDonorsNotListed => 'Nie na liście? Skontaktuj się z nami!';

  @override
  String get developerUnlocked => 'Jesteś teraz deweloperem!';

  @override
  String get databaseErrorLoading => 'Błąd ładowania bazy danych';

  @override
  String get databaseUnknownSize => 'Nieznany';

  @override
  String get databaseExportTitle => 'Eksportuj bazę danych';

  @override
  String get databaseExportSubtitle => 'Zapisz kopię zapasową bazy danych';

  @override
  String get databaseImportSubtitle =>
      'Zastąp obecną bazę danych zaimportowaną';

  @override
  String get databaseImportWarning =>
      'To zastąpi Twoją obecną bazę danych. \nWszystkie dane zostaną utracone. Nie można tego cofnąć!';

  @override
  String get databaseExportSanitizedBody =>
      'Wyeksportowany plik nie będzie zawierał Twoich logowań ani kluczy API.\nWszystko inne, w tym konta, hosty, historia, obserwacje i zadania, jest uwzględnione.';

  @override
  String get databaseImportNewerFile =>
      'Ten plik został utworzony przez nowszą wersję aplikacji i nie może zostać zaimportowany.';

  @override
  String get databaseImportSanitized =>
      'Dla bezpieczeństwa, zapisane logowania zostały usunięte z zaimportowanego pliku.';

  @override
  String databaseImportHostsWarning(String hosts) {
    return 'Ostrzeżenie: zaimportowany plik zawiera konta na innych stronach: $hosts';
  }

  @override
  String get databaseImportCancelled => 'Import anulowany';

  @override
  String get postsTitle => 'Posty';

  @override
  String favoritesOf(String user) {
    return 'Ulubione $user';
  }

  @override
  String get favoritesUnavailable =>
      'Ulubione są niedostępne dla użytkowników anonimowych';

  @override
  String get favoriteOrder => 'Ulubiona kolejność';

  @override
  String get orderAdded => 'dodana kolejność';

  @override
  String get orderId => 'id kolejności';

  @override
  String get postStateDeleted => 'usunięty';

  @override
  String get postStateUnsupported => 'nieobsługiwany';

  @override
  String get postStateUnavailable => 'niedostępny';

  @override
  String get menuShare => 'Udostępnij';

  @override
  String get menuDownload => 'Pobierz';

  @override
  String get menuBrowse => 'Przeglądaj';

  @override
  String get menuEdit => 'Edytuj';

  @override
  String get menuComment => 'Komentarz';

  @override
  String get menuReport => 'Zgłoś';

  @override
  String get menuFlag => 'Oznacz';

  @override
  String get actionOpen => 'Otwórz';

  @override
  String get actionFollow => 'Obserwuj';

  @override
  String get actionUnfollow => 'Przestań obserwować';

  @override
  String get actionMute => 'Wycisz';

  @override
  String get actionNotify => 'Powiadom';

  @override
  String get actionBookmark => 'Zakładka';

  @override
  String get actionUnbookmark => 'Usuń zakładkę';

  @override
  String get actionBlock => 'Zablokuj';

  @override
  String get actionUnblock => 'Odblokuj';

  @override
  String get actionRemove => 'Usuń';

  @override
  String get actionAdd => 'Dodaj';

  @override
  String get actionSubtract => 'Odejmij';

  @override
  String selectionPost(num id) {
    return 'post #$id';
  }

  @override
  String selectionPostsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count postów',
    );
    return '$_temp0';
  }

  @override
  String get noPosts => 'Brak postów';

  @override
  String get failedToLoadPosts => 'Nie udało się załadować postów';

  @override
  String get offlineBanner =>
      'Jesteś offline. Wyświetlanie danych z pamięci podręcznej.';

  @override
  String get offlineNoData => 'Jesteś offline';

  @override
  String postListPageSummary(num count, Object page) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count postów',
      one: '$count post',
    );
    return 'Strona $page · $_temp0';
  }

  @override
  String get postListPageLimit =>
      'Osiągnięto limit stron serwera. Proszę zawęź wyszukiwanie.';

  @override
  String get postListJumpToPage => 'Przejdź do strony';

  @override
  String get postListJumpPageLabel => 'Numer strony';

  @override
  String postListJumpPageRange(Object max) {
    return 'Wpisz numer strony między 1 a $max';
  }

  @override
  String get postDeletedOverlay => 'Post został usunięty';

  @override
  String get postUnavailableOverlay => 'Post jest niedostępny';

  @override
  String get postBlacklistedOverlay => 'Post jest na czarnej liście';

  @override
  String unsupportedFileType(String ext) {
    return 'Pliki typu $ext nie są obsługiwane';
  }

  @override
  String get loginRequiredEdit => 'Musisz być zalogowany, aby edytować posty!';

  @override
  String get loginRequiredComment => 'Musisz być zalogowany, aby komentować!';

  @override
  String get loginRequiredReport =>
      'Musisz być zalogowany, aby zgłaszać posty!';

  @override
  String get loginRequiredFlag => 'Musisz być zalogowany, aby oznaczać posty!';

  @override
  String postsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zablokowano $count postów',
      one: 'Zablokowany 1 post',
    );
    return '$_temp0';
  }

  @override
  String get blacklistUpdateFailed =>
      'Nie udało się zaktualizować czarnej listy!';

  @override
  String get blacklistAddTag => 'Dodaj tag';

  @override
  String get blacklistEditTag => 'Edytuj tag';

  @override
  String get denylistEntryDeleted => 'Usunięto wpis z czarnej listy';

  @override
  String get blacklistEmpty => 'Twoja czarna lista jest pusta';

  @override
  String get menuDelete => 'Usuń';

  @override
  String get filterScore => 'Ocena';

  @override
  String get filterFavoriteCount => 'Liczba ulubionych';

  @override
  String get filterSortBy => 'Sortuj według';

  @override
  String get filterNew => 'Nowe';

  @override
  String get filterRank => 'Ranking';

  @override
  String get filterRandom => 'Losowe';

  @override
  String get filterDefault => 'Domyślne';

  @override
  String get filterRating => 'Ocena';

  @override
  String get filterSafe => 'Bezpieczne';

  @override
  String get filterQuestionable => 'Wątpliwe';

  @override
  String get filterExplicit => 'Jawne';

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get filterPool => 'Zbiór';

  @override
  String get filterHasPool => 'Ma zbiór';

  @override
  String get filterChild => 'Dziecko';

  @override
  String get filterIsChildPost => 'Jest postem-dzieckiem';

  @override
  String get filterParent => 'Rodzic';

  @override
  String get filterIsParentPost => 'Jest postem-rodzicem';

  @override
  String get filterUploadDate => 'Data przesłania';

  @override
  String get filterLastDay => 'Ostatni dzień';

  @override
  String get filterLastWeek => 'Ostatni tydzień';

  @override
  String get filterLastMonth => 'Ostatni miesiąc';

  @override
  String get filterLastYear => 'Ostatni rok';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterActive => 'Aktywne';

  @override
  String get filterPending => 'Oczekujące';

  @override
  String get filterDeleted => 'Usunięte';

  @override
  String get filterFlagged => 'Oznaczone';

  @override
  String get filterAny => 'Dowolne';

  @override
  String get filterFileType => 'Typ pliku';

  @override
  String get filterUploader => 'Przesyłający';

  @override
  String get filterWidth => 'Szerokość';

  @override
  String get filterHeight => 'Wysokość';

  @override
  String get filterTagCount => 'Liczba tagów';

  @override
  String get filterTrue => 'Prawda';

  @override
  String get filterFalse => 'Fałsz';

  @override
  String get filterImages => 'Obrazy';

  @override
  String get filterVideos => 'Wideo';

  @override
  String get filterTitleContains => 'Tytuł zawiera';

  @override
  String get filterCategory => 'Kategoria';

  @override
  String get filterGeneral => 'Ogólne';

  @override
  String get filterSiteBugReports => 'Zgłoszenia błędów i propozycje funkcji';

  @override
  String get filterTagWikiProjects => 'Projekty tagów/wiki i pytania';

  @override
  String get filterTagAliasSuggestions =>
      'Propozycje aliasów i implikacji tagów';

  @override
  String get filterArtTalk => 'Rozmowy o sztuce';

  @override
  String get filterOffTopic => 'Pozaspecjalistyczne';

  @override
  String get filterE621Tools => 'Narzędzia i aplikacje e621';

  @override
  String get filterNewestFirst => 'Najpierw najnowsze';

  @override
  String get filterOldestFirst => 'Najpierw najstarsze';

  @override
  String get filterSticky => 'Przyklejone';

  @override
  String get filterIsSticky => 'Jest przyklejone';

  @override
  String get filterLocked => 'Zablokowane';

  @override
  String get filterIsLocked => 'Jest zablokowane';

  @override
  String get filterDescription => 'Opis';

  @override
  String get filterCreator => 'Twórca';

  @override
  String get filterIsActive => 'Jest aktywne';

  @override
  String get filterSeries => 'Seria';

  @override
  String get filterCollection => 'Kolekcja';

  @override
  String get filterName => 'Nazwa';

  @override
  String get filterCreated => 'Utworzone';

  @override
  String get filterUpdated => 'Zaktualizowane';

  @override
  String get filterPostCount => 'Liczba wpisów';

  @override
  String postUpdateFailed(num id) {
    return 'Nie udało się zaktualizować wpisu #$id';
  }

  @override
  String postUpdated(num id) {
    return 'Zaktualizowano wpis #$id';
  }

  @override
  String get failedToLoadPost => 'Nie udało się załadować wpisu';

  @override
  String get postNotFound => 'Nie znaleziono wpisu';

  @override
  String get commentsTitle => 'Komentarze';

  @override
  String commentsOfPost(num postId) {
    return 'Komentarze do #$postId';
  }

  @override
  String get commentOrder => 'Kolejność komentarzy';

  @override
  String get noComments => 'Brak komentarzy';

  @override
  String get failedToLoadComments => 'Nie udało się załadować komentarzy';

  @override
  String commentTitle(num id) {
    return 'Komentarz #$id';
  }

  @override
  String get failedToLoadComment => 'Nie udało się załadować komentarza';

  @override
  String get commentNotFound => 'Nie znaleziono komentarza';

  @override
  String commentEditorTitle(num postId) {
    return 'Komentarz #$postId';
  }

  @override
  String get commentSendFailed => 'Nie udało się wysłać komentarza!';

  @override
  String get commentSent => 'Komentarz wysłany!';

  @override
  String get commentHidden => 'Ten komentarz jest ukryty';

  @override
  String commentUpvoteFailed(num id) {
    return 'Nie udało się zagłosować na komentarz #$id';
  }

  @override
  String commentDownvoteFailed(num id) {
    return 'Nie udało się zagłosować na komentarz #$id';
  }

  @override
  String get commentLoginRequiredEdit =>
      'Musisz być zalogowany, aby edytować komentarze!';

  @override
  String get commentLoginRequiredReply =>
      'Musisz być zalogowany, aby odpowiadać na komentarze!';

  @override
  String get commentLoginRequiredReport =>
      'Musisz być zalogowany, aby zgłaszać komentarze!';

  @override
  String commentCopiedId(num id) {
    return 'Skopiowano ID komentarza #$id';
  }

  @override
  String get warningUserWarned =>
      'Użytkownik otrzymał ostrzeżenie za tę wiadomość';

  @override
  String get warningUserRecorded =>
      'Użytkownik otrzymał notatkę za tę wiadomość';

  @override
  String get warningUserBanned => 'Użytkownik został zbanowany za tę wiadomość';

  @override
  String get repliesTitle => 'Odpowiedzi';

  @override
  String get replyOrder => 'Kolejność odpowiedzi';

  @override
  String get noReplies => 'Brak odpowiedzi';

  @override
  String get failedToLoadReplies => 'Nie udało się załadować odpowiedzi';

  @override
  String replyTitle(num id) {
    return 'Odpowiedź #$id';
  }

  @override
  String get failedToLoadReply => 'Nie udało się załadować odpowiedzi';

  @override
  String get replyNotFound => 'Nie znaleziono odpowiedzi';

  @override
  String replyEditorTitle(num topicId) {
    return 'Odpowiedź #$topicId';
  }

  @override
  String get replySendFailed => 'Nie udało się wysłać odpowiedzi!';

  @override
  String get replySent => 'Odpowiedź wysłana!';

  @override
  String get replyHidden => 'Ta odpowiedź jest ukryta';

  @override
  String get replyLoginRequiredEdit =>
      'Musisz być zalogowany, aby edytować odpowiedzi!';

  @override
  String get replyLoginRequiredReply =>
      'Musisz być zalogowany, aby odpowiadać!';

  @override
  String get replyLoginRequiredReport =>
      'Musisz być zalogowany, aby zgłaszać odpowiedzi!';

  @override
  String replyCopiedId(num id) {
    return 'Skopiowano ID odpowiedzi #$id';
  }

  @override
  String get menuReply => 'Odpowiedz';

  @override
  String get menuCopyId => 'Kopiuj ID';

  @override
  String get menuRefresh => 'Odśwież';

  @override
  String get actionCopy => 'Kopiuj';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get actionShow => 'Pokaż';

  @override
  String get actionHide => 'Ukryj';

  @override
  String get actionCannotBeUndone => 'Tej akcji nie można cofnąć.';

  @override
  String get info => 'Informacje';

  @override
  String wikiTitle(String idOrTitle) {
    return 'Wiki $idOrTitle';
  }

  @override
  String get failedToLoadWiki => 'Nie udało się załadować wiki';

  @override
  String get wikiNotFound => 'Nie znaleziono wiki';

  @override
  String wikiCopiedId(num id) {
    return 'Skopiowano ID wiki #$id';
  }

  @override
  String get wikiInfoId => 'id';

  @override
  String get wikiInfoAlias => 'alias';

  @override
  String get wikiInfoCreated => 'utworzone';

  @override
  String get wikiInfoUpdated => 'zaktualizowane';

  @override
  String get wikiInfoLocked => 'zablokowane';

  @override
  String get wikiInfoYes => 'tak';

  @override
  String get wikiInfoNo => 'nie';

  @override
  String userTitle(String idOrName) {
    return 'Użytkownik $idOrName';
  }

  @override
  String get failedToLoadUser => 'Nie udało się załadować użytkownika';

  @override
  String get userNotFound => 'Użytkownik nie znaleziony';

  @override
  String get userUploads => 'Przesłania';

  @override
  String get userLoginRequiredReport =>
      'Musisz być zalogowany, aby zgłosić użytkownika!';

  @override
  String get userComission => 'Zlecenie';

  @override
  String get userId => 'id';

  @override
  String get userJoined => 'dołączył';

  @override
  String get userRank => 'poziom';

  @override
  String get userPosts => 'wpisy';

  @override
  String get userEdits => 'edycje';

  @override
  String get userFavorites => 'ulubione';

  @override
  String get userComments => 'komentarze';

  @override
  String get userForum => 'forum';

  @override
  String userCopiedId(num id) {
    return 'Skopiowano id użytkownika #$id';
  }

  @override
  String get logsTitle => 'Logi';

  @override
  String logsTitleDate(String date) {
    return 'Logi - $date';
  }

  @override
  String selectionLogsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count logi',
    );
    return '$_temp0';
  }

  @override
  String selectionLogsFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plików logów',
    );
    return '$_temp0';
  }

  @override
  String get logsLevels => 'Poziomy';

  @override
  String get logsRecording => 'Nagrywanie';

  @override
  String get logsVerbose => 'Szczegółowość';

  @override
  String get logsVerboseAll => 'zapisywane wszystkie poziomy';

  @override
  String logsVerboseMinimum(String level) {
    return 'poziom $level i wyższe';
  }

  @override
  String get logFilesTitle => 'Pliki logów';

  @override
  String get failedToLoadLogFiles => 'Nie udało się załadować plików logów!';

  @override
  String get noLogFiles => 'Brak dostępnych plików logów!';

  @override
  String get logsLive => 'Na żywo';

  @override
  String get noLogs => 'Brak logów';

  @override
  String get failedToReadLog => 'Nie udało się odczytać logu';

  @override
  String get noErrorsLogged => 'Brak zapisanych błędów';

  @override
  String logsErrorsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count błędów',
      one: '1 błąd',
    );
    return '$_temp0';
  }

  @override
  String get logsAll => 'Wszystkie logi';

  @override
  String get logsDismissAll => 'Odrzuć wszystkie';

  @override
  String logsDeleteTitle(num count) {
    return 'Usunąć $count plików logów?';
  }

  @override
  String get identityAccounts => 'Konta';

  @override
  String get identityAdd => 'Dodaj konto';

  @override
  String get identityEdit => 'Edytuj konto';

  @override
  String get identityRemoveTitle => 'Usunąć konto?';

  @override
  String get identityRemoveBody =>
      'Wszystkie jego dane zostaną trwale usunięte, w tym historia i obserwowani.';

  @override
  String get identityAnonymous => 'Anonimowy';

  @override
  String get identityDuplicate =>
      'Masz już tożsamość dla tej domeny i nazwy użytkownika.';

  @override
  String identityLoginFailed(String reason) {
    return 'Nie udało się zalogować. \n$reason';
  }

  @override
  String get identityLoginCheckDetails =>
      'Sprawdź połączenie z siecią i dane logowania';

  @override
  String get identitySite => 'Strona';

  @override
  String get identityHostRequired => 'Musisz podać adres URL strony.';

  @override
  String get identityHostInvalid => 'Nieprawidłowy adres URL';

  @override
  String get identityHostReadOnly =>
      'Strona nie może być zmieniona. Dodaj nowe konto, aby użyć innej.';

  @override
  String get identityUsernameLabel => 'Nazwa użytkownika';

  @override
  String get identityUsernameRequired => 'Musisz podać nazwę użytkownika.';

  @override
  String get identityApikeyLabel => 'Klucz API';

  @override
  String get identityApikeyHelp => 'Gdzie mogę znaleźć swój klucz API?';

  @override
  String get identityApikeyRequired =>
      'Musisz podać klucz API.\nnp. 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identityApikeyInvalid =>
      'Klucz API to ciąg 24 lub 32 znaków A-z i 0-9\nnp. 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identitySignupPrompt => 'Nie masz konta? Zarejestruj się tutaj';

  @override
  String get identityHostHint =>
      'Strona, na której znajduje się Twoje konto i wpisy.';

  @override
  String get identitySignIn => 'Zaloguj się';

  @override
  String get identityGuest => 'Gość';

  @override
  String get identityLogin => 'Logowanie';

  @override
  String get identityBrowseAnonymously => 'Przeglądaj anonimowo';

  @override
  String identityConnecting(String host, String username) {
    return 'Łączenie z $host jako $username…';
  }

  @override
  String identityActivateFailed(Object error) {
    return 'Nie udało się aktywować tożsamości: $error';
  }

  @override
  String traitsActivateFailed(Object error) {
    return 'Nie udało się aktywować cech: $error';
  }

  @override
  String get failedToLoadIdentities => 'Nie udało się załadować tożsamości';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingBack => 'Wstecz';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String onboardingWelcomeTitle(String app) {
    return 'Witaj w $app';
  }

  @override
  String get onboardingWelcomeBody => 'Zaawansowana przeglądarka booru.';

  @override
  String get onboardingThemeTitle => 'Wybierz wygląd';

  @override
  String get onboardingThemeBody =>
      'Wybierz motyw. Zawsze możesz to zmienić później.';

  @override
  String get onboardingQualityTitle => 'Dostosuj media';

  @override
  String get onboardingQualityBody =>
      'Wybierz, jak ciężkie mają być wideo i miniatury. Możesz to zmienić później w ustawieniach.';

  @override
  String get onboardingLoginTitle => 'Połącz konto';

  @override
  String get onboardingLanguageTitle => 'Wybierz język';

  @override
  String get followAddToSubscriptions => 'Dodaj do subskrypcji';

  @override
  String get followNoSubscriptions => 'Brak subskrypcji';

  @override
  String get followFailedToLoadSubscriptions =>
      'Nie udało się załadować subskrypcji';

  @override
  String get followAddToBookmarks => 'Dodaj do zakładek';

  @override
  String get followNoBookmarks => 'Brak zakładek';

  @override
  String get followFailedToLoadBookmarks => 'Nie udało się załadować zakładek';

  @override
  String get followUnseenPosts => 'nieprzeczytane wpisy';

  @override
  String followMarkPostsSeen(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'oznacz $count postów jako przeczytane',
      many: 'oznacz $count postów jako przeczytane',
      few: 'oznacz $count posty jako przeczytane',
      one: 'oznacz 1 post jako przeczytany',
    );
    return '$_temp0';
  }

  @override
  String get followNoUnseenPosts => 'brak nieprzeczytanych postów';

  @override
  String get followShowUnseenFirst => 'pokaż nieprzeczytane jako pierwsze';

  @override
  String get followFilteringUnseen => 'filtrowanie nieprzeczytanych';

  @override
  String get followAllPostsShown => 'wszystkie posty wyświetlone';

  @override
  String get followForceSync => 'Wymuś synchronizację';

  @override
  String get followSyncAllFollows => 'synchronizuj wszystkie obserwowane';

  @override
  String followSyncingFollows(String progress) {
    return 'synchronizowanie obserwowanych... $progress';
  }

  @override
  String get followEditorTitle => 'Edytuj obserwowane';

  @override
  String get followSubscribe => 'Obserwuj';

  @override
  String get followEditPrompt => 'Edytuj obserwowane';

  @override
  String get followTitlePrompt => 'Tytuł obserwowanego';

  @override
  String get followMarkAsRead => 'Oznacz jako przeczytane';

  @override
  String get followDisableNotifications => 'Wyłącz powiadomienia';

  @override
  String get followEnableNotifications => 'Włącz powiadomienia';

  @override
  String get followRename => 'Zmień nazwę';

  @override
  String followNewPosts(num count, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label nowych postów',
      many: 'nowych postów',
      few: 'nowe posty',
      one: '1 nowy post',
    );
    return '$_temp0';
  }

  @override
  String followSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count obserwowanych',
      many: '$count obserwowanych',
      few: '$count obserwowane',
      one: '1 obserwowane',
    );
    return '$_temp0';
  }

  @override
  String followAlias(String? alias) {
    return 'alias $alias';
  }

  @override
  String historySelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wpisów',
      many: '$count wpisów',
      few: '$count wpisy',
      one: '1 wpis',
    );
    return '$_temp0';
  }

  @override
  String historyEntriesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunięto $count wpisów',
      many: 'Usunięto $count wpisów',
      few: 'Usunięto $count wpisy',
      one: 'Usunięto 1 wpis',
    );
    return '$_temp0';
  }

  @override
  String get historyClear => 'Wyczyść historię';

  @override
  String get historyClearSubtitle => 'Usuń wszystkie wpisy';

  @override
  String get historyClearConfirm => 'Wyczyścić historię?';

  @override
  String get historyClearConfirmBody =>
      'Wszystkie wpisy w historii zostaną trwale usunięte. Tej operacji nie można cofnąć.';

  @override
  String get historyClearAction => 'Wyczyść';

  @override
  String get historyLimit => 'Limit historii';

  @override
  String historyLimitEnableBody(String amount, num months) {
    return 'Włączenie limitu historii oznacza, że wszystkie wpisy starsze niż $months miesięcy oraz wszystkie wpisy poza $amount najnowszymi są automatycznie usuwane.';
  }

  @override
  String get historyLimitTitle => 'Ogranicz historię';

  @override
  String historyLimitOn(String amount, num months) {
    return 'Ograniczone do nowszych niż $months miesięcy lub mniej niż $amount wpisów.';
  }

  @override
  String get historyLimitOff => 'historia jest nieskończona';

  @override
  String get historyEntries => 'Wpisy';

  @override
  String get historyType => 'Typ';

  @override
  String get historyItems => 'Elementy';

  @override
  String get historySearches => 'Wyszukiwania';

  @override
  String get historyWikis => 'Wikis';

  @override
  String get historyUsers => 'Użytkownicy';

  @override
  String get historyEmpty => 'Twoja historia jest pusta';

  @override
  String get historyFailedToLoad => 'Nie udało się załadować historii';

  @override
  String get historyNoDescription => 'brak opisu';

  @override
  String get historyHotPosts => 'Popularne posty';

  @override
  String historyLinkPost(num id) {
    return 'Post #$id';
  }

  @override
  String historyLinkUser(num id) {
    return 'Użytkownik #$id';
  }

  @override
  String historyLinkWiki(num id) {
    return 'Wiki #$id';
  }

  @override
  String historyLinkUserByName(String id) {
    return '$id - Użytkownik';
  }

  @override
  String historyLinkWikiByName(String id) {
    return '$id - Wiki';
  }

  @override
  String historySearchQuery(String type, String query) {
    return '$type - $query';
  }

  @override
  String get historyWiki => 'Wiki';

  @override
  String get poolEmpty => 'Brak pul';

  @override
  String get poolFailedToLoadPools => 'Nie udało się załadować pul';

  @override
  String get poolTitle => 'Tytuł puli';

  @override
  String get poolInfoPosts => 'posty';

  @override
  String get poolInfoId => 'id';

  @override
  String get poolInfoActivity => 'aktywność';

  @override
  String get poolInfoActive => 'aktywna';

  @override
  String get poolInfoInactive => 'nieaktywna';

  @override
  String get poolInfoCreated => 'utworzona';

  @override
  String get poolInfoUpdated => 'zaktualizowana';

  @override
  String poolCopiedId(num id) {
    return 'Skopiowano id puli #$id';
  }

  @override
  String poolLink(num id) {
    return 'Pula #$id';
  }

  @override
  String get poolFailedToLoadPool => 'Nie udało się załadować puli';

  @override
  String get poolNotFound => 'Pula nie znaleziona';

  @override
  String get poolOrder => 'Kolejność puli';

  @override
  String get poolOldestFirst => 'Od najstarszych';

  @override
  String get poolNewestFirst => 'Od najnowszych';

  @override
  String get poolReaderMode => 'Tryt czytania puli';

  @override
  String get poolReaderLargeImages => 'duże obrazy';

  @override
  String get poolReaderNormalGrid => 'normalna siatka';

  @override
  String get topicsTitle => 'Tematy';

  @override
  String get topicHideTagEdits => 'Ukryj edycje tagów';

  @override
  String get topicTagEditsHidden => 'ukryte';

  @override
  String get topicTagEditsVisible => 'widoczne';

  @override
  String topicLink(num id) {
    return 'Temat #$id';
  }

  @override
  String get topicFailedToLoadTopic => 'Nie udało się załadować tematu';

  @override
  String get topicNotFound => 'Temat nie znaleziony';

  @override
  String get topicEmpty => 'Brak tematów';

  @override
  String get topicFailedToLoadTopics => 'Nie udało się załadować tematów';

  @override
  String get topicInfoReplies => 'odpowiedzi';

  @override
  String get topicInfoId => 'id';

  @override
  String topicCopiedId(num id) {
    return 'Skopiowano id tematu #$id';
  }

  @override
  String get topicInfoLocked => 'zablokowany';

  @override
  String get topicInfoYes => 'tak';

  @override
  String get topicInfoNo => 'nie';

  @override
  String get topicInfoCreated => 'utworzony';

  @override
  String get topicInfoUpdated => 'zaktualizowany';

  @override
  String get filterTags => 'Tagi';

  @override
  String get loginRequired => 'Musisz być zalogowany, aby wykonać tę akcję.';

  @override
  String get actionChooseIdentity => 'Wybierz tożsamość';

  @override
  String get dateToday => 'Dzisiaj';

  @override
  String get dateYesterday => 'Wczoraj';

  @override
  String detailCommentsButton(num count) {
    return 'KOMENTARZE ($count)';
  }

  @override
  String get detailFile => 'Plik';

  @override
  String get detailSources => 'Źródła';

  @override
  String get detailNoSources => 'brak źródeł';

  @override
  String get detailChildren => 'Dzieci';

  @override
  String get detailDeletion => 'Usunięcie';

  @override
  String get detailBlacklisted => 'Na czarnej liście';

  @override
  String get detailNoArtist => 'brak artysty';

  @override
  String detailPoolPosts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count postów',
      many: '$count postów',
      few: '$count postów',
      one: '1 post',
    );
    return '$_temp0';
  }

  @override
  String postCopiedId(num id) {
    return 'Skopiowano ID posta #$id';
  }

  @override
  String postUpvoteFailed(num id) {
    return 'Nie udało się zagłosować na post #$id';
  }

  @override
  String postDownvoteFailed(num id) {
    return 'Nie udało się zagłosować na post #$id';
  }

  @override
  String postAddFavoriteFailed(num id) {
    return 'Nie udało się dodać posta #$id do ulubionych';
  }

  @override
  String postRemoveFavoriteFailed(num id) {
    return 'Nie udało się usunąć posta #$id z ulubionych';
  }

  @override
  String get editorSection => 'Sekcja';

  @override
  String get editorQuote => 'Cytat';

  @override
  String get editorCode => 'Kod';

  @override
  String get editorSpoiler => 'Spoiler';

  @override
  String get editorBold => 'Pogrubienie';

  @override
  String get editorItalic => 'Kursywa';

  @override
  String get editorUnderlined => 'Podkreślenie';

  @override
  String get editorStrikethrough => 'Przekreślenie';

  @override
  String get editorPreviewPlaceholder => 'tutaj twój tekst';

  @override
  String get editorWrite => 'Pisanie';

  @override
  String get editorPreview => 'Podgląd';

  @override
  String get editorTypeHere => 'pisz tutaj...';

  @override
  String get tagNoTags => 'brak tagów';

  @override
  String get tagFailedToLoadTags => 'nie udało się załadować tagów';

  @override
  String get tagUnableToRetrieveWiki => 'nie udało się pobrać wpisu wiki';

  @override
  String get tagNoWikiEntry => 'brak wpisu wiki';

  @override
  String get tagCategoryGeneral => 'Ogólne';

  @override
  String get tagCategorySpecies => 'Gatunki';

  @override
  String get tagCategoryCharacter => 'Postacie';

  @override
  String get tagCategoryCopyright => 'Prawa autorskie';

  @override
  String get tagCategoryMeta => 'Meta';

  @override
  String get tagCategoryLore => 'Lore';

  @override
  String get tagCategoryArtist => 'Artysta';

  @override
  String get tagCategoryContributor => 'Współtwórca';

  @override
  String get tagCategoryInvalid => 'Nieprawidłowe';

  @override
  String editDescriptionTitle(num postId) {
    return 'Opis posta #$postId';
  }

  @override
  String get editDescriptionHint => 'Wprowadź opis posta...';

  @override
  String get editInvalidNumber => 'Nieprawidłowy format liczby';

  @override
  String get editInvalidParent => 'Nieprawidłowy nadrzędny post';

  @override
  String get editParentIdLabel => 'ID nadrzędnego (opcjonalnie)';

  @override
  String get editParentIdHint => 'ID nadrzędnego posta';

  @override
  String get editReasonLabel => 'Powód edycji (opcjonalnie)';

  @override
  String get editReasonHint => 'Dlaczego edytujesz ten post?';

  @override
  String editSourcesTitle(num postId) {
    return 'Źródła posta #$postId';
  }

  @override
  String get editTagsHint => 'tagi oddzielone spacjami';

  @override
  String editTagPreviewFailed(String error) {
    return 'Błąd podczas ładowania podglądu tagów: $error';
  }

  @override
  String get editTagStatusNew => 'nowy';

  @override
  String get editTagStatusInvalid => 'nieprawidłowy';

  @override
  String get editTagStatusEmpty => 'pusty';

  @override
  String get editTagStatusUnderused => 'rzadko używany';

  @override
  String reportCommentSuccess(num id) {
    return 'Zgłoszono komentarz #$id';
  }

  @override
  String reportCommentFailed(num id) {
    return 'Nie udało się zgłosić komentarza #$id';
  }

  @override
  String reportReplySuccess(num id) {
    return 'Zgłoszono odpowiedź #$id';
  }

  @override
  String reportReplyFailed(num id) {
    return 'Nie udało się zgłosić odpowiedzi #$id';
  }

  @override
  String reportUserSuccess(num id) {
    return 'Zgłoszono użytkownika #$id';
  }

  @override
  String reportUserFailed(num id) {
    return 'Nie udało się zgłosić użytkownika #$id';
  }

  @override
  String reportPostSuccess(num id) {
    return 'Zgłoszono post #$id';
  }

  @override
  String reportPostFailed(num id) {
    return 'Nie udało się zgłosić posta #$id';
  }

  @override
  String get reportTypeRequired => 'Typ nie może być pusty';

  @override
  String get reportReason => 'Powód';

  @override
  String get reportReasonRequired => 'Powód nie może być pusty';

  @override
  String get reportSubmitted => 'Zgłoszenie przesłane';

  @override
  String get reportSubmitFailed => 'Nie udało się przesłać zgłoszenia';

  @override
  String get reportTypeRating => 'Nadużywanie ocen';

  @override
  String get reportTypeFile => 'Złośliwy plik';

  @override
  String get reportTypeSource => 'Złośliwe źródła';

  @override
  String get reportTypeDescription => 'Nadużywanie opisu';

  @override
  String get reportTypeNote => 'Nadużywanie notatek';

  @override
  String get reportTypeTagging => 'Nadużywanie tagów';

  @override
  String get reportTypeRatingBody =>
      'Ocena przesłania została ustawiona na nieprawidłową.';

  @override
  String get reportTypeFileBody =>
      'Plik zawiera złośliwy kod lub ukryty archiwum. Nie dotyczy to obrazów przedstawionych na obrazie.';

  @override
  String get reportTypeSourceBody =>
      'Jedno lub więcej z podanych źródeł prowadzi do złośliwych stron lub treści premium.';

  @override
  String get reportTypeDescriptionBody =>
      'Opis zawiera złośliwą treść lub został edytowany tak, by zawierał obraźliwy materiał.';

  @override
  String get reportTypeNoteBody =>
      'Notatki do tego postu są nieprawidłowe, nękające lub w inny sposób obraźliwe.';

  @override
  String get reportTypeTaggingBody =>
      'Jeden lub więcej tagów w tym poście jest nieprawidłowych lub jeden lub więcej prawidłowych tagów zostało usuniętych z tego posta.';

  @override
  String flagPostSuccess(num id) {
    return 'Oznaczono post #$id';
  }

  @override
  String flagPostFailed(num id) {
    return 'Nie udało się zgłosić posta #$id';
  }

  @override
  String get flagParentId => 'ID rodzica';

  @override
  String get flagParentIdRequired => 'ID rodzica nie może być puste';

  @override
  String get flagParentIdInvalid => 'ID rodzica musi być liczbą';

  @override
  String get flagTypeUploadingGuidelines =>
      'Nie spełnia wytycznych dotyczących przesyłania';

  @override
  String get flagTypeYoungHuman =>
      'Młodo-ludzka postać w sytuacji o charakterze erotycznym';

  @override
  String get flagTypeDnpArtist =>
      'Twórca tego posta znajduje się na liście unikania';

  @override
  String get flagTypePayContent =>
      'Treść z płatnych stron, komercyjna lub subskrypcyjna';

  @override
  String get flagTypeTrace => 'Ślad pracy innego artysty';

  @override
  String get flagTypePreviouslyDeleted => 'Wcześniej usunięty';

  @override
  String get flagTypeRealPorn => 'Prawdziwa pornografia';

  @override
  String get flagTypeCorrupt =>
      'Plik jest uszkodzony, uszkodzony lub w inny sposób nie działa';

  @override
  String get flagTypeInferior => 'Duplikat lub gorsza wersja innego posta';

  @override
  String get flagTypeUploadingGuidelinesBody =>
      'Ten post nie spełnia standardów strony, dotyczy to wartości artystycznej, jakości obrazu, istotności lub czegoś innego.\nPamiętaj, że Twoje osobiste preferencje nie mają na to wpływu. Jeśli treść posta jest dla Ciebie nieodpowiednia, po prostu [[e621:blacklist|dodaj do czarnej listy]].';

  @override
  String get flagTypeYoungHumanBody =>
      'Posty przedstawiające ludzi i podobne postacie w sposób seksualny lub nagi nie są akceptowalne na tej stronie.';

  @override
  String get flagTypeDnpArtistBody =>
      'Niektórzy artyści zażądali, aby ich prace nie były publikowane na tej stronie, i otrzymali status [[avoid_posting|Nie Publikuj]].\nCzasem ten status wiąże się z warunkami; zobacz [[conditional_dnp]] aby dowiedzieć się więcej.';

  @override
  String get flagTypePayContentBody =>
      'Nie hostujemy treści z płatnych stron ani treści komercyjnych w żadnej formie. Obejmuje to wycieki z Patreona, ponowne publikacje z pirackich stron i tym podobne.';

  @override
  String get flagTypeTraceBody =>
      'Obrazy śledzone z prac innych artystów nie są akceptowalne na tej stronie. Nawiązywanie do czegoś jest w porządku, ale kopiowanie czyjejś pracy wprost nie jest.\nProszę, dodaj więcej informacji w komentarzach lub po prostu dodaj oryginalną pracę jako rodzica posta, jeśli jest hostowana na tej stronie.';

  @override
  String get flagTypePreviouslyDeletedBody =>
      'Posty są zazwyczaj usuwane z dobrych powodów, a ponowne przesyłanie usuniętej treści nie jest akceptowalne.\nProszę, dodaj więcej informacji w komentarzach lub po prostu dodaj oryginalny post jako rodzica tego posta.';

  @override
  String get flagTypeRealPornBody =>
      'Posty przedstawiające prawdziwą pornografię nie są akceptowalne na tej stronie. Bez wyjątków.\nZauważ, że obrazy przedstawiające nie-erotyczne zdjęcia są akceptowalne.';

  @override
  String get flagTypeCorruptBody =>
      'Coś jest nie tak z tym postem. Może to być uszkodzony film lub uszkodzony obraz.\nW każdym przypadku, aby uniknąć nieporozumień, wyjaśnij sytuację w komentarzach.';

  @override
  String get flagTypeInferiorBody =>
      'Lepsza wersja tego posta już istnieje na stronie.\nMoże to obejmować obrazy z lepszą jakością wizualną (większe, mniej skompresowane), ale także wersje \"naprawione\", z uwzględnieniem błędów artystycznych.\nZauważ, że edycje i alternatywne wersje nie należą do tej kategorii.';

  @override
  String get taskCancelAll => 'Anuluj wszystkie';

  @override
  String get taskClearDone => 'Wyczyń zakończone';

  @override
  String get taskClearSelection => 'Wyczyń wybór';

  @override
  String get taskCancel => 'Anuluj';

  @override
  String get taskDismiss => 'Odrzuć';

  @override
  String get taskNoTasks => 'Brak zadań';

  @override
  String get taskFailedToLoadTasks => 'Nie udało się załadować zadań';

  @override
  String taskSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zadań',
      many: '$count zadań',
      few: '$count zadania',
      one: '1 zadanie',
    );
    return '$_temp0';
  }

  @override
  String get taskGroupActive => 'Aktywne';

  @override
  String get taskGroupFailed => 'Nieudane';

  @override
  String get taskActionDownload => 'pobierz';

  @override
  String get taskActionFavorite => 'ulubione';

  @override
  String get taskActionUnfavorite => 'usuń z ulubionych';

  @override
  String get taskDownloadRunning => 'pobieranie';

  @override
  String get taskFavoriteRunning => 'dodawanie do ulubionych';

  @override
  String get taskUnfavoriteRunning => 'usuwanie z ulubionych';

  @override
  String get taskDownloadCompleted => 'pobrano';

  @override
  String get taskFavoriteCompleted => 'dodano do ulubionych';

  @override
  String get taskUnfavoriteCompleted => 'usunięto z ulubionych';

  @override
  String taskQueuedTo(String action) {
    return 'kolejkowane do $action';
  }

  @override
  String taskFailedTo(String action) {
    return 'nie udało się $action';
  }

  @override
  String taskCanceledAction(String action) {
    return 'anulowano $action';
  }

  @override
  String taskTileTitle(String label, num id) {
    return '$label post #$id';
  }

  @override
  String followNotificationBody(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ma $count nowych postów!',
      many: 'ma $count nowych postów!',
      few: 'ma $count nowe posty!',
      one: 'ma nowy post!',
    );
    return '$_temp0';
  }

  @override
  String get followNotificationSummary => 'Nowe posty!';

  @override
  String get followChannelName => 'Obserwowane tagi';

  @override
  String get followChannelDescription =>
      'Powiadomienia o tagach, które obserwujesz';

  @override
  String get hostUnavailableTitle => 'Host niedostępny';

  @override
  String hostUnavailableBody(String host) {
    return 'Wygląda na to, że $host jest niedostępny!';
  }

  @override
  String get hostUnavailableResolveHint =>
      'Proszę rozwiąż problem w poniższym oknie przeglądarki.\n\nCiasteczka Cloudflare captcha zostaną zapisane.';

  @override
  String get hostUnavailableResolve => 'Rozwiąż';

  @override
  String hostUnavailableWaitBody(String host) {
    return '\nProszę poczekaj aż $host rozwiąże sytuację po swojej stronie.';
  }

  @override
  String get downloadChooseFolder => 'Wybierz folder';

  @override
  String get searchFilterTitle => 'Filtry';

  @override
  String get searchFilterQueryLabel => 'Aktualne zapytanie:';

  @override
  String get filterSectionSort => 'Sortowanie';

  @override
  String get filterSectionContent => 'Treść';

  @override
  String get filterSectionTime => 'Czas i status';

  @override
  String get filterSectionMedia => 'Media';

  @override
  String get filterSectionOther => 'Inne';

  @override
  String get searchFilterReset => 'Resetuj filtry';

  @override
  String get dtextParsingFailed => 'Przetwarzanie DText nie powiodło się';

  @override
  String get filteredShow => 'Pokaż';

  @override
  String get filteredHide => 'Ukryj';

  @override
  String get selectOptions => 'Wybierz opcje...';

  @override
  String get databaseNotE1547 => 'Ten plik nie jest bazą danych e1547.';

  @override
  String get adultGateTitle => 'Szybka kontrola rzeczywistości';

  @override
  String get adultGateBody =>
      'Ta aplikacja prowadzi prosto do e621, społeczności sztuki tylko dla dorosłych. Potwierdź, że jesteś pełnoletni tam, gdzie mieszkasz — ufamy Ci, nasi prawnicy już nie.';

  @override
  String get adultGateConfirm => 'Oczywiście — mam 18 lub więcej lat';

  @override
  String get adultGateDeny => 'Cofnij mnie';

  @override
  String get databaseExportPasswordLabel => 'Hasło (opcjonalne)';

  @override
  String get databaseExportPasswordHint =>
      'Szyfruje eksportowany plik. Pozostaw puste, aby uzyskać zwykły, nieszyfrowany plik.';

  @override
  String get databaseImportEncryptedTitle => 'Szyfrowana baza danych';

  @override
  String get databaseImportPasswordLabel => 'Hasło';

  @override
  String get databaseImportWrongPassword =>
      'Nieprawidłowe hasło lub uszkodzony plik.';

  @override
  String get actionUnlock => 'ODBLOKUJ';
}
