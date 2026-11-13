// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'e1547';

  @override
  String get failedToLoad => 'Tải thất bại';

  @override
  String get nothingToSeeHere => 'Không có gì để xem ở đây';

  @override
  String get loading => 'Đang tải...';

  @override
  String get actionCancel => 'HỦY';

  @override
  String get actionOk => 'OK';

  @override
  String get actionTryAgain => 'Thử lại';

  @override
  String get actionDownload => 'TẢI VỀ';

  @override
  String get actionImport => 'NHẬP';

  @override
  String get actionExport => 'XUẤT';

  @override
  String get actionUndo => 'Hoàn tác';

  @override
  String get actionRestartNow => 'KHỞI ĐỘNG LẠI';

  @override
  String get failedToLoadSuggestions => 'Không thể tải gợi ý';

  @override
  String selectionItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mục',
      one: '1 mục',
    );
    return '$_temp0';
  }

  @override
  String get actionAbort => 'HỦY BỎ';

  @override
  String get actionSelectAll => 'Chọn tất cả';

  @override
  String fileSavedAs(String name) {
    return 'Đã lưu file với tên $name';
  }

  @override
  String get copiedToClipboard => 'Đã sao chép vào clipboard';

  @override
  String get saveFile => 'Lưu file';

  @override
  String get filterTooltip => 'Lọc';

  @override
  String get rangeInvalidFormat => 'Định dạng không hợp lệ';

  @override
  String itemProgress(num current, num total) {
    return 'Mục $current/$total';
  }

  @override
  String get taskCancelled => 'Đã hủy tác vụ';

  @override
  String taskFailedAt(num index) {
    return 'Thất bại ở mục $index';
  }

  @override
  String get taskDone => 'Hoàn thành';

  @override
  String get failedToInitialize => 'Khởi tạo thất bại';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navHot => 'Nổi bật';

  @override
  String get navSearch => 'Tìm kiếm';

  @override
  String get navFavorites => 'Yêu thích';

  @override
  String get navTimeline => 'Dòng thời gian';

  @override
  String get navSubscriptions => 'Theo dõi';

  @override
  String get navBookmarks => 'Dấu trang';

  @override
  String get navPools => 'Pool';

  @override
  String get navForum => 'Diễn đàn';

  @override
  String get navHistory => 'Lịch sử';

  @override
  String get navTasks => 'Tác vụ';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get navAbout => 'Giới thiệu';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get sectionAccount => 'Tài khoản';

  @override
  String get sectionUser => 'Người dùng';

  @override
  String get sectionAppearance => 'Giao diện';

  @override
  String get sectionInteractions => 'Tương tác';

  @override
  String get sectionSecurity => 'Bảo mật';

  @override
  String get sectionDevelopment => 'Phát triển';

  @override
  String get settingsBlacklist => 'Danh sách chặn';

  @override
  String tagsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tag bị chặn',
      one: '1 tag bị chặn',
    );
    return '$_temp0';
  }

  @override
  String get settingsFollows => 'Theo dõi';

  @override
  String searchesFollowed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tìm kiếm theo dõi',
      one: '1 tìm kiếm theo dõi',
    );
    return '$_temp0';
  }

  @override
  String get settingsHistory => 'Lịch sử';

  @override
  String pagesVisited(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trang đã xem',
      one: '1 trang đã xem',
    );
    return '$_temp0';
  }

  @override
  String get settingsTheme => 'Chủ đề';

  @override
  String get themeDark => 'tối';

  @override
  String get themeAmoled => 'amoled';

  @override
  String get themeLight => 'sáng';

  @override
  String get themeBlue => 'xanh dương';

  @override
  String get themeSystem => 'hệ thống';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get languageSystemDefault => 'Mặc định hệ thống';

  @override
  String get settingsHandedness => 'Tay thuận';

  @override
  String get handRight => 'Tay phải';

  @override
  String get handLeft => 'Tay trái';

  @override
  String get settingsHandednessHint =>
      'Nút và thao tác nhanh sẽ di chuyển về phía tay thuận này.';

  @override
  String get thumbnailQuality => 'Chất lượng hình thu nhỏ';

  @override
  String get settingsQuilt => 'Lưới';

  @override
  String get gridTitle => 'Lưới';

  @override
  String get quiltSquare => 'hình vuông';

  @override
  String get quiltVertical => 'mở rộng chiều dọc';

  @override
  String get settingsPostInfo => 'Thông tin bài';

  @override
  String get postInfoShown => 'hiển thị thông tin';

  @override
  String get postInfoHidden => 'chỉ hình ảnh';

  @override
  String get settingsDownloadLocation => 'Vị trí tải';

  @override
  String get settingsUpvoteFavorites => 'Bình chọn yêu thích';

  @override
  String get upvoteFavoritesOn => 'bình chọn và lưu';

  @override
  String get upvoteFavoritesOff => 'chỉ lưu';

  @override
  String get settingsVideoVolume => 'Â lượng video';

  @override
  String get videoMuted => 'âm thanh tắt';

  @override
  String get videoWithSound => 'có âm thanh';

  @override
  String videoSeekSeconds(Object seconds) {
    return '$seconds giây';
  }

  @override
  String get videoResSource => 'Nguồn';

  @override
  String get videoResNote =>
      'Video không luôn luôn có sẵn ở các kích thước tiêu chuẩn; kích thước gần nhất với lựa chọn sẽ được sử dụng.';

  @override
  String get qualityLow => 'Thấp';

  @override
  String get qualityMedium => 'Trung bình';

  @override
  String get qualityHigh => 'Cao';

  @override
  String get settingsAutoLoadVideos => 'Tải video tự động';

  @override
  String get autoLoadVideosOn => 'video tải khi duyệt';

  @override
  String get autoLoadVideosOff => 'video tải khi phát';

  @override
  String get autoLoadVideosDialogTitle => 'Tải video tự động?';

  @override
  String get autoLoadVideosDialogBody =>
      'Video sẽ được tải hoàn toàn khi bạn duyệt và tìm kiếm. Điều này có thể tiêu tốn nhiều dữ liệu trên kết nối đo lường.';

  @override
  String get videoQuality => 'Chất lượng video';

  @override
  String get settingsSecureDisplay => 'Màn hình an toàn';

  @override
  String get secureDisplayOn => 'màn hình được bảo vệ';

  @override
  String get secureDisplayOff => 'màn hình hiển thị';

  @override
  String get settingsIncognitoKeyboard => 'Bàn phím ẩn danh';

  @override
  String get enabled => 'đã bật';

  @override
  String get disabled => 'đã tắt';

  @override
  String get settingsPinLock => 'Khóa PIN';

  @override
  String get pinEnabled => 'PIN đã bật';

  @override
  String get pinDisabled => 'PIN đã tắt';

  @override
  String get settingsBiometricLock => 'Khóa sinh trắc';

  @override
  String get biometricsEnabled => 'sinh trắc đã bật';

  @override
  String get biometricsDisabled => 'sinh trắc đã tắt';

  @override
  String get biometricsUnavailable => 'không tìm thấy phần cứng sinh trắc học';

  @override
  String get biometricsNotEnrolled =>
      'có cảm biến vân tay nhưng chưa đăng ký vân tay nào';

  @override
  String get biometricsRequiresPin =>
      'hãy đặt mã PIN trước: khoá sinh trắc học sẽ dùng nó làm phương thức dự phòng khi cảm biến trục trặc';

  @override
  String get settingsUpdaterBeta => 'Cập nhật mới nhất';

  @override
  String get updaterBetaOn => 'Phiên bản ổn định và bản phát hành trước';

  @override
  String get updaterBetaOff => 'Chỉ phiên bản ổn định';

  @override
  String get settingsDeveloperMode => 'Chế độ nhà phát triển';

  @override
  String get devOptionsShown => 'tùy chọn hiển thị';

  @override
  String get devOptionsHidden => 'tùy chọn ẩn';

  @override
  String errorsLogged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lỗi đã ghi',
      one: '1 lỗi đã ghi',
    );
    return '$_temp0';
  }

  @override
  String get settingsDatabase => 'Cơ sở dữ liệu';

  @override
  String get databaseExporting => 'Đang xuất cơ sở dữ liệu...';

  @override
  String get databaseExported => 'Xuất cơ sở dữ liệu thành công';

  @override
  String get databaseExportFailed => 'Xuất thất bại';

  @override
  String get databaseExport => 'Xuất';

  @override
  String get databaseImporting => 'Đang nhập cơ sở dữ liệu...';

  @override
  String databaseInvalidFile(String error) {
    return 'Tệp cơ sở dữ liệu không hợp lệ: $error';
  }

  @override
  String databaseImportFailed(String error) {
    return 'Nhập thất bại: $error';
  }

  @override
  String get databaseImportTooLarge => 'Tệp này quá lớn để nhập.';

  @override
  String get databaseImportTitle => 'Nhập Cơ sở dữ liệu';

  @override
  String get databaseRestartTitle => 'Cần khởi động lại';

  @override
  String get databaseRestartBody =>
      'Ứng dụng cần khởi động lại để áp dụng các thay đổi.';

  @override
  String get databaseImport => 'Nhập';

  @override
  String get lockEnterPin => 'Nhập PIN';

  @override
  String get lockEnterNewPin => 'Nhập PIN mới';

  @override
  String get lockConfirmNewPin => 'Xác nhận PIN mới';

  @override
  String get lockFailedAuth => 'Xác thực thất bại';

  @override
  String get lockPleaseAuth => 'Vui lòng xác thực';

  @override
  String get lockRetry => 'Thử lại';

  @override
  String get lockBiometricReason => 'Xác thực để mở khóa.';

  @override
  String get lockBiometricFailure =>
      'Lỗi nghiêm trọng trong xác thực sinh trắc';

  @override
  String get lockWrongPin => 'PIN không đúng';

  @override
  String get lockPinMismatch => 'PIN không khớp';

  @override
  String lockPinCooldown(int seconds) {
    return 'Quá nhiều lần thử, hãy thử lại sau $seconds giây';
  }

  @override
  String get aboutVersion => 'Phiên bản';

  @override
  String get updaterFetching => 'Đang kiểm tra cập nhật...';

  @override
  String get updaterCheckFailed => 'Không thể kiểm tra cập nhật';

  @override
  String get updaterNewest => 'Bạn đang dùng phiên bản mới nhất';

  @override
  String updaterNewer(String version) {
    return 'Phiên bản mới hơn có sẵn: $version';
  }

  @override
  String get updaterNewerHeader => 'Phiên bản mới hơn có sẵn: ';

  @override
  String get aboutExperimentalPlatform => 'Nền tảng thử nghiệm';

  @override
  String get aboutExperimentalBody =>
      'Nền tảng này không được hỗ trợ. Dự kiến có lỗi và tính năng thiếu.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutUpstream => 'Nguồn gốc';

  @override
  String get aboutUpstreamBody => 'Ứng dụng này là một nhánh của clragon/e1547';

  @override
  String get aboutDiscord => 'Discord';

  @override
  String get aboutForum => 'Diễn đàn';

  @override
  String aboutForumTopic(num id) {
    return 'Chủ đề e621 #$id';
  }

  @override
  String get aboutWebsite => 'Trang web';

  @override
  String get aboutKofi => 'Ko-fi';

  @override
  String get aboutEmail => 'Email';

  @override
  String get aboutPlaystore => 'Playstore';

  @override
  String get aboutDonors => 'Người tài trợ';

  @override
  String get aboutDonorsThanks => 'Cảm ơn vì đã giúp tôi tiếp tục phát triển!';

  @override
  String get aboutNoDonors => 'Chưa có người tài trợ';

  @override
  String get aboutDonorsFailed => 'Không thể lấy danh sách người tài trợ';

  @override
  String get aboutDonorsNotListed =>
      'Không có trong danh sách? Liên hệ với chúng tôi!';

  @override
  String get developerUnlocked => 'Bạn giờ là nhà phát triển!';

  @override
  String get databaseErrorLoading => 'Lỗi tải cơ sở dữ liệu';

  @override
  String get databaseUnknownSize => 'Không xác định';

  @override
  String get databaseExportTitle => 'Xuất Cơ sở dữ liệu';

  @override
  String get databaseExportSubtitle => 'Lưu một bản sao lưu của cơ sở dữ liệu';

  @override
  String get databaseImportSubtitle =>
      'Thay thế cơ sở dữ liệu hiện tại bằng tệp đã nhập';

  @override
  String get databaseImportWarning =>
      'Điều này sẽ thay thế cơ sở dữ liệu hiện tại. \nTất cả dữ liệu sẽ mất. Không thể hoàn tác!';

  @override
  String get databaseExportSanitizedBody =>
      'Tệp xuất sẽ không chứa thông tin đăng nhập hoặc khóa API của bạn.\nMọi thứ khác, bao gồm tài khoản, máy chủ, lịch sử, theo dõi và tác vụ, đều được bao gồm.';

  @override
  String get databaseImportNewerFile =>
      'Tệp này được tạo bởi phiên bản ứng dụng mới hơn và không thể nhập.';

  @override
  String get databaseImportSanitized =>
      'Để an toàn, thông tin đăng nhập đã được xóa khỏi tệp đã nhập.';

  @override
  String databaseImportHostsWarning(String hosts) {
    return 'Cảnh báo: tệp đã nhập chứa tài khoản trên các trang khác: $hosts';
  }

  @override
  String get databaseImportCancelled => 'Đã hủy nhập';

  @override
  String get postsTitle => 'Bài đăng';

  @override
  String favoritesOf(String user) {
    return 'Sưu thích của $user';
  }

  @override
  String get favoritesUnavailable =>
      'Sưu thích không khả dụng cho người dùng ẩn danh';

  @override
  String get favoriteOrder => 'Thứ tự yêu thích';

  @override
  String get orderAdded => 'đã thêm';

  @override
  String get orderId => 'id thứ tự';

  @override
  String get postStateDeleted => 'đã xóa';

  @override
  String get postStateUnsupported => 'không được hỗ trợ';

  @override
  String get postStateUnavailable => 'không có sẵn';

  @override
  String get menuShare => 'Chia sẻ';

  @override
  String get menuDownload => 'Tải xuống';

  @override
  String get menuBrowse => 'Duyệt';

  @override
  String get menuEdit => 'Chỉnh sửa';

  @override
  String get menuComment => 'Bình luận';

  @override
  String get menuReport => 'Báo cáo';

  @override
  String get menuFlag => 'Đánh dấu';

  @override
  String get actionOpen => 'Mở';

  @override
  String get actionFollow => 'Theo dõi';

  @override
  String get actionUnfollow => 'Bỏ theo dõi';

  @override
  String get actionMute => 'Tắt tiếng';

  @override
  String get actionNotify => 'Thông báo';

  @override
  String get actionBookmark => 'Lưu lại';

  @override
  String get actionUnbookmark => 'Bỏ lưu';

  @override
  String get actionBlock => 'Chặn';

  @override
  String get actionUnblock => 'Bỏ chặn';

  @override
  String get actionRemove => 'Xóa';

  @override
  String get actionAdd => 'Thêm';

  @override
  String get actionSubtract => 'Trừ';

  @override
  String selectionPost(num id) {
    return 'bài #$id';
  }

  @override
  String selectionPostsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bài',
    );
    return '$_temp0';
  }

  @override
  String get noPosts => 'Không có bài';

  @override
  String get failedToLoadPosts => 'Không thể tải bài';

  @override
  String get offlineBanner => 'Bạn đang offline. Đang hiển thị dữ liệu đã lưu.';

  @override
  String get offlineNoData => 'Bạn đang offline';

  @override
  String postListPageSummary(num count, Object page) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bài',
      one: '$count bài',
    );
    return 'Trang $page · $_temp0';
  }

  @override
  String get postListPageLimit =>
      'Bạn đã đạt đến giới hạn trang của máy chủ. Vui lòng thu hẹp các điều kiện tìm kiếm.';

  @override
  String get postListJumpToPage => 'Đến trang';

  @override
  String get postListJumpPageLabel => 'Số trang';

  @override
  String postListJumpPageRange(Object max) {
    return 'Nhập số trang từ 1 đến $max';
  }

  @override
  String get postDeletedOverlay => 'Bài đã bị xóa';

  @override
  String get postUnavailableOverlay => 'Bài không có sẵn';

  @override
  String get postBlacklistedOverlay => 'Bài đã bị chặn';

  @override
  String unsupportedFileType(String ext) {
    return 'Tệp $ext không được hỗ trợ';
  }

  @override
  String get loginRequiredEdit => 'Bạn phải đăng nhập để chỉnh sửa bài!';

  @override
  String get loginRequiredComment => 'Bạn phải đăng nhập để bình luận!';

  @override
  String get loginRequiredReport => 'Bạn phải đăng nhập để báo cáo bài!';

  @override
  String get loginRequiredFlag => 'Bạn phải đăng nhập để đánh dấu bài!';

  @override
  String postsBlocked(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'đã chặn $count bài',
      one: 'đã chặn 1 bài',
    );
    return '$_temp0';
  }

  @override
  String get blacklistUpdateFailed => 'Cập nhật danh sách chặn thất bại!';

  @override
  String get blacklistAddTag => 'Thêm thẻ';

  @override
  String get blacklistEditTag => 'Chỉnh sửa thẻ';

  @override
  String get denylistEntryDeleted => 'Đã xóa mục chặn';

  @override
  String get blacklistEmpty => 'Danh sách chặn của bạn trống';

  @override
  String get menuDelete => 'Xóa';

  @override
  String get filterScore => 'Điểm';

  @override
  String get filterFavoriteCount => 'Số lượt thích';

  @override
  String get filterSortBy => 'Sắp xếp theo';

  @override
  String get filterNew => 'Mới';

  @override
  String get filterRank => 'Xếp hạng';

  @override
  String get filterRandom => 'Ngẫu nhiên';

  @override
  String get filterDefault => 'Mặc định';

  @override
  String get filterRating => 'Đánh giá';

  @override
  String get filterSafe => 'An toàn';

  @override
  String get filterQuestionable => 'Nghi vấn';

  @override
  String get filterExplicit => 'Rõ ràng';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterPool => 'Bộ sưu tập';

  @override
  String get filterHasPool => 'Có bộ sưu tập';

  @override
  String get filterChild => 'Con';

  @override
  String get filterIsChildPost => 'Là bài con';

  @override
  String get filterParent => 'Cha';

  @override
  String get filterIsParentPost => 'Là bài cha';

  @override
  String get filterUploadDate => 'Ngày tải lên';

  @override
  String get filterLastDay => 'Ngày cuối';

  @override
  String get filterLastWeek => 'Tuần cuối';

  @override
  String get filterLastMonth => 'Tháng cuối';

  @override
  String get filterLastYear => 'Năm cuối';

  @override
  String get filterStatus => 'Trạng thái';

  @override
  String get filterActive => 'Hoạt động';

  @override
  String get filterPending => 'Chờ xử lý';

  @override
  String get filterDeleted => 'Đã xóa';

  @override
  String get filterFlagged => 'Đã đánh dấu';

  @override
  String get filterAny => 'Bất kỳ';

  @override
  String get filterFileType => 'Loại tệp';

  @override
  String get filterUploader => 'Người tải lên';

  @override
  String get filterWidth => 'Chiều rộng';

  @override
  String get filterHeight => 'Chiều cao';

  @override
  String get filterTagCount => 'Số thẻ';

  @override
  String get filterTrue => 'Đúng';

  @override
  String get filterFalse => 'Sai';

  @override
  String get filterImages => 'Hình ảnh';

  @override
  String get filterVideos => 'Video';

  @override
  String get filterTitleContains => 'Tiêu đề chứa';

  @override
  String get filterCategory => 'Thể loại';

  @override
  String get filterGeneral => 'Chung';

  @override
  String get filterSiteBugReports => 'Báo cáo lỗi & Yêu cầu tính năng';

  @override
  String get filterTagWikiProjects => 'Dự án Wiki/Thẻ & Câu hỏi';

  @override
  String get filterTagAliasSuggestions => 'Gợi ý Thẻ bí danh & Ngụ ý';

  @override
  String get filterArtTalk => 'Thảo luận nghệ thuật';

  @override
  String get filterOffTopic => 'Nội dung không liên quan';

  @override
  String get filterE621Tools => 'Công cụ & Ứng dụng e621';

  @override
  String get filterNewestFirst => 'Mới nhất trước';

  @override
  String get filterOldestFirst => 'Cũ nhất trước';

  @override
  String get filterSticky => 'Ghim';

  @override
  String get filterIsSticky => 'Đã ghim';

  @override
  String get filterLocked => 'Khóa';

  @override
  String get filterIsLocked => 'Đã khóa';

  @override
  String get filterDescription => 'Mô tả';

  @override
  String get filterCreator => 'Người tạo';

  @override
  String get filterIsActive => 'Đang hoạt động';

  @override
  String get filterSeries => 'Series';

  @override
  String get filterCollection => 'Bộ sưu tập';

  @override
  String get filterName => 'Tên';

  @override
  String get filterCreated => 'Tạo lúc';

  @override
  String get filterUpdated => 'Cập nhật lúc';

  @override
  String get filterPostCount => 'Số bài';

  @override
  String postUpdateFailed(num id) {
    return 'Cập nhật bài #$id thất bại';
  }

  @override
  String postUpdated(num id) {
    return 'Đã cập nhật bài #$id';
  }

  @override
  String get failedToLoadPost => 'Tải bài thất bại';

  @override
  String get postNotFound => 'Không tìm thấy bài';

  @override
  String get commentsTitle => 'Bình luận';

  @override
  String commentsOfPost(num postId) {
    return 'Bình luận bài #$postId';
  }

  @override
  String get commentOrder => 'Sắp xếp bình luận';

  @override
  String get noComments => 'Không có bình luận';

  @override
  String get failedToLoadComments => 'Tải bình luận thất bại';

  @override
  String commentTitle(num id) {
    return 'Bình luận #$id';
  }

  @override
  String get failedToLoadComment => 'Tải bình luận thất bại';

  @override
  String get commentNotFound => 'Không tìm thấy bình luận';

  @override
  String commentEditorTitle(num postId) {
    return 'Bình luận bài #$postId';
  }

  @override
  String get commentSendFailed => 'Gửi bình luận thất bại!';

  @override
  String get commentSent => 'Đã gửi bình luận!';

  @override
  String get commentHidden => 'Bình luận này đã bị ẩn';

  @override
  String commentUpvoteFailed(num id) {
    return 'Không thể thích bình luận #$id';
  }

  @override
  String commentDownvoteFailed(num id) {
    return 'Không thể không thích bình luận #$id';
  }

  @override
  String get commentLoginRequiredEdit =>
      'Bạn phải đăng nhập để chỉnh sửa bình luận!';

  @override
  String get commentLoginRequiredReply =>
      'Bạn phải đăng nhập để trả lời bình luận!';

  @override
  String get commentLoginRequiredReport =>
      'Bạn phải đăng nhập để báo cáo bình luận!';

  @override
  String commentCopiedId(num id) {
    return 'Đã sao chép id bình luận #$id';
  }

  @override
  String get warningUserWarned =>
      'Người dùng đã nhận cảnh báo cho tin nhắn này';

  @override
  String get warningUserRecorded =>
      'Người dùng đã bị ghi nhận cho tin nhắn này';

  @override
  String get warningUserBanned => 'Người dùng đã bị cấm cho tin nhắn này';

  @override
  String get repliesTitle => 'Trả lời';

  @override
  String get replyOrder => 'Sắp xếp trả lời';

  @override
  String get noReplies => 'Không có trả lời';

  @override
  String get failedToLoadReplies => 'Tải trả lời thất bại';

  @override
  String replyTitle(num id) {
    return 'Trả lời #$id';
  }

  @override
  String get failedToLoadReply => 'Tải trả lời thất bại';

  @override
  String get replyNotFound => 'Không tìm thấy trả lời';

  @override
  String replyEditorTitle(num topicId) {
    return 'Trả lời #$topicId';
  }

  @override
  String get replySendFailed => 'Gửi trả lời thất bại!';

  @override
  String get replySent => 'Đã gửi trả lời!';

  @override
  String get replyHidden => 'Trả lời này đã bị ẩn';

  @override
  String get replyLoginRequiredEdit =>
      'Bạn phải đăng nhập để chỉnh sửa trả lời!';

  @override
  String get replyLoginRequiredReply => 'Bạn phải đăng nhập để trả lời!';

  @override
  String get replyLoginRequiredReport =>
      'Bạn phải đăng nhập để báo cáo trả lời!';

  @override
  String replyCopiedId(num id) {
    return 'Đã sao chép id trả lời #$id';
  }

  @override
  String get menuReply => 'Trả lời';

  @override
  String get menuCopyId => 'Sao chép ID';

  @override
  String get menuRefresh => 'Làm mới';

  @override
  String get actionCopy => 'Sao chép';

  @override
  String get actionSave => 'Lưu';

  @override
  String get actionShow => 'Hiện';

  @override
  String get actionHide => 'Ẩn';

  @override
  String get actionCannotBeUndone => 'Hành động này không thể hoàn tác.';

  @override
  String get info => 'Thông tin';

  @override
  String wikiTitle(String idOrTitle) {
    return 'Wiki $idOrTitle';
  }

  @override
  String get failedToLoadWiki => 'Tải wiki thất bại';

  @override
  String get wikiNotFound => 'Không tìm thấy wiki';

  @override
  String wikiCopiedId(num id) {
    return 'Đã sao chép id wiki #$id';
  }

  @override
  String get wikiInfoId => 'id';

  @override
  String get wikiInfoAlias => 'bí danh';

  @override
  String get wikiInfoCreated => 'tạo lúc';

  @override
  String get wikiInfoUpdated => 'cập nhật lúc';

  @override
  String get wikiInfoLocked => 'đã khóa';

  @override
  String get wikiInfoYes => 'có';

  @override
  String get wikiInfoNo => 'không';

  @override
  String userTitle(String idOrName) {
    return 'Người dùng $idOrName';
  }

  @override
  String get failedToLoadUser => 'Không thể tải người dùng';

  @override
  String get userNotFound => 'Không tìm thấy người dùng';

  @override
  String get userUploads => 'Đăng tải';

  @override
  String get userLoginRequiredReport =>
      'Bạn phải đăng nhập để báo cáo người dùng!';

  @override
  String get userComission => 'Đặt hàng';

  @override
  String get userId => 'id';

  @override
  String get userJoined => 'tham gia';

  @override
  String get userRank => 'xếp hạng';

  @override
  String get userPosts => 'bài đăng';

  @override
  String get userEdits => 'chỉnh sửa';

  @override
  String get userFavorites => 'yêu thích';

  @override
  String get userComments => 'bình luận';

  @override
  String get userForum => 'diễn đàn';

  @override
  String userCopiedId(num id) {
    return 'Đã sao chép id người dùng #$id';
  }

  @override
  String get logsTitle => 'Nhật ký';

  @override
  String logsTitleDate(String date) {
    return 'Nhật ký - $date';
  }

  @override
  String selectionLogsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nhật ký',
    );
    return '$_temp0';
  }

  @override
  String selectionLogsFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tệp nhật ký',
    );
    return '$_temp0';
  }

  @override
  String get logsLevels => 'Cấp độ';

  @override
  String get logsRecording => 'Đang ghi';

  @override
  String get logsVerbose => 'Chi tiết';

  @override
  String get logsVerboseAll => 'ghi tất cả cấp độ';

  @override
  String logsVerboseMinimum(String level) {
    return '$level và trở lên';
  }

  @override
  String get logFilesTitle => 'Tệp Nhật ký';

  @override
  String get failedToLoadLogFiles => 'Không thể tải tệp nhật ký!';

  @override
  String get noLogFiles => 'Không có tệp nhật ký nào!';

  @override
  String get logsLive => 'Trực tiếp';

  @override
  String get noLogs => 'Không có nhật ký';

  @override
  String get failedToReadLog => 'Không thể đọc nhật ký';

  @override
  String get noErrorsLogged => 'Không có lỗi nào được ghi';

  @override
  String logsErrorsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lỗi',
      one: '1 lỗi',
    );
    return '$_temp0';
  }

  @override
  String get logsAll => 'Tất cả nhật ký';

  @override
  String get logsDismissAll => 'Loại bỏ tất cả';

  @override
  String logsDeleteTitle(num count) {
    return 'Xóa $count tệp nhật ký?';
  }

  @override
  String get identityAccounts => 'Tài khoản';

  @override
  String get identityAdd => 'Thêm tài khoản';

  @override
  String get identityEdit => 'Chỉnh sửa tài khoản';

  @override
  String get identityRemoveTitle => 'Xóa tài khoản?';

  @override
  String get identityRemoveBody =>
      'Tất cả dữ liệu của nó sẽ bị xóa vĩnh viễn, bao gồm lịch sử và theo dõi.';

  @override
  String get identityAnonymous => 'Ẩn danh';

  @override
  String get identityCredentialsRejected =>
      'Trang web đã từ chối thông tin đăng nhập này. Hãy kiểm tra tên người dùng và khóa API.';

  @override
  String get identityVerifyUnreachable =>
      'Không thể kết nối với trang web để xác minh thông tin đăng nhập.';

  @override
  String get identityDuplicate =>
      'Bạn đã có một danh tính dưới host và tên người dùng này.';

  @override
  String identityLoginFailed(String reason) {
    return 'Đăng nhập thất bại. \n$reason';
  }

  @override
  String get identityLoginCheckDetails =>
      'Kiểm tra kết nối mạng và thông tin đăng nhập';

  @override
  String get identitySite => 'Trang web';

  @override
  String get identityHostRequired => 'Bạn phải cung cấp URL host.';

  @override
  String get identityHostInvalid => 'URL host không hợp lệ';

  @override
  String get identityHostReadOnly =>
      'Không thể thay đổi trang web. Thêm tài khoản mới để sử dụng trang khác.';

  @override
  String get identityUsernameLabel => 'Tên người dùng';

  @override
  String get identityUsernameRequired => 'Bạn phải cung cấp tên người dùng.';

  @override
  String get identityApikeyLabel => 'Khóa API';

  @override
  String get identityApikeyHelp => 'Tôi tìm khóa API của mình ở đâu?';

  @override
  String get identityApikeyRequired =>
      'Bạn phải cung cấp khóa API.\nví dụ: 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identityApikeyInvalid =>
      'Khóa API là một chuỗi 24 hoặc 32 ký tự từ a-z và 0-9\nví dụ: 1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  String get identitySignupPrompt => 'Chưa có tài khoản? Đăng ký tại đây';

  @override
  String get identityHostHint =>
      'Trang web lưu trữ tài khoản và bài đăng của bạn.';

  @override
  String get identitySignIn => 'Đăng nhập';

  @override
  String get identityGuest => 'Khách';

  @override
  String get identityLogin => 'Đăng nhập';

  @override
  String get identityBrowseAnonymously => 'Duyệt ẩn danh';

  @override
  String identityConnecting(String host, String username) {
    return 'Đang kết nối đến $host với tư cách $username…';
  }

  @override
  String identityActivateFailed(Object error) {
    return 'Không thể kích hoạt danh tính: $error';
  }

  @override
  String traitsActivateFailed(Object error) {
    return 'Không thể kích hoạt đặc điểm: $error';
  }

  @override
  String get failedToLoadIdentities => 'Không thể tải danh tính';

  @override
  String get onboardingSkip => 'Bỏ qua';

  @override
  String get onboardingBack => 'Quay lại';

  @override
  String get onboardingNext => 'Tiếp theo';

  @override
  String onboardingWelcomeTitle(String app) {
    return 'Chào mừng đến với $app';
  }

  @override
  String get onboardingWelcomeBody => 'Trình duyệt booru tinh vi.';

  @override
  String get onboardingThemeTitle => 'Chọn giao diện';

  @override
  String get onboardingThemeBody =>
      'Hãy thử một cái. Bạn luôn có thể thay đổi sau.';

  @override
  String get onboardingQualityTitle => 'Điều chỉnh phương tiện';

  @override
  String get onboardingQualityBody =>
      'Chọn cách tải video và hình thu nhỏ. Bạn có thể thay đổi sau trong cài đặt.';

  @override
  String get onboardingLoginTitle => 'Kết nối tài khoản';

  @override
  String get onboardingLanguageTitle => 'Chọn ngôn ngữ';

  @override
  String get followAddToSubscriptions => 'Thêm vào theo dõi';

  @override
  String get followNoSubscriptions => 'Không có theo dõi';

  @override
  String get followFailedToLoadSubscriptions => 'Không thể tải theo dõi';

  @override
  String get followAddToBookmarks => 'Thêm vào dấu trang';

  @override
  String get followNoBookmarks => 'Không có dấu trang';

  @override
  String get followFailedToLoadBookmarks => 'Không thể tải dấu trang';

  @override
  String get followUnseenPosts => 'bài đăng chưa xem';

  @override
  String followMarkPostsSeen(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'đánh dấu $count bài đã xem',
      one: 'đánh dấu 1 bài đã xem',
    );
    return '$_temp0';
  }

  @override
  String get followNoUnseenPosts => 'không có bài chưa xem';

  @override
  String get followShowUnseenFirst => 'hiển thị bài chưa xem trước';

  @override
  String get followFilteringUnseen => 'lọc bài chưa xem';

  @override
  String get followAllPostsShown => 'đã hiển thị tất cả bài';

  @override
  String get followForceSync => 'Đồng bộ buộc';

  @override
  String get followSyncAllFollows => 'đồng bộ tất cả theo dõi';

  @override
  String followSyncingFollows(String progress) {
    return 'đang đồng bộ theo dõi... $progress';
  }

  @override
  String get followEditorTitle => 'Chỉnh sửa theo dõi';

  @override
  String get followSubscribe => 'Theo dõi';

  @override
  String get followEditPrompt => 'Chỉnh sửa theo dõi';

  @override
  String get followTitlePrompt => 'Tên theo dõi';

  @override
  String get followMarkAsRead => 'Đánh dấu đã đọc';

  @override
  String get followDisableNotifications => 'Tắt thông báo';

  @override
  String get followEnableNotifications => 'Bật thông báo';

  @override
  String get followRename => 'Đổi tên';

  @override
  String followNewPosts(num count, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label bài mới',
      one: '1 bài mới',
    );
    return '$_temp0';
  }

  @override
  String followSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count theo dõi',
      one: '1 theo dõi',
    );
    return '$_temp0';
  }

  @override
  String followAlias(String? alias) {
    return 'bí danh $alias';
  }

  @override
  String historySelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mục',
      one: '1 mục',
    );
    return '$_temp0';
  }

  @override
  String historyEntriesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã xóa $count mục lịch sử',
      one: 'Đã xóa 1 mục lịch sử',
    );
    return '$_temp0';
  }

  @override
  String get historyClear => 'Xóa lịch sử';

  @override
  String get historyClearSubtitle => 'Xóa tất cả mục';

  @override
  String get historyClearConfirm => 'Xóa lịch sử?';

  @override
  String get historyClearConfirmBody =>
      'Tất cả mục lịch sử sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.';

  @override
  String get historyClearAction => 'Xóa';

  @override
  String get historyLimit => 'Giới hạn lịch sử';

  @override
  String historyLimitEnableBody(String amount, num months) {
    return 'Bật giới hạn lịch sử có nghĩa là tất cả mục lịch sử cũ hơn $months tháng và nhiều hơn $amount mục sẽ bị xóa tự động.';
  }

  @override
  String get historyLimitTitle => 'Giới hạn lịch sử';

  @override
  String historyLimitOn(String amount, num months) {
    return 'Giới hạn dưới $months tháng hoặc ít hơn $amount mục.';
  }

  @override
  String get historyLimitOff => 'lịch sử không giới hạn';

  @override
  String get historyEntries => 'Mục';

  @override
  String get historyType => 'Loại';

  @override
  String get historyItems => 'Mục';

  @override
  String get historySearches => 'Tìm kiếm';

  @override
  String get historyWikis => 'Wiki';

  @override
  String get historyUsers => 'Người dùng';

  @override
  String get historyEmpty => 'Lịch sử của bạn trống';

  @override
  String get historyFailedToLoad => 'Không thể tải lịch sử';

  @override
  String get historyNoDescription => 'không mô tả';

  @override
  String get historyHotPosts => 'Bài hot';

  @override
  String historyLinkPost(num id) {
    return 'Bài #$id';
  }

  @override
  String historyLinkUser(num id) {
    return 'Người dùng #$id';
  }

  @override
  String historyLinkWiki(num id) {
    return 'Wiki #$id';
  }

  @override
  String historyLinkUserByName(String id) {
    return '$id - Người dùng';
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
  String get poolEmpty => 'Không có bộ sưu tập';

  @override
  String get poolFailedToLoadPools => 'Không thể tải bộ sưu tập';

  @override
  String get poolTitle => 'Tên bộ sưu tập';

  @override
  String get poolInfoPosts => 'bài';

  @override
  String get poolInfoId => 'id';

  @override
  String get poolInfoActivity => 'hoạt động';

  @override
  String get poolInfoActive => 'hoạt động';

  @override
  String get poolInfoInactive => 'không hoạt động';

  @override
  String get poolInfoCreated => 'tạo';

  @override
  String get poolInfoUpdated => 'cập nhật';

  @override
  String poolCopiedId(num id) {
    return 'Đã sao chép id bộ sưu tập #$id';
  }

  @override
  String poolLink(num id) {
    return 'Bộ sưu tập #$id';
  }

  @override
  String get poolFailedToLoadPool => 'Không thể tải bộ sưu tập';

  @override
  String get poolNotFound => 'Không tìm thấy bộ sưu tập';

  @override
  String get poolOrder => 'Thứ tự bộ sưu tập';

  @override
  String get poolOldestFirst => 'Cũ nhất trước';

  @override
  String get poolNewestFirst => 'Mới nhất trước';

  @override
  String get poolReaderMode => 'Chế độ đọc bộ sưu tập';

  @override
  String get poolReaderLargeImages => 'hình ảnh lớn';

  @override
  String get poolReaderNormalGrid => 'lưới thông thường';

  @override
  String get topicsTitle => 'Chủ đề';

  @override
  String get topicHideTagEdits => 'Ẩn chỉnh sửa tag';

  @override
  String get topicTagEditsHidden => 'ẩn';

  @override
  String get topicTagEditsVisible => 'hiện';

  @override
  String topicLink(num id) {
    return 'Chủ đề #$id';
  }

  @override
  String get topicFailedToLoadTopic => 'Không thể tải chủ đề';

  @override
  String get topicNotFound => 'Không tìm thấy chủ đề';

  @override
  String get topicEmpty => 'Không có chủ đề';

  @override
  String get topicFailedToLoadTopics => 'Không thể tải chủ đề';

  @override
  String get topicInfoReplies => 'trả lời';

  @override
  String get topicInfoId => 'id';

  @override
  String topicCopiedId(num id) {
    return 'Đã sao chép id chủ đề #$id';
  }

  @override
  String get topicInfoLocked => 'khóa';

  @override
  String get topicInfoYes => 'có';

  @override
  String get topicInfoNo => 'không';

  @override
  String get topicInfoCreated => 'tạo';

  @override
  String get topicInfoUpdated => 'cập nhật';

  @override
  String get filterTags => 'Thẻ';

  @override
  String get loginRequired => 'Bạn cần đăng nhập để thực hiện hành động này.';

  @override
  String get actionChooseIdentity => 'Chọn danh tính';

  @override
  String get dateToday => 'Hôm nay';

  @override
  String get dateYesterday => 'Hôm qua';

  @override
  String detailCommentsButton(num count) {
    return 'BÌNH LUẬN ($count)';
  }

  @override
  String get detailFile => 'Tệp';

  @override
  String get detailSources => 'Nguồn';

  @override
  String get detailNoSources => 'không nguồn';

  @override
  String get detailChildren => 'Con';

  @override
  String get detailDeletion => 'Xóa';

  @override
  String get detailBlacklisted => 'Đen';

  @override
  String get detailNoArtist => 'không nghệ sĩ';

  @override
  String detailPoolPosts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bài viết',
      one: '1 bài viết',
    );
    return '$_temp0';
  }

  @override
  String postCopiedId(num id) {
    return 'Đã sao chép ID bài viết #$id';
  }

  @override
  String postUpvoteFailed(num id) {
    return 'Không thể upvote bài viết #$id';
  }

  @override
  String postDownvoteFailed(num id) {
    return 'Không thể downvote bài viết #$id';
  }

  @override
  String postAddFavoriteFailed(num id) {
    return 'Không thể thêm bài viết #$id vào yêu thích';
  }

  @override
  String postRemoveFavoriteFailed(num id) {
    return 'Không thể bỏ bài viết #$id khỏi yêu thích';
  }

  @override
  String get editorSection => 'Phần';

  @override
  String get editorQuote => 'Trích dẫn';

  @override
  String get editorCode => 'Mã';

  @override
  String get editorSpoiler => 'Tiết lộ';

  @override
  String get editorBold => 'Đậm';

  @override
  String get editorItalic => 'Nghiêng';

  @override
  String get editorUnderlined => 'Gạch chân';

  @override
  String get editorStrikethrough => 'Gạch ngang';

  @override
  String get editorPreviewPlaceholder => 'văn bản của bạn ở đây';

  @override
  String get editorWrite => 'Viết';

  @override
  String get editorPreview => 'Xem trước';

  @override
  String get editorTypeHere => 'nhập ở đây...';

  @override
  String get tagNoTags => 'không thẻ';

  @override
  String get tagFailedToLoadTags => 'tải thẻ thất bại';

  @override
  String get tagUnableToRetrieveWiki => 'không thể lấy mục wiki';

  @override
  String get tagNoWikiEntry => 'không có mục wiki';

  @override
  String get tagCategoryGeneral => 'Chung';

  @override
  String get tagCategorySpecies => 'Loài';

  @override
  String get tagCategoryCharacter => 'Nhân vật';

  @override
  String get tagCategoryCopyright => 'Bản quyền';

  @override
  String get tagCategoryMeta => 'Meta';

  @override
  String get tagCategoryLore => 'Lore';

  @override
  String get tagCategoryArtist => 'Nghệ sĩ';

  @override
  String get tagCategoryContributor => 'Đóng góp';

  @override
  String get tagCategoryInvalid => 'Không hợp lệ';

  @override
  String editDescriptionTitle(num postId) {
    return 'Mô tả #$postId';
  }

  @override
  String get editDescriptionHint => 'Nhập mô tả bài viết...';

  @override
  String get editInvalidNumber => 'Định dạng số không hợp lệ';

  @override
  String get editInvalidParent => 'Bài viết cha không hợp lệ';

  @override
  String get editParentIdLabel => 'ID Cha (tùy chọn)';

  @override
  String get editParentIdHint => 'ID bài viết cha';

  @override
  String get editReasonLabel => 'Lý do chỉnh sửa (tùy chọn)';

  @override
  String get editReasonHint => 'Tại sao bạn đang chỉnh sửa bài viết này?';

  @override
  String editSourcesTitle(num postId) {
    return 'Nguồn #$postId';
  }

  @override
  String get editTagsHint => 'các thẻ cách nhau bằng dấu cách';

  @override
  String editTagPreviewFailed(String error) {
    return 'Lỗi tải xem trước thẻ: $error';
  }

  @override
  String get editTagStatusNew => 'mới';

  @override
  String get editTagStatusInvalid => 'không hợp lệ';

  @override
  String get editTagStatusEmpty => 'rỗng';

  @override
  String get editTagStatusUnderused => 'ít dùng';

  @override
  String reportCommentSuccess(num id) {
    return 'Đã báo cáo bình luận #$id';
  }

  @override
  String reportCommentFailed(num id) {
    return 'Báo cáo bình luận #$id thất bại';
  }

  @override
  String reportReplySuccess(num id) {
    return 'Đã báo cáo trả lời #$id';
  }

  @override
  String reportReplyFailed(num id) {
    return 'Báo cáo trả lời #$id thất bại';
  }

  @override
  String reportUserSuccess(num id) {
    return 'Đã báo cáo người dùng #$id';
  }

  @override
  String reportUserFailed(num id) {
    return 'Báo cáo người dùng #$id thất bại';
  }

  @override
  String reportPostSuccess(num id) {
    return 'Đã báo cáo bài viết #$id';
  }

  @override
  String reportPostFailed(num id) {
    return 'Báo cáo bài viết #$id thất bại';
  }

  @override
  String get reportTypeRequired => 'Loại không được để trống';

  @override
  String get reportReason => 'Lý do';

  @override
  String get reportReasonRequired => 'Lý do không được để trống';

  @override
  String get reportSubmitted => 'Đã gửi báo cáo';

  @override
  String get reportSubmitFailed => 'Gửi báo cáo thất bại';

  @override
  String get reportTypeRating => 'Lạm dụng đánh giá';

  @override
  String get reportTypeFile => 'Tệp độc hại';

  @override
  String get reportTypeSource => 'Nguồn độc hại';

  @override
  String get reportTypeDescription => 'Lạm dụng mô tả';

  @override
  String get reportTypeNote => 'Lạm dụng ghi chú';

  @override
  String get reportTypeTagging => 'Lạm dụng thẻ';

  @override
  String get reportTypeRatingBody =>
      'Đánh giá của bài viết đã được đặt thành điều gì đó không chính xác.';

  @override
  String get reportTypeFileBody =>
      'Tệp chứa mã độc hoặc chứa tệp lưu trữ ẩn. Điều này không dành cho hình ảnh được mô tả trong hình ảnh.';

  @override
  String get reportTypeSourceBody =>
      'Một hoặc nhiều nguồn được liệt kê liên kết đến trang độc hại hoặc nội dung trả phí.';

  @override
  String get reportTypeDescriptionBody =>
      'Mô tả chứa nội dung độc hại, hoặc đã được chỉnh sửa để chứa tài liệu lạm dụng.';

  @override
  String get reportTypeNoteBody =>
      'Ghi chú trên bài viết này sai, quấy rối, hoặc khác biệt lạm dụng.';

  @override
  String get reportTypeTaggingBody =>
      'Một hoặc nhiều thẻ trên bài viết này không hợp lệ hoặc một hoặc nhiều thẻ hợp lệ đã bị xóa khỏi bài viết này.';

  @override
  String flagPostSuccess(num id) {
    return 'Đã đánh cờ bài viết #$id';
  }

  @override
  String flagPostFailed(num id) {
    return 'Không thể báo cáo bài #$id';
  }

  @override
  String get flagParentId => 'ID bài gốc';

  @override
  String get flagParentIdRequired => 'ID bài gốc không được để trống';

  @override
  String get flagParentIdInvalid => 'ID bài gốc phải là số';

  @override
  String get flagTypeUploadingGuidelines => 'Không đáp ứng hướng dẫn tải lên';

  @override
  String get flagTypeYoungHuman =>
      'Nhân vật dạng người trong tình huống nhạy cảm';

  @override
  String get flagTypeDnpArtist =>
      'Nghệ sĩ của bài này nằm trong danh sách tránh đăng';

  @override
  String get flagTypePayContent =>
      'Nội dung trả phí, thương mại hoặc thành viên';

  @override
  String get flagTypeTrace => 'Sao chép tác phẩm của nghệ sĩ khác';

  @override
  String get flagTypePreviouslyDeleted => 'Đã bị xóa trước đó';

  @override
  String get flagTypeRealPorn => 'Phòng tình thật';

  @override
  String get flagTypeCorrupt => 'Tệp bị hỏng, lỗi hoặc không hoạt động';

  @override
  String get flagTypeInferior => 'Bản sao hoặc phiên bản kém hơn của bài khác';

  @override
  String get flagTypeUploadingGuidelinesBody =>
      'Bài này không đạt tiêu chuẩn của trang, dù về giá trị nghệ thuật, chất lượng hình ảnh, sự liên quan hoặc điều gì khác.\nLưu ý rằng sở thích cá nhân của bạn không ảnh hưởng đến việc này. Nếu bạn thấy nội dung của bài này không phù hợp, hãy thêm vào [[e621:blacklist|danh sách chặn]].';

  @override
  String get flagTypeYoungHumanBody =>
      'Các bài có nhân vật dạng người được mô tả theo cách nhạy cảm hoặc khỏa thân không được chấp nhận trên trang này.';

  @override
  String get flagTypeDnpArtistBody =>
      'Một số nghệ sĩ đã yêu cầu không đăng tác phẩm của họ trên trang này và đã được cấp trạng thái [[avoid_posting|Không Đăng]].\nĐôi khi trạng thái đó đi kèm điều kiện; xem [[conditional_dnp]] để biết thêm thông tin';

  @override
  String get flagTypePayContentBody =>
      'Chúng tôi không lưu trữ nội dung trả phí hoặc thương mại của bất kỳ loại nào. Điều này bao gồm rò rỉ Patreon, đăng lại từ các trang web vi phạm bản quyền, v.v.';

  @override
  String get flagTypeTraceBody =>
      'Hình ảnh sao chép từ tác phẩm của nghệ sĩ khác không được chấp nhận trên trang này. Tham khảo từ thứ gì đó là được, nhưng sao chép hoàn toàn công việc của người khác thì không.\nVui lòng để lại thêm thông tin trong bình luận, hoặc thêm tác phẩm gốc làm bài cha của bài này nếu nó được lưu trữ trên trang này.';

  @override
  String get flagTypePreviouslyDeletedBody =>
      'Các bài thường bị xóa vì lý do chính đáng, và tải lại nội dung đã bị xóa là không được chấp nhận.\nVui lòng để lại thêm thông tin trong bình luận, hoặc thêm bài gốc làm bài cha của bài này.';

  @override
  String get flagTypeRealPornBody =>
      'Các bài có phòng tình thật không được chấp nhận trên trang này. Không có ngoại lệ.\nLưu ý rằng hình ảnh có ảnh chụp không nhạy cảm là được chấp nhận.';

  @override
  String get flagTypeCorruptBody =>
      'Có điều gì đó không ổn với bài này. Có thể là video bị lỗi, hoặc hình ảnh bị hỏng.\nBất kể thế nào, để tránh nhầm lẫn, vui lòng giải thích tình huống trong bình luận.';

  @override
  String get flagTypeInferiorBody =>
      'Một phiên bản tốt hơn của bài này đã có trên trang.\nĐiều này có thể bao gồm hình ảnh có chất lượng hình ảnh tốt hơn (lớn hơn, ít nén hơn), nhưng cũng có thể có các phiên bản \"sửa lỗi\", với những lỗi hình ảnh được nghệ sĩ khắc phục.\nLưu ý rằng chỉnh sửa và phiên bản thay đổi không thuộc danh mục này.';

  @override
  String get taskCancelAll => 'Hủy tất cả';

  @override
  String get taskClearDone => 'Xóa hoàn thành';

  @override
  String get taskClearSelection => 'Xóa lựa chọn';

  @override
  String get taskCancel => 'Hủy';

  @override
  String get taskDismiss => 'Đóng';

  @override
  String get taskNoTasks => 'Không có tác vụ';

  @override
  String get taskFailedToLoadTasks => 'Không thể tải tác vụ';

  @override
  String taskSelectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tác vụ',
      one: '1 tác vụ',
    );
    return '$_temp0';
  }

  @override
  String get taskGroupActive => 'Đang hoạt động';

  @override
  String get taskGroupFailed => 'Thất bại';

  @override
  String get taskActionDownload => 'tải xuống';

  @override
  String get taskActionFavorite => 'yêu thích';

  @override
  String get taskActionUnfavorite => 'bỏ yêu thích';

  @override
  String get taskDownloadRunning => 'đang tải xuống';

  @override
  String get taskFavoriteRunning => 'đang thêm vào yêu thích';

  @override
  String get taskUnfavoriteRunning => 'đang bỏ yêu thích';

  @override
  String get taskDownloadCompleted => 'đã tải xuống';

  @override
  String get taskFavoriteCompleted => 'đã thêm vào yêu thích';

  @override
  String get taskUnfavoriteCompleted => 'đã bỏ yêu thích';

  @override
  String taskQueuedTo(String action) {
    return 'đang chờ $action';
  }

  @override
  String taskFailedTo(String action) {
    return 'thất bại $action';
  }

  @override
  String taskCanceledAction(String action) {
    return 'đã hủy $action';
  }

  @override
  String taskTileTitle(String label, num id) {
    return '$label bài #$id';
  }

  @override
  String followNotificationBody(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'có $count bài mới!',
      one: 'có bài mới!',
    );
    return '$_temp0';
  }

  @override
  String get followNotificationSummary => 'Bài mới!';

  @override
  String get followNotificationHiddenBody =>
      'Các thẻ bạn theo dõi có bài đăng mới.';

  @override
  String get followHideNotificationContent => 'Ẩn nội dung thông báo';

  @override
  String get followHideNotificationContentHint =>
      'Ẩn tiêu đề, phần xem trước và hình thu nhỏ của thông báo';

  @override
  String get notificationStaleIdentity =>
      'Thông báo này thuộc về một tài khoản không còn trên thiết bị này.';

  @override
  String get followChannelName => 'Thẻ theo dõi';

  @override
  String get followChannelDescription =>
      'Thông báo về các thẻ bạn đang theo dõi';

  @override
  String get hostUnavailableTitle => 'Máy chủ không khả dụng';

  @override
  String hostUnavailableBody(String host) {
    return 'Có vẻ như $host không khả dụng!';
  }

  @override
  String get hostUnavailableResolveHint =>
      'Vui lòng giải quyết vấn đề trong cửa sổ trình duyệt sau.\n\nCookie xác nhận Cloudflare sẽ được lưu.';

  @override
  String get hostUnavailableResolve => 'Giải quyết';

  @override
  String hostUnavailableWaitBody(String host) {
    return '\nVui lòng chờ $host giải quyết tình huống trên máy chủ của họ.';
  }

  @override
  String get downloadChooseFolder => 'Chọn thư mục';

  @override
  String get searchFilterTitle => 'Bộ lọc';

  @override
  String get searchFilterQueryLabel => 'Truy vấn hiện tại:';

  @override
  String get filterSectionSort => 'Sắp xếp';

  @override
  String get filterSectionContent => 'Nội dung';

  @override
  String get filterSectionTime => 'Thời gian & trạng thái';

  @override
  String get filterSectionMedia => 'Phương tiện';

  @override
  String get filterSectionOther => 'Khác';

  @override
  String get searchFilterReset => 'Đặt lại bộ lọc';

  @override
  String get dtextParsingFailed => 'Phân tích DText thất bại';

  @override
  String get filteredShow => 'Hiển thị';

  @override
  String get filteredHide => 'Ẩn';

  @override
  String get selectOptions => 'Chọn tùy chọn...';

  @override
  String get databaseNotE1547 => 'Đây không phải là cơ sở dữ liệu e1547.';

  @override
  String get adultGateTitle => 'Kiểm tra nhanh';

  @override
  String get adultGateBody =>
      'Ứng dụng này dẫn thẳng đến e621, một cộng đồng nghệ thuật chỉ dành cho người lớn. Vui lòng xác nhận rằng bạn đã đủ tuổi pháp lý nơi bạn sống — chúng tôi tin bạn, luật sư của chúng tôi thì không.';

  @override
  String get adultGateConfirm => 'Chắc chắn rồi — tôi trên 18 tuổi';

  @override
  String get adultGateDeny => 'Đưa tôi trở lại';

  @override
  String get databaseExportPasswordLabel => 'Mật khẩu (tùy chọn)';

  @override
  String get databaseExportPasswordHint =>
      'Mã hóa tệp xuất. Để trống để xuất tệp văn bản thuần túy, không mã hóa.';

  @override
  String get databaseImportEncryptedTitle => 'Cơ sở dữ liệu mã hóa';

  @override
  String get databaseImportPasswordLabel => 'Mật khẩu';

  @override
  String get databaseImportWrongPassword => 'Mật khẩu sai hoặc tệp bị hỏng.';

  @override
  String get actionUnlock => 'MỞ KHÓA';

  @override
  String get editorDiscardTitle => 'Discard changes?';

  @override
  String get editorDiscardBody => 'Your changes have not been submitted.';

  @override
  String get editorDiscardConfirm => 'Discard';

  @override
  String get editorContinueEditing => 'Continue editing';

  @override
  String postListGoingToPage(num page) {
    return 'Going to page $page';
  }

  @override
  String get actionRetry => 'Retry';

  @override
  String get selectionQueueDownloadsFailed => 'Failed to queue downloads';

  @override
  String get selectionQueueFavoritesFailed => 'Failed to queue favorites';
}
