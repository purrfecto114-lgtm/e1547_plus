import 'package:e1547/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history.freezed.dart';
part 'history.g.dart';

/// The maximum length of a history entry's subtitle, in code points.
///
/// Subtitles carry post and pool descriptions, wiki bodies and forum
/// replies, which regularly exceed what a history tile could display;
/// storing them whole only bloats the database. They are cut down
/// before they are stored, counting code points so that no surrogate
/// pair is split in half.
const int historySubtitleLimit = 500;

extension HistorySubtitleTruncating on String {
  /// Truncates this string for use as a history entry's subtitle.
  String truncateHistorySubtitle() => ellipse(historySubtitleLimit);
}

@freezed
abstract class History with _$History {
  const factory History({
    required int id,
    required DateTime visitedAt,
    required String link,
    required HistoryCategory category,
    required HistoryType type,
    required String? title,
    required String? subtitle,
    required List<String> thumbnails,
  }) = _History;

  factory History.fromJson(dynamic json) => _$HistoryFromJson(json);
}

@freezed
abstract class HistoryRequest with _$HistoryRequest {
  const factory HistoryRequest({
    required DateTime visitedAt,
    required String link,
    required HistoryCategory category,
    required HistoryType type,
    String? title,
    String? subtitle,
    @Default([]) List<String> thumbnails,
  }) = _HistoryRequest;

  factory HistoryRequest.fromJson(dynamic json) =>
      _$HistoryRequestFromJson(json);
}

enum HistoryCategory { items, searches }

enum HistoryType { posts, pools, topics, users, wikis }
