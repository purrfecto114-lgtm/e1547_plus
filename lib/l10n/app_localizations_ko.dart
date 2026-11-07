// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'e1547';

  @override
  String get failedToLoad => '로드 실패';

  @override
  String get nothingToSeeHere => '여기는 볼 거 없어요';

  @override
  String get loading => '로딩 중...';

  @override
  String get actionCancel => '취소';

  @override
  String get actionOk => '확인';

  @override
  String get actionTryAgain => '다시 시도';

  @override
  String get actionDownload => '다운로드';

  @override
  String get actionImport => '가져오기';

  @override
  String get actionExport => '내보내기';

  @override
  String get actionUndo => '실행 취소';

  @override
  String get actionRestartNow => '지금 재시작';

  @override
  String get failedToLoadSuggestions => '제안 로드 실패';

  @override
  String selectionItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목',
      one: '1개 항목',
    );
    return '$_temp0';
  }

  @override
  String get actionAbort => '중단';

  @override
  String get actionSelectAll => '전체 선택';

  @override
  String fileSavedAs(String name) {
    return '$name(으)로 저장됨';
  }

  @override
  String get copiedToClipboard => '클립보드에 복사됨';

  @override
  String get saveFile => '파일 저장';

  @override
  String get filterTooltip => '필터';

  @override
  String get rangeInvalidFormat => '잘못된 형식';

  @override
  String itemProgress(num current, num total) {
    return '항목 $current/$total';
  }

  @override
  String get taskCancelled => '작업이 취소됨';

  @override
  String taskFailedAt(num index) {
    return '항목 $index에서 실패';
  }

  @override
  String get taskDone => '완료';

  @override
  String get failedToInitialize => '초기화 실패';

  @override
  String get navHome => '홈';

  @override
  String get navHot => '인기';

  @override
  String get navSearch => '검색';

  @override
  String get navFavorites => '즐겨찾기';

  @override
  String get navTimeline => '타임라인';

  @override
  String get navSubscriptions => '구독';

  @override
  String get navBookmarks => '북마크';

  @override
  String get navPools => '풀';

  @override
  String get navForum => '포럼';

  @override
  String get navHistory => '기록';

  @override
  String get navTasks => '작업';

  @override
  String get navSettings => '설정';

  @override
  String get navAbout => '정보';

  @override
  String get settingsTitle => '설정';

  @override
  String get sectionAccount => '계정';

  @override
  String get sectionUser => '사용자';

  @override
  String get sectionAppearance => '외관';

  @override
  String get sectionInteractions => '상호작용';

  @override
  String get sectionSecurity => '보안';

  @override
  String get sectionDevelopment => '개발';

  @override
  String get settingsBlacklist => '블랙리스트';

  @override
  String tagsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 태그 차단됨',
      one: '1개 태그 차단됨',
    );
    return '$_temp0';
  }

  @override
  String get settingsFollows => '팔로우';

  @override
  String searchesFollowed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 검색 팔로우됨',
      one: '1개 검색 팔로우됨',
    );
    return '$_temp0';
  }

  @override
  String get settingsHistory => '기록';

  @override
  String pagesVisited(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 페이지 방문',
      one: '1개 페이지 방문',
    );
    return '$_temp0';
  }

  @override
  String get settingsTheme => '테마';

  @override
  String get themeDark => '다크';

  @override
  String get themeAmoled => '아모레드';

  @override
  String get themeLight => '라이트';

  @override
  String get themeBlue => '블루';

  @override
  String get themeSystem => '시스템';

  @override
  String get settingsLanguage => '언어';

  @override
  String get languageSystemDefault => '시스템 기본값';

  @override
  String get settingsHandedness => '선호 손';

  @override
  String get handRight => '오른손';

  @override
  String get handLeft => '왼손';

  @override
  String get settingsHandednessHint => '버튼과 빠른 작업이 이 손이 닿는 범위 내로 이동합니다.';

  @override
  String get thumbnailQuality => '썸네일 화질';

  @override
  String get settingsQuilt => '퀼트';

  @override
  String get gridTitle => '그리드';

  @override
  String get quiltSquare => '타일이 정사각형';

  @override
  String get quiltVertical => '타일이 세로로 확장';

  @override
  String get settingsPostInfo => '게시물 정보';

  @override
  String get postInfoShown => '타일에 정보 표시';

  @override
  String get postInfoHidden => '이미지 타일만';

  @override
  String get settingsDownloadLocation => '다운로드 위치';

  @override
  String get settingsUpvoteFavorites => '즐겨찾기에 추천';

  @override
  String get upvoteFavoritesOn => '추천하고 즐겨찾기';

  @override
  String get upvoteFavoritesOff => '즐겨찾기만';

  @override
  String get settingsVideoVolume => '동영상 볼륨';

  @override
  String get videoMuted => '음소거';

  @override
  String get videoWithSound => '소리 있음';

  @override
  String videoSeekSeconds(Object seconds) {
    return '$seconds초';
  }

  @override
  String get videoResSource => '원본';

  @override
  String get videoResNote => '동영상은 항상 표준 크기로 제공되지 않습니다; 선택에 가장 가까운 크기가 사용됩니다.';

  @override
  String get qualityLow => '낮음';

  @override
  String get qualityMedium => '보통';

  @override
  String get qualityHigh => '높음';

  @override
  String get settingsAutoLoadVideos => '자동으로 동영상 로드';

  @override
  String get autoLoadVideosOn => '탐색 시 동영상 로드';

  @override
  String get autoLoadVideosOff => '재생 시 동영상 로드';

  @override
  String get autoLoadVideosDialogTitle => '동영상을 자동으로 로드할까요?';

  @override
  String get autoLoadVideosDialogBody =>
      '탐색 및 검색 시 전체 동영상이 다운로드됩니다. 이는 유료 연결에서 많은 데이터를 소모할 수 있습니다.';

  @override
  String get videoQuality => '동영상 품질';

  @override
  String get settingsSecureDisplay => '보안 디스플레이';

  @override
  String get secureDisplayOn => '화면 보호됨';

  @override
  String get secureDisplayOff => '화면 표시됨';

  @override
  String get settingsIncognitoKeyboard => '시크릿 키보드';

  @override
  String get enabled => '활성화됨';

  @override
  String get disabled => '비활성화됨';

  @override
  String get settingsPinLock => 'PIN 잠금';

  @override
  String get pinEnabled => 'PIN 활성화됨';

  @override
  String get pinDisabled => 'PIN 비활성화됨';

  @override
  String get settingsBiometricLock => '생체 인식 잠금';

  @override
  String get biometricsEnabled => '생체 인식 활성화됨';

  @override
  String get biometricsDisabled => '생체 인식 비활성화됨';

  @override
  String get biometricsUnavailable => '생체 인식 하드웨어가 없습니다';

  @override
  String get biometricsNotEnrolled => '지문 센서가 있지만 등록된 지문이 없습니다';

  @override
  String get settingsUpdaterBeta => '최신 업데이트';

  @override
  String get updaterBetaOn => '안정판 및 프리릴리스 버전';

  @override
  String get updaterBetaOff => '안정판만';

  @override
  String get settingsDeveloperMode => '개발자 모드';

  @override
  String get devOptionsShown => '옵션 표시됨';

  @override
  String get devOptionsHidden => '옵션 숨겨짐';

  @override
  String errorsLogged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 오류 기록됨',
      one: '1개 오류 기록됨',
    );
    return '$_temp0';
  }

  @override
  String get settingsDatabase => '데이터베이스';

  @override
  String get databaseExporting => '데이터베이스 내보내는 중...';

  @override
  String get databaseExported => '데이터베이스 내보내기 성공';

  @override
  String get databaseExportFailed => '내보내기 실패';

  @override
  String get databaseExport => '내보내기';

  @override
  String get databaseImporting => '데이터베이스 가져오는 중...';

  @override
  String databaseInvalidFile(String error) {
    return '잘못된 데이터베이스 파일: $error';
  }

  @override
  String databaseImportFailed(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String get databaseImportTitle => '데이터베이스 가져오기';

  @override
  String get databaseRestartTitle => '재시작 필요';

  @override
  String get databaseRestartBody => '변경 사항을 적용하려면 앱을 다시 시작해야 합니다.';

  @override
  String get databaseImport => '가져오기';

  @override
  String get lockEnterPin => 'PIN 입력';

  @override
  String get lockEnterNewPin => '새 PIN 입력';

  @override
  String get lockConfirmNewPin => '새 PIN 확인';

  @override
  String get lockFailedAuth => '인증 실패';

  @override
  String get lockPleaseAuth => '인증해주세요';

  @override
  String get lockRetry => '재시도';

  @override
  String get lockBiometricReason => '잠금을 해제하려면 인증해주세요.';

  @override
  String get lockBiometricFailure => '생체 인증 심각한 오류';

  @override
  String get lockWrongPin => 'PIN이 올바르지 않습니다';

  @override
  String get lockPinMismatch => 'PIN이 일치하지 않습니다';

  @override
  String get aboutVersion => '버전';

  @override
  String get updaterFetching => '업데이트 확인 중...';

  @override
  String get updaterCheckFailed => '업데이트 확인 실패';

  @override
  String get updaterNewest => '최신 버전입니다';

  @override
  String updaterNewer(String version) {
    return '새 버전이 있습니다: $version';
  }

  @override
  String get updaterNewerHeader => '새 버전이 있습니다: ';

  @override
  String get aboutExperimentalPlatform => '실험적 플랫폼';

  @override
  String get aboutExperimentalBody =>
      '이 플랫폼은 지원되지 않습니다. 버그와 누락된 기능이 있을 수 있습니다.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutUpstream => '원본 프로젝트';

  @override
  String get aboutUpstreamBody => '이 앱은 clragon/e1547의 포크 버전입니다';

  @override
  String get aboutDiscord => 'Discord';

  @override
  String get aboutForum => '포럼';

  @override
  String aboutForumTopic(num id) {
    return 'e621 스레드 #$id';
  }

  @override
  String get aboutWebsite => '웹사이트';

  @override
  String get aboutKofi => 'Ko-fi';

  @override
  String get aboutEmail => '이메일';

  @override
  String get aboutPlaystore => 'Play Store';

  @override
  String get aboutDonors => '후원자';

  @override
  String get aboutDonorsThanks => '개발을 계속하는 데 도와주셔서 감사합니다!';

  @override
  String get aboutNoDonors => '후원자가 아직 없습니다';

  @override
  String get aboutDonorsFailed => '후원자 정보를 가져오지 못했습니다';

  @override
  String get aboutDonorsNotListed => '목록에 없으신가요? 연락주세요!';

  @override
  String get developerUnlocked => '이제 개발자입니다!';

  @override
  String get databaseErrorLoading => '데이터베이스 로드 오류';

  @override
  String get databaseUnknownSize => '알 수 없음';

  @override
  String get databaseExportTitle => '데이터베이스 내보내기';

  @override
  String get databaseExportSubtitle => '데이터베이스 백업 복사본 저장';

  @override
  String get databaseImportSubtitle => '가져온 데이터베이스로 현재 데이터베이스 교체';

  @override
  String get databaseImportWarning =>
      '이것은 현재 데이터베이스를 교체합니다. \n모든 데이터가 손실됩니다. 이는 취소할 수 없습니다!';

  @override
  String get databaseExportSanitizedBody =>
      '내보낸 파일에는 로그인 정보나 API 키가 포함되지 않습니다.\n계정, 호스트, 기록, 팔로우 및 작업을 포함한 모든 다른 데이터가 포함됩니다.';

  @override
  String get databaseImportNewerFile => '이 파일은 더 새 버전의 앱에서 생성되어 가져올 수 없습니다.';

  @override
  String get databaseImportSanitized => '안을 위해, 가져온 파일에서 저장된 로그인 정보가 제거되었습니다.';

  @override
  String databaseImportHostsWarning(String hosts) {
    return '경고: 가져온 파일에 다른 사이트의 계정이 포함되어 있습니다: $hosts';
  }

  @override
  String get databaseImportCancelled => '가져오기 취소됨';

  @override
  String get postsTitle => '게시물';

  @override
  String favoritesOf(String user) {
    return '$user의 즐겨찾기';
  }

  @override
  String get favoritesUnavailable => '익명 사용자는 즐겨찾기를 사용할 수 없습니다';

  @override
  String get favoriteOrder => '즐겨찾기 순서';

  @override
  String get orderAdded => '추가된 순서';

  @override
  String get orderId => 'ID 순서';

  @override
  String get postStateDeleted => '삭제됨';

  @override
  String get postStateUnsupported => '지원되지 않음';

  @override
  String get postStateUnavailable => '사용 불가';

  @override
  String get menuShare => '공유';

  @override
  String get menuDownload => '다운로드';

  @override
  String get menuBrowse => '찾아보기';

  @override
  String get menuEdit => '편집';

  @override
  String get menuComment => '댓글';

  @override
  String get menuReport => '신고';

  @override
  String get menuFlag => '표시';

  @override
  String get actionOpen => '열기';

  @override
  String get actionFollow => '팔로우';

  @override
  String get actionUnfollow => '언팔로우';

  @override
  String get actionMute => '뮤트';

  @override
  String get actionNotify => '알림';

  @override
  String get actionBookmark => '북마크';

  @override
  String get actionUnbookmark => '북마크 해제';

  @override
  String get actionBlock => '차단';

  @override
  String get actionUnblock => '차단 해제';

  @override
  String get actionRemove => '제거';

  @override
  String get actionAdd => '추가';

  @override
  String get actionSubtract => '제외';

  @override
  String selectionPost(num id) {
    return '글 #$id';
  }

  @override
  String selectionPostsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 글',
    );
    return '$_temp0';
  }

  @override
  String get noPosts => '글 없음';

  @override
  String get failedToLoadPosts => '글 불러오기 실패';

  @override
  String get offlineBanner => '오프라인 상태입니다. 캐시된 데이터를 표시합니다.';

  @override
  String get offlineNoData => '오프라인 상태입니다';

  @override
  String postListPageSummary(num count, Object page) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 글',
      one: '$count개 글',
    );
    return '페이지 $page · $_temp0';
  }

  @override
  String get postListPageLimit => '서버 페이지 한도에 도달했습니다. 검색어를 좁혀주세요.';

  @override
  String get postListJumpToPage => '페이지로 이동';

  @override
  String get postListJumpPageLabel => '페이지 번호';

  @override
  String postListJumpPageRange(Object max) {
    return '1과 $max 사이의 페이지 번호를 입력하세요';
  }

  @override
  String get postDeletedOverlay => '글이 삭제되었습니다';

  @override
  String get postUnavailableOverlay => '글을 사용할 수 없습니다';

  @override
  String get postBlacklistedOverlay => '글이 차단 목록에 있습니다';

  @override
  String unsupportedFileType(String ext) {
    return '$ext 파일은 지원되지 않습니다';
  }

  @override
  String get loginRequiredEdit => '글을 편집하려면 로그인해야 합니다!';

  @override
  String get loginRequiredComment => '댓글을 남기려면 로그인해야 합니다!';

  @override
  String get loginRequiredReport => '글을 신고하려면 로그인해야 합니다!';

  @override
  String get loginRequiredFlag => '글을 표시하려면 로그인해야 합니다!';

  @override
  String postsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 글 차단됨',
      one: '1개 글 차단됨',
    );
    return '$_temp0';
  }

  @override
  String get blacklistUpdateFailed => '차단 목록 업데이트 실패!';

  @override
  String get blacklistAddTag => '태그 추가';

  @override
  String get blacklistEditTag => '태그 편집';

  @override
  String get denylistEntryDeleted => '차단 항목 제거됨';

  @override
  String get blacklistEmpty => '차단 목록이 비어 있습니다';

  @override
  String get menuDelete => '삭제';

  @override
  String get filterScore => '점수';

  @override
  String get filterFavoriteCount => '즐겨찾기 수';

  @override
  String get filterSortBy => '정렬 기준';

  @override
  String get filterNew => '새로운';

  @override
  String get filterRank => '순위';

  @override
  String get filterRandom => '무작위';

  @override
  String get filterDefault => '기본';

  @override
  String get filterRating => '등급';

  @override
  String get filterSafe => '안전';

  @override
  String get filterQuestionable => '의심스러운';

  @override
  String get filterExplicit => '노골적';

  @override
  String get filterAll => '모두';

  @override
  String get filterPool => '풀';

  @override
  String get filterHasPool => '풀 있음';

  @override
  String get filterChild => '하위';

  @override
  String get filterIsChildPost => '하위 글임';

  @override
  String get filterParent => '상위';

  @override
  String get filterIsParentPost => '상위 글임';

  @override
  String get filterUploadDate => '업로드 날짜';

  @override
  String get filterLastDay => '지난 1일';

  @override
  String get filterLastWeek => '지난 1주';

  @override
  String get filterLastMonth => '지난 1개월';

  @override
  String get filterLastYear => '지난 1년';

  @override
  String get filterStatus => '상태';

  @override
  String get filterActive => '활성';

  @override
  String get filterPending => '대기 중';

  @override
  String get filterDeleted => '삭제됨';

  @override
  String get filterFlagged => '표시됨';

  @override
  String get filterAny => '모두';

  @override
  String get filterFileType => '파일 형식';

  @override
  String get filterUploader => '업로더';

  @override
  String get filterWidth => '너비';

  @override
  String get filterHeight => '높이';

  @override
  String get filterTagCount => '태그 수';

  @override
  String get filterTrue => '참';

  @override
  String get filterFalse => '거짓';

  @override
  String get filterImages => '이미지';

  @override
  String get filterVideos => '동영상';

  @override
  String get filterTitleContains => '제목 포함';

  @override
  String get filterCategory => '카테고리';

  @override
  String get filterGeneral => '일반';

  @override
  String get filterSiteBugReports => '사이트 버그 리포트 및 기능 요청';

  @override
  String get filterTagWikiProjects => '태크/위키 프로젝트 및 질문';

  @override
  String get filterTagAliasSuggestions => '태크 별칭 및 함축 제안';

  @override
  String get filterArtTalk => '아트 토크';

  @override
  String get filterOffTopic => '주제 외';

  @override
  String get filterE621Tools => 'e621 도구 및 애플리케이션';

  @override
  String get filterNewestFirst => '최신순';

  @override
  String get filterOldestFirst => '오래된순';

  @override
  String get filterSticky => '고정';

  @override
  String get filterIsSticky => '고정됨';

  @override
  String get filterLocked => '잠김';

  @override
  String get filterIsLocked => '잠겨있음';

  @override
  String get filterDescription => '설명';

  @override
  String get filterCreator => '제작자';

  @override
  String get filterIsActive => '활성 상태';

  @override
  String get filterSeries => '시리즈';

  @override
  String get filterCollection => '컬렉션';

  @override
  String get filterName => '이름';

  @override
  String get filterCreated => '생성됨';

  @override
  String get filterUpdated => '업데이트됨';

  @override
  String get filterPostCount => '글 수';

  @override
  String postUpdateFailed(num id) {
    return '글 업데이트 실패 #$id';
  }

  @override
  String postUpdated(num id) {
    return '글 업데이트됨 #$id';
  }

  @override
  String get failedToLoadPost => '글 불러오기 실패';

  @override
  String get postNotFound => '글을 찾을 수 없음';

  @override
  String get commentsTitle => '댓글';

  @override
  String commentsOfPost(num postId) {
    return '#$postId 댓글';
  }

  @override
  String get commentOrder => '댓글 순서';

  @override
  String get noComments => '댓글 없음';

  @override
  String get failedToLoadComments => '댓글 불러오기 실패';

  @override
  String commentTitle(num id) {
    return '댓글 #$id';
  }

  @override
  String get failedToLoadComment => '댓글 불러오기 실패';

  @override
  String get commentNotFound => '댓글을 찾을 수 없음';

  @override
  String commentEditorTitle(num postId) {
    return '#$postId 댓글';
  }

  @override
  String get commentSendFailed => '댓글 전송 실패!';

  @override
  String get commentSent => '댓글 전송됨!';

  @override
  String get commentHidden => '이 댓글은 숨겨짐';

  @override
  String commentUpvoteFailed(num id) {
    return '댓글 추천 실패 #$id';
  }

  @override
  String commentDownvoteFailed(num id) {
    return '댓글 비추천 실패 #$id';
  }

  @override
  String get commentLoginRequiredEdit => '댓글을 수정하려면 로그인해야 합니다!';

  @override
  String get commentLoginRequiredReply => '댓글에 답글을 달려면 로그인해야 합니다!';

  @override
  String get commentLoginRequiredReport => '댓글을 신고하려면 로그인해야 합니다!';

  @override
  String commentCopiedId(num id) {
    return '댓글 ID 복사됨 #$id';
  }

  @override
  String get warningUserWarned => '이 메시지로 인해 사용자에게 경고가 발생함';

  @override
  String get warningUserRecorded => '이 메시지로 인해 사용자에게 기록이 남음';

  @override
  String get warningUserBanned => '이 메시지로 인해 사용자가 차단됨';

  @override
  String get repliesTitle => '답글';

  @override
  String get replyOrder => '답글 순서';

  @override
  String get noReplies => '답글 없음';

  @override
  String get failedToLoadReplies => '답글 불러오기 실패';

  @override
  String replyTitle(num id) {
    return '답글 #$id';
  }

  @override
  String get failedToLoadReply => '답글 불러오기 실패';

  @override
  String get replyNotFound => '답글을 찾을 수 없음';

  @override
  String replyEditorTitle(num topicId) {
    return '#$topicId 답글';
  }

  @override
  String get replySendFailed => '답글 전송 실패!';

  @override
  String get replySent => '답글 전송됨!';

  @override
  String get replyHidden => '이 답글은 숨겨짐';

  @override
  String get replyLoginRequiredEdit => '답글을 수정하려면 로그인해야 합니다!';

  @override
  String get replyLoginRequiredReply => '답글에 답글을 달려면 로그인해야 합니다!';

  @override
  String get replyLoginRequiredReport => '답글을 신고하려면 로그인해야 합니다!';

  @override
  String replyCopiedId(num id) {
    return '답글 ID 복사됨 #$id';
  }

  @override
  String get menuReply => '답글';

  @override
  String get menuCopyId => 'ID 복사';

  @override
  String get menuRefresh => '새로고침';

  @override
  String get actionCopy => '복사';

  @override
  String get actionSave => '저장';

  @override
  String get actionShow => '보기';

  @override
  String get actionHide => '숨기기';

  @override
  String get actionCannotBeUndone => '이 작업은 취소할 수 없습니다.';

  @override
  String get info => '정보';

  @override
  String wikiTitle(String idOrTitle) {
    return '위키 $idOrTitle';
  }

  @override
  String get failedToLoadWiki => '위키 불러오기 실패';

  @override
  String get wikiNotFound => '위키를 찾을 수 없음';

  @override
  String wikiCopiedId(num id) {
    return '위키 ID 복사됨 #$id';
  }

  @override
  String get wikiInfoId => 'ID';

  @override
  String get wikiInfoAlias => '별칭';

  @override
  String get wikiInfoCreated => '생성됨';

  @override
  String get wikiInfoUpdated => '업데이트됨';

  @override
  String get wikiInfoLocked => '잠김';

  @override
  String get wikiInfoYes => '예';

  @override
  String get wikiInfoNo => '아니오';

  @override
  String userTitle(String idOrName) {
    return '사용자 $idOrName';
  }

  @override
  String get failedToLoadUser => '사용자 로드 실패';

  @override
  String get userNotFound => '사용자를 찾을 수 없음';

  @override
  String get userUploads => '업로드';

  @override
  String get userLoginRequiredReport => '신고하려면 로그인해야 합니다!';

  @override
  String get userComission => '커미션';

  @override
  String get userId => 'ID';

  @override
  String get userJoined => '가입일';

  @override
  String get userRank => '등급';

  @override
  String get userPosts => '게시물';

  @override
  String get userEdits => '편집';

  @override
  String get userFavorites => '즐겨찾기';

  @override
  String get userComments => '댓글';

  @override
  String get userForum => '포럼';

  @override
  String userCopiedId(num id) {
    return '사용자 ID #$id 복사됨';
  }

  @override
  String get logsTitle => '로그';

  @override
  String logsTitleDate(String date) {
    return '로그 - $date';
  }

  @override
  String selectionLogsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 로그',
    );
    return '$_temp0';
  }

  @override
  String selectionLogsFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 로그 파일',
    );
    return '$_temp0';
  }

  @override
  String get logsLevels => '레벨';

  @override
  String get logsRecording => '녹음 중';

  @override
  String get logsVerbose => '상세';

  @override
  String get logsVerboseAll => '모든 레벨 기록됨';

  @override
  String logsVerboseMinimum(String level) {
    return '$level 이상';
  }

  @override
  String get logFilesTitle => '로그 파일';

  @override
  String get failedToLoadLogFiles => '로그 파일 로드 실패!';

  @override
  String get noLogFiles => '사용 가능한 로그 파일이 없습니다!';

  @override
  String get logsLive => '실시간';

  @override
  String get noLogs => '로그 없음';

  @override
  String get failedToReadLog => '로그 읽기 실패';

  @override
  String get noErrorsLogged => '오류 없음';

  @override
  String logsErrorsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 오류',
      one: '1개 오류',
    );
    return '$_temp0';
  }

  @override
  String get logsAll => '모든 로그';

  @override
  String get logsDismissAll => '모두 닫기';

  @override
  String logsDeleteTitle(num count) {
    return '$count개 로그 파일을 삭제할까요?';
  }

  @override
  String get identityAccounts => '계정';

  @override
  String get identityAdd => '계정 추가';

  @override
  String get identityEdit => '계정 편집';

  @override
  String get identityRemoveTitle => '계정을 제거할까요?';

  @override
  String get identityRemoveBody => '모든 데이터가 영구적으로 제거됩니다, 기록과 팔로우를 포함하여.';

  @override
  String get identityAnonymous => '익명';

  @override
  String get identityDuplicate => '이 호스트와 사용자 이름으로 이미 계정이 있습니다.';

  @override
  String identityLoginFailed(String reason) {
    return '로그인 실패. \n$reason';
  }

  @override
  String get identityLoginCheckDetails => '네트워크 연결과 로그인 정보를 확인하세요';

  @override
  String get identitySite => '사이트';

  @override
  String get identityHostRequired => '호스트 URL을 제공해야 합니다.';

  @override
  String get identityHostInvalid => '잘못된 호스트 URL';

  @override
  String get identityHostReadOnly =>
      '사이트를 변경할 수 없습니다. 다른 사이트를 사용하려면 새 계정을 추가하세요.';

  @override
  String get identityUsernameLabel => '사용자 이름';

  @override
  String get identityUsernameRequired => '사용자 이름을 제공해야 합니다.';

  @override
  String get identityApikeyLabel => 'API 키';

  @override
  String get identityApikeyHelp => 'API 키는 어디서 찾을 수 있나요?';

  @override
  String get identityApikeyRequired =>
      'API 키를 제공해야 합니다.\n예: 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identityApikeyInvalid =>
      'API 키는 24 또는 32자의 A-z와 0-9 문자열입니다\n예: 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identitySignupPrompt => '계정이 없으신가요? 여기서 가입하세요';

  @override
  String get identityHostHint => '계정과 게시물을 호스팅하는 사이트.';

  @override
  String get identitySignIn => '로그인';

  @override
  String get identityGuest => '게스트';

  @override
  String get identityLogin => '로그인';

  @override
  String get identityBrowseAnonymously => '익명으로 둘러보기';

  @override
  String identityConnecting(String host, String username) {
    return '$host에 $username로 연결 중...';
  }

  @override
  String identityActivateFailed(Object error) {
    return '계정 활성화 실패: $error';
  }

  @override
  String traitsActivateFailed(Object error) {
    return '특성 활성화 실패: $error';
  }

  @override
  String get failedToLoadIdentities => '계정 로드 실패';

  @override
  String get onboardingSkip => '건너뛰기';

  @override
  String get onboardingBack => '뒤로';

  @override
  String get onboardingNext => '다음';

  @override
  String onboardingWelcomeTitle(String app) {
    return '$app에 오신 것을 환영합니다';
  }

  @override
  String get onboardingWelcomeBody => '정교한 booru 브라우저입니다.';

  @override
  String get onboardingThemeTitle => '외관 선택';

  @override
  String get onboardingThemeBody => '한번 시도해보세요. 나중에 마음을 바꿀 수 있습니다.';

  @override
  String get onboardingQualityTitle => '미디어 조정';

  @override
  String get onboardingQualityBody =>
      '비디오와 썸네일이 얼마나 로드될지 선택하세요. 나중에 설정에서 변경할 수 있습니다.';

  @override
  String get onboardingLoginTitle => '계정 연결';

  @override
  String get onboardingLanguageTitle => '언어 선택';

  @override
  String get followAddToSubscriptions => '구독에 추가';

  @override
  String get followNoSubscriptions => '구독 없음';

  @override
  String get followFailedToLoadSubscriptions => '구독 로드 실패';

  @override
  String get followAddToBookmarks => '북마크에 추가';

  @override
  String get followNoBookmarks => '북마크 없음';

  @override
  String get followFailedToLoadBookmarks => '북마크 로드 실패';

  @override
  String get followUnseenPosts => '읽지 않은 게시물';

  @override
  String followMarkPostsSeen(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 게시물을 본 것으로 표시',
      one: '1개 게시물을 본 것으로 표시',
    );
    return '$_temp0';
  }

  @override
  String get followNoUnseenPosts => '새 게시물 없음';

  @override
  String get followShowUnseenFirst => '새 게시물 우선 표시';

  @override
  String get followFilteringUnseen => '새 게시물 필터링 중';

  @override
  String get followAllPostsShown => '모든 게시물 표시됨';

  @override
  String get followForceSync => '강제 동기화';

  @override
  String get followSyncAllFollows => '모든 팔로우 동기화';

  @override
  String followSyncingFollows(String progress) {
    return '팔로우 동기화 중... $progress';
  }

  @override
  String get followEditorTitle => '팔로우 편집';

  @override
  String get followSubscribe => '구독';

  @override
  String get followEditPrompt => '팔로우 편집';

  @override
  String get followTitlePrompt => '팔로우 제목';

  @override
  String get followMarkAsRead => '읽음으로 표시';

  @override
  String get followDisableNotifications => '알림 끄기';

  @override
  String get followEnableNotifications => '알림 켜기';

  @override
  String get followRename => '이름 변경';

  @override
  String followNewPosts(num count, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label 새 게시물',
      one: '새 게시물 1개',
    );
    return '$_temp0';
  }

  @override
  String followSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 팔로우',
      one: '팔로우 1개',
    );
    return '$_temp0';
  }

  @override
  String followAlias(String? alias) {
    return '별칭 $alias';
  }

  @override
  String historySelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목',
      one: '항목 1개',
    );
    return '$_temp0';
  }

  @override
  String historyEntriesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '기록 항목 $count개 삭제됨',
      one: '기록 항목 1개 삭제됨',
    );
    return '$_temp0';
  }

  @override
  String get historyClear => '기록 삭제';

  @override
  String get historyClearSubtitle => '모든 항목 삭제';

  @override
  String get historyClearConfirm => '기록을 삭제하시겠습니까?';

  @override
  String get historyClearConfirmBody =>
      '모든 기록 항목이 영구적으로 삭제됩니다. 이 작업은 취소할 수 없습니다.';

  @override
  String get historyClearAction => '삭제';

  @override
  String get historyLimit => '기록 제한';

  @override
  String historyLimitEnableBody(String amount, num months) {
    return '기록 제한을 사용하면 $amount개를 초과하거나 $months개월이 지난 모든 기록 항목이 자동으로 삭제됩니다.';
  }

  @override
  String get historyLimitTitle => '기록 제한';

  @override
  String historyLimitOn(String amount, num months) {
    return '$months개월 이전 또는 $amount개 이하의 항목으로 제한됨.';
  }

  @override
  String get historyLimitOff => '무한 기록';

  @override
  String get historyEntries => '항목';

  @override
  String get historyType => '유형';

  @override
  String get historyItems => '항목';

  @override
  String get historySearches => '검색';

  @override
  String get historyWikis => '위키';

  @override
  String get historyUsers => '사용자';

  @override
  String get historyEmpty => '기록이 비어 있습니다';

  @override
  String get historyFailedToLoad => '기록 불러오기 실패';

  @override
  String get historyNoDescription => '설명 없음';

  @override
  String get historyHotPosts => '인기 게시물';

  @override
  String historyLinkPost(num id) {
    return '게시물 #$id';
  }

  @override
  String historyLinkUser(num id) {
    return '사용자 #$id';
  }

  @override
  String historyLinkWiki(num id) {
    return '위키 #$id';
  }

  @override
  String historyLinkUserByName(String id) {
    return '$id - 사용자';
  }

  @override
  String historyLinkWikiByName(String id) {
    return '$id - 위키';
  }

  @override
  String historySearchQuery(String type, String query) {
    return '$type - $query';
  }

  @override
  String get historyWiki => '위키';

  @override
  String get poolEmpty => '풀이 없음';

  @override
  String get poolFailedToLoadPools => '풀 불러오기 실패';

  @override
  String get poolTitle => '풀 제목';

  @override
  String get poolInfoPosts => '게시물';

  @override
  String get poolInfoId => 'ID';

  @override
  String get poolInfoActivity => '활동';

  @override
  String get poolInfoActive => '활성';

  @override
  String get poolInfoInactive => '비활성';

  @override
  String get poolInfoCreated => '생성됨';

  @override
  String get poolInfoUpdated => '업데이트됨';

  @override
  String poolCopiedId(num id) {
    return '풀 ID #$id 복사됨';
  }

  @override
  String poolLink(num id) {
    return '풀 #$id';
  }

  @override
  String get poolFailedToLoadPool => '풀 불러오기 실패';

  @override
  String get poolNotFound => '풀을 찾을 수 없음';

  @override
  String get poolOrder => '풀 순서';

  @override
  String get poolOldestFirst => '오래된 것부터';

  @override
  String get poolNewestFirst => '새 것부터';

  @override
  String get poolReaderMode => '풀 읽기 모드';

  @override
  String get poolReaderLargeImages => '큰 이미지';

  @override
  String get poolReaderNormalGrid => '일반 그리드';

  @override
  String get topicsTitle => '주제';

  @override
  String get topicHideTagEdits => '태그 편집 숨기기';

  @override
  String get topicTagEditsHidden => '숨김';

  @override
  String get topicTagEditsVisible => '표시됨';

  @override
  String topicLink(num id) {
    return '주제 #$id';
  }

  @override
  String get topicFailedToLoadTopic => '주제 불러오기 실패';

  @override
  String get topicNotFound => '주제를 찾을 수 없음';

  @override
  String get topicEmpty => '주제가 없음';

  @override
  String get topicFailedToLoadTopics => '주제 불러오기 실패';

  @override
  String get topicInfoReplies => '답글';

  @override
  String get topicInfoId => 'ID';

  @override
  String topicCopiedId(num id) {
    return '주제 ID #$id 복사됨';
  }

  @override
  String get topicInfoLocked => '잠김';

  @override
  String get topicInfoYes => '예';

  @override
  String get topicInfoNo => '아니오';

  @override
  String get topicInfoCreated => '생성됨';

  @override
  String get topicInfoUpdated => '업데이트됨';

  @override
  String get filterTags => '태그';

  @override
  String get loginRequired => '이 작업을 수행하려면 로그인해야 합니다.';

  @override
  String get actionChooseIdentity => '계정 선택';

  @override
  String get dateToday => '오늘';

  @override
  String get dateYesterday => '어제';

  @override
  String detailCommentsButton(num count) {
    return '댓글 ($count)';
  }

  @override
  String get detailFile => '파일';

  @override
  String get detailSources => '출처';

  @override
  String get detailNoSources => '출처 없음';

  @override
  String get detailChildren => '하위 게시물';

  @override
  String get detailDeletion => '삭제';

  @override
  String get detailBlacklisted => '차단됨';

  @override
  String get detailNoArtist => '아티스트 없음';

  @override
  String detailPoolPosts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 게시물',
      one: '1개 게시물',
    );
    return '$_temp0';
  }

  @override
  String postCopiedId(num id) {
    return '게시물 ID #$id 복사됨';
  }

  @override
  String postUpvoteFailed(num id) {
    return '게시물 #$id 추천 실패';
  }

  @override
  String postDownvoteFailed(num id) {
    return '게시물 #$id 비추천 실패';
  }

  @override
  String postAddFavoriteFailed(num id) {
    return '게시물 #$id를 즐겨찾기에 추가하지 못했습니다';
  }

  @override
  String postRemoveFavoriteFailed(num id) {
    return '게시물 #$id를 즐겨찾기에서 제거하지 못했습니다';
  }

  @override
  String get editorSection => '섹션';

  @override
  String get editorQuote => '인용';

  @override
  String get editorCode => '코드';

  @override
  String get editorSpoiler => '스포일러';

  @override
  String get editorBold => '굵게';

  @override
  String get editorItalic => '기울임';

  @override
  String get editorUnderlined => '밑줄';

  @override
  String get editorStrikethrough => '취소선';

  @override
  String get editorPreviewPlaceholder => '여기에 텍스트 입력';

  @override
  String get editorWrite => '작성';

  @override
  String get editorPreview => '미리보기';

  @override
  String get editorTypeHere => '여기에 입력...';

  @override
  String get tagNoTags => '태그 없음';

  @override
  String get tagFailedToLoadTags => '태그 로드 실패';

  @override
  String get tagUnableToRetrieveWiki => '위키 항목을 가져올 수 없음';

  @override
  String get tagNoWikiEntry => '위키 항목 없음';

  @override
  String get tagCategoryGeneral => '일반';

  @override
  String get tagCategorySpecies => '종';

  @override
  String get tagCategoryCharacter => '캐릭터';

  @override
  String get tagCategoryCopyright => '저작권';

  @override
  String get tagCategoryMeta => '메타';

  @override
  String get tagCategoryLore => '배경설정';

  @override
  String get tagCategoryArtist => '아티스트';

  @override
  String get tagCategoryContributor => '기여자';

  @override
  String get tagCategoryInvalid => '유효하지 않음';

  @override
  String editDescriptionTitle(num postId) {
    return '#$postId 설명';
  }

  @override
  String get editDescriptionHint => '게시물 설명을 입력하세요...';

  @override
  String get editInvalidNumber => '잘못된 숫자 형식';

  @override
  String get editInvalidParent => '잘못된 부모 게시물';

  @override
  String get editParentIdLabel => '부모 ID (선택사항)';

  @override
  String get editParentIdHint => '부모 게시물 ID';

  @override
  String get editReasonLabel => '편집 사유 (선택사항)';

  @override
  String get editReasonHint => '이 게시물을 왜 편집하시나요?';

  @override
  String editSourcesTitle(num postId) {
    return '#$postId 출처';
  }

  @override
  String get editTagsHint => '공백으로 구분된 태그';

  @override
  String editTagPreviewFailed(String error) {
    return '태그 미리보기 로드 오류: $error';
  }

  @override
  String get editTagStatusNew => '새로운';

  @override
  String get editTagStatusInvalid => '유효하지 않음';

  @override
  String get editTagStatusEmpty => '비어있음';

  @override
  String get editTagStatusUnderused => '사용 부족';

  @override
  String reportCommentSuccess(num id) {
    return '댓글 #$id 신고됨';
  }

  @override
  String reportCommentFailed(num id) {
    return '댓글 #$id 신고 실패';
  }

  @override
  String reportReplySuccess(num id) {
    return '답글 #$id 신고됨';
  }

  @override
  String reportReplyFailed(num id) {
    return '답글 #$id 신고 실패';
  }

  @override
  String reportUserSuccess(num id) {
    return '사용자 #$id 신고됨';
  }

  @override
  String reportUserFailed(num id) {
    return '사용자 #$id 신고 실패';
  }

  @override
  String reportPostSuccess(num id) {
    return '게시물 #$id 신고됨';
  }

  @override
  String reportPostFailed(num id) {
    return '게시물 #$id 신고 실패';
  }

  @override
  String get reportTypeRequired => '유형을 입력해야 합니다';

  @override
  String get reportReason => '사유';

  @override
  String get reportReasonRequired => '사유를 입력해야 합니다';

  @override
  String get reportSubmitted => '신고가 제출되었습니다';

  @override
  String get reportSubmitFailed => '신고 제출 실패';

  @override
  String get reportTypeRating => '평오용';

  @override
  String get reportTypeFile => '악성 파일';

  @override
  String get reportTypeSource => '악성 출처';

  @override
  String get reportTypeDescription => '설명 오용';

  @override
  String get reportTypeNote => '노트 오용';

  @override
  String get reportTypeTagging => '태그 오용';

  @override
  String get reportTypeRatingBody => '게시물의 평가가 올바르지 않게 설정되었습니다.';

  @override
  String get reportTypeFileBody =>
      '파일에 악성 코드나 숨겨진 파일 아카이브가 포함되어 있습니다. 이미지 자체에 묘사된 내용이 아닙니다.';

  @override
  String get reportTypeSourceBody => '하나 이상의 출처 악성 페이지나 유료 콘텐츠로 연결됩니다.';

  @override
  String get reportTypeDescriptionBody =>
      '설명에 악성 콘텐츠가 포함되어 있거나, 편집되어 비속한 자료가 포함되었습니다.';

  @override
  String get reportTypeNoteBody =>
      '이 게시물의 노트가 잘못되었거나, 괴롭힘을 당하거나, 그 밖에 비속한 내용을 포함하고 있습니다.';

  @override
  String get reportTypeTaggingBody =>
      '이 게시물의 하나 이상의 태그가 유효하지 않거나, 하나 이상의 유효한 태그가 게시물에서 제거되었습니다.';

  @override
  String flagPostSuccess(num id) {
    return '게시물 #$id가 신호되었습니다';
  }

  @override
  String flagPostFailed(num id) {
    return '게시물 #$id 신고 실패';
  }

  @override
  String get flagParentId => '상위 ID';

  @override
  String get flagParentIdRequired => '상위 ID는 비워둘 수 없습니다';

  @override
  String get flagParentIdInvalid => '상위 ID는 숫자여야 합니다';

  @override
  String get flagTypeUploadingGuidelines => '업로드 가이드라인 미준수';

  @override
  String get flagTypeYoungHuman => '노출 상황의 인간형 캐릭터';

  @override
  String get flagTypeDnpArtist => '이 게시물의 작가는 게시 금지 목록에 있음';

  @override
  String get flagTypePayContent => '유료 사이트, 상업적 또는 구독 콘텐츠';

  @override
  String get flagTypeTrace => '다른 작가 작품의 트레이스';

  @override
  String get flagTypePreviouslyDeleted => '이전에 삭제됨';

  @override
  String get flagTypeRealPorn => '실생색 포르노그래피';

  @override
  String get flagTypeCorrupt => '파일이 손상되었거나 깨졌거나 작동하지 않음';

  @override
  String get flagTypeInferior => '다른 게시물의 중복 또는 열등한 버전';

  @override
  String get flagTypeUploadingGuidelinesBody =>
      '이 게시물은 예술적 가치, 이미지 품질, 관련성 또는 기타 사이트 기준을 충족하지 못합니다.\n개인적 취향은 이에 영향을 미치지 않습니다. 게시물 내용이 문제가 있다면 [[e621:blacklist|차단 목록]]에 추가하세요.';

  @override
  String get flagTypeYoungHumanBody =>
      '성적 또는 노출 방식으로 묘사된 인간 및 인간형 캐릭터가 포함된 게시물은 이 사이트에서 허용되지 않습니다.';

  @override
  String get flagTypeDnpArtistBody =>
      '특정 작가들은 자신의 작품이 이 사이트에 게시되지 않기를 요청했으며, [[avoid_posting|게시 금지]] 상태를 받았습니다.\n때로는 이 상태에 조건이 따르기도 합니다; 자세한 내용은 [[conditional_dnp]]를 참조하세요.';

  @override
  String get flagTypePayContentBody =>
      '우리는 어떤 종류의 유료 사이트 또는 상업적 콘텐츠를 호스팅하지 않습니다. 이에는 Patreon 유출, 불법 웹사이트에서 재업로드 등이 포함됩니다.';

  @override
  String get flagTypeTraceBody =>
      '다른 작가의 작품에서 트레이스된 이미지는 이 사이트에서 허용되지 않습니다. 참조는 괜찮지만, 다른 사람의 작품을 그대로 복제하는 것은 아닙니다.\n댓글에 더 많은 정보를 남기거나, 원작이 이 사이트에 호스팅되어 있다면 원작을 게시물의 상위로 추가하세요.';

  @override
  String get flagTypePreviouslyDeletedBody =>
      '게시물은 보통 좋은 이유로 삭제되며, 삭제된 콘텐츠를 다시 업로드하는 것은 허용되지 않습니다.\n댓글에 더 많은 정보를 남기거나, 원본 게시물을 이 게시물의 상위로 추가하세요.';

  @override
  String get flagTypeRealPornBody =>
      '실생색 포르노그래피가 포함된 게시물은 이 사이트에서 허용되지 않습니다. 예외는 없습니다.\n비에로틱 사진이 포함된 이미지는 허용됩니다.';

  @override
  String get flagTypeCorruptBody =>
      '이 게시물에 문제가 있습니다. 깨진 비디오나 손상된 이미일 수 있습니다.\n어느 쪽이든, 혼란을 피하기 위해 상황을 댓글로 설명해주세요.';

  @override
  String get flagTypeInferiorBody =>
      '이 게시물의 우수한 버전이 이미 사이트에 존재합니다.\n이에는 시각적 품질이 더 좋은 이미지(더 크고, 압축 덜 됨)가 포함될 수 있으며, 작가가 시실적 실수를 수정한 \"수정된\" 버전도 포함될 수 있습니다.\n편집 및 대안 버전은 이 범주에 해당하지 않습니다.';

  @override
  String get taskCancelAll => '모두 취소';

  @override
  String get taskClearDone => '완료된 것 지우기';

  @override
  String get taskClearSelection => '선택 해제';

  @override
  String get taskCancel => '취소';

  @override
  String get taskDismiss => '닫기';

  @override
  String get taskNoTasks => '작업 없음';

  @override
  String get taskFailedToLoadTasks => '작업 불러오기 실패';

  @override
  String taskSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 작업',
      one: '1개 작업',
    );
    return '$_temp0';
  }

  @override
  String get taskGroupActive => '진행 중';

  @override
  String get taskGroupFailed => '실패';

  @override
  String get taskActionDownload => '다운로드';

  @override
  String get taskActionFavorite => '즐겨찾기';

  @override
  String get taskActionUnfavorite => '즐겨찾기 해제';

  @override
  String get taskDownloadRunning => '다운로드 중';

  @override
  String get taskFavoriteRunning => '즐겨찾기 중';

  @override
  String get taskUnfavoriteRunning => '즐겨찾기 해제 중';

  @override
  String get taskDownloadCompleted => '다운로드됨';

  @override
  String get taskFavoriteCompleted => '즐겨찾기됨';

  @override
  String get taskUnfavoriteCompleted => '즐겨찾기 해제됨';

  @override
  String taskQueuedTo(String action) {
    return '$action 대기열에 추가됨';
  }

  @override
  String taskFailedTo(String action) {
    return '$action 실패';
  }

  @override
  String taskCanceledAction(String action) {
    return '$action 취소됨';
  }

  @override
  String taskTileTitle(String label, num id) {
    return '$label 게시물 #$id';
  }

  @override
  String followNotificationBody(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 새 게시물이 있습니다!',
      one: '새 게시물이 있습니다!',
    );
    return '$_temp0';
  }

  @override
  String get followNotificationSummary => '새 게시물!';

  @override
  String get followChannelName => '팔로우한 태그';

  @override
  String get followChannelDescription => '팔로우 중인 태그 알림';

  @override
  String get hostUnavailableTitle => '호스트 사용 불가';

  @override
  String hostUnavailableBody(String host) {
    return '$host를 사용할 수 없는 것 같습니다!';
  }

  @override
  String get hostUnavailableResolveHint =>
      '다음 브라우저 창에서 문제를 해결하세요.\n\nCloudflare 캡챠 쿠키가 저장됩니다.';

  @override
  String get hostUnavailableResolve => '해결';

  @override
  String hostUnavailableWaitBody(String host) {
    return '\n$host에서 문제를 해결할 때까지 기다려주세요.';
  }

  @override
  String get downloadChooseFolder => '폴더 선택';

  @override
  String get searchFilterTitle => '필터';

  @override
  String get searchFilterQueryLabel => '현재 검색어:';

  @override
  String get filterSectionSort => '정렬';

  @override
  String get filterSectionContent => '콘텐츠';

  @override
  String get filterSectionTime => '시간 및 상태';

  @override
  String get filterSectionMedia => '미디어';

  @override
  String get filterSectionOther => '기타';

  @override
  String get searchFilterReset => '필터 초기화';

  @override
  String get dtextParsingFailed => 'DText 파싱 실패';

  @override
  String get filteredShow => '보기';

  @override
  String get filteredHide => '숨기기';

  @override
  String get selectOptions => '옵션 선택...';

  @override
  String get databaseNotE1547 => '이 파일은 e1547 데이터베이스가 아닙니다.';

  @override
  String get adultGateTitle => '간단한 현실 확인';

  @override
  String get adultGateBody =>
      '이 앱은 성인만을 위한 예술 커뮤니티인 e621로 직접 연결됩니다. 거주지에서 법적 성인임을 확인해주세요 - 우리는 당신을 믿지만, 변호사들은 그렇지 않습니다.';

  @override
  String get adultGateConfirm => '물론입니다 - 저는 18세 이상입니다';

  @override
  String get adultGateDeny => '돌아가기';

  @override
  String get databaseExportPasswordLabel => '비밀번호 (선택)';

  @override
  String get databaseExportPasswordHint =>
      '내보낸 파일을 암호화합니다. 비워두면 평문 암호화 파일로 저장됩니다.';

  @override
  String get databaseImportEncryptedTitle => '암호화된 데이터베이스';

  @override
  String get databaseImportPasswordLabel => '비밀번호';

  @override
  String get databaseImportWrongPassword => '잘못된 비밀번호 또는 손상된 파일입니다.';

  @override
  String get actionUnlock => '잠금 해제';
}
