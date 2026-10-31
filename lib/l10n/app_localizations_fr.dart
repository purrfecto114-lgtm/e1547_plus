// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'e1547';

  @override
  String get failedToLoad => 'Échec du chargement';

  @override
  String get nothingToSeeHere => 'Rien à voir ici';

  @override
  String get loading => 'Chargement...';

  @override
  String get actionCancel => 'ANNULER';

  @override
  String get actionOk => 'OK';

  @override
  String get actionTryAgain => 'Réessayer';

  @override
  String get actionDownload => 'TÉLÉCHARGER';

  @override
  String get actionImport => 'IMPORTER';

  @override
  String get actionExport => 'EXPORTER';

  @override
  String get actionUndo => 'Annuler';

  @override
  String get actionRestartNow => 'REDÉMARRER';

  @override
  String get failedToLoadSuggestions => 'Échec du chargement des suggestions';

  @override
  String selectionItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String get actionAbort => 'Abandonner';

  @override
  String get actionSelectAll => 'Tout sélectionner';

  @override
  String fileSavedAs(String name) {
    return 'Fichier enregistré sous $name';
  }

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get saveFile => 'Enregistrer le fichier';

  @override
  String get filterTooltip => 'Filtrer';

  @override
  String get rangeInvalidFormat => 'Format invalide';

  @override
  String itemProgress(num current, num total) {
    return 'Élément $current/$total';
  }

  @override
  String get taskCancelled => 'Tâche annulée';

  @override
  String taskFailedAt(num index) {
    return 'Échec à l\'élément $index';
  }

  @override
  String get taskDone => 'Terminé';

  @override
  String get failedToInitialize => 'Échec de l\'initialisation';

  @override
  String get navHome => 'Accueil';

  @override
  String get navHot => 'Populaires';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navTimeline => 'Chronologie';

  @override
  String get navSubscriptions => 'Abonnements';

  @override
  String get navBookmarks => 'Signets';

  @override
  String get navPools => 'Pools';

  @override
  String get navForum => 'Forum';

  @override
  String get navHistory => 'Historique';

  @override
  String get navTasks => 'Tâches';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navAbout => 'À propos';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get sectionAccount => 'Compte';

  @override
  String get sectionUser => 'Utilisateur';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get sectionInteractions => 'Interactions';

  @override
  String get sectionSecurity => 'Sécurité';

  @override
  String get sectionDevelopment => 'Développement';

  @override
  String get settingsBlacklist => 'Blacklist';

  @override
  String tagsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags bloqués',
      one: '1 tag bloqué',
    );
    return '$_temp0';
  }

  @override
  String get settingsFollows => 'Abonnements';

  @override
  String searchesFollowed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recherches suivies',
      one: '1 recherche suivie',
    );
    return '$_temp0';
  }

  @override
  String get settingsHistory => 'Historique';

  @override
  String pagesVisited(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages visitées',
      one: '1 page visitée',
    );
    return '$_temp0';
  }

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeDark => 'sombre';

  @override
  String get themeAmoled => 'amoled';

  @override
  String get themeLight => 'clair';

  @override
  String get themeBlue => 'bleu';

  @override
  String get themeSystem => 'système';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystemDefault => 'Langue du système';

  @override
  String get settingsTileSize => 'Taille des tuiles';

  @override
  String get settingsQuilt => 'Mosaïque';

  @override
  String get gridTitle => 'Grille';

  @override
  String get quiltSquare => 'tuiles carrées';

  @override
  String get quiltVertical => 'tuiles étendues verticalement';

  @override
  String get settingsPostInfo => 'Infos des posts';

  @override
  String get postInfoShown => 'infos sur les tuiles';

  @override
  String get postInfoHidden => 'tuiles image uniquement';

  @override
  String get settingsDownloadLocation => 'Emplacement de téléchargement';

  @override
  String get settingsUpvoteFavorites => 'Upvoter les favoris';

  @override
  String get upvoteFavoritesOn => 'upvoter et mettre en favori';

  @override
  String get upvoteFavoritesOff => 'mettre en favori seulement';

  @override
  String get settingsVideoVolume => 'Volume des vidéos';

  @override
  String get videoMuted => 'muet';

  @override
  String get videoWithSound => 'avec le son';

  @override
  String videoSeekSeconds(Object seconds) {
    return '$seconds secondes';
  }

  @override
  String get settingsVideoResolution => 'Résolution des vidéos';

  @override
  String get videoResStandard => '480p';

  @override
  String get videoResHigh => '720p';

  @override
  String get videoResFull => '1080p';

  @override
  String get videoResUltra => '4K';

  @override
  String get videoResSource => 'Source';

  @override
  String get videoResNote =>
      'Les vidéos ne sont pas toujours disponibles dans les tailles standard ; la taille la plus proche de la sélection est utilisée.';

  @override
  String get settingsAutoLoadVideos => 'Charger les vidéos automatiquement';

  @override
  String get autoLoadVideosOn => 'vidéos chargées pendant la navigation';

  @override
  String get autoLoadVideosOff => 'vidéos chargées à la lecture';

  @override
  String get autoLoadVideosDialogTitle =>
      'Charger les vidéos automatiquement ?';

  @override
  String get autoLoadVideosDialogBody =>
      'Les vidéos seront entièrement téléchargées pendant que tu navigues et que tu effectues des recherches. Cela peut consommer beaucoup de données sur les connexions limitées.';

  @override
  String get videoQuality => 'Qualité vidéo';

  @override
  String get settingsSecureDisplay => 'Affichage sécurisé';

  @override
  String get secureDisplayOn => 'écran protégé';

  @override
  String get secureDisplayOff => 'écran visible';

  @override
  String get settingsIncognitoKeyboard => 'Clavier incognito';

  @override
  String get enabled => 'activé';

  @override
  String get disabled => 'désactivé';

  @override
  String get settingsPinLock => 'Verrouillage PIN';

  @override
  String get pinEnabled => 'PIN activé';

  @override
  String get pinDisabled => 'PIN désactivé';

  @override
  String get settingsBiometricLock => 'Verrouillage biométrique';

  @override
  String get biometricsEnabled => 'biométrie activée';

  @override
  String get biometricsDisabled => 'biométrie désactivée';

  @override
  String get settingsDeveloperMode => 'Mode développeur';

  @override
  String get devOptionsShown => 'options affichées';

  @override
  String get devOptionsHidden => 'options masquées';

  @override
  String errorsLogged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count erreurs enregistrées',
      one: '1 erreur enregistrée',
    );
    return '$_temp0';
  }

  @override
  String get settingsDatabase => 'Base de données';

  @override
  String get databaseExporting => 'Export de la base de données...';

  @override
  String get databaseExported => 'Base de données exportée avec succès';

  @override
  String get databaseExportFailed => 'Échec de l\'export';

  @override
  String get databaseExport => 'Exporter';

  @override
  String get databaseImporting => 'Import de la base de données...';

  @override
  String databaseInvalidFile(String error) {
    return 'Fichier de base de données invalide : $error';
  }

  @override
  String databaseImportFailed(String error) {
    return 'Échec de l\'import : $error';
  }

  @override
  String get databaseImportTitle => 'Importer une base de données';

  @override
  String get databaseRestartTitle => 'Redémarrage requis';

  @override
  String get databaseRestartBody =>
      'L\'application doit redémarrer pour appliquer les modifications.';

  @override
  String get databaseImport => 'Importer';

  @override
  String get lockEnterPin => 'Saisis le PIN';

  @override
  String get lockEnterNewPin => 'Saisis le nouveau PIN';

  @override
  String get lockConfirmNewPin => 'Confirme le nouveau PIN';

  @override
  String get lockFailedAuth => 'Échec de l\'authentification';

  @override
  String get lockPleaseAuth => 'Merci de t\'authentifier';

  @override
  String get lockRetry => 'Réessayer';

  @override
  String get lockBiometricReason => 'Authentifie-toi pour déverrouiller.';

  @override
  String get lockBiometricFailure =>
      'Échec grave de l\'authentification biométrique';

  @override
  String get aboutVersion => 'Version';

  @override
  String get updaterFetching => 'Recherche de mises à jour...';

  @override
  String get updaterCheckFailed => 'Échec de la vérification des mises à jour';

  @override
  String get updaterNewest => 'Tu as déjà la dernière version';

  @override
  String updaterNewer(String version) {
    return 'Une nouvelle version est disponible : $version';
  }

  @override
  String get updaterNewerHeader => 'Une nouvelle version est disponible : ';

  @override
  String get aboutExperimentalPlatform => 'Plateforme expérimentale';

  @override
  String get aboutExperimentalBody =>
      'Cette plateforme n\'est pas prise en charge. Attends-toi à des bugs et à des fonctionnalités manquantes.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutUpstream => 'Projet original';

  @override
  String get aboutUpstreamBody =>
      'Cette application est un fork de clragon/e1547';

  @override
  String get aboutDiscord => 'Discord';

  @override
  String get aboutForum => 'Forum';

  @override
  String aboutForumTopic(num id) {
    return 'Sujet e621 #$id';
  }

  @override
  String get aboutWebsite => 'Site web';

  @override
  String get aboutKofi => 'Ko-fi';

  @override
  String get aboutEmail => 'E-mail';

  @override
  String get aboutPlaystore => 'Playstore';

  @override
  String get aboutDonors => 'Donateurs';

  @override
  String get aboutDonorsThanks =>
      'Merci de m\'aider à maintenir le développement !';

  @override
  String get aboutNoDonors => 'Pas encore de donateurs';

  @override
  String get aboutDonorsFailed => 'Échec de la récupération des donateurs';

  @override
  String get aboutDonorsNotListed => 'Pas sur la liste ? Contacte-nous !';

  @override
  String get developerUnlocked => 'Tu es maintenant développeur !';

  @override
  String get databaseErrorLoading =>
      'Erreur de chargement de la base de données';

  @override
  String get databaseUnknownSize => 'Inconnue';

  @override
  String get databaseExportTitle => 'Exporter la base de données';

  @override
  String get databaseExportSubtitle =>
      'Enregistre une copie de sauvegarde de ta base de données';

  @override
  String get databaseImportSubtitle =>
      'Remplace la base de données actuelle par celle importée';

  @override
  String get databaseImportWarning =>
      'Cela remplacera ta base de données actuelle.\nToutes les données seront perdues. C\'est irréversible !';

  @override
  String get databaseExportSanitizedBody =>
      'Le fichier exporté ne contiendra ni tes identifiants ni tes clés API.\nTout le reste est inclus : comptes, hôtes, historique, abonnements et tâches.';

  @override
  String get databaseImportNewerFile =>
      'Ce fichier a été créé par une version plus récente de l\'application et ne peut pas être importé.';

  @override
  String get databaseImportSanitized =>
      'Par sécurité, les identifiants enregistrés ont été retirés du fichier importé.';

  @override
  String databaseImportHostsWarning(String hosts) {
    return 'Attention : le fichier importé contient des comptes sur d\'autres sites : $hosts';
  }

  @override
  String get databaseImportCancelled => 'Import annulé';

  @override
  String get postsTitle => 'Posts';

  @override
  String favoritesOf(String user) {
    return 'Favoris de $user';
  }

  @override
  String get favoritesUnavailable =>
      'Les favoris ne sont pas disponibles pour les utilisateurs anonymes';

  @override
  String get favoriteOrder => 'Ordre des favoris';

  @override
  String get orderAdded => 'ordre d\'ajout';

  @override
  String get orderId => 'ordre par id';

  @override
  String get postStateDeleted => 'supprimé';

  @override
  String get postStateUnsupported => 'non pris en charge';

  @override
  String get postStateUnavailable => 'indisponible';

  @override
  String get menuShare => 'Partager';

  @override
  String get menuDownload => 'Télécharger';

  @override
  String get menuBrowse => 'Parcourir';

  @override
  String get menuEdit => 'Modifier';

  @override
  String get menuComment => 'Commenter';

  @override
  String get menuReport => 'Signaler';

  @override
  String get menuFlag => 'Flaguer';

  @override
  String get actionOpen => 'Ouvrir';

  @override
  String get actionFollow => 'Suivre';

  @override
  String get actionUnfollow => 'Ne plus suivre';

  @override
  String get actionMute => 'Ignorer';

  @override
  String get actionNotify => 'Notifier';

  @override
  String get actionBookmark => 'Ajouter aux signets';

  @override
  String get actionUnbookmark => 'Retirer des signets';

  @override
  String get actionBlock => 'Bloquer';

  @override
  String get actionUnblock => 'Débloquer';

  @override
  String get actionRemove => 'Retirer';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionSubtract => 'Soustraire';

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
  String get noPosts => 'Aucun post';

  @override
  String get failedToLoadPosts => 'Échec du chargement des posts';

  @override
  String get offlineBanner =>
      'Tu es hors ligne. Affichage des données en cache.';

  @override
  String get offlineNoData => 'Tu es hors ligne';

  @override
  String postListPageSummary(num count, Object page) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '$count post',
    );
    return 'Page $page · $_temp0';
  }

  @override
  String get postListPageLimit =>
      'Tu as atteint la limite de pages du serveur. Merci d\'affiner tes termes de recherche.';

  @override
  String get postListJumpToPage => 'Aller à la page';

  @override
  String get postListJumpPageLabel => 'Numéro de page';

  @override
  String postListJumpPageRange(Object max) {
    return 'Saisis un numéro de page entre 1 et $max';
  }

  @override
  String get postDeletedOverlay => 'Ce post a été supprimé';

  @override
  String get postUnavailableOverlay => 'Ce post est indisponible';

  @override
  String get postBlacklistedOverlay => 'Ce post est blacklisté';

  @override
  String unsupportedFileType(String ext) {
    return 'Les fichiers $ext ne sont pas pris en charge';
  }

  @override
  String get loginRequiredEdit =>
      'Tu dois être connecté pour modifier des posts !';

  @override
  String get loginRequiredComment => 'Tu dois être connecté pour commenter !';

  @override
  String get loginRequiredReport =>
      'Tu dois être connecté pour signaler des posts !';

  @override
  String get loginRequiredFlag =>
      'Tu dois être connecté pour flaguer des posts !';

  @override
  String postsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts bloqués',
      one: '1 post bloqué',
    );
    return '$_temp0';
  }

  @override
  String get blacklistUpdateFailed =>
      'Échec de la mise à jour de la blacklist !';

  @override
  String get blacklistAddTag => 'Ajouter un tag';

  @override
  String get blacklistEditTag => 'Modifier le tag';

  @override
  String get denylistEntryDeleted => 'Entrée de la blacklist supprimée';

  @override
  String get blacklistEmpty => 'Ta blacklist est vide';

  @override
  String get menuDelete => 'Supprimer';

  @override
  String get filterScore => 'Score';

  @override
  String get filterFavoriteCount => 'Nombre de favoris';

  @override
  String get filterSortBy => 'Trier par';

  @override
  String get filterNew => 'Nouveaux';

  @override
  String get filterRank => 'Rang';

  @override
  String get filterRandom => 'Aléatoire';

  @override
  String get filterDefault => 'Par défaut';

  @override
  String get filterRating => 'Notation';

  @override
  String get filterSafe => 'Sûr';

  @override
  String get filterQuestionable => 'Douteux';

  @override
  String get filterExplicit => 'Explicite';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterPool => 'Pool';

  @override
  String get filterHasPool => 'A un pool';

  @override
  String get filterChild => 'Enfant';

  @override
  String get filterIsChildPost => 'Est un post enfant';

  @override
  String get filterParent => 'Parent';

  @override
  String get filterIsParentPost => 'Est un post parent';

  @override
  String get filterUploadDate => 'Date de mise en ligne';

  @override
  String get filterLastDay => 'Dernier jour';

  @override
  String get filterLastWeek => 'Dernière semaine';

  @override
  String get filterLastMonth => 'Dernier mois';

  @override
  String get filterLastYear => 'Dernière année';

  @override
  String get filterStatus => 'Statut';

  @override
  String get filterActive => 'Actif';

  @override
  String get filterPending => 'En attente';

  @override
  String get filterDeleted => 'Supprimé';

  @override
  String get filterFlagged => 'Flagué';

  @override
  String get filterAny => 'Tous';

  @override
  String get filterFileType => 'Type de fichier';

  @override
  String get filterUploader => 'Uploader';

  @override
  String get filterWidth => 'Largeur';

  @override
  String get filterHeight => 'Hauteur';

  @override
  String get filterTagCount => 'Nombre de tags';

  @override
  String get filterTrue => 'Vrai';

  @override
  String get filterFalse => 'Faux';

  @override
  String get filterImages => 'Images';

  @override
  String get filterVideos => 'Vidéos';

  @override
  String get filterTitleContains => 'Le titre contient';

  @override
  String get filterCategory => 'Catégorie';

  @override
  String get filterGeneral => 'Général';

  @override
  String get filterSiteBugReports =>
      'Bugs du site & demandes de fonctionnalités';

  @override
  String get filterTagWikiProjects => 'Projets et questions tags/wiki';

  @override
  String get filterTagAliasSuggestions =>
      'Suggestions d\'alias et d\'implications de tags';

  @override
  String get filterArtTalk => 'Discussion artistique';

  @override
  String get filterOffTopic => 'Hors sujet';

  @override
  String get filterE621Tools => 'Outils et applications e621';

  @override
  String get filterNewestFirst => 'Du plus récent';

  @override
  String get filterOldestFirst => 'Du plus ancien';

  @override
  String get filterSticky => 'Épinglé';

  @override
  String get filterIsSticky => 'Est épinglé';

  @override
  String get filterLocked => 'Verrouillé';

  @override
  String get filterIsLocked => 'Est verrouillé';

  @override
  String get filterDescription => 'Description';

  @override
  String get filterCreator => 'Créateur';

  @override
  String get filterIsActive => 'Est actif';

  @override
  String get filterSeries => 'Série';

  @override
  String get filterCollection => 'Collection';

  @override
  String get filterName => 'Nom';

  @override
  String get filterCreated => 'Créé';

  @override
  String get filterUpdated => 'Mis à jour';

  @override
  String get filterPostCount => 'Nombre de posts';

  @override
  String postUpdateFailed(num id) {
    return 'Échec de la mise à jour du post #$id';
  }

  @override
  String postUpdated(num id) {
    return 'Post #$id mis à jour';
  }

  @override
  String get failedToLoadPost => 'Échec du chargement du post';

  @override
  String get postNotFound => 'Post introuvable';

  @override
  String get commentsTitle => 'Commentaires';

  @override
  String commentsOfPost(num postId) {
    return 'Commentaires sur #$postId';
  }

  @override
  String get commentOrder => 'Ordre des commentaires';

  @override
  String get noComments => 'Aucun commentaire';

  @override
  String get failedToLoadComments => 'Échec du chargement des commentaires';

  @override
  String commentTitle(num id) {
    return 'Commentaire #$id';
  }

  @override
  String get failedToLoadComment => 'Échec du chargement du commentaire';

  @override
  String get commentNotFound => 'Commentaire introuvable';

  @override
  String commentEditorTitle(num postId) {
    return 'Commentaire sur #$postId';
  }

  @override
  String get commentSendFailed => 'Échec de l\'envoi du commentaire !';

  @override
  String get commentSent => 'Commentaire envoyé !';

  @override
  String get commentHidden => 'Ce commentaire est masqué';

  @override
  String commentUpvoteFailed(num id) {
    return 'Échec de l\'upvote du commentaire #$id';
  }

  @override
  String commentDownvoteFailed(num id) {
    return 'Échec du downvote du commentaire #$id';
  }

  @override
  String get commentLoginRequiredEdit =>
      'Tu dois être connecté pour modifier des commentaires !';

  @override
  String get commentLoginRequiredReply =>
      'Tu dois être connecté pour répondre aux commentaires !';

  @override
  String get commentLoginRequiredReport =>
      'Tu dois être connecté pour signaler des commentaires !';

  @override
  String commentCopiedId(num id) {
    return 'id du commentaire #$id copié';
  }

  @override
  String get warningUserWarned =>
      'L\'utilisateur a reçu un avertissement pour ce message';

  @override
  String get warningUserRecorded =>
      'L\'utilisateur a reçu une mention à son dossier pour ce message';

  @override
  String get warningUserBanned => 'L\'utilisateur a été banni pour ce message';

  @override
  String get repliesTitle => 'Réponses';

  @override
  String get replyOrder => 'Ordre des réponses';

  @override
  String get noReplies => 'Aucune réponse';

  @override
  String get failedToLoadReplies => 'Échec du chargement des réponses';

  @override
  String replyTitle(num id) {
    return 'Réponse #$id';
  }

  @override
  String get failedToLoadReply => 'Échec du chargement de la réponse';

  @override
  String get replyNotFound => 'Réponse introuvable';

  @override
  String replyEditorTitle(num topicId) {
    return 'Réponse sur #$topicId';
  }

  @override
  String get replySendFailed => 'Échec de l\'envoi de la réponse !';

  @override
  String get replySent => 'Réponse envoyée !';

  @override
  String get replyHidden => 'Cette réponse est masquée';

  @override
  String get replyLoginRequiredEdit =>
      'Tu dois être connecté pour modifier des réponses !';

  @override
  String get replyLoginRequiredReply => 'Tu dois être connecté pour répondre !';

  @override
  String get replyLoginRequiredReport =>
      'Tu dois être connecté pour signaler des réponses !';

  @override
  String replyCopiedId(num id) {
    return 'id de la réponse #$id copié';
  }

  @override
  String get menuReply => 'Répondre';

  @override
  String get menuCopyId => 'Copier l\'ID';

  @override
  String get menuRefresh => 'Rafraîchir';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionShow => 'Afficher';

  @override
  String get actionHide => 'Masquer';

  @override
  String get actionCannotBeUndone => 'Cette action est irréversible.';

  @override
  String get info => 'Info';

  @override
  String wikiTitle(String idOrTitle) {
    return 'Wiki $idOrTitle';
  }

  @override
  String get failedToLoadWiki => 'Échec du chargement du wiki';

  @override
  String get wikiNotFound => 'Wiki introuvable';

  @override
  String wikiCopiedId(num id) {
    return 'id du wiki #$id copié';
  }

  @override
  String get wikiInfoId => 'id';

  @override
  String get wikiInfoAlias => 'alias';

  @override
  String get wikiInfoCreated => 'créé';

  @override
  String get wikiInfoUpdated => 'mis à jour';

  @override
  String get wikiInfoLocked => 'verrouillé';

  @override
  String get wikiInfoYes => 'oui';

  @override
  String get wikiInfoNo => 'non';

  @override
  String userTitle(String idOrName) {
    return 'Utilisateur $idOrName';
  }

  @override
  String get failedToLoadUser => 'Échec du chargement de l\'utilisateur';

  @override
  String get userNotFound => 'Utilisateur introuvable';

  @override
  String get userUploads => 'Mises en ligne';

  @override
  String get userLoginRequiredReport =>
      'Tu dois être connecté pour signaler des utilisateurs !';

  @override
  String get userComission => 'Commission';

  @override
  String get userId => 'id';

  @override
  String get userJoined => 'inscrit';

  @override
  String get userRank => 'rang';

  @override
  String get userPosts => 'posts';

  @override
  String get userEdits => 'modifications';

  @override
  String get userFavorites => 'favoris';

  @override
  String get userComments => 'commentaires';

  @override
  String get userForum => 'forum';

  @override
  String userCopiedId(num id) {
    return 'id de l\'utilisateur #$id copié';
  }

  @override
  String get logsTitle => 'Journaux';

  @override
  String logsTitleDate(String date) {
    return 'Journaux - $date';
  }

  @override
  String selectionLogsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count journaux',
    );
    return '$_temp0';
  }

  @override
  String selectionLogsFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers de journal',
    );
    return '$_temp0';
  }

  @override
  String get logsLevels => 'Niveaux';

  @override
  String get logsRecording => 'Enregistrement';

  @override
  String get logsVerbose => 'Détaillé';

  @override
  String get logsVerboseAll => 'tous les niveaux enregistrés';

  @override
  String logsVerboseMinimum(String level) {
    return '$level et plus';
  }

  @override
  String get logFilesTitle => 'Fichiers de journal';

  @override
  String get failedToLoadLogFiles =>
      'Échec du chargement des fichiers de journal !';

  @override
  String get noLogFiles => 'Aucun fichier de journal disponible !';

  @override
  String get logsLive => 'En direct';

  @override
  String get noLogs => 'Aucun journal';

  @override
  String get failedToReadLog => 'Échec de la lecture du journal';

  @override
  String get noErrorsLogged => 'Aucune erreur enregistrée';

  @override
  String logsErrorsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count erreurs',
      one: '1 erreur',
    );
    return '$_temp0';
  }

  @override
  String get logsAll => 'Tous les journaux';

  @override
  String get logsDismissAll => 'Tout ignorer';

  @override
  String logsDeleteTitle(num count) {
    return 'Supprimer $count fichiers de journal ?';
  }

  @override
  String get identityAccounts => 'Comptes';

  @override
  String get identityAdd => 'Ajouter un compte';

  @override
  String get identityEdit => 'Modifier le compte';

  @override
  String get identityRemoveTitle => 'Retirer le compte ?';

  @override
  String get identityRemoveBody =>
      'Toutes ses données seront définitivement supprimées, y compris l\'historique et les abonnements.';

  @override
  String get identityAnonymous => 'Anonyme';

  @override
  String get identityDuplicate =>
      'Tu as déjà une identité avec cet hôte et ce nom d\'utilisateur.';

  @override
  String identityLoginFailed(String reason) {
    return 'Échec de la connexion.\n$reason';
  }

  @override
  String get identityLoginCheckDetails =>
      'Vérifie ta connexion réseau et tes identifiants';

  @override
  String get identitySite => 'Site';

  @override
  String get identityHostRequired => 'Tu dois fournir une URL d\'hôte.';

  @override
  String get identityHostInvalid => 'URL d\'hôte invalide';

  @override
  String get identityHostReadOnly =>
      'Le site ne peut pas être modifié. Ajoute un nouveau compte pour en utiliser un autre.';

  @override
  String get identityUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get identityUsernameRequired =>
      'Tu dois fournir un nom d\'utilisateur.';

  @override
  String get identityApikeyLabel => 'Clé API';

  @override
  String get identityApikeyHelp => 'Où trouver ma clé API ?';

  @override
  String get identityApikeyRequired =>
      'Tu dois fournir une clé API.\np. ex. 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identityApikeyInvalid =>
      'La clé API est une séquence de 24 ou 32 caractères parmi A-z et 0-9\np. ex. 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identitySignupPrompt => 'Pas encore de compte ? Inscris-toi ici';

  @override
  String get identityHostHint => 'Le site qui héberge ton compte et tes posts.';

  @override
  String get identitySignIn => 'Se connecter';

  @override
  String get identityGuest => 'Invité';

  @override
  String get identityLogin => 'Connexion';

  @override
  String get identityBrowseAnonymously => 'Naviguer anonymement';

  @override
  String identityConnecting(String host, String username) {
    return 'Connexion à $host en tant que $username…';
  }

  @override
  String identityActivateFailed(Object error) {
    return 'Échec de l\'activation de l\'identité : $error';
  }

  @override
  String traitsActivateFailed(Object error) {
    return 'Échec de l\'activation des traits : $error';
  }

  @override
  String get failedToLoadIdentities => 'Échec du chargement des identités';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String onboardingWelcomeTitle(String app) {
    return 'Bienvenue sur $app';
  }

  @override
  String get onboardingWelcomeBody => 'Un navigateur de boorus sophistiqué.';

  @override
  String get onboardingThemeTitle => 'Choisis ton style';

  @override
  String get onboardingThemeBody =>
      'Essaie-en un. Tu pourras toujours changer d\'avis plus tard.';

  @override
  String get onboardingLoginTitle => 'Connecte un compte';

  @override
  String get onboardingLanguageTitle => 'Choisis une langue';

  @override
  String get followAddToSubscriptions => 'Ajouter aux abonnements';

  @override
  String get followNoSubscriptions => 'Aucun abonnement';

  @override
  String get followFailedToLoadSubscriptions =>
      'Échec du chargement des abonnements';

  @override
  String get followAddToBookmarks => 'Ajouter aux signets';

  @override
  String get followNoBookmarks => 'Aucun signet';

  @override
  String get followFailedToLoadBookmarks => 'Échec du chargement des signets';

  @override
  String get followUnseenPosts => 'posts non vus';

  @override
  String followMarkPostsSeen(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'marquer $count posts comme vus',
      one: 'marquer 1 post comme vu',
    );
    return '$_temp0';
  }

  @override
  String get followNoUnseenPosts => 'aucun post non vu';

  @override
  String get followShowUnseenFirst => 'afficher les non-vus en premier';

  @override
  String get followFilteringUnseen => 'filtrage des non-vus';

  @override
  String get followAllPostsShown => 'tous les posts affichés';

  @override
  String get followForceSync => 'Forcer la synchronisation';

  @override
  String get followSyncAllFollows => 'synchroniser tous les abonnements';

  @override
  String followSyncingFollows(String progress) {
    return 'synchronisation des abonnements... $progress';
  }

  @override
  String get followEditorTitle => 'Modifier les abonnements';

  @override
  String get followSubscribe => 'S\'abonner';

  @override
  String get followEditPrompt => 'Modifier l\'abonnement';

  @override
  String get followTitlePrompt => 'Titre de l\'abonnement';

  @override
  String get followMarkAsRead => 'Marquer comme lu';

  @override
  String get followDisableNotifications => 'Désactiver les notifications';

  @override
  String get followEnableNotifications => 'Activer les notifications';

  @override
  String get followRename => 'Renommer';

  @override
  String followNewPosts(num count, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label nouveaux posts',
      one: '1 nouveau post',
    );
    return '$_temp0';
  }

  @override
  String followSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
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
      other: '$count entrées',
      one: '1 entrée',
    );
    return '$_temp0';
  }

  @override
  String historyEntriesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées d\'historique supprimées',
      one: '1 entrée d\'historique supprimée',
    );
    return '$_temp0';
  }

  @override
  String get historyClear => 'Effacer l\'historique';

  @override
  String get historyClearSubtitle => 'Supprimer toutes les entrées';

  @override
  String get historyClearConfirm => 'Effacer l\'historique ?';

  @override
  String get historyClearConfirmBody =>
      'Toutes les entrées de l\'historique seront définitivement supprimées. Cette action est irréversible.';

  @override
  String get historyClearAction => 'Effacer';

  @override
  String get historyLimit => 'Limite d\'historique';

  @override
  String historyLimitEnableBody(String amount, num months) {
    return 'Activer la limite d\'historique signifie que toutes les entrées au-delà de $amount et toutes les entrées de plus de $months mois sont automatiquement supprimées.';
  }

  @override
  String get historyLimitTitle => 'Limiter l\'historique';

  @override
  String historyLimitOn(String amount, num months) {
    return 'Limité aux $months derniers mois ou aux $amount dernières entrées.';
  }

  @override
  String get historyLimitOff => 'l\'historique est illimité';

  @override
  String get historyEntries => 'Entrées';

  @override
  String get historyType => 'Type';

  @override
  String get historyItems => 'Éléments';

  @override
  String get historySearches => 'Recherches';

  @override
  String get historyWikis => 'Wikis';

  @override
  String get historyUsers => 'Utilisateurs';

  @override
  String get historyEmpty => 'Ton historique est vide';

  @override
  String get historyFailedToLoad => 'Échec du chargement de l\'historique';

  @override
  String get historyNoDescription => 'aucune description';

  @override
  String get historyHotPosts => 'Posts populaires';

  @override
  String historyLinkPost(num id) {
    return 'Post #$id';
  }

  @override
  String historyLinkUser(num id) {
    return 'Utilisateur #$id';
  }

  @override
  String historyLinkWiki(num id) {
    return 'Wiki #$id';
  }

  @override
  String historyLinkUserByName(String id) {
    return '$id - Utilisateur';
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
  String get poolEmpty => 'Aucun pool';

  @override
  String get poolFailedToLoadPools => 'Échec du chargement des pools';

  @override
  String get poolTitle => 'Titre du pool';

  @override
  String get poolInfoPosts => 'posts';

  @override
  String get poolInfoId => 'id';

  @override
  String get poolInfoActivity => 'activité';

  @override
  String get poolInfoActive => 'actif';

  @override
  String get poolInfoInactive => 'inactif';

  @override
  String get poolInfoCreated => 'créé';

  @override
  String get poolInfoUpdated => 'mis à jour';

  @override
  String poolCopiedId(num id) {
    return 'id du pool #$id copié';
  }

  @override
  String poolLink(num id) {
    return 'Pool #$id';
  }

  @override
  String get poolFailedToLoadPool => 'Échec du chargement du pool';

  @override
  String get poolNotFound => 'Pool introuvable';

  @override
  String get poolOrder => 'Ordre du pool';

  @override
  String get poolOldestFirst => 'Du plus ancien';

  @override
  String get poolNewestFirst => 'Du plus récent';

  @override
  String get poolReaderMode => 'Mode lecture du pool';

  @override
  String get poolReaderLargeImages => 'grandes images';

  @override
  String get poolReaderNormalGrid => 'grille normale';

  @override
  String get topicsTitle => 'Sujets';

  @override
  String get topicHideTagEdits => 'Masquer les modifications de tags';

  @override
  String get topicTagEditsHidden => 'masquées';

  @override
  String get topicTagEditsVisible => 'visibles';

  @override
  String topicLink(num id) {
    return 'Sujet #$id';
  }

  @override
  String get topicFailedToLoadTopic => 'Échec du chargement du sujet';

  @override
  String get topicNotFound => 'Sujet introuvable';

  @override
  String get topicEmpty => 'Aucun sujet';

  @override
  String get topicFailedToLoadTopics => 'Échec du chargement des sujets';

  @override
  String get topicInfoReplies => 'réponses';

  @override
  String get topicInfoId => 'id';

  @override
  String topicCopiedId(num id) {
    return 'id du sujet #$id copié';
  }

  @override
  String get topicInfoLocked => 'verrouillé';

  @override
  String get topicInfoYes => 'oui';

  @override
  String get topicInfoNo => 'non';

  @override
  String get topicInfoCreated => 'créé';

  @override
  String get topicInfoUpdated => 'mis à jour';

  @override
  String get filterTags => 'Tags';

  @override
  String get loginRequired =>
      'Tu dois être connecté pour effectuer cette action.';

  @override
  String get actionChooseIdentity => 'Choisir une identité';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateYesterday => 'Hier';

  @override
  String detailCommentsButton(num count) {
    return 'COMMENTAIRES ($count)';
  }

  @override
  String get detailFile => 'Fichier';

  @override
  String get detailSources => 'Sources';

  @override
  String get detailNoSources => 'aucune source';

  @override
  String get detailChildren => 'Enfants';

  @override
  String get detailDeletion => 'Motif de suppression';

  @override
  String get detailBlacklisted => 'Blacklisté';

  @override
  String get detailNoArtist => 'aucun artiste';

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
    return 'id du post #$id copié';
  }

  @override
  String postUpvoteFailed(num id) {
    return 'Échec de l\'upvote du post #$id';
  }

  @override
  String postDownvoteFailed(num id) {
    return 'Échec du downvote du post #$id';
  }

  @override
  String postAddFavoriteFailed(num id) {
    return 'Échec de l\'ajout du post #$id aux favoris';
  }

  @override
  String postRemoveFavoriteFailed(num id) {
    return 'Échec du retrait du post #$id des favoris';
  }

  @override
  String get editorSection => 'Section';

  @override
  String get editorQuote => 'Citation';

  @override
  String get editorCode => 'Code';

  @override
  String get editorSpoiler => 'Spoiler';

  @override
  String get editorBold => 'Gras';

  @override
  String get editorItalic => 'Italique';

  @override
  String get editorUnderlined => 'Souligné';

  @override
  String get editorStrikethrough => 'Barré';

  @override
  String get editorPreviewPlaceholder => 'ton texte ici';

  @override
  String get editorWrite => 'Écrire';

  @override
  String get editorPreview => 'Aperçu';

  @override
  String get editorTypeHere => 'écris ici...';

  @override
  String get tagNoTags => 'aucun tag';

  @override
  String get tagFailedToLoadTags => 'échec du chargement des tags';

  @override
  String get tagUnableToRetrieveWiki =>
      'impossible de récupérer l\'entrée wiki';

  @override
  String get tagNoWikiEntry => 'aucune entrée wiki';

  @override
  String get tagCategoryGeneral => 'Général';

  @override
  String get tagCategorySpecies => 'Espèce';

  @override
  String get tagCategoryCharacter => 'Personnage';

  @override
  String get tagCategoryCopyright => 'Copyright';

  @override
  String get tagCategoryMeta => 'Meta';

  @override
  String get tagCategoryLore => 'Lore';

  @override
  String get tagCategoryArtist => 'Artiste';

  @override
  String get tagCategoryContributor => 'Contributeur';

  @override
  String get tagCategoryInvalid => 'Invalide';

  @override
  String editDescriptionTitle(num postId) {
    return 'Description de #$postId';
  }

  @override
  String get editDescriptionHint => 'Saisis la description du post...';

  @override
  String get editInvalidNumber => 'Format de nombre invalide';

  @override
  String get editInvalidParent => 'Post parent invalide';

  @override
  String get editParentIdLabel => 'ID du parent (facultatif)';

  @override
  String get editParentIdHint => 'ID du post parent';

  @override
  String get editReasonLabel => 'Motif de modification (facultatif)';

  @override
  String get editReasonHint => 'Pourquoi modifies-tu ce post ?';

  @override
  String editSourcesTitle(num postId) {
    return 'Sources de #$postId';
  }

  @override
  String get editTagsHint => 'tags séparés par des espaces';

  @override
  String editTagPreviewFailed(String error) {
    return 'Erreur de chargement de l\'aperçu des tags : $error';
  }

  @override
  String get editTagStatusNew => 'nouveau';

  @override
  String get editTagStatusInvalid => 'invalide';

  @override
  String get editTagStatusEmpty => 'vide';

  @override
  String get editTagStatusUnderused => 'sous-utilisé';

  @override
  String reportCommentSuccess(num id) {
    return 'Commentaire #$id signalé';
  }

  @override
  String reportCommentFailed(num id) {
    return 'Échec du signalement du commentaire #$id';
  }

  @override
  String reportReplySuccess(num id) {
    return 'Réponse #$id signalée';
  }

  @override
  String reportReplyFailed(num id) {
    return 'Échec du signalement de la réponse #$id';
  }

  @override
  String reportUserSuccess(num id) {
    return 'Utilisateur #$id signalé';
  }

  @override
  String reportUserFailed(num id) {
    return 'Échec du signalement de l\'utilisateur #$id';
  }

  @override
  String reportPostSuccess(num id) {
    return 'Post #$id signalé';
  }

  @override
  String reportPostFailed(num id) {
    return 'Échec du signalement du post #$id';
  }

  @override
  String get reportTypeRequired => 'Le type ne peut pas être vide';

  @override
  String get reportReason => 'Motif';

  @override
  String get reportReasonRequired => 'Le motif ne peut pas être vide';

  @override
  String get reportSubmitted => 'Signalement envoyé';

  @override
  String get reportSubmitFailed => 'Échec de l\'envoi du signalement';

  @override
  String get reportTypeRating => 'Abus de notation';

  @override
  String get reportTypeFile => 'Fichier malveillant';

  @override
  String get reportTypeSource => 'Source malveillante';

  @override
  String get reportTypeDescription => 'Abus de description';

  @override
  String get reportTypeNote => 'Abus de note';

  @override
  String get reportTypeTagging => 'Abus de tags';

  @override
  String get reportTypeRatingBody =>
      'La notation du post a été définie sur une valeur incorrecte.';

  @override
  String get reportTypeFileBody =>
      'Le fichier contient du code malveillant ou une archive de fichiers cachée. Ceci ne concerne pas ce qui est représenté dans l\'image elle-même.';

  @override
  String get reportTypeSourceBody =>
      'Une ou plusieurs sources listées mènent vers des pages malveillantes ou du contenu payant.';

  @override
  String get reportTypeDescriptionBody =>
      'La description contient du contenu malveillant, ou a été modifiée pour inclure du matériel abusif.';

  @override
  String get reportTypeNoteBody =>
      'Les notes de ce post sont erronées, harcelantes ou autrement abusives.';

  @override
  String get reportTypeTaggingBody =>
      'Un ou plusieurs tags de ce post ne sont pas valides, ou un ou plusieurs tags valides ont été retirés de ce post.';

  @override
  String flagPostSuccess(num id) {
    return 'Post #$id flagué';
  }

  @override
  String flagPostFailed(num id) {
    return 'Échec du flag du post #$id';
  }

  @override
  String get flagParentId => 'ID du parent';

  @override
  String get flagParentIdRequired => 'L\'ID du parent ne peut pas être vide';

  @override
  String get flagParentIdInvalid => 'L\'ID du parent doit être un nombre';

  @override
  String get flagTypeUploadingGuidelines =>
      'Ne respecte pas les règles de mise en ligne';

  @override
  String get flagTypeYoungHuman =>
      'Personnage humanoïde mineur dans une situation explicite';

  @override
  String get flagTypeDnpArtist =>
      'L\'artiste de ce post est sur la liste « Ne pas publier »';

  @override
  String get flagTypePayContent =>
      'Contenu payant, commercial ou sur abonnement';

  @override
  String get flagTypeTrace => 'Décalque du travail d\'un autre artiste';

  @override
  String get flagTypePreviouslyDeleted => 'Déjà supprimé auparavant';

  @override
  String get flagTypeRealPorn => 'Pornographie réelle';

  @override
  String get flagTypeCorrupt =>
      'Le fichier est corrompu, endommagé ou défectueux';

  @override
  String get flagTypeInferior =>
      'Doublon ou version inférieure d\'un autre post';

  @override
  String get flagTypeUploadingGuidelinesBody =>
      'Ce post ne répond pas aux standards du site, que ce soit pour sa valeur artistique, sa qualité d\'image, sa pertinence ou autre chose.\nGarde à l\'esprit que tes préférences personnelles n\'ont pas à entrer en ligne de compte. Si le contenu d\'un post te pose problème, utilise simplement [[e621:blacklist|blacklist]].';

  @override
  String get flagTypeYoungHumanBody =>
      'Les posts mettant en scène des personnages humains ou humanoïdes de manière sexuelle ou dans du nu explicite ne sont pas acceptés sur ce site.';

  @override
  String get flagTypeDnpArtistBody =>
      'Certains artistes ont demandé que leurs œuvres ne soient pas publiées sur ce site et ont obtenu le statut [[avoid_posting|Do Not Post]].\nCe statut s\'accompagne parfois de conditions ; voir [[conditional_dnp]] pour plus d\'informations';

  @override
  String get flagTypePayContentBody =>
      'Nous n\'hébergeons aucun contenu paysite ni commercial, d\'aucune sorte. Cela inclut les fuites Patreon, les reposts depuis des sites de piratage, etc.';

  @override
  String get flagTypeTraceBody =>
      'Les images décalquées sur l\'œuvre d\'autres artistes ne sont pas acceptées sur ce site. S\'inspirer d\'une référence, c\'est acceptable, mais copier carrément le travail de quelqu\'un d\'autre ne l\'est pas.\nMerci de laisser plus d\'informations dans les commentaires, ou d\'ajouter simplement l\'œuvre originale comme parent du post si elle est hébergée sur ce site.';

  @override
  String get flagTypePreviouslyDeletedBody =>
      'Les posts sont généralement supprimés pour une bonne raison, et republier du contenu supprimé n\'est pas acceptable.\nMerci de laisser plus d\'informations dans les commentaires, ou d\'ajouter simplement le post original comme parent de ce post.';

  @override
  String get flagTypeRealPornBody =>
      'Les posts contenant de la pornographie réelle ne sont pas acceptés sur ce site. Aucune exception.\nNote que les images contenant des photographies non érotiques sont acceptables.';

  @override
  String get flagTypeCorruptBody =>
      'Quelque chose ne fonctionne pas tout à fait avec ce post. Il peut s\'agir d\'une vidéo cassée ou d\'une image corrompue.\nQuoi qu\'il en soit, pour éviter toute confusion, merci d\'expliquer la situation dans les commentaires.';

  @override
  String get flagTypeInferiorBody =>
      'Une version supérieure de ce post existe déjà sur le site.\nCela peut inclure des images de meilleure qualité visuelle (plus grandes, moins compressées), mais aussi des versions « corrigées », dont les erreurs visuelles ont été prises en compte par l\'artiste.\nNote que les éditions et les versions alternatives ne relèvent pas de cette catégorie.';

  @override
  String get taskCancelAll => 'Tout annuler';

  @override
  String get taskClearDone => 'Effacer les terminées';

  @override
  String get taskClearSelection => 'Effacer la sélection';

  @override
  String get taskCancel => 'Annuler';

  @override
  String get taskDismiss => 'Ignorer';

  @override
  String get taskNoTasks => 'Aucune tâche';

  @override
  String get taskFailedToLoadTasks => 'Échec du chargement des tâches';

  @override
  String taskSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
    );
    return '$_temp0';
  }

  @override
  String get taskGroupActive => 'En cours';

  @override
  String get taskGroupFailed => 'Échouées';

  @override
  String get taskActionDownload => 'téléchargement';

  @override
  String get taskActionFavorite => 'ajout aux favoris';

  @override
  String get taskActionUnfavorite => 'retrait des favoris';

  @override
  String get taskDownloadRunning => 'téléchargement';

  @override
  String get taskFavoriteRunning => 'ajout aux favoris';

  @override
  String get taskUnfavoriteRunning => 'retrait des favoris';

  @override
  String get taskDownloadCompleted => 'téléchargé';

  @override
  String get taskFavoriteCompleted => 'ajouté aux favoris';

  @override
  String get taskUnfavoriteCompleted => 'retiré des favoris';

  @override
  String taskQueuedTo(String action) {
    return '$action en file d\'attente';
  }

  @override
  String taskFailedTo(String action) {
    return '$action échoué';
  }

  @override
  String taskCanceledAction(String action) {
    return '$action annulé';
  }

  @override
  String taskTileTitle(String label, num id) {
    return 'Post #$id : $label';
  }

  @override
  String followNotificationBody(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'a $count nouveaux posts !',
      one: 'a un nouveau post !',
    );
    return '$_temp0';
  }

  @override
  String get followNotificationSummary => 'Nouveaux posts !';

  @override
  String get followChannelName => 'Tags suivis';

  @override
  String get followChannelDescription =>
      'Notifications pour les tags que tu suis';

  @override
  String get hostUnavailableTitle => 'Hôte indisponible';

  @override
  String hostUnavailableBody(String host) {
    return 'Il semble que $host ne soit pas disponible !';
  }

  @override
  String get hostUnavailableResolveHint =>
      'Résous le problème dans la fenêtre de navigateur qui va s\'ouvrir.\n\nLes cookies du captcha Cloudflare seront enregistrés.';

  @override
  String get hostUnavailableResolve => 'Résoudre';

  @override
  String hostUnavailableWaitBody(String host) {
    return '\nMerci d\'attendre que $host règle la situation de son côté.';
  }

  @override
  String get downloadChooseFolder => 'Choisir un dossier';

  @override
  String get searchFilterTitle => 'Filtres';

  @override
  String get searchFilterQueryLabel => 'Requête actuelle :';

  @override
  String get dtextParsingFailed => 'Échec de l\'analyse DText';

  @override
  String get filteredShow => 'Afficher';

  @override
  String get filteredHide => 'Masquer';

  @override
  String get selectOptions => 'Sélectionner des options...';

  @override
  String get databaseNotE1547 =>
      'Ce fichier n\'est pas une base de données e1547.';

  @override
  String get adultGateTitle => 'Vérification express';

  @override
  String get adultGateBody =>
      'Cette application t\'emmène directement sur e621, une communauté artistique strictement réservée aux adultes. Merci de confirmer que tu as l\'âge légal là où tu vis — on te fait confiance, nos avocats un peu moins.';

  @override
  String get adultGateConfirm => 'Bien sûr — j\'ai 18 ans ou plus';

  @override
  String get adultGateDeny => 'Remène-moi en lieu sûr';

  @override
  String get databaseExportPasswordLabel => 'Mot de passe (facultatif)';

  @override
  String get databaseExportPasswordHint =>
      'Chiffre le fichier exporté. Laisse vide pour un fichier en clair, non chiffré.';

  @override
  String get databaseImportEncryptedTitle => 'Base de données chiffrée';

  @override
  String get databaseImportPasswordLabel => 'Mot de passe';

  @override
  String get databaseImportWrongPassword =>
      'Mot de passe incorrect ou fichier corrompu.';

  @override
  String get actionUnlock => 'DÉVERROUILLER';
}
