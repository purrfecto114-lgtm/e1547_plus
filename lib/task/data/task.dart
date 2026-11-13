import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    required int id,
    required TaskAction action,
    required int postId,
    required TaskStatus status,
    required String? error,
    required DateTime createdAt,
    required DateTime? completedAt,
    required TaskMetadata? metadata,
  }) = _Task;
}

@freezed
abstract class TaskRequest with _$TaskRequest {
  const factory TaskRequest({
    required TaskAction action,
    required int postId,
    TaskMetadata? metadata,
  }) = _TaskRequest;
}

@freezed
abstract class TaskMetadata with _$TaskMetadata {
  const factory TaskMetadata({
    String? previewUrl,
    String? fileUrl,
    String? fileName,
  }) = _TaskMetadata;

  factory TaskMetadata.fromJson(Map<String, dynamic> json) =>
      _$TaskMetadataFromJson(json);
}

enum TaskAction { download, favorite, unfavorite }

enum TaskStatus { pending, running, completed, failed, canceled }

extension TaskStatusX on TaskStatus {
  /// Still queued or in progress.
  bool get isActive => this == TaskStatus.pending || this == TaskStatus.running;

  /// Finished, regardless of outcome.
  bool get isTerminal =>
      this == TaskStatus.completed ||
      this == TaskStatus.failed ||
      this == TaskStatus.canceled;
}

/// A user-comprehensible reason why a task failed.
///
/// The raw exception text stays in [Task.error] for the technical details;
/// this is the category that decides which hint and which next step the
/// interface offers for a failure.
enum TaskErrorCategory {
  /// The save destination could not be determined or written to.
  directory,

  /// The server rejected this account's credentials.
  auth,

  /// The transfer could not reach the server or timed out.
  network,

  /// The finished download could not be written to the gallery.
  saving,

  /// Anything else.
  unknown,
}

/// Maps a stored task error onto the category that explains the failure.
///
/// The error text is whatever [Object.toString] produced when the task
/// failed — usually a `FileDownloadException`, possibly wrapping a
/// `DioException` — so the matching relies on stable fragments of those
/// texts rather than on exception types, which the database does not keep.
TaskErrorCategory categorizeTaskError(String? error) {
  if (error == null) return TaskErrorCategory.unknown;
  final String text = error.toLowerCase();
  bool containsAny(List<String> needles) =>
      needles.any((needle) => text.contains(needle));
  // The plain marker of the directory picker being dismissed.
  if (text.contains('no directory was selected')) {
    return TaskErrorCategory.directory;
  }
  // Storage-level rejections of the destination.
  if (containsAny(['permission', 'eacces', 'eperm', 'access denied'])) {
    return TaskErrorCategory.directory;
  }
  // Credential rejections, as the api reports them.
  if (containsAny([
    'status code of 401',
    'status code of 403',
    'unauthorized',
    'forbidden',
    'credentials',
    'authentication',
    'api key',
  ])) {
    return TaskErrorCategory.auth;
  }
  // Anything that kept the transfer from the server.
  if (containsAny([
    'connection',
    'timeout',
    'timed out',
    'socket',
    'network',
    'host lookup',
  ])) {
    return TaskErrorCategory.network;
  }
  if (text.contains('saving to the gallery failed')) {
    return TaskErrorCategory.saving;
  }
  return TaskErrorCategory.unknown;
}
