// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'e1547';

  @override
  String get failedToLoad => 'Caricamento fallito';

  @override
  String get nothingToSeeHere => 'Nulla da vedere qui';

  @override
  String get loading => 'Caricamento...';

  @override
  String get actionCancel => 'ANNULLA';

  @override
  String get actionOk => 'OK';

  @override
  String get actionTryAgain => 'Riprova';

  @override
  String get actionDownload => 'SCARICA';

  @override
  String get actionImport => 'IMPORTA';

  @override
  String get actionExport => 'ESPORTA';

  @override
  String get actionUndo => 'Annulla';

  @override
  String get actionRestartNow => 'RIAVVIA ORA';

  @override
  String get failedToLoadSuggestions => 'Caricamento suggerimenti fallito';

  @override
  String selectionItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get actionAbort => 'Interrompi';

  @override
  String get actionSelectAll => 'Seleziona tutto';

  @override
  String fileSavedAs(String name) {
    return 'File salvato come $name';
  }

  @override
  String get copiedToClipboard => 'Copiato negli appunti';

  @override
  String get saveFile => 'Salva file';

  @override
  String get filterTooltip => 'Filtra';

  @override
  String get rangeInvalidFormat => 'Formato non valido';

  @override
  String itemProgress(num current, num total) {
    return 'Elemento $current/$total';
  }

  @override
  String get taskCancelled => 'Task annullato';

  @override
  String taskFailedAt(num index) {
    return 'Fallito all\'elemento $index';
  }

  @override
  String get taskDone => 'Completato';

  @override
  String get failedToInitialize => 'Inizializzazione fallita';

  @override
  String get navHome => 'Home';

  @override
  String get navHot => 'Popolari';

  @override
  String get navSearch => 'Ricerca';

  @override
  String get navFavorites => 'Preferiti';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navSubscriptions => 'Sottoscrizioni';

  @override
  String get navBookmarks => 'Segnalibri';

  @override
  String get navPools => 'Pool';

  @override
  String get navForum => 'Forum';

  @override
  String get navHistory => 'Cronologia';

  @override
  String get navTasks => 'Task';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get navAbout => 'Informazioni';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionUser => 'Utente';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get sectionInteractions => 'Interazioni';

  @override
  String get sectionSecurity => 'Sicurezza';

  @override
  String get sectionDevelopment => 'Sviluppo';

  @override
  String get settingsBlacklist => 'Lista nera';

  @override
  String tagsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tag bloccati',
      one: '1 tag bloccato',
    );
    return '$_temp0';
  }

  @override
  String get settingsFollows => 'Seguiti';

  @override
  String searchesFollowed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricerche seguite',
      one: '1 ricerca seguita',
    );
    return '$_temp0';
  }

  @override
  String get settingsHistory => 'Cronologia';

  @override
  String pagesVisited(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagine visitate',
      one: '1 pagina visitata',
    );
    return '$_temp0';
  }

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeDark => 'scuro';

  @override
  String get themeAmoled => 'amoled';

  @override
  String get themeLight => 'chiaro';

  @override
  String get themeBlue => 'blu';

  @override
  String get themeSystem => 'sistema';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get languageSystemDefault => 'Predefinita di sistema';

  @override
  String get settingsHandedness => 'Mano preferita';

  @override
  String get handRight => 'Destra';

  @override
  String get handLeft => 'Sinistra';

  @override
  String get settingsHandednessHint =>
      'I pulsanti e le azioni rapide si spostano nella portata di questa mano.';

  @override
  String get thumbnailQuality => 'Qualità delle miniature';

  @override
  String get settingsQuilt => 'Mosaico';

  @override
  String get gridTitle => 'Griglia';

  @override
  String get quiltSquare => 'tile quadratiche';

  @override
  String get quiltVertical => 'tile si espandono verticalmente';

  @override
  String get settingsPostInfo => 'Info post';

  @override
  String get postInfoShown => 'info sulle tile dei post';

  @override
  String get postInfoHidden => 'solo le tile delle immagini';

  @override
  String get settingsDownloadLocation => 'Posizione download';

  @override
  String get settingsUpvoteFavorites => 'Apprezza i preferiti';

  @override
  String get upvoteFavoritesOn => 'apprezza e metti nei preferiti';

  @override
  String get upvoteFavoritesOff => 'solo nei preferiti';

  @override
  String get settingsVideoVolume => 'Volume video';

  @override
  String get videoMuted => 'muto';

  @override
  String get videoWithSound => 'con suono';

  @override
  String videoSeekSeconds(Object seconds) {
    return '$seconds secondi';
  }

  @override
  String get videoResSource => 'Sorgente';

  @override
  String get videoResNote =>
      'I video non sono sempre disponibili nelle dimensioni standard; viene usata quella più vicina alla selezione.';

  @override
  String get qualityLow => 'Bassa';

  @override
  String get qualityMedium => 'Media';

  @override
  String get qualityHigh => 'Alta';

  @override
  String get settingsAutoLoadVideos => 'Caricamento automatico video';

  @override
  String get autoLoadVideosOn => 'video caricati durante la navigazione';

  @override
  String get autoLoadVideosOff => 'video caricati alla riproduzione';

  @override
  String get autoLoadVideosDialogTitle => 'Caricare i video automaticamente?';

  @override
  String get autoLoadVideosDialogBody =>
      'I video verranno scaricati completamente durante la navigazione e la ricerca. Ciò può consumare molti dati su connessioni a consumo.';

  @override
  String get videoQuality => 'Qualità video';

  @override
  String get settingsSecureDisplay => 'Display sicuro';

  @override
  String get secureDisplayOn => 'schermo protetto';

  @override
  String get secureDisplayOff => 'schermo visibile';

  @override
  String get settingsIncognitoKeyboard => 'Tastiera in incognito';

  @override
  String get enabled => 'abilitato';

  @override
  String get disabled => 'disabilitato';

  @override
  String get settingsPinLock => 'Blocco PIN';

  @override
  String get pinEnabled => 'PIN abilitato';

  @override
  String get pinDisabled => 'PIN disabilitato';

  @override
  String get settingsBiometricLock => 'Blocco biometrico';

  @override
  String get biometricsEnabled => 'biometrie abilitate';

  @override
  String get biometricsDisabled => 'biometrie disabilitate';

  @override
  String get biometricsUnavailable => 'nessun hardware biometrico trovato';

  @override
  String get biometricsNotEnrolled =>
      'sensore di impronte trovato, ma nessuna impronta registrata';

  @override
  String get biometricsRequiresPin =>
      'imposta prima un PIN: il blocco biometrico lo usa come riserva se il sensore fallisce';

  @override
  String get settingsUpdaterBeta => 'Aggiornamenti recenti';

  @override
  String get updaterBetaOn => 'Versioni stabili e pre-release';

  @override
  String get updaterBetaOff => 'Solo versioni stabili';

  @override
  String get settingsDeveloperMode => 'Modalità sviluppatore';

  @override
  String get devOptionsShown => 'opzioni mostrate';

  @override
  String get devOptionsHidden => 'opzioni nascoste';

  @override
  String errorsLogged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errori registrati',
      one: '1 error registrato',
    );
    return '$_temp0';
  }

  @override
  String get settingsDatabase => 'Database';

  @override
  String get databaseExporting => 'Esportazione database in corso...';

  @override
  String get databaseExported => 'Database esportato con successo';

  @override
  String get databaseExportFailed => 'Esportazione fallita';

  @override
  String get databaseExport => 'Esporta';

  @override
  String get databaseImporting => 'Importazione database in corso...';

  @override
  String databaseInvalidFile(String error) {
    return 'File database non valido: $error';
  }

  @override
  String databaseImportFailed(String error) {
    return 'Importazione fallita: $error';
  }

  @override
  String get databaseImportTooLarge =>
      'Questo file è troppo grande per essere importato.';

  @override
  String get databaseImportTitle => 'Importa Database';

  @override
  String get databaseRestartTitle => 'Riavvio Richiesto';

  @override
  String get databaseRestartBody =>
      'L\'applicazione deve riavviarsi per applicare le modifiche.';

  @override
  String get databaseImport => 'Importa';

  @override
  String get lockEnterPin => 'Inserisci PIN';

  @override
  String get lockEnterNewPin => 'Inserisci nuovo PIN';

  @override
  String get lockConfirmNewPin => 'Conferma nuovo PIN';

  @override
  String get lockFailedAuth => 'Autenticazione fallita';

  @override
  String get lockPleaseAuth => 'Per favore autenticati';

  @override
  String get lockRetry => 'Riprova';

  @override
  String get lockBiometricReason => 'Autenticati per sbloccare.';

  @override
  String get lockBiometricFailure =>
      'Grave errore nell\'autenticazione biometrica';

  @override
  String get lockWrongPin => 'PIN errato';

  @override
  String get lockPinMismatch => 'I PIN non coincidono';

  @override
  String lockPinCooldown(int seconds) {
    return 'Troppi tentativi, riprova tra $seconds s';
  }

  @override
  String get aboutVersion => 'Versione';

  @override
  String get updaterFetching => 'Ricerca aggiornamenti...';

  @override
  String get updaterCheckFailed => 'Impossibile controllare aggiornamenti';

  @override
  String get updaterNewest => 'Hai l\'ultima versione';

  @override
  String updaterNewer(String version) {
    return 'È disponibile una versione più recente: $version';
  }

  @override
  String get updaterNewerHeader => 'È disponibile una versione più recente: ';

  @override
  String get aboutExperimentalPlatform => 'Piattaforma sperimentale';

  @override
  String get aboutExperimentalBody =>
      'Questa piattaforma non è supportata. Aspettati bug e funzionalità mancanti.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutUpstream => 'Progetto originale';

  @override
  String get aboutUpstreamBody => 'Questa app è un fork di clragon/e1547';

  @override
  String get aboutDiscord => 'Discord';

  @override
  String get aboutForum => 'Forum';

  @override
  String aboutForumTopic(num id) {
    return 'Discussione e621 #$id';
  }

  @override
  String get aboutWebsite => 'Sito web';

  @override
  String get aboutKofi => 'Ko-fi';

  @override
  String get aboutEmail => 'Email';

  @override
  String get aboutPlaystore => 'Playstore';

  @override
  String get aboutDonors => 'Donatori';

  @override
  String get aboutDonorsThanks =>
      'Grazie per aiutarmi a continuare lo sviluppo!';

  @override
  String get aboutNoDonors => 'Ancora nessun donatore';

  @override
  String get aboutDonorsFailed => 'Impossibile recuperare i donatori';

  @override
  String get aboutDonorsNotListed => 'Non sei nella lista? Contattaci!';

  @override
  String get developerUnlocked => 'Ora sei uno sviluppatore!';

  @override
  String get databaseErrorLoading => 'Errore nel caricamento del database';

  @override
  String get databaseUnknownSize => 'Sconosciuto';

  @override
  String get databaseExportTitle => 'Esporta Database';

  @override
  String get databaseExportSubtitle =>
      'Salva una copia di backup del tuo database';

  @override
  String get databaseImportSubtitle =>
      'Sostituisci il database corrente con quello importato';

  @override
  String get databaseImportWarning =>
      'Questo sostituirà il tuo database corrente. \nTutti i dati andranno persi. Questa operazione non può essere annullata!';

  @override
  String get databaseExportSanitizedBody =>
      'Il file esportato non conterrà i tuoi accessi o chiavi API.\nTutto il resto, inclusi account, host, cronologia, seguiti e attività, è incluso.';

  @override
  String get databaseImportNewerFile =>
      'Questo file è stato creato con una versione più recente dell\'app e non può essere importato.';

  @override
  String get databaseImportSanitized =>
      'Per sicurezza, gli accessi salvati sono stati rimossi dal file importato.';

  @override
  String databaseImportHostsWarning(String hosts) {
    return 'Attenzione: il file importato contiene account su altri siti: $hosts';
  }

  @override
  String get databaseImportCancelled => 'Importazione annullata';

  @override
  String get postsTitle => 'Post';

  @override
  String favoritesOf(String user) {
    return 'Preferiti di $user';
  }

  @override
  String get favoritesUnavailable =>
      'I preferiti non sono disponibili per gli utenti anonimi';

  @override
  String get favoriteOrder => 'Ordine preferito';

  @override
  String get orderAdded => 'ordine aggiunto';

  @override
  String get orderId => 'ID ordine';

  @override
  String get postStateDeleted => 'eliminato';

  @override
  String get postStateUnsupported => 'non supportato';

  @override
  String get postStateUnavailable => 'non disponibile';

  @override
  String get menuShare => 'Condividi';

  @override
  String get menuDownload => 'Scarica';

  @override
  String get menuBrowse => 'Sfoglia';

  @override
  String get menuEdit => 'Modifica';

  @override
  String get menuComment => 'Commenta';

  @override
  String get menuReport => 'Segnala';

  @override
  String get menuFlag => 'Segna';

  @override
  String get actionOpen => 'Apri';

  @override
  String get actionFollow => 'Segui';

  @override
  String get actionUnfollow => 'Smetti di seguire';

  @override
  String get actionMute => 'Silenzia';

  @override
  String get actionNotify => 'Notifiche';

  @override
  String get actionBookmark => 'Salva';

  @override
  String get actionUnbookmark => 'Rimuovi salvataggio';

  @override
  String get actionBlock => 'Blocca';

  @override
  String get actionUnblock => 'Sblocca';

  @override
  String get actionRemove => 'Rimuovi';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionSubtract => 'Sottrai';

  @override
  String selectionPost(num id) {
    return 'post #$id';
  }

  @override
  String selectionPostsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count post',
    );
    return '$_temp0';
  }

  @override
  String get noPosts => 'Nessun post';

  @override
  String get failedToLoadPosts => 'Caricamento post fallito';

  @override
  String get offlineBanner => 'Sei offline. Vengono mostrati i dati in cache.';

  @override
  String get offlineNoData => 'Sei offline';

  @override
  String postListPageSummary(num count, Object page) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count post',
      one: '$count post',
    );
    return 'Pagina $page · $_temp0';
  }

  @override
  String get postListPageLimit =>
      'Hai raggiunto il limite di pagine del server. Per favore, restringi i termini di ricerca.';

  @override
  String get postListJumpToPage => 'Vai alla pagina';

  @override
  String get postListJumpPageLabel => 'Numero pagina';

  @override
  String postListJumpPageRange(Object max) {
    return 'Inserisci un numero di pagina tra 1 e $max';
  }

  @override
  String get postDeletedOverlay => 'Post eliminato';

  @override
  String get postUnavailableOverlay => 'Post non disponibile';

  @override
  String get postBlacklistedOverlay => 'Post nella blacklist';

  @override
  String unsupportedFileType(String ext) {
    return 'I file $ext non sono supportati';
  }

  @override
  String get loginRequiredEdit => 'Devi essere loggato per modificare i post!';

  @override
  String get loginRequiredComment => 'Devi essere loggato per commentare!';

  @override
  String get loginRequiredReport => 'Devi essere loggato per segnalare i post!';

  @override
  String get loginRequiredFlag => 'Devi essere loggato per segnare i post!';

  @override
  String postsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bloccati $count post',
      one: 'bloccato 1 post',
    );
    return '$_temp0';
  }

  @override
  String get blacklistUpdateFailed => 'Aggiornamento blacklist fallito!';

  @override
  String get blacklistAddTag => 'Aggiungi tag';

  @override
  String get blacklistEditTag => 'Modifica tag';

  @override
  String get denylistEntryDeleted => 'Voce blacklist rimossa';

  @override
  String get blacklistEmpty => 'La tua blacklist è vuota';

  @override
  String get menuDelete => 'Elimina';

  @override
  String get filterScore => 'Punteggio';

  @override
  String get filterFavoriteCount => 'Conteggio preferiti';

  @override
  String get filterSortBy => 'Ordina per';

  @override
  String get filterNew => 'Nuovi';

  @override
  String get filterRank => 'Classifica';

  @override
  String get filterRandom => 'Casuale';

  @override
  String get filterDefault => 'Predefinito';

  @override
  String get filterRating => 'Valutazione';

  @override
  String get filterSafe => 'Sicuro';

  @override
  String get filterQuestionable => 'Dubbia';

  @override
  String get filterExplicit => 'Esplicito';

  @override
  String get filterAll => 'Tutti';

  @override
  String get filterPool => 'Pool';

  @override
  String get filterHasPool => 'Ha pool';

  @override
  String get filterChild => 'Figlio';

  @override
  String get filterIsChildPost => 'È post figlio';

  @override
  String get filterParent => 'Genitore';

  @override
  String get filterIsParentPost => 'È post genitore';

  @override
  String get filterUploadDate => 'Data caricamento';

  @override
  String get filterLastDay => 'Ultimo giorno';

  @override
  String get filterLastWeek => 'Ultima settimana';

  @override
  String get filterLastMonth => 'Ultimo mese';

  @override
  String get filterLastYear => 'Ultimo anno';

  @override
  String get filterStatus => 'Stato';

  @override
  String get filterActive => 'Attivo';

  @override
  String get filterPending => 'In attesa';

  @override
  String get filterDeleted => 'Eliminato';

  @override
  String get filterFlagged => 'Segnalato';

  @override
  String get filterAny => 'Qualsiasi';

  @override
  String get filterFileType => 'Tipo file';

  @override
  String get filterUploader => 'Caricatore';

  @override
  String get filterWidth => 'Larghezza';

  @override
  String get filterHeight => 'Altezza';

  @override
  String get filterTagCount => 'Conteggio tag';

  @override
  String get filterTrue => 'Vero';

  @override
  String get filterFalse => 'Falso';

  @override
  String get filterImages => 'Immagini';

  @override
  String get filterVideos => 'Video';

  @override
  String get filterTitleContains => 'Il titolo contiene';

  @override
  String get filterCategory => 'Categoria';

  @override
  String get filterGeneral => 'Generale';

  @override
  String get filterSiteBugReports =>
      'Segnalazioni bug e richieste funzionalità del sito';

  @override
  String get filterTagWikiProjects => 'Progetti Wiki e domande sui tag';

  @override
  String get filterTagAliasSuggestions =>
      'Suggerimenti alias e implicazioni dei tag';

  @override
  String get filterArtTalk => 'Art Talk';

  @override
  String get filterOffTopic => 'Off Topic';

  @override
  String get filterE621Tools => 'Strumenti e applicazioni e621';

  @override
  String get filterNewestFirst => 'Prima i più recenti';

  @override
  String get filterOldestFirst => 'Prima i più vecchi';

  @override
  String get filterSticky => 'In evidenza';

  @override
  String get filterIsSticky => 'È in evidenza';

  @override
  String get filterLocked => 'Bloccato';

  @override
  String get filterIsLocked => 'È bloccato';

  @override
  String get filterDescription => 'Descrizione';

  @override
  String get filterCreator => 'Creatore';

  @override
  String get filterIsActive => 'È attivo';

  @override
  String get filterSeries => 'Serie';

  @override
  String get filterCollection => 'Collezione';

  @override
  String get filterName => 'Nome';

  @override
  String get filterCreated => 'Creato';

  @override
  String get filterUpdated => 'Aggiornato';

  @override
  String get filterPostCount => 'Numero di post';

  @override
  String postUpdateFailed(num id) {
    return 'Aggiornamento post #$id fallito';
  }

  @override
  String postUpdated(num id) {
    return 'Post #$id aggiornato';
  }

  @override
  String get failedToLoadPost => 'Caricamento post fallito';

  @override
  String get postNotFound => 'Post non trovato';

  @override
  String get commentsTitle => 'Commenti';

  @override
  String commentsOfPost(num postId) {
    return 'Commenti del post #$postId';
  }

  @override
  String get commentOrder => 'Ordine commenti';

  @override
  String get noComments => 'Nessun commento';

  @override
  String get failedToLoadComments => 'Caricamento commenti fallito';

  @override
  String commentTitle(num id) {
    return 'Commento #$id';
  }

  @override
  String get failedToLoadComment => 'Caricamento commento fallito';

  @override
  String get commentNotFound => 'Commento non trovato';

  @override
  String commentEditorTitle(num postId) {
    return 'Commento #$postId';
  }

  @override
  String get commentSendFailed => 'Invio commento fallito!';

  @override
  String get commentSent => 'Commento inviato!';

  @override
  String get commentHidden => 'Questo commento è nascosto';

  @override
  String commentUpvoteFailed(num id) {
    return 'Voto positivo al commento #$id fallito';
  }

  @override
  String commentDownvoteFailed(num id) {
    return 'Voto negativo al commento #$id fallito';
  }

  @override
  String get commentLoginRequiredEdit =>
      'Devi essere loggato per modificare i commenti!';

  @override
  String get commentLoginRequiredReply =>
      'Devi essere loggato per rispondere ai commenti!';

  @override
  String get commentLoginRequiredReport =>
      'Devi essere loggato per segnalare i commenti!';

  @override
  String commentCopiedId(num id) {
    return 'ID commento #$id copiato';
  }

  @override
  String get warningUserWarned =>
      'L\'utente ha ricevuto un avviso per questo messaggio';

  @override
  String get warningUserRecorded =>
      'L\'utente ha ricevuto un record per questo messaggio';

  @override
  String get warningUserBanned =>
      'L\'utente è stato bannato per questo messaggio';

  @override
  String get repliesTitle => 'Risposte';

  @override
  String get replyOrder => 'Ordine risposte';

  @override
  String get noReplies => 'Nessuna risposta';

  @override
  String get failedToLoadReplies => 'Caricamento risposte fallito';

  @override
  String replyTitle(num id) {
    return 'Risposta #$id';
  }

  @override
  String get failedToLoadReply => 'Caricamento risposta fallito';

  @override
  String get replyNotFound => 'Risposta non trovata';

  @override
  String replyEditorTitle(num topicId) {
    return 'Risposta #$topicId';
  }

  @override
  String get replySendFailed => 'Invio risposta fallito!';

  @override
  String get replySent => 'Risposta inviata!';

  @override
  String get replyHidden => 'Questa risposta è nascosta';

  @override
  String get replyLoginRequiredEdit =>
      'Devi essere loggato per modificare le risposte!';

  @override
  String get replyLoginRequiredReply => 'Devi essere loggato per rispondere!';

  @override
  String get replyLoginRequiredReport =>
      'Devi essere loggato per segnalare le risposte!';

  @override
  String replyCopiedId(num id) {
    return 'ID risposta #$id copiato';
  }

  @override
  String get menuReply => 'Rispondi';

  @override
  String get menuCopyId => 'Copia ID';

  @override
  String get menuRefresh => 'Aggiorna';

  @override
  String get actionCopy => 'Copia';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionShow => 'Mostra';

  @override
  String get actionHide => 'Nascondi';

  @override
  String get actionCannotBeUndone => 'Questa azione non può essere annullata.';

  @override
  String get info => 'Info';

  @override
  String wikiTitle(String idOrTitle) {
    return 'Wiki $idOrTitle';
  }

  @override
  String get failedToLoadWiki => 'Caricamento wiki fallito';

  @override
  String get wikiNotFound => 'Wiki non trovata';

  @override
  String wikiCopiedId(num id) {
    return 'ID wiki #$id copiato';
  }

  @override
  String get wikiInfoId => 'id';

  @override
  String get wikiInfoAlias => 'alias';

  @override
  String get wikiInfoCreated => 'creato';

  @override
  String get wikiInfoUpdated => 'aggiornato';

  @override
  String get wikiInfoLocked => 'bloccato';

  @override
  String get wikiInfoYes => 'sì';

  @override
  String get wikiInfoNo => 'no';

  @override
  String userTitle(String idOrName) {
    return 'Utente $idOrName';
  }

  @override
  String get failedToLoadUser => 'Impossibile caricare l\'utente';

  @override
  String get userNotFound => 'Utente non trovato';

  @override
  String get userUploads => 'Caricamenti';

  @override
  String get userLoginRequiredReport =>
      'Devi essere loggato per segnalare utenti!';

  @override
  String get userComission => 'Commissione';

  @override
  String get userId => 'id';

  @override
  String get userJoined => 'iscritto';

  @override
  String get userRank => 'livello';

  @override
  String get userPosts => 'post';

  @override
  String get userEdits => 'modifiche';

  @override
  String get userFavorites => 'preferiti';

  @override
  String get userComments => 'commenti';

  @override
  String get userForum => 'forum';

  @override
  String userCopiedId(num id) {
    return 'Copiato id utente #$id';
  }

  @override
  String get logsTitle => 'Log';

  @override
  String logsTitleDate(String date) {
    return 'Log - $date';
  }

  @override
  String selectionLogsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count log',
    );
    return '$_temp0';
  }

  @override
  String selectionLogsFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count file log',
    );
    return '$_temp0';
  }

  @override
  String get logsLevels => 'Livelli';

  @override
  String get logsRecording => 'Registrazione';

  @override
  String get logsVerbose => 'Dettagliato';

  @override
  String get logsVerboseAll => 'tutti i livelli registrati';

  @override
  String logsVerboseMinimum(String level) {
    return '$level e superiori';
  }

  @override
  String get logFilesTitle => 'File Log';

  @override
  String get failedToLoadLogFiles => 'Impossibile caricare i file log!';

  @override
  String get noLogFiles => 'Nessun file log disponibile!';

  @override
  String get logsLive => 'Live';

  @override
  String get noLogs => 'Nessun log';

  @override
  String get failedToReadLog => 'Impossibile leggere il log';

  @override
  String get noErrorsLogged => 'Nessun errore registrato';

  @override
  String logsErrorsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errori',
      one: '1 errore',
    );
    return '$_temp0';
  }

  @override
  String get logsAll => 'Tutti i log';

  @override
  String get logsDismissAll => 'Ignora tutti';

  @override
  String logsDeleteTitle(num count) {
    return 'Eliminare $count file log?';
  }

  @override
  String get identityAccounts => 'Account';

  @override
  String get identityAdd => 'Aggiungi account';

  @override
  String get identityEdit => 'Modifica account';

  @override
  String get identityRemoveTitle => 'Rimuovere account?';

  @override
  String get identityRemoveBody =>
      'Tutti i suoi dati saranno rimossi permanentemente, inclusi cronologia e seguiti.';

  @override
  String get identityAnonymous => 'Anonimo';

  @override
  String get identityCredentialsRejected =>
      'Il sito ha rifiutato queste credenziali. Controlla nome utente e chiave API.';

  @override
  String get identityVerifyUnreachable =>
      'Impossibile contattare il sito per verificare queste credenziali.';

  @override
  String get identityDuplicate =>
      'Hai già un identità con questo host e username.';

  @override
  String identityLoginFailed(String reason) {
    return 'Accesso fallito. \n$reason';
  }

  @override
  String get identityLoginCheckDetails =>
      'Controlla la connessione di rete e i dati di accesso';

  @override
  String get identitySite => 'Sito';

  @override
  String get identityHostRequired => 'Devi fornire un URL host.';

  @override
  String get identityHostInvalid => 'URL host non valido';

  @override
  String get identityHostReadOnly =>
      'Il sito non può essere modificato. Aggiungi un nuovo account per usare uno diverso.';

  @override
  String get identityUsernameLabel => 'Username';

  @override
  String get identityUsernameRequired => 'Devi fornire un username.';

  @override
  String get identityApikeyLabel => 'Chiave API';

  @override
  String get identityApikeyHelp => 'Dove trovo la mia chiave API?';

  @override
  String get identityApikeyRequired =>
      'Devi fornire una chiave API.\nes. 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identityApikeyInvalid =>
      'La chiave API è una sequenza di 24 o 32 caratteri a-z e 0-9\nes. 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identitySignupPrompt => 'Non hai un account? Iscriviti qui';

  @override
  String get identityHostHint => 'Il sito che ospita il tuo account e i post.';

  @override
  String get identitySignIn => 'Accedi';

  @override
  String get identityGuest => 'Ospite';

  @override
  String get identityLogin => 'Accedi';

  @override
  String get identityBrowseAnonymously => 'Naviga in modo anonimo';

  @override
  String identityConnecting(String host, String username) {
    return 'Connessione a $host come $username…';
  }

  @override
  String identityActivateFailed(Object error) {
    return 'Impossibile attivare l\'identità: $error';
  }

  @override
  String traitsActivateFailed(Object error) {
    return 'Impossibile attivare i tratti: $error';
  }

  @override
  String get failedToLoadIdentities => 'Impossibile caricare le identità';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingBack => 'Indietro';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String onboardingWelcomeTitle(String app) {
    return 'Benvenuto in $app';
  }

  @override
  String get onboardingWelcomeBody => 'Un browser booru sofisticato.';

  @override
  String get onboardingThemeTitle => 'Scegli un tema';

  @override
  String get onboardingThemeBody =>
      'Prova uno. Puoi sempre cambiare idea più tardi.';

  @override
  String get onboardingQualityTitle => 'Regola i media';

  @override
  String get onboardingQualityBody =>
      'Scegli come caricare video e miniature. Puoi cambiarlo più tardi nelle impostazioni.';

  @override
  String get onboardingLoginTitle => 'Collega un account';

  @override
  String get onboardingLanguageTitle => 'Scegli una lingua';

  @override
  String get followAddToSubscriptions => 'Aggiungi alle sottoscrizioni';

  @override
  String get followNoSubscriptions => 'Nessuna sottoscrizione';

  @override
  String get followFailedToLoadSubscriptions =>
      'Impossibile caricare le sottoscrizioni';

  @override
  String get followAddToBookmarks => 'Aggiungi ai segnalibri';

  @override
  String get followNoBookmarks => 'Nessun segnalibro';

  @override
  String get followFailedToLoadBookmarks => 'Impossibile caricare i segnalibri';

  @override
  String get followUnseenPosts => 'post non visti';

  @override
  String followMarkPostsSeen(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'contrassegna $count post come letti',
      one: 'contrassegna 1 post come letto',
    );
    return '$_temp0';
  }

  @override
  String get followNoUnseenPosts => 'nessun post non letto';

  @override
  String get followShowUnseenFirst => 'mostra non letti per primi';

  @override
  String get followFilteringUnseen => 'filtro per non letti';

  @override
  String get followAllPostsShown => 'tutti i post mostrati';

  @override
  String get followForceSync => 'Sincronizzazione forzata';

  @override
  String get followSyncAllFollows => 'sincronizza tutti i seguiti';

  @override
  String followSyncingFollows(String progress) {
    return 'sincronizzazione seguiti... $progress';
  }

  @override
  String get followEditorTitle => 'Modifica seguiti';

  @override
  String get followSubscribe => 'Iscriviti';

  @override
  String get followEditPrompt => 'Modifica seguito';

  @override
  String get followTitlePrompt => 'Titolo seguito';

  @override
  String get followMarkAsRead => 'Contrassegna come letto';

  @override
  String get followDisableNotifications => 'Disabilita notifiche';

  @override
  String get followEnableNotifications => 'Abilita notifiche';

  @override
  String get followRename => 'Rinomina';

  @override
  String followNewPosts(num count, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label nuovi post',
      one: '1 nuovo post',
    );
    return '$_temp0';
  }

  @override
  String followSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguiti',
      one: '1 seguito',
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
      other: '$count voci',
      one: '1 voce',
    );
    return '$_temp0';
  }

  @override
  String historyEntriesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cancellate $count voci della cronologia',
      one: 'Cancellata 1 voce della cronologia',
    );
    return '$_temp0';
  }

  @override
  String get historyClear => 'Cronologia';

  @override
  String get historyClearSubtitle => 'Elimina tutte le voci';

  @override
  String get historyClearConfirm => 'Cancellare la cronologia?';

  @override
  String get historyClearConfirmBody =>
      'Tutte le voci della cronologia verranno eliminate definitivamente. Questa azione non può essere annullata.';

  @override
  String get historyClearAction => 'Cancella';

  @override
  String get historyLimit => 'Limite cronologia';

  @override
  String historyLimitEnableBody(String amount, num months) {
    return 'Abilitare il limite della cronologia significa che tutte le voci oltre $amount e tutte le voci più vecchie di $months mesi vengono eliminate automaticamente.';
  }

  @override
  String get historyLimitTitle => 'Limita cronologia';

  @override
  String historyLimitOn(String amount, num months) {
    return 'Limitato a meno di $months mesi o meno di $amount voci.';
  }

  @override
  String get historyLimitOff => 'cronologia illimitata';

  @override
  String get historyEntries => 'Voci';

  @override
  String get historyType => 'Tipo';

  @override
  String get historyItems => 'Elementi';

  @override
  String get historySearches => 'Ricerche';

  @override
  String get historyWikis => 'Wiki';

  @override
  String get historyUsers => 'Utenti';

  @override
  String get historyEmpty => 'La tua cronologia è vuota';

  @override
  String get historyFailedToLoad => 'Impossibile caricare la cronologia';

  @override
  String get historyNoDescription => 'nessuna descrizione';

  @override
  String get historyHotPosts => 'Post popolari';

  @override
  String historyLinkPost(num id) {
    return 'Post #$id';
  }

  @override
  String historyLinkUser(num id) {
    return 'Utente #$id';
  }

  @override
  String historyLinkWiki(num id) {
    return 'Wiki #$id';
  }

  @override
  String historyLinkUserByName(String id) {
    return '$id - Utente';
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
  String get poolEmpty => 'Nessuna collezione';

  @override
  String get poolFailedToLoadPools => 'Impossibile caricare le collezioni';

  @override
  String get poolTitle => 'Titolo collezione';

  @override
  String get poolInfoPosts => 'post';

  @override
  String get poolInfoId => 'id';

  @override
  String get poolInfoActivity => 'attività';

  @override
  String get poolInfoActive => 'attiva';

  @override
  String get poolInfoInactive => 'inattiva';

  @override
  String get poolInfoCreated => 'creata';

  @override
  String get poolInfoUpdated => 'aggiornata';

  @override
  String poolCopiedId(num id) {
    return 'Copiato id collezione #$id';
  }

  @override
  String poolLink(num id) {
    return 'Collezione #$id';
  }

  @override
  String get poolFailedToLoadPool => 'Impossibile caricare la collezione';

  @override
  String get poolNotFound => 'Collezione non trovata';

  @override
  String get poolOrder => 'Ordine collezione';

  @override
  String get poolOldestFirst => 'Prima i più vecchi';

  @override
  String get poolNewestFirst => 'Prima i più recenti';

  @override
  String get poolReaderMode => 'Modalità lettura collezione';

  @override
  String get poolReaderLargeImages => 'immagini grandi';

  @override
  String get poolReaderNormalGrid => 'griglia normale';

  @override
  String get topicsTitle => 'Argomenti';

  @override
  String get topicHideTagEdits => 'Nascondi modifiche tag';

  @override
  String get topicTagEditsHidden => 'nascoste';

  @override
  String get topicTagEditsVisible => 'visibili';

  @override
  String topicLink(num id) {
    return 'Argomento #$id';
  }

  @override
  String get topicFailedToLoadTopic => 'Impossibile caricare l\'argomento';

  @override
  String get topicNotFound => 'Argomento non trovato';

  @override
  String get topicEmpty => 'Nessun argomento';

  @override
  String get topicFailedToLoadTopics => 'Impossibile caricare gli argomenti';

  @override
  String get topicInfoReplies => 'risposte';

  @override
  String get topicInfoId => 'id';

  @override
  String topicCopiedId(num id) {
    return 'Copiato id argomento #$id';
  }

  @override
  String get topicInfoLocked => 'bloccato';

  @override
  String get topicInfoYes => 'sì';

  @override
  String get topicInfoNo => 'no';

  @override
  String get topicInfoCreated => 'creato';

  @override
  String get topicInfoUpdated => 'aggiornato';

  @override
  String get filterTags => 'Tag';

  @override
  String get loginRequired =>
      'Devi essere connesso per eseguire questa azione.';

  @override
  String get actionChooseIdentity => 'Scegli identità';

  @override
  String get dateToday => 'Oggi';

  @override
  String get dateYesterday => 'Ieri';

  @override
  String detailCommentsButton(num count) {
    return 'COMMENTI ($count)';
  }

  @override
  String get detailFile => 'File';

  @override
  String get detailSources => 'Fonti';

  @override
  String get detailNoSources => 'nessuna fonte';

  @override
  String get detailChildren => 'Figli';

  @override
  String get detailDeletion => 'Eliminazione';

  @override
  String get detailBlacklisted => 'Nera';

  @override
  String get detailNoArtist => 'nessun artista';

  @override
  String detailPoolPosts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
    );
    return '$_temp0';
  }

  @override
  String postCopiedId(num id) {
    return 'Copiato ID post #$id';
  }

  @override
  String postUpvoteFailed(num id) {
    return 'Impossibile dare +1 al post #$id';
  }

  @override
  String postDownvoteFailed(num id) {
    return 'Impossibile dare -1 al post #$id';
  }

  @override
  String postAddFavoriteFailed(num id) {
    return 'Impossibile aggiungere il post #$id ai preferiti';
  }

  @override
  String postRemoveFavoriteFailed(num id) {
    return 'Impossibile rimuovere il post #$id dai preferiti';
  }

  @override
  String get editorSection => 'Sezione';

  @override
  String get editorQuote => 'Citazione';

  @override
  String get editorCode => 'Codice';

  @override
  String get editorSpoiler => 'Spoiler';

  @override
  String get editorBold => 'Grassetto';

  @override
  String get editorItalic => 'Corsivo';

  @override
  String get editorUnderlined => 'Sottolineato';

  @override
  String get editorStrikethrough => 'Barrato';

  @override
  String get editorPreviewPlaceholder => 'il tuo testo qui';

  @override
  String get editorWrite => 'Scrivi';

  @override
  String get editorPreview => 'Anteprima';

  @override
  String get editorTypeHere => 'scrivi qui...';

  @override
  String get tagNoTags => 'nessun tag';

  @override
  String get tagFailedToLoadTags => 'impossibile caricare i tag';

  @override
  String get tagUnableToRetrieveWiki => 'impossibile recuperare la voce wiki';

  @override
  String get tagNoWikiEntry => 'nessuna voce wiki';

  @override
  String get tagCategoryGeneral => 'Generale';

  @override
  String get tagCategorySpecies => 'Specie';

  @override
  String get tagCategoryCharacter => 'Personaggio';

  @override
  String get tagCategoryCopyright => 'Copyright';

  @override
  String get tagCategoryMeta => 'Meta';

  @override
  String get tagCategoryLore => 'Lore';

  @override
  String get tagCategoryArtist => 'Artista';

  @override
  String get tagCategoryContributor => 'Contributore';

  @override
  String get tagCategoryInvalid => 'Non valido';

  @override
  String editDescriptionTitle(num postId) {
    return 'Descrizione #$postId';
  }

  @override
  String get editDescriptionHint => 'Inserisci la descrizione del post...';

  @override
  String get editInvalidNumber => 'Formato numero non valido';

  @override
  String get editInvalidParent => 'Post padre non valido';

  @override
  String get editParentIdLabel => 'ID padre (opzionale)';

  @override
  String get editParentIdHint => 'ID del post padre';

  @override
  String get editReasonLabel => 'Motivo modifica (opzionale)';

  @override
  String get editReasonHint => 'Perché stai modificando questo post?';

  @override
  String editSourcesTitle(num postId) {
    return 'Fonti #$postId';
  }

  @override
  String get editTagsHint => 'tag separati da spazio';

  @override
  String editTagPreviewFailed(String error) {
    return 'Errore nel caricante l\'anteprima del tag: $error';
  }

  @override
  String get editTagStatusNew => 'nuovo';

  @override
  String get editTagStatusInvalid => 'non valido';

  @override
  String get editTagStatusEmpty => 'vuoto';

  @override
  String get editTagStatusUnderused => 'sotto-utilizzato';

  @override
  String reportCommentSuccess(num id) {
    return 'Segnalato commento #$id';
  }

  @override
  String reportCommentFailed(num id) {
    return 'Impossibile segnalare il commento #$id';
  }

  @override
  String reportReplySuccess(num id) {
    return 'Segnalata risposta #$id';
  }

  @override
  String reportReplyFailed(num id) {
    return 'Impossibile segnalare la risposta #$id';
  }

  @override
  String reportUserSuccess(num id) {
    return 'Segnalato utente #$id';
  }

  @override
  String reportUserFailed(num id) {
    return 'Impossibile segnalare l\'utente #$id';
  }

  @override
  String reportPostSuccess(num id) {
    return 'Segnalato post #$id';
  }

  @override
  String reportPostFailed(num id) {
    return 'Impossibile segnalare il post #$id';
  }

  @override
  String get reportTypeRequired => 'Il tipo non può essere vuoto';

  @override
  String get reportReason => 'Motivo';

  @override
  String get reportReasonRequired => 'Il motivo non può essere vuoto';

  @override
  String get reportSubmitted => 'Segnale inviata';

  @override
  String get reportSubmitFailed => 'Impossibile inviare la segnalazione';

  @override
  String get reportTypeRating => 'Abuso di valutazione';

  @override
  String get reportTypeFile => 'File dannoso';

  @override
  String get reportTypeSource => 'Fonte dannosa';

  @override
  String get reportTypeDescription => 'Abuso di descrizione';

  @override
  String get reportTypeNote => 'Abuso di note';

  @override
  String get reportTypeTagging => 'Abuso di tagging';

  @override
  String get reportTypeRatingBody =>
      'La valutazione del post è stata impostata a qualcosa di non corretto.';

  @override
  String get reportTypeFileBody =>
      'Il file contiene codice dannoso o un archivio nascosto. Questo non si riferisce all\'immagine stessa.';

  @override
  String get reportTypeSourceBody =>
      'Una o più fonti collegate portano a pagine dannose o contenuti a pagamento.';

  @override
  String get reportTypeDescriptionBody =>
      'La descrizione contiene contenuti dannosi o è stata modificata per contenere materiale abusivo.';

  @override
  String get reportTypeNoteBody =>
      'Le note di questo post sono errate, abusive o comunque dannose.';

  @override
  String get reportTypeTaggingBody =>
      'Uno o più tag di questo post non sono validi o uno o più tag validi sono stati rimossi.';

  @override
  String flagPostSuccess(num id) {
    return 'Post #$id segnalato';
  }

  @override
  String flagPostFailed(num id) {
    return 'Segnalazione post #$id fallita';
  }

  @override
  String get flagParentId => 'ID post padre';

  @override
  String get flagParentIdRequired => 'L\'ID post padre non può essere vuoto';

  @override
  String get flagParentIdInvalid => 'L\'ID post padre deve essere un numero';

  @override
  String get flagTypeUploadingGuidelines =>
      'Non rispetta le linee guida per l\'upload';

  @override
  String get flagTypeYoungHuman => 'Personaggio umano in esplicita situazione';

  @override
  String get flagTypeDnpArtist =>
      'L\'artista di questo post è nella lista di evita pubblicazione';

  @override
  String get flagTypePayContent =>
      'Contenuto a pagamento, commerciale o abbonamento';

  @override
  String get flagTypeTrace => 'Traccia di un\'opera di un altro artista';

  @override
  String get flagTypePreviouslyDeleted => 'Precedentemente eliminato';

  @override
  String get flagTypeRealPorn => 'Pornografia reale';

  @override
  String get flagTypeCorrupt =>
      'Il file è corrotto, danneggiato o non funziona';

  @override
  String get flagTypeInferior =>
      'Versione duplicata o inferiore di un altro post';

  @override
  String get flagTypeUploadingGuidelinesBody =>
      'Questo post non rispetta gli standard del sito, per valore artistico, qualità dell\'immagine, rilevanza o altro.\nRicorda che le tue preferenze personali non hanno alcun peso. Se trovi il contenuto di un post offensivo, semplicemente [[e621:blacklist|blacklistalo]].';

  @override
  String get flagTypeYoungHumanBody =>
      'Non sono accettati post che rappresentano personaggi umani o umanoidi in situazioni sessuali o nudi espliciti.';

  @override
  String get flagTypeDnpArtistBody =>
      'Alcuni artisti hanno richiesto che le loro opere non vengano pubblicate su questo sito e hanno ottenuto lo stato [[avoid_posting|Non Pubblicare]].\nA volte questo stato include condizioni; vedi [[conditional_dnp]] per maggiori informazioni.';

  @override
  String get flagTypePayContentBody =>
      'Non ospitiamo contenuti a pagamento o commerciali di alcun tipo. Questo include fughe da Patreon, repost da siti di pirateria e così via.';

  @override
  String get flagTypeTraceBody =>
      'Non sono accettate immagini tratte da opere di altri artisti. Prendere spunto è ok, ma copiare direttamente il lavoro di qualcunno no.\nPer favore, lascia maggiori informazioni nei commenti, o aggiungi l\'opera originale come post padre se è ospitata su questo sito.';

  @override
  String get flagTypePreviouslyDeletedBody =>
      'I post vengono rimossi per buone ragioni e non è accettato riuploadare contenuti eliminati.\nPer favore, lascia maggiori informazioni nei commenti, o aggiungi il post originale come post padre di questo.';

  @override
  String get flagTypeRealPornBody =>
      'Non sono accettati post con pornografia reale. Nessuna eccezione.\nNota che sono accettate immagini con foto non erotiche.';

  @override
  String get flagTypeCorruptBody =>
      'C\'è qualcosa che non va in questo post. Potrebbe essere un video rotto o un\'immagine corrotta.\nIn ogni caso, per evitare confusione, per favore spiega la situazione nei commenti.';

  @override
  String get flagTypeInferiorBody =>
      'Esiste già una versione superiore di questo post sul sito.\nQuesto può includere immagini con qualità migliore (più grandi, meno compresse), ma anche versioni \"corrette\", con errori visivi corretti dall\'artista.\nNota che modifiche e versioni alternative non rientrano in questa categoria.';

  @override
  String get taskCancelAll => 'Annulla tutto';

  @override
  String get taskClearDone => 'Pulisci completati';

  @override
  String get taskClearSelection => 'Pulisci selezione';

  @override
  String get taskCancel => 'Annulla';

  @override
  String get taskDismiss => 'Ignora';

  @override
  String get taskNoTasks => 'Nessuna attività';

  @override
  String get taskFailedToLoadTasks => 'Caricamento attività fallito';

  @override
  String taskSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attività',
      one: '1 attività',
    );
    return '$_temp0';
  }

  @override
  String get taskGroupActive => 'Attive';

  @override
  String get taskGroupFailed => 'Fallite';

  @override
  String get taskActionDownload => 'scaricamento';

  @override
  String get taskActionFavorite => 'preferiti';

  @override
  String get taskActionUnfavorite => 'rimozione preferiti';

  @override
  String get taskDownloadRunning => 'in download';

  @override
  String get taskFavoriteRunning => 'in aggiunta preferiti';

  @override
  String get taskUnfavoriteRunning => 'in rimozione preferiti';

  @override
  String get taskDownloadCompleted => 'scaricato';

  @override
  String get taskFavoriteCompleted => 'aggiunto ai preferiti';

  @override
  String get taskUnfavoriteCompleted => 'rimosso dai preferiti';

  @override
  String taskQueuedTo(String action) {
    return 'in coda per $action';
  }

  @override
  String taskFailedTo(String action) {
    return 'fallito $action';
  }

  @override
  String taskCanceledAction(String action) {
    return '$action annullato';
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
      other: 'ha $count nuovi post!',
      one: 'ha un nuovo post!',
    );
    return '$_temp0';
  }

  @override
  String get followNotificationSummary => 'Nuovi post!';

  @override
  String get followNotificationHiddenBody =>
      'I tuoi tag seguiti hanno nuovi post.';

  @override
  String get followHideNotificationContent =>
      'Nascondi il contenuto delle notifiche';

  @override
  String get followHideNotificationContentHint =>
      'Titoli, anteprime e miniature delle notifiche vengono nascosti';

  @override
  String get notificationStaleIdentity =>
      'Questa notifica appartiene a un account che non è più presente su questo dispositivo.';

  @override
  String get followChannelName => 'Tag seguiti';

  @override
  String get followChannelDescription => 'Notifiche per i tag che segui';

  @override
  String get hostUnavailableTitle => 'Host non disponibile';

  @override
  String hostUnavailableBody(String host) {
    return 'Sembra che $host non sia disponibile!';
  }

  @override
  String get hostUnavailableResolveHint =>
      'Per favore risolvi il problema nella finestra del browser seguente.\n\nI cookie di captcha di Cloudflare saranno salvati.';

  @override
  String get hostUnavailableResolve => 'Risolvi';

  @override
  String hostUnavailableWaitBody(String host) {
    return '\nPer favore aspetta che $host risolva la situazione dalla loro parte.';
  }

  @override
  String get downloadChooseFolder => 'Scegli una cartella';

  @override
  String get searchFilterTitle => 'Filtri';

  @override
  String get searchFilterQueryLabel => 'Query corrente:';

  @override
  String get filterSectionSort => 'Ordinamento';

  @override
  String get filterSectionContent => 'Contenuto';

  @override
  String get filterSectionTime => 'Tempo e stato';

  @override
  String get filterSectionMedia => 'Media';

  @override
  String get filterSectionOther => 'Altro';

  @override
  String get searchFilterReset => 'Ripristina filtri';

  @override
  String get dtextParsingFailed => 'Analisi DText fallita';

  @override
  String get filteredShow => 'Mostra';

  @override
  String get filteredHide => 'Nascondi';

  @override
  String get selectOptions => 'Seleziona opzioni...';

  @override
  String get databaseNotE1547 => 'Questo file non è un database e1547.';

  @override
  String get adultGateTitle => 'Controllo rapido';

  @override
  String get adultGateBody =>
      'Questa app conduce direttamente a e621, una community artistica riservata esclusivamente ad adulti. Per favore conferma di avere l\'età legale nel tuo paese - ti fidiamo, i nostri avvocati no.';

  @override
  String get adultGateConfirm => 'Certo - ho 18 anni o più';

  @override
  String get adultGateDeny => 'Rimandami indietro';

  @override
  String get databaseExportPasswordLabel => 'Password (opzionale)';

  @override
  String get databaseExportPasswordHint =>
      'Crittografa il file esportato. Lascia vuoto per un file non crittografato.';

  @override
  String get databaseImportEncryptedTitle => 'Database crittografato';

  @override
  String get databaseImportPasswordLabel => 'Password';

  @override
  String get databaseImportWrongPassword => 'Password errata o file corrotto.';

  @override
  String get actionUnlock => 'SBLOCCA';

  @override
  String get editorDiscardTitle => 'Scartare le modifiche?';

  @override
  String get editorDiscardBody => 'Le modifiche non sono state inviate.';

  @override
  String get editorDiscardConfirm => 'Scarta';

  @override
  String get editorContinueEditing => 'Continua a modificare';

  @override
  String postListGoingToPage(num page) {
    return 'Passaggio alla pagina $page';
  }

  @override
  String get actionRetry => 'Riprova';

  @override
  String get selectionQueueDownloadsFailed => 'Impossibile accodare i download';

  @override
  String get selectionQueueFavoritesFailed =>
      'Impossibile accodare i preferiti';

  @override
  String get taskBubbleDone => 'Fatto';

  @override
  String get taskBubbleCanceled => 'Annullato';

  @override
  String taskBubbleFailures(int completed, int failed) {
    return '$completed completate, $failed fallite';
  }

  @override
  String get taskBubbleSaving => 'Salvataggio';

  @override
  String get taskBubbleWorking => 'In corso';
}
