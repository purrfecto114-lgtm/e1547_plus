// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'e1547';

  @override
  String get failedToLoad => 'Falha ao carregar';

  @override
  String get nothingToSeeHere => 'Nada para ver aqui';

  @override
  String get loading => 'Carregando...';

  @override
  String get actionCancel => 'CANCELAR';

  @override
  String get actionOk => 'OK';

  @override
  String get actionTryAgain => 'Tentar novamente';

  @override
  String get actionDownload => 'BAIXAR';

  @override
  String get actionImport => 'IMPORTAR';

  @override
  String get actionExport => 'EXPORTAR';

  @override
  String get actionUndo => 'Desfazer';

  @override
  String get actionRestartNow => 'REINICIAR AGORA';

  @override
  String get failedToLoadSuggestions => 'Falha ao carregar as sugestões';

  @override
  String selectionItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get actionAbort => 'Abortar';

  @override
  String get actionSelectAll => 'Selecionar tudo';

  @override
  String fileSavedAs(String name) {
    return 'Arquivo salvo como $name';
  }

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get saveFile => 'Salvar arquivo';

  @override
  String get filterTooltip => 'Filtrar';

  @override
  String get rangeInvalidFormat => 'Formato inválido';

  @override
  String itemProgress(num current, num total) {
    return 'Item $current/$total';
  }

  @override
  String get taskCancelled => 'Tarefa cancelada';

  @override
  String taskFailedAt(num index) {
    return 'Falhou no item $index';
  }

  @override
  String get taskDone => 'Concluído';

  @override
  String get failedToInitialize => 'Falha ao inicializar';

  @override
  String get navHome => 'Início';

  @override
  String get navHot => 'Populares';

  @override
  String get navSearch => 'Pesquisar';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navTimeline => 'Linha do tempo';

  @override
  String get navSubscriptions => 'Inscrições';

  @override
  String get navBookmarks => 'Marcadores';

  @override
  String get navPools => 'Pools';

  @override
  String get navForum => 'Fórum';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navTasks => 'Tarefas';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navAbout => 'Sobre';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get sectionAccount => 'Conta';

  @override
  String get sectionUser => 'Usuário';

  @override
  String get sectionAppearance => 'Aparência';

  @override
  String get sectionInteractions => 'Interações';

  @override
  String get sectionSecurity => 'Segurança';

  @override
  String get sectionDevelopment => 'Desenvolvimento';

  @override
  String get settingsBlacklist => 'Blacklist';

  @override
  String tagsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags bloqueadas',
      one: '1 tag bloqueada',
    );
    return '$_temp0';
  }

  @override
  String get settingsFollows => 'Inscrições';

  @override
  String searchesFollowed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pesquisas seguidas',
      one: '1 pesquisa seguida',
    );
    return '$_temp0';
  }

  @override
  String get settingsHistory => 'Histórico';

  @override
  String pagesVisited(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas visitadas',
      one: '1 página visitada',
    );
    return '$_temp0';
  }

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeDark => 'escuro';

  @override
  String get themeAmoled => 'amoled';

  @override
  String get themeLight => 'claro';

  @override
  String get themeBlue => 'azul';

  @override
  String get themeSystem => 'sistema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get settingsTileSize => 'Tamanho dos mosaicos';

  @override
  String get settingsQuilt => 'Mosaico';

  @override
  String get gridTitle => 'Grade';

  @override
  String get quiltSquare => 'mosaicos quadrados';

  @override
  String get quiltVertical => 'mosaicos se expandem verticalmente';

  @override
  String get settingsPostInfo => 'Informações do post';

  @override
  String get postInfoShown => 'informações nos mosaicos';

  @override
  String get postInfoHidden => 'apenas imagens';

  @override
  String get settingsDownloadLocation => 'Local de download';

  @override
  String get settingsUpvoteFavorites => 'Upvote ao favoritar';

  @override
  String get upvoteFavoritesOn => 'upvote e favorito';

  @override
  String get upvoteFavoritesOff => 'somente favorito';

  @override
  String get settingsVideoVolume => 'Volume do vídeo';

  @override
  String get videoMuted => 'silenciado';

  @override
  String get videoWithSound => 'com som';

  @override
  String videoSeekSeconds(Object seconds) {
    return '$seconds segundos';
  }

  @override
  String get settingsVideoResolution => 'Resolução do vídeo';

  @override
  String get videoResStandard => '480p';

  @override
  String get videoResHigh => '720p';

  @override
  String get videoResFull => '1080p';

  @override
  String get videoResUltra => '4K';

  @override
  String get videoResSource => 'Original';

  @override
  String get videoResNote =>
      'Os vídeos nem sempre estão disponíveis em tamanhos padrão; é usado o tamanho mais próximo da seleção.';

  @override
  String get settingsAutoLoadVideos => 'Carregar vídeos automaticamente';

  @override
  String get autoLoadVideosOn => 'vídeos carregam ao navegar';

  @override
  String get autoLoadVideosOff => 'vídeos carregam ao reproduzir';

  @override
  String get autoLoadVideosDialogTitle => 'Carregar vídeos automaticamente?';

  @override
  String get autoLoadVideosDialogBody =>
      'Os vídeos serão baixados por completo enquanto você navega e pesquisa. Isso pode consumir muitos dados em conexões limitadas.';

  @override
  String get videoQuality => 'Qualidade do vídeo';

  @override
  String get settingsSecureDisplay => 'Exibição segura';

  @override
  String get secureDisplayOn => 'tela protegida';

  @override
  String get secureDisplayOff => 'tela visível';

  @override
  String get settingsIncognitoKeyboard => 'Teclado anônimo';

  @override
  String get enabled => 'ativado';

  @override
  String get disabled => 'desativado';

  @override
  String get settingsPinLock => 'Bloqueio por PIN';

  @override
  String get pinEnabled => 'PIN ativado';

  @override
  String get pinDisabled => 'PIN desativado';

  @override
  String get settingsBiometricLock => 'Bloqueio biométrico';

  @override
  String get biometricsEnabled => 'biometria ativada';

  @override
  String get biometricsDisabled => 'biometria desativada';

  @override
  String get settingsDeveloperMode => 'Modo desenvolvedor';

  @override
  String get devOptionsShown => 'opções visíveis';

  @override
  String get devOptionsHidden => 'opções ocultas';

  @override
  String errorsLogged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count erros registrados',
      one: '1 erro registrado',
    );
    return '$_temp0';
  }

  @override
  String get settingsDatabase => 'Banco de dados';

  @override
  String get databaseExporting => 'Exportando banco de dados...';

  @override
  String get databaseExported => 'Banco de dados exportado com sucesso';

  @override
  String get databaseExportFailed => 'Falha ao exportar';

  @override
  String get databaseExport => 'Exportar';

  @override
  String get databaseImporting => 'Importando banco de dados...';

  @override
  String databaseInvalidFile(String error) {
    return 'Arquivo de banco de dados inválido: $error';
  }

  @override
  String databaseImportFailed(String error) {
    return 'Falha na importação: $error';
  }

  @override
  String get databaseImportTitle => 'Importar banco de dados';

  @override
  String get databaseRestartTitle => 'Reinicialização necessária';

  @override
  String get databaseRestartBody =>
      'O app precisa ser reiniciado para aplicar as mudanças.';

  @override
  String get databaseImport => 'Importar';

  @override
  String get lockEnterPin => 'Digite o PIN';

  @override
  String get lockEnterNewPin => 'Digite o novo PIN';

  @override
  String get lockConfirmNewPin => 'Confirme o novo PIN';

  @override
  String get lockFailedAuth => 'Falha na autenticação';

  @override
  String get lockPleaseAuth => 'Autentique-se';

  @override
  String get lockRetry => 'Tentar novamente';

  @override
  String get lockBiometricReason => 'Autentique-se para desbloquear.';

  @override
  String get lockBiometricFailure => 'Falha grave na autenticação biométrica';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get updaterFetching => 'Buscando atualizações...';

  @override
  String get updaterCheckFailed => 'Falha ao verificar atualizações';

  @override
  String get updaterNewest => 'Você tem a versão mais recente';

  @override
  String updaterNewer(String version) {
    return 'Há uma versão mais recente disponível: $version';
  }

  @override
  String get updaterNewerHeader => 'Há uma versão mais recente disponível: ';

  @override
  String get aboutExperimentalPlatform => 'Plataforma experimental';

  @override
  String get aboutExperimentalBody =>
      'Esta plataforma não tem suporte. Espere bugs e recursos ausentes.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutUpstream => 'Projeto original';

  @override
  String get aboutUpstreamBody => 'Este app é um fork de clragon/e1547';

  @override
  String get aboutDiscord => 'Discord';

  @override
  String get aboutForum => 'Fórum';

  @override
  String aboutForumTopic(num id) {
    return 'Tópico do e621 #$id';
  }

  @override
  String get aboutWebsite => 'Site';

  @override
  String get aboutKofi => 'Ko-fi';

  @override
  String get aboutEmail => 'E-mail';

  @override
  String get aboutPlaystore => 'Play Store';

  @override
  String get aboutDonors => 'Apoiadores';

  @override
  String get aboutDonorsThanks =>
      'Obrigado por ajudar a manter o desenvolvimento!';

  @override
  String get aboutNoDonors => 'Ainda sem apoiadores';

  @override
  String get aboutDonorsFailed => 'Falha ao carregar os apoiadores';

  @override
  String get aboutDonorsNotListed => 'Não está na lista? Fale com a gente!';

  @override
  String get developerUnlocked => 'Agora você é um desenvolvedor!';

  @override
  String get databaseErrorLoading => 'Erro ao carregar o banco de dados';

  @override
  String get databaseUnknownSize => 'Desconhecido';

  @override
  String get databaseExportTitle => 'Exportar banco de dados';

  @override
  String get databaseExportSubtitle =>
      'Salve uma cópia de segurança do seu banco de dados';

  @override
  String get databaseImportSubtitle =>
      'Substituir o banco de dados atual pelo importado';

  @override
  String get databaseImportWarning =>
      'Isso substituirá seu banco de dados atual. \nTodos os dados serão perdidos. Isso não pode ser desfeito!';

  @override
  String get databaseExportSanitizedBody =>
      'O arquivo exportado não conterá seus logins nem suas chaves de API.\nTodo o resto está incluído: contas, hosts, histórico, inscrições e tarefas.';

  @override
  String get databaseImportNewerFile =>
      'Este arquivo foi criado por uma versão mais recente do app e não pode ser importado.';

  @override
  String get databaseImportSanitized =>
      'Por segurança, os logins salvos foram removidos do arquivo importado.';

  @override
  String databaseImportHostsWarning(String hosts) {
    return 'Atenção: o arquivo importado contém contas em outros sites: $hosts';
  }

  @override
  String get databaseImportCancelled => 'Importação cancelada';

  @override
  String get postsTitle => 'Posts';

  @override
  String favoritesOf(String user) {
    return 'Favoritos de $user';
  }

  @override
  String get favoritesUnavailable =>
      'Favoritos não estão disponíveis para usuários anônimos';

  @override
  String get favoriteOrder => 'Ordem dos favoritos';

  @override
  String get orderAdded => 'ordem de adição';

  @override
  String get orderId => 'ordem por ID';

  @override
  String get postStateDeleted => 'excluído';

  @override
  String get postStateUnsupported => 'não suportado';

  @override
  String get postStateUnavailable => 'indisponível';

  @override
  String get menuShare => 'Compartilhar';

  @override
  String get menuDownload => 'Baixar';

  @override
  String get menuBrowse => 'Abrir no navegador';

  @override
  String get menuEdit => 'Editar';

  @override
  String get menuComment => 'Comentar';

  @override
  String get menuReport => 'Denunciar';

  @override
  String get menuFlag => 'Sinalizar';

  @override
  String get actionOpen => 'Abrir';

  @override
  String get actionFollow => 'Seguir';

  @override
  String get actionUnfollow => 'Deixar de seguir';

  @override
  String get actionMute => 'Silenciar';

  @override
  String get actionNotify => 'Notificar';

  @override
  String get actionBookmark => 'Marcar';

  @override
  String get actionUnbookmark => 'Desmarcar';

  @override
  String get actionBlock => 'Bloquear';

  @override
  String get actionUnblock => 'Desbloquear';

  @override
  String get actionRemove => 'Remover';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionSubtract => 'Subtrair';

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
  String get noPosts => 'Nenhum post';

  @override
  String get failedToLoadPosts => 'Falha ao carregar os posts';

  @override
  String get offlineBanner => 'Você está offline. Exibindo dados em cache.';

  @override
  String get offlineNoData => 'Você está offline';

  @override
  String postListPageSummary(num count, Object page) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '$count post',
    );
    return 'Página $page · $_temp0';
  }

  @override
  String get postListPageLimit =>
      'Você atingiu o limite de páginas do servidor. Refine os termos da sua pesquisa.';

  @override
  String get postListJumpToPage => 'Ir para a página';

  @override
  String get postListJumpPageLabel => 'Número da página';

  @override
  String postListJumpPageRange(Object max) {
    return 'Digite um número de página entre 1 e $max';
  }

  @override
  String get postDeletedOverlay => 'O post foi excluído';

  @override
  String get postUnavailableOverlay => 'O post está indisponível';

  @override
  String get postBlacklistedOverlay => 'O post está na blacklist';

  @override
  String unsupportedFileType(String ext) {
    return 'Arquivos $ext não são suportados';
  }

  @override
  String get loginRequiredEdit =>
      'Você precisa estar logado para editar posts!';

  @override
  String get loginRequiredComment => 'Você precisa estar logado para comentar!';

  @override
  String get loginRequiredReport =>
      'Você precisa estar logado para denunciar posts!';

  @override
  String get loginRequiredFlag =>
      'Você precisa estar logado para sinalizar posts!';

  @override
  String postsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts bloqueados',
      one: '1 post bloqueado',
    );
    return '$_temp0';
  }

  @override
  String get blacklistUpdateFailed => 'Falha ao atualizar a blacklist!';

  @override
  String get blacklistAddTag => 'Adicionar tag';

  @override
  String get blacklistEditTag => 'Editar tag';

  @override
  String get denylistEntryDeleted => 'Entrada da blacklist removida';

  @override
  String get blacklistEmpty => 'Sua blacklist está vazia';

  @override
  String get menuDelete => 'Excluir';

  @override
  String get filterScore => 'Pontuação';

  @override
  String get filterFavoriteCount => 'Número de favoritos';

  @override
  String get filterSortBy => 'Ordenar por';

  @override
  String get filterNew => 'Novos';

  @override
  String get filterRank => 'Rank';

  @override
  String get filterRandom => 'Aleatório';

  @override
  String get filterDefault => 'Padrão';

  @override
  String get filterRating => 'Classificação';

  @override
  String get filterSafe => 'Seguro';

  @override
  String get filterQuestionable => 'Questionável';

  @override
  String get filterExplicit => 'Explícito';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterPool => 'Pool';

  @override
  String get filterHasPool => 'Com pool';

  @override
  String get filterChild => 'Filho';

  @override
  String get filterIsChildPost => 'É post filho';

  @override
  String get filterParent => 'Pai';

  @override
  String get filterIsParentPost => 'É post pai';

  @override
  String get filterUploadDate => 'Data de upload';

  @override
  String get filterLastDay => 'Último dia';

  @override
  String get filterLastWeek => 'Última semana';

  @override
  String get filterLastMonth => 'Último mês';

  @override
  String get filterLastYear => 'Último ano';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterActive => 'Ativo';

  @override
  String get filterPending => 'Pendente';

  @override
  String get filterDeleted => 'Excluído';

  @override
  String get filterFlagged => 'Sinalizado';

  @override
  String get filterAny => 'Qualquer';

  @override
  String get filterFileType => 'Tipo de arquivo';

  @override
  String get filterUploader => 'Uploader';

  @override
  String get filterWidth => 'Largura';

  @override
  String get filterHeight => 'Altura';

  @override
  String get filterTagCount => 'Número de tags';

  @override
  String get filterTrue => 'Sim';

  @override
  String get filterFalse => 'Não';

  @override
  String get filterImages => 'Imagens';

  @override
  String get filterVideos => 'Vídeos';

  @override
  String get filterTitleContains => 'Título contém';

  @override
  String get filterCategory => 'Categoria';

  @override
  String get filterGeneral => 'Geral';

  @override
  String get filterSiteBugReports =>
      'Relatórios de bugs e pedidos de recursos do site';

  @override
  String get filterTagWikiProjects => 'Projetos de tags/wikis e dúvidas';

  @override
  String get filterTagAliasSuggestions =>
      'Sugestões de alias e implicações de tags';

  @override
  String get filterArtTalk => 'Conversa sobre arte';

  @override
  String get filterOffTopic => 'Off topic';

  @override
  String get filterE621Tools => 'Ferramentas e aplicativos do e621';

  @override
  String get filterNewestFirst => 'Mais recentes primeiro';

  @override
  String get filterOldestFirst => 'Mais antigos primeiro';

  @override
  String get filterSticky => 'Fixado';

  @override
  String get filterIsSticky => 'Está fixado';

  @override
  String get filterLocked => 'Fechado';

  @override
  String get filterIsLocked => 'Está fechado';

  @override
  String get filterDescription => 'Descrição';

  @override
  String get filterCreator => 'Criador';

  @override
  String get filterIsActive => 'Está ativo';

  @override
  String get filterSeries => 'Série';

  @override
  String get filterCollection => 'Coleção';

  @override
  String get filterName => 'Nome';

  @override
  String get filterCreated => 'Criado';

  @override
  String get filterUpdated => 'Atualizado';

  @override
  String get filterPostCount => 'Número de posts';

  @override
  String postUpdateFailed(num id) {
    return 'Falha ao atualizar o post #$id';
  }

  @override
  String postUpdated(num id) {
    return 'Post #$id atualizado';
  }

  @override
  String get failedToLoadPost => 'Falha ao carregar o post';

  @override
  String get postNotFound => 'Post não encontrado';

  @override
  String get commentsTitle => 'Comentários';

  @override
  String commentsOfPost(num postId) {
    return 'Comentários do post #$postId';
  }

  @override
  String get commentOrder => 'Ordem dos comentários';

  @override
  String get noComments => 'Nenhum comentário';

  @override
  String get failedToLoadComments => 'Falha ao carregar os comentários';

  @override
  String commentTitle(num id) {
    return 'Comentário #$id';
  }

  @override
  String get failedToLoadComment => 'Falha ao carregar o comentário';

  @override
  String get commentNotFound => 'Comentário não encontrado';

  @override
  String commentEditorTitle(num postId) {
    return 'Comentário do post #$postId';
  }

  @override
  String get commentSendFailed => 'Falha ao enviar o comentário!';

  @override
  String get commentSent => 'Comentário enviado!';

  @override
  String get commentHidden => 'Este comentário está oculto';

  @override
  String commentUpvoteFailed(num id) {
    return 'Falha ao dar upvote no comentário #$id';
  }

  @override
  String commentDownvoteFailed(num id) {
    return 'Falha ao dar downvote no comentário #$id';
  }

  @override
  String get commentLoginRequiredEdit =>
      'Você precisa estar logado para editar comentários!';

  @override
  String get commentLoginRequiredReply =>
      'Você precisa estar logado para responder comentários!';

  @override
  String get commentLoginRequiredReport =>
      'Você precisa estar logado para denunciar comentários!';

  @override
  String commentCopiedId(num id) {
    return 'ID do comentário #$id copiado';
  }

  @override
  String get warningUserWarned =>
      'O usuário recebeu uma advertência por esta mensagem';

  @override
  String get warningUserRecorded =>
      'O usuário recebeu um registro por esta mensagem';

  @override
  String get warningUserBanned => 'O usuário foi banido por esta mensagem';

  @override
  String get repliesTitle => 'Respostas';

  @override
  String get replyOrder => 'Ordem das respostas';

  @override
  String get noReplies => 'Nenhuma resposta';

  @override
  String get failedToLoadReplies => 'Falha ao carregar as respostas';

  @override
  String replyTitle(num id) {
    return 'Resposta #$id';
  }

  @override
  String get failedToLoadReply => 'Falha ao carregar a resposta';

  @override
  String get replyNotFound => 'Resposta não encontrada';

  @override
  String replyEditorTitle(num topicId) {
    return 'Resposta no tópico #$topicId';
  }

  @override
  String get replySendFailed => 'Falha ao enviar a resposta!';

  @override
  String get replySent => 'Resposta enviada!';

  @override
  String get replyHidden => 'Esta resposta está oculta';

  @override
  String get replyLoginRequiredEdit =>
      'Você precisa estar logado para editar respostas!';

  @override
  String get replyLoginRequiredReply =>
      'Você precisa estar logado para responder!';

  @override
  String get replyLoginRequiredReport =>
      'Você precisa estar logado para denunciar respostas!';

  @override
  String replyCopiedId(num id) {
    return 'ID da resposta #$id copiado';
  }

  @override
  String get menuReply => 'Responder';

  @override
  String get menuCopyId => 'Copiar ID';

  @override
  String get menuRefresh => 'Atualizar';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionShow => 'Mostrar';

  @override
  String get actionHide => 'Ocultar';

  @override
  String get actionCannotBeUndone => 'Esta ação não pode ser desfeita.';

  @override
  String get info => 'Info';

  @override
  String wikiTitle(String idOrTitle) {
    return 'Wiki $idOrTitle';
  }

  @override
  String get failedToLoadWiki => 'Falha ao carregar a wiki';

  @override
  String get wikiNotFound => 'Wiki não encontrada';

  @override
  String wikiCopiedId(num id) {
    return 'ID da wiki #$id copiado';
  }

  @override
  String get wikiInfoId => 'id';

  @override
  String get wikiInfoAlias => 'alias';

  @override
  String get wikiInfoCreated => 'criado';

  @override
  String get wikiInfoUpdated => 'atualizado';

  @override
  String get wikiInfoLocked => 'bloqueada';

  @override
  String get wikiInfoYes => 'sim';

  @override
  String get wikiInfoNo => 'não';

  @override
  String userTitle(String idOrName) {
    return 'Usuário $idOrName';
  }

  @override
  String get failedToLoadUser => 'Falha ao carregar o usuário';

  @override
  String get userNotFound => 'Usuário não encontrado';

  @override
  String get userUploads => 'Uploads';

  @override
  String get userLoginRequiredReport =>
      'Você precisa estar logado para denunciar usuários!';

  @override
  String get userComission => 'Encomendas';

  @override
  String get userId => 'id';

  @override
  String get userJoined => 'membro desde';

  @override
  String get userRank => 'cargo';

  @override
  String get userPosts => 'posts';

  @override
  String get userEdits => 'edições';

  @override
  String get userFavorites => 'favoritos';

  @override
  String get userComments => 'comentários';

  @override
  String get userForum => 'fórum';

  @override
  String userCopiedId(num id) {
    return 'ID do usuário #$id copiado';
  }

  @override
  String get logsTitle => 'Logs';

  @override
  String logsTitleDate(String date) {
    return 'Logs - $date';
  }

  @override
  String selectionLogsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count logs',
    );
    return '$_temp0';
  }

  @override
  String selectionLogsFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos de log',
    );
    return '$_temp0';
  }

  @override
  String get logsLevels => 'Níveis';

  @override
  String get logsRecording => 'Gravação';

  @override
  String get logsVerbose => 'Detalhado';

  @override
  String get logsVerboseAll => 'todos os níveis registrados';

  @override
  String logsVerboseMinimum(String level) {
    return '$level e acima';
  }

  @override
  String get logFilesTitle => 'Arquivos de log';

  @override
  String get failedToLoadLogFiles => 'Falha ao carregar os arquivos de log!';

  @override
  String get noLogFiles => 'Nenhum arquivo de log disponível!';

  @override
  String get logsLive => 'Ao vivo';

  @override
  String get noLogs => 'Nenhum log';

  @override
  String get failedToReadLog => 'Falha ao ler o log';

  @override
  String get noErrorsLogged => 'Nenhum erro registrado';

  @override
  String logsErrorsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count erros',
      one: '1 erro',
    );
    return '$_temp0';
  }

  @override
  String get logsAll => 'Todos os logs';

  @override
  String get logsDismissAll => 'Dispensar todos';

  @override
  String logsDeleteTitle(num count) {
    return 'Excluir $count arquivos de log?';
  }

  @override
  String get identityAccounts => 'Contas';

  @override
  String get identityAdd => 'Adicionar conta';

  @override
  String get identityEdit => 'Editar conta';

  @override
  String get identityRemoveTitle => 'Remover conta?';

  @override
  String get identityRemoveBody =>
      'Todos os dados dela serão removidos permanentemente, incluindo histórico e inscrições.';

  @override
  String get identityAnonymous => 'Anônimo';

  @override
  String get identityDuplicate =>
      'Você já tem uma identidade com este host e este nome de usuário.';

  @override
  String identityLoginFailed(String reason) {
    return 'Falha ao fazer login. \n$reason';
  }

  @override
  String get identityLoginCheckDetails =>
      'Verifique sua conexão de rede e seus dados de login';

  @override
  String get identitySite => 'Site';

  @override
  String get identityHostRequired => 'Informe a URL do host.';

  @override
  String get identityHostInvalid => 'URL do host inválida';

  @override
  String get identityHostReadOnly =>
      'O site não pode ser alterado. Adicione uma nova conta para usar outro.';

  @override
  String get identityUsernameLabel => 'Nome de usuário';

  @override
  String get identityUsernameRequired => 'Informe um nome de usuário.';

  @override
  String get identityApikeyLabel => 'Chave de API';

  @override
  String get identityApikeyHelp => 'Onde encontro minha chave de API?';

  @override
  String get identityApikeyRequired =>
      'Informe uma chave de API.\nex.: 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identityApikeyInvalid =>
      'A chave de API é uma sequência de 24 ou 32 caracteres entre A-z e 0-9\nex.: 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identitySignupPrompt => 'Não tem uma conta? Cadastre-se aqui';

  @override
  String get identityHostHint => 'O site que hospeda sua conta e seus posts.';

  @override
  String get identitySignIn => 'Entrar';

  @override
  String get identityGuest => 'Visitante';

  @override
  String get identityLogin => 'Fazer login';

  @override
  String get identityBrowseAnonymously => 'Navegar anonimamente';

  @override
  String identityConnecting(String host, String username) {
    return 'Conectando a $host como $username…';
  }

  @override
  String identityActivateFailed(Object error) {
    return 'Falha ao ativar a identidade: $error';
  }

  @override
  String traitsActivateFailed(Object error) {
    return 'Falha ao ativar as preferências: $error';
  }

  @override
  String get failedToLoadIdentities => 'Falha ao carregar as identidades';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingBack => 'Voltar';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String onboardingWelcomeTitle(String app) {
    return 'Bem-vindo ao $app';
  }

  @override
  String get onboardingWelcomeBody => 'Um navegador de boorus sofisticado.';

  @override
  String get onboardingThemeTitle => 'Escolha um estilo';

  @override
  String get onboardingThemeBody =>
      'Experimente. Você pode mudar de ideia quando quiser.';

  @override
  String get onboardingLoginTitle => 'Conecte uma conta';

  @override
  String get onboardingLanguageTitle => 'Escolha um idioma';

  @override
  String get followAddToSubscriptions => 'Adicionar às inscrições';

  @override
  String get followNoSubscriptions => 'Nenhuma inscrição';

  @override
  String get followFailedToLoadSubscriptions =>
      'Falha ao carregar as inscrições';

  @override
  String get followAddToBookmarks => 'Adicionar aos marcadores';

  @override
  String get followNoBookmarks => 'Nenhum marcador';

  @override
  String get followFailedToLoadBookmarks => 'Falha ao carregar os marcadores';

  @override
  String get followUnseenPosts => 'posts não vistos';

  @override
  String followMarkPostsSeen(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'marcar $count posts como vistos',
      one: 'marcar 1 post como visto',
    );
    return '$_temp0';
  }

  @override
  String get followNoUnseenPosts => 'nenhum post não visto';

  @override
  String get followShowUnseenFirst => 'mostrar não vistos primeiro';

  @override
  String get followFilteringUnseen => 'filtrando não vistos';

  @override
  String get followAllPostsShown => 'mostrando todos os posts';

  @override
  String get followForceSync => 'Forçar sincronização';

  @override
  String get followSyncAllFollows => 'sincronizar todas as inscrições';

  @override
  String followSyncingFollows(String progress) {
    return 'sincronizando inscrições... $progress';
  }

  @override
  String get followEditorTitle => 'Editar inscrições';

  @override
  String get followSubscribe => 'Inscrever-se';

  @override
  String get followEditPrompt => 'Editar inscrição';

  @override
  String get followTitlePrompt => 'Nome da inscrição';

  @override
  String get followMarkAsRead => 'Marcar como lido';

  @override
  String get followDisableNotifications => 'Desativar notificações';

  @override
  String get followEnableNotifications => 'Ativar notificações';

  @override
  String get followRename => 'Renomear';

  @override
  String followNewPosts(num count, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label novos posts',
      one: '1 novo post',
    );
    return '$_temp0';
  }

  @override
  String followSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inscrições',
      one: '1 inscrição',
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
      other: '$count entradas',
      one: '1 entrada',
    );
    return '$_temp0';
  }

  @override
  String historyEntriesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas do histórico excluídas',
      one: 'Entrada do histórico excluída',
    );
    return '$_temp0';
  }

  @override
  String get historyClear => 'Limpar histórico';

  @override
  String get historyClearSubtitle => 'Excluir todas as entradas';

  @override
  String get historyClearConfirm => 'Limpar histórico?';

  @override
  String get historyClearConfirmBody =>
      'Todas as entradas do histórico serão excluídas permanentemente. Esta ação não pode ser desfeita.';

  @override
  String get historyClearAction => 'Limpar';

  @override
  String get historyLimit => 'Limite do histórico';

  @override
  String historyLimitEnableBody(String amount, num months) {
    return 'Ativar o limite do histórico significa que todas as entradas além de $amount e todas as entradas com mais de $months meses são excluídas automaticamente.';
  }

  @override
  String get historyLimitTitle => 'Limitar histórico';

  @override
  String historyLimitOn(String amount, num months) {
    return 'Limitado a entradas mais recentes que $months meses ou a menos de $amount entradas.';
  }

  @override
  String get historyLimitOff => 'o histórico é infinito';

  @override
  String get historyEntries => 'Entradas';

  @override
  String get historyType => 'Tipo';

  @override
  String get historyItems => 'Itens';

  @override
  String get historySearches => 'Pesquisas';

  @override
  String get historyWikis => 'Wikis';

  @override
  String get historyUsers => 'Usuários';

  @override
  String get historyEmpty => 'Seu histórico está vazio';

  @override
  String get historyFailedToLoad => 'Falha ao carregar o histórico';

  @override
  String get historyNoDescription => 'sem descrição';

  @override
  String get historyHotPosts => 'Posts populares';

  @override
  String historyLinkPost(num id) {
    return 'Post #$id';
  }

  @override
  String historyLinkUser(num id) {
    return 'Usuário #$id';
  }

  @override
  String historyLinkWiki(num id) {
    return 'Wiki #$id';
  }

  @override
  String historyLinkUserByName(String id) {
    return '$id - Usuário';
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
  String get poolEmpty => 'Nenhum pool';

  @override
  String get poolFailedToLoadPools => 'Falha ao carregar os pools';

  @override
  String get poolTitle => 'Título do pool';

  @override
  String get poolInfoPosts => 'posts';

  @override
  String get poolInfoId => 'id';

  @override
  String get poolInfoActivity => 'atividade';

  @override
  String get poolInfoActive => 'ativo';

  @override
  String get poolInfoInactive => 'inativo';

  @override
  String get poolInfoCreated => 'criado';

  @override
  String get poolInfoUpdated => 'atualizado';

  @override
  String poolCopiedId(num id) {
    return 'ID do pool #$id copiado';
  }

  @override
  String poolLink(num id) {
    return 'Pool #$id';
  }

  @override
  String get poolFailedToLoadPool => 'Falha ao carregar o pool';

  @override
  String get poolNotFound => 'Pool não encontrado';

  @override
  String get poolOrder => 'Ordem do pool';

  @override
  String get poolOldestFirst => 'Mais antigos primeiro';

  @override
  String get poolNewestFirst => 'Mais recentes primeiro';

  @override
  String get poolReaderMode => 'Modo de leitura do pool';

  @override
  String get poolReaderLargeImages => 'imagens grandes';

  @override
  String get poolReaderNormalGrid => 'grade normal';

  @override
  String get topicsTitle => 'Tópicos';

  @override
  String get topicHideTagEdits => 'Ocultar edições de tags';

  @override
  String get topicTagEditsHidden => 'ocultas';

  @override
  String get topicTagEditsVisible => 'visíveis';

  @override
  String topicLink(num id) {
    return 'Tópico #$id';
  }

  @override
  String get topicFailedToLoadTopic => 'Falha ao carregar o tópico';

  @override
  String get topicNotFound => 'Tópico não encontrado';

  @override
  String get topicEmpty => 'Nenhum tópico';

  @override
  String get topicFailedToLoadTopics => 'Falha ao carregar os tópicos';

  @override
  String get topicInfoReplies => 'respostas';

  @override
  String get topicInfoId => 'id';

  @override
  String topicCopiedId(num id) {
    return 'ID do tópico #$id copiado';
  }

  @override
  String get topicInfoLocked => 'fechado';

  @override
  String get topicInfoYes => 'sim';

  @override
  String get topicInfoNo => 'não';

  @override
  String get topicInfoCreated => 'criado';

  @override
  String get topicInfoUpdated => 'atualizado';

  @override
  String get filterTags => 'Tags';

  @override
  String get loginRequired =>
      'Você precisa estar logado para realizar esta ação.';

  @override
  String get actionChooseIdentity => 'Escolher identidade';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String detailCommentsButton(num count) {
    return 'COMENTÁRIOS ($count)';
  }

  @override
  String get detailFile => 'Arquivo';

  @override
  String get detailSources => 'Fontes';

  @override
  String get detailNoSources => 'sem fontes';

  @override
  String get detailChildren => 'Posts filhos';

  @override
  String get detailDeletion => 'Exclusão';

  @override
  String get detailBlacklisted => 'Na blacklist';

  @override
  String get detailNoArtist => 'sem artista';

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
    return 'ID do post #$id copiado';
  }

  @override
  String postUpvoteFailed(num id) {
    return 'Falha ao dar upvote no post #$id';
  }

  @override
  String postDownvoteFailed(num id) {
    return 'Falha ao dar downvote no post #$id';
  }

  @override
  String postAddFavoriteFailed(num id) {
    return 'Falha ao adicionar o post #$id aos favoritos';
  }

  @override
  String postRemoveFavoriteFailed(num id) {
    return 'Falha ao remover o post #$id dos favoritos';
  }

  @override
  String get editorSection => 'Seção';

  @override
  String get editorQuote => 'Citação';

  @override
  String get editorCode => 'Código';

  @override
  String get editorSpoiler => 'Spoiler';

  @override
  String get editorBold => 'Negrito';

  @override
  String get editorItalic => 'Itálico';

  @override
  String get editorUnderlined => 'Sublinhado';

  @override
  String get editorStrikethrough => 'Tachado';

  @override
  String get editorPreviewPlaceholder => 'seu texto aqui';

  @override
  String get editorWrite => 'Escrever';

  @override
  String get editorPreview => 'Prévia';

  @override
  String get editorTypeHere => 'digite aqui...';

  @override
  String get tagNoTags => 'sem tags';

  @override
  String get tagFailedToLoadTags => 'falha ao carregar as tags';

  @override
  String get tagUnableToRetrieveWiki =>
      'não foi possível obter a entrada da wiki';

  @override
  String get tagNoWikiEntry => 'sem entrada na wiki';

  @override
  String get tagCategoryGeneral => 'Geral';

  @override
  String get tagCategorySpecies => 'Espécie';

  @override
  String get tagCategoryCharacter => 'Personagem';

  @override
  String get tagCategoryCopyright => 'Copyright';

  @override
  String get tagCategoryMeta => 'Meta';

  @override
  String get tagCategoryLore => 'Lore';

  @override
  String get tagCategoryArtist => 'Artista';

  @override
  String get tagCategoryContributor => 'Contribuidor';

  @override
  String get tagCategoryInvalid => 'Inválido';

  @override
  String editDescriptionTitle(num postId) {
    return 'Descrição do post #$postId';
  }

  @override
  String get editDescriptionHint => 'Digite a descrição do post...';

  @override
  String get editInvalidNumber => 'Formato de número inválido';

  @override
  String get editInvalidParent => 'Post pai inválido';

  @override
  String get editParentIdLabel => 'ID do post pai (opcional)';

  @override
  String get editParentIdHint => 'ID do post pai';

  @override
  String get editReasonLabel => 'Motivo da edição (opcional)';

  @override
  String get editReasonHint => 'Por que você está editando este post?';

  @override
  String editSourcesTitle(num postId) {
    return 'Fontes do post #$postId';
  }

  @override
  String get editTagsHint => 'tags separadas por espaços';

  @override
  String editTagPreviewFailed(String error) {
    return 'Erro ao carregar a prévia da tag: $error';
  }

  @override
  String get editTagStatusNew => 'nova';

  @override
  String get editTagStatusInvalid => 'inválida';

  @override
  String get editTagStatusEmpty => 'vazia';

  @override
  String get editTagStatusUnderused => 'pouco usada';

  @override
  String reportCommentSuccess(num id) {
    return 'Comentário #$id denunciado';
  }

  @override
  String reportCommentFailed(num id) {
    return 'Falha ao denunciar o comentário #$id';
  }

  @override
  String reportReplySuccess(num id) {
    return 'Resposta #$id denunciada';
  }

  @override
  String reportReplyFailed(num id) {
    return 'Falha ao denunciar a resposta #$id';
  }

  @override
  String reportUserSuccess(num id) {
    return 'Usuário #$id denunciado';
  }

  @override
  String reportUserFailed(num id) {
    return 'Falha ao denunciar o usuário #$id';
  }

  @override
  String reportPostSuccess(num id) {
    return 'Post #$id denunciado';
  }

  @override
  String reportPostFailed(num id) {
    return 'Falha ao denunciar o post #$id';
  }

  @override
  String get reportTypeRequired => 'O tipo não pode ficar vazio';

  @override
  String get reportReason => 'Motivo';

  @override
  String get reportReasonRequired => 'O motivo não pode ficar vazio';

  @override
  String get reportSubmitted => 'Denúncia enviada';

  @override
  String get reportSubmitFailed => 'Falha ao enviar a denúncia';

  @override
  String get reportTypeRating => 'Abuso de classificação';

  @override
  String get reportTypeFile => 'Arquivo malicioso';

  @override
  String get reportTypeSource => 'Fonte maliciosa';

  @override
  String get reportTypeDescription => 'Abuso de descrição';

  @override
  String get reportTypeNote => 'Abuso de notas';

  @override
  String get reportTypeTagging => 'Abuso de tags';

  @override
  String get reportTypeRatingBody =>
      'A classificação da publicação foi definida com um valor incorreto.';

  @override
  String get reportTypeFileBody =>
      'O arquivo contém código malicioso ou um arquivo oculto embutido. Não se refere ao conteúdo retratado na imagem em si.';

  @override
  String get reportTypeSourceBody =>
      'Uma ou mais das fontes listadas levam a páginas maliciosas ou a conteúdo pago.';

  @override
  String get reportTypeDescriptionBody =>
      'A descrição contém conteúdo malicioso ou foi editada para conter material abusivo.';

  @override
  String get reportTypeNoteBody =>
      'As notas deste post estão erradas, são assediantes ou abusivas de alguma outra forma.';

  @override
  String get reportTypeTaggingBody =>
      'Uma ou mais tags deste post não são válidas, ou uma ou mais tags válidas foram removidas deste post.';

  @override
  String flagPostSuccess(num id) {
    return 'Post #$id sinalizado';
  }

  @override
  String flagPostFailed(num id) {
    return 'Falha ao sinalizar o post #$id';
  }

  @override
  String get flagParentId => 'ID do post pai';

  @override
  String get flagParentIdRequired => 'O ID do post pai não pode ficar vazio';

  @override
  String get flagParentIdInvalid => 'O ID do post pai deve ser um número';

  @override
  String get flagTypeUploadingGuidelines => 'Não atende às diretrizes de envio';

  @override
  String get flagTypeYoungHuman =>
      'Personagem humanoide jovem em situação explícita';

  @override
  String get flagTypeDnpArtist =>
      'O artista deste post está na lista de não publicar';

  @override
  String get flagTypePayContent => 'Conteúdo pago, comercial ou de assinatura';

  @override
  String get flagTypeTrace => 'Traçado sobre a obra de outro artista';

  @override
  String get flagTypePreviouslyDeleted => 'Excluído anteriormente';

  @override
  String get flagTypeRealPorn => 'Pornografia real';

  @override
  String get flagTypeCorrupt =>
      'O arquivo está corrompido, quebrado ou simplesmente não funciona';

  @override
  String get flagTypeInferior => 'Duplicata ou versão inferior de outro post';

  @override
  String get flagTypeUploadingGuidelinesBody =>
      'Este post não atende aos padrões do site, seja pelo valor artístico, pela qualidade da imagem, pela relevância ou por outro motivo.\nTenha em mente que suas preferências pessoais não influenciam nisso. Se você não gosta do conteúdo de um post, simplesmente o adicione à [[e621:blacklist|blacklist]].';

  @override
  String get flagTypeYoungHumanBody =>
      'Posts com personagens humanos ou humanoides retratados de forma sexual ou nudes explícitos não são aceitos neste site.';

  @override
  String get flagTypeDnpArtistBody =>
      'Alguns artistas pediram que suas obras não fossem publicadas neste site e receberam o status de [[avoid_posting|Do Not Post]].\nÀs vezes, esse status vem acompanhado de condições; veja [[conditional_dnp]] para mais informações';

  @override
  String get flagTypePayContentBody =>
      'Não hospedamos conteúdo pago ou comercial de nenhum tipo. Isso inclui vazamentos de Patreon, republicações de sites de pirataria e afins.';

  @override
  String get flagTypeTraceBody =>
      'Imagens traçadas sobre a arte de outros artistas não são aceitas neste site. Usar referências é ok, mas copiar diretamente o trabalho de outra pessoa, não.\nPor favor, deixe mais informações nos comentários, ou simplesmente adicione a obra original como post pai deste, caso ela esteja hospedada neste site.';

  @override
  String get flagTypePreviouslyDeletedBody =>
      'Posts geralmente são removidos por um bom motivo, e reenviar conteúdo excluído não é aceitável.\nPor favor, deixe mais informações nos comentários, ou simplesmente adicione o post original como post pai deste.';

  @override
  String get flagTypeRealPornBody =>
      'Posts com pornografia da vida real não são aceitos neste site. Sem exceções.\nNote que imagens com fotografias não eróticas são aceitas.';

  @override
  String get flagTypeCorruptBody =>
      'Algo neste post não funciona direito. Pode ser um vídeo quebrado ou uma imagem corrompida.\nDe qualquer forma, para evitar confusão, explique a situação nos comentários.';

  @override
  String get flagTypeInferiorBody =>
      'Já existe uma versão superior deste post no site.\nIsso pode incluir imagens com melhor qualidade visual (maiores, menos comprimidas), mas também versões \"corrigidas\", com os erros visuais ajustados pelo artista.\nNote que edições e versões alternativas não se enquadram nesta categoria.';

  @override
  String get taskCancelAll => 'Cancelar tudo';

  @override
  String get taskClearDone => 'Limpar concluídas';

  @override
  String get taskClearSelection => 'Limpar seleção';

  @override
  String get taskCancel => 'Cancelar';

  @override
  String get taskDismiss => 'Dispensar';

  @override
  String get taskNoTasks => 'Nenhuma tarefa';

  @override
  String get taskFailedToLoadTasks => 'Falha ao carregar as tarefas';

  @override
  String taskSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarefas',
      one: '1 tarefa',
    );
    return '$_temp0';
  }

  @override
  String get taskGroupActive => 'Ativas';

  @override
  String get taskGroupFailed => 'Falhas';

  @override
  String get taskActionDownload => 'baixar';

  @override
  String get taskActionFavorite => 'favoritar';

  @override
  String get taskActionUnfavorite => 'desfavoritar';

  @override
  String get taskDownloadRunning => 'baixando';

  @override
  String get taskFavoriteRunning => 'favoritando';

  @override
  String get taskUnfavoriteRunning => 'desfavoritando';

  @override
  String get taskDownloadCompleted => 'baixado';

  @override
  String get taskFavoriteCompleted => 'favoritado';

  @override
  String get taskUnfavoriteCompleted => 'desfavoritado';

  @override
  String taskQueuedTo(String action) {
    return 'na fila para $action';
  }

  @override
  String taskFailedTo(String action) {
    return 'falha ao $action';
  }

  @override
  String taskCanceledAction(String action) {
    return '$action cancelado';
  }

  @override
  String taskTileTitle(String label, num id) {
    return 'Post #$id: $label';
  }

  @override
  String followNotificationBody(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tem $count novos posts!',
      one: 'tem um novo post!',
    );
    return '$_temp0';
  }

  @override
  String get followNotificationSummary => 'Novos posts!';

  @override
  String get followChannelName => 'Tags seguidas';

  @override
  String get followChannelDescription => 'Notificações das tags que você segue';

  @override
  String get hostUnavailableTitle => 'Host indisponível';

  @override
  String hostUnavailableBody(String host) {
    return 'Parece que $host não está disponível!';
  }

  @override
  String get hostUnavailableResolveHint =>
      'Resolva o problema na janela do navegador a seguir.\n\nOs cookies do captcha do Cloudflare serão salvos.';

  @override
  String get hostUnavailableResolve => 'Resolver';

  @override
  String hostUnavailableWaitBody(String host) {
    return '\nAguarde $host resolver a situação por lá.';
  }

  @override
  String get downloadChooseFolder => 'Escolher uma pasta';

  @override
  String get searchFilterTitle => 'Filtros';

  @override
  String get searchFilterQueryLabel => 'Pesquisa atual:';

  @override
  String get dtextParsingFailed => 'Falha ao interpretar o DText';

  @override
  String get filteredShow => 'Mostrar';

  @override
  String get filteredHide => 'Ocultar';

  @override
  String get selectOptions => 'Selecionar opções...';

  @override
  String get databaseNotE1547 =>
      'Este arquivo não é um banco de dados do e1547.';

  @override
  String get adultGateTitle => 'Uma rápida checagem de realidade';

  @override
  String get adultGateBody =>
      'Este app leva direto ao e621, uma comunidade de arte estritamente para adultos. Confirme que você tem idade legal onde vive — nós confiamos em você, são só os nossos advogados que não.';

  @override
  String get adultGateConfirm => 'Claro — tenho 18 anos ou mais';

  @override
  String get adultGateDeny => 'Me leva de volta';

  @override
  String get databaseExportPasswordLabel => 'Senha (opcional)';

  @override
  String get databaseExportPasswordHint =>
      'Criptografa o arquivo exportado. Deixe vazio para um arquivo simples, sem criptografia.';

  @override
  String get databaseImportEncryptedTitle => 'Banco de dados criptografado';

  @override
  String get databaseImportPasswordLabel => 'Senha';

  @override
  String get databaseImportWrongPassword =>
      'Senha incorreta ou arquivo corrompido.';

  @override
  String get actionUnlock => 'DESBLOQUEAR';
}
