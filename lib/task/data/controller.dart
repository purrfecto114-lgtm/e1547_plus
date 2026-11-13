import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/task/task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum TaskKind { none, download, favorite, unfavorite, mixed, done }

const Duration _lingerAfterDone = Duration(seconds: 2);

/// Batches that ended with failures keep their summary around longer, so
/// the outcome can actually be read before the bubble hides again.
const Duration _lingerAfterFailure = Duration(seconds: 6);

/// The phase a running download task is in.
enum TaskDownloadPhase { downloading, saving }

/// Live progress of a running download task.
@immutable
class TaskDownloadProgress {
  const TaskDownloadProgress({
    this.phase = TaskDownloadPhase.downloading,
    this.transferred = 0,
    this.total,
  });

  /// Bytes received so far. While saving, this is whatever the final
  /// report of the transfer left behind.
  final int transferred;

  /// The total length the response announced, or null when it did not.
  final int? total;

  /// Whether the finished file is currently being exported.
  final TaskDownloadPhase phase;

  /// The fraction of the transfer that has arrived, or null when the
  /// length is unknown or the file is being saved.
  double? get fraction {
    if (phase != TaskDownloadPhase.downloading) return null;
    if (total == null || total! <= 0) return null;
    return (transferred / total!).clamp(0, 1);
  }
}

/// Exports a fetched download file into the user's gallery folder. Injectable
/// like [DownloadFileFetcher], so tests can hold the export itself open.
///
/// Returns the location the export actually wrote, when it can be addressed
/// for a later rollback; see [FileDownloader.downloadFile].
typedef FileExporter =
    Future<String?> Function({
      required File file,
      required String? directory,
      String? folderName,
      String? fileName,
      void Function(String dir)? onDirectoryChanged,
    });

Future<String?> exportDownloadFile({
  required File file,
  required String? directory,
  String? folderName,
  String? fileName,
  void Function(String dir)? onDirectoryChanged,
}) => FileDownloader.downloadImage(
  file: file,
  directory: directory,
  folderName: folderName,
  fileName: fileName,
  onDirectoryChanged: onDirectoryChanged,
);

class TasksController extends ChangeNotifier {
  TasksController({
    required this.repository,
    required this.client,
    required this.cacheManager,
    required this.settings,
    required this.identity,
    DownloadFileFetcher? fileFetcher,
    this.exporter = exportDownloadFile,
  }) : _injectedFetcher = fileFetcher {
    _init();
  }

  final TaskRepository repository;
  final Client client;
  final BaseCacheManager cacheManager;
  final Settings settings;
  final int identity;

  final DownloadFileFetcher? _injectedFetcher;

  /// The single credential-free client that all of this controller's
  /// downloads travel on, so its connection pool is reused across the
  /// files of a whole batch instead of being rebuilt per file.
  Dio? _transferClient;

  Dio get transferClient => _transferClient ??= createTransferClient();

  /// Fetches download files over the network; canceling its token aborts
  /// the transfer itself, not just the listening side. Defaults to a
  /// fetcher that shares [transferClient].
  DownloadFileFetcher get fileFetcher =>
      _injectedFetcher ?? _fetchWithTransferClient;

  Future<File> _fetchWithTransferClient(
    String url,
    CancelToken cancelToken,
    void Function(int count, int? total)? onProgress,
  ) => fetchFileToTemp(url, cancelToken, onProgress, client: transferClient);

  /// Exports fetched files into the user's gallery folder.
  final FileExporter exporter;

  late final Logger _logger = Logger('TasksController', {'identity': identity});

  List<Task> _active = const [];
  List<Task> get active => _active;

  int _runningTotal = 0;
  int _runningDone = 0;
  int get runningTotal => _runningTotal;
  int get runningDone => _runningDone;

  /// Tasks of the current batch that completed successfully.
  int _runningSucceeded = 0;

  /// Tasks of the current batch that failed.
  int _runningFailed = 0;

  /// Tasks of the current batch that were canceled.
  int _runningCanceled = 0;

  /// Tasks of the current batch that completed successfully.
  int get runningSucceeded => _runningSucceeded;

  /// Tasks of the current batch that failed.
  int get runningFailed => _runningFailed;

  /// Tasks of the current batch that were canceled.
  int get runningCanceled => _runningCanceled;

  final Set<int> _runningIds = {};
  bool isRunning(int taskId) => _runningIds.contains(taskId);

  /// Live download workers; each exits when the queue is empty, and any
  /// enqueue spawns replacements up to the concurrency limit. Without this,
  /// tasks arriving while every worker is busy would wait for a worker to
  /// free up, collapsing the queue to a single lane.
  int _downloadWorkers = 0;

  /// Whether the sequential api lane has a worker.
  bool _apiWorkerActive = false;

  /// Whether a favorite or unfavorite task of this controller succeeded
  /// since the api lane last went idle. The favorites query is then
  /// revalidated once per batch instead of once per task.
  bool _favoritesDirty = false;

  /// Cancel tokens of in-flight download transfers, so canceling a task
  /// aborts its network transfer.
  final Map<int, CancelToken> _cancelTokens = {};

  /// Sum of in-flight progress across all running tasks (0..n), driving the
  /// aggregate bubble progress.
  final ValueNotifier<double> currentProgress = ValueNotifier(0);

  /// Per-task download progress, so each running tile updates on its own
  /// without rebuilding the others.
  final Map<int, ValueNotifier<TaskDownloadProgress>> _progress = {};
  ValueListenable<TaskDownloadProgress>? progressOf(int taskId) =>
      _progress[taskId];

  /// Bytes received so far by the batch's in-flight downloads.
  int _runningTransferred = 0;

  /// Whether any in-flight download has an unknown length.
  bool _runningUnknownLength = false;

  /// Whether any in-flight download is exporting its finished file.
  bool _runningSaving = false;

  /// Bytes received so far by the batch's in-flight downloads.
  int get runningTransferred => _runningTransferred;

  /// Whether any in-flight download has an unknown length or is already
  /// saving its file, which makes an aggregate percentage meaningless.
  bool get runningIndeterminate => _runningUnknownLength || _runningSaving;

  /// Whether any in-flight download is exporting its finished file.
  bool get runningSaving => _runningSaving;

  StreamSubscription<List<Task>>? _activeSub;
  Timer? _hideTimer;
  bool _seeded = false;
  bool _disposed = false;

  // Downloads hit the CDN, which is free of the API rate limit, so they run
  // concurrently. Favorites and unfavorites stay on a single sequential lane.
  static const int _maxConcurrentDownloads = 4;

  // Kept separate from the controller's own listeners so toggling doesn't
  // mark Provider scopes dirty mid-build.
  final ValueNotifier<bool> suppressBubble = ValueNotifier<bool>(false);

  TaskKind get kind {
    if (_active.isEmpty) {
      return _runningTotal > 0 ? TaskKind.done : TaskKind.none;
    }
    final actions = _active.map((e) => e.action).toSet();
    if (actions.length > 1) return TaskKind.mixed;
    return switch (actions.first) {
      TaskAction.download => TaskKind.download,
      TaskAction.favorite => TaskKind.favorite,
      TaskAction.unfavorite => TaskKind.unfavorite,
    };
  }

  double get progress {
    if (_runningTotal == 0) return 0;
    return ((_runningDone + currentProgress.value) / _runningTotal).clamp(0, 1);
  }

  void _recomputeProgress() {
    if (_disposed) return;
    double inFlight = 0;
    int transferred = 0;
    bool unknown = false;
    bool saving = false;
    for (final notifier in _progress.values) {
      final TaskDownloadProgress progress = notifier.value;
      inFlight += progress.fraction ?? 0;
      transferred += progress.transferred;
      unknown =
          unknown ||
          (progress.phase == TaskDownloadPhase.downloading &&
              progress.total == null);
      saving = saving || progress.phase == TaskDownloadPhase.saving;
    }
    currentProgress.value = inFlight;
    final bool aggregatesChanged =
        _runningTransferred != transferred ||
        _runningUnknownLength != unknown ||
        _runningSaving != saving;
    _runningTransferred = transferred;
    _runningUnknownLength = unknown;
    _runningSaving = saving;
    // The fraction can stay put while the byte counts behind it move, e.g.
    // for a transfer without a length; the bubble listens for those too.
    if (aggregatesChanged) {
      notifyListeners();
    }
  }

  Future<void> _init() async {
    await repository.resetRunning(identity: identity);
    // the controller may be disposed while the reset is in flight; leaving
    // now keeps the active watch from outliving the controller
    if (_disposed) return;
    _activeSub = repository.active(identity: identity).stream.listen((list) {
      final bool wasActive = _active.isNotEmpty;
      _active = list;
      if (!_seeded) {
        _seeded = true;
        if (list.isNotEmpty) {
          _runningTotal = list.length;
          _runningDone = 0;
        }
      }
      if (list.isNotEmpty) {
        _hideTimer?.cancel();
        _hideTimer = null;
        // a task may have been enqueued by a controller that was disposed
        // before the insert landed; picking work up again here keeps such
        // tasks from waiting for the next user action
        if (!wasActive) _kick();
      } else if (wasActive) {
        _hideTimer?.cancel();
        _hideTimer = Timer(_lingerForOutcome(), _resetCounters);
      }
      notifyListeners();
    });
    unawaited(_runSweep());
    _kick();
  }

  /// How long a finished batch keeps its bubble on screen.
  ///
  /// A batch with failures shows a summary instead of a bare checkmark, so
  /// it gets more time than the usual confirmation blink.
  Duration _lingerForOutcome() =>
      _runningFailed > 0 ? _lingerAfterFailure : _lingerAfterDone;

  void _resetCounters() {
    if (_disposed) return;
    _runningTotal = 0;
    _runningDone = 0;
    _runningSucceeded = 0;
    _runningFailed = 0;
    _runningCanceled = 0;
    notifyListeners();
  }

  Future<void> _runSweep() async {
    try {
      await repository.sweep(
        action: TaskAction.download,
        status: TaskStatus.completed,
        maxAge: const Duration(days: 7),
      );
      for (final action in const [TaskAction.favorite, TaskAction.unfavorite]) {
        await repository.sweep(
          action: action,
          status: TaskStatus.completed,
          maxAge: const Duration(days: 1),
        );
      }
      for (final action in TaskAction.values) {
        await repository.sweep(
          action: action,
          status: TaskStatus.canceled,
          maxAge: const Duration(days: 1),
        );
      }
      // Failed tasks — downloads and favorites alike — are kept by age, so
      // users can come back to them the next day; anything older than the
      // retention window gives way, without a count limit.
      for (final action in TaskAction.values) {
        await repository.sweep(
          action: action,
          status: TaskStatus.failed,
          maxAge: TaskRepository.failedRetention,
        );
      }
    } on Object catch (e, s) {
      _logger.warn('Task sweep failed', null, e, s);
    }
  }

  /// Queues one request. Returns the created task, or the already-queued
  /// task that absorbed it as a duplicate.
  Future<Task> enqueue(TaskRequest request) async {
    final List<Task> queued = await _insertRequests([request]);
    return queued.first;
  }

  /// Queues every request, resolving the download directory once for the
  /// whole batch before anything is persisted: a canceled prompt aborts
  /// the enqueue with an empty result. Returns the created tasks together
  /// with the duplicates that were absorbed into already-queued ones, so
  /// an all-duplicate batch still reports its posts as queued.
  Future<List<Task>> enqueueAll(Iterable<TaskRequest> requests) async {
    final List<TaskRequest> list = requests.toList();
    if (list.isEmpty) return const [];
    if (list.any((request) => request.action == TaskAction.download)) {
      // Resolve the save directory once for the whole batch, before
      // anything is persisted: no transfer should finish only to find a
      // directory picker waiting behind it. A canceled picker aborts the
      // enqueue without inserting a single task.
      if (!await _preflightDownloadDirectory()) {
        return const [];
      }
    }
    return _insertRequests(list);
  }

  /// Persists requests and updates the batch counters, without any
  /// preflight; [enqueueAll] owns the batch-level decisions.
  Future<List<Task>> _insertRequests(List<TaskRequest> requests) async {
    final (:created, :merged) = await repository.addAll(requests, identity);
    if (created.isEmpty) {
      // An all-duplicate batch creates nothing: it must not cut short the
      // bubble of the batch before it, which lingers on its summary, nor
      // zero the counters that summary is made of.
      return [...created, ...merged];
    }
    _hideTimer?.cancel();
    _hideTimer = null;
    if (!_disposed) {
      _beginBatch(created.length);
      notifyListeners();
      _kick();
    }
    // Duplicate requests merged into tasks that were already queued are
    // returned alongside the fresh ones, so an all-duplicate batch still
    // reports its posts as queued instead of looking like a cancellation.
    return [...created, ...merged];
  }

  /// Starts a fresh batch when the queue has gone idle, or extends the
  /// batch that is still running.
  void _beginBatch(int count) {
    final bool previousBatchSettled =
        _runningTotal == _runningDone && _active.isEmpty && _runningIds.isEmpty;
    if (previousBatchSettled) {
      // Nothing is queued or in flight anymore; the previous batch had its
      // moment on the bubble, and this one starts from a clean slate.
      _runningTotal = count;
      _runningDone = 0;
      _runningSucceeded = 0;
      _runningFailed = 0;
      _runningCanceled = 0;
    } else {
      _runningTotal += count;
    }
  }

  /// Resolves a writable download destination before a batch starts.
  ///
  /// Android verifies the persisted write permission and falls back to the
  /// directory picker, desktop prompts while no directory is configured,
  /// and the result is persisted so the batch's workers share one
  /// directory. Returns false when the user cancels the picker — the
  /// caller must not enqueue anything then.
  Future<bool> _preflightDownloadDirectory() async {
    final DownloadDirectoryCheck check =
        await FileDownloader.ensureDownloadDirectory(
          directory: settings.downloadPath.value,
          onDirectoryChanged: (dir) => settings.downloadPath.value = dir,
        );
    return check == DownloadDirectoryCheck.ready;
  }

  void _kick() {
    // spawn download workers up to the concurrency limit; exiting workers
    // free their slot, so new tasks always find a fresh worker
    while (!_disposed && _downloadWorkers < _maxConcurrentDownloads) {
      _downloadWorkers++;
      unawaited(_downloadWorker().whenComplete(() => _downloadWorkers--));
    }
    if (!_disposed && !_apiWorkerActive) {
      _apiWorkerActive = true;
      unawaited(_drainApi().whenComplete(() => _apiWorkerActive = false));
    }
  }

  Future<void> _downloadWorker() async {
    while (!_disposed) {
      final Task? next = await repository.claimNext(
        identity: identity,
        actions: const {TaskAction.download},
      );
      if (next == null) break;
      if (_disposed) {
        // give the claimed task back so the next controller can pick it up
        await repository.release(next.id);
        break;
      }
      await _process(next);
    }
  }

  Future<void> _drainApi() async {
    while (!_disposed) {
      final Task? next = await repository.claimNext(
        identity: identity,
        actions: const {TaskAction.favorite, TaskAction.unfavorite},
      );
      if (next == null) break;
      if (_disposed) {
        // give the claimed task back so the next controller can pick it up
        await repository.release(next.id);
        break;
      }
      await _process(next);
    }
    // the api lane is idle again; favorite lists need one revalidation for
    // the whole batch, not one per task
    await _flushFavorites();
  }

  /// Revalidates the favorites query once a batch of favorite tasks
  /// settles, so the favorites page agrees with the item cache updates.
  Future<void> _flushFavorites() async {
    if (!_favoritesDirty) return;
    _favoritesDirty = false;
    try {
      final CachedQuery cache = client.posts.queryCache;
      await cache.invalidateKey([...client.posts.queryKey, 'favorites']);
      final String? username = client.identity.username;
      if (username != null) {
        await cache.invalidateKey(
          client.posts.queryKey,
          where: (params) {
            final Object? tags = params['tags'];
            return tags is String && tags.contains('fav:$username');
          },
        );
      }
    } on Object catch (e, s) {
      _logger.warn('Invalidating favorites failed', null, e, s);
    }
  }

  Future<void> _process(Task task) async {
    _runningIds.add(task.id);
    // Only downloads report transfer progress; favorite tasks have no
    // length to measure and finish with one api call.
    if (task.action == TaskAction.download) {
      _progress[task.id] = ValueNotifier<TaskDownloadProgress>(
        const TaskDownloadProgress(),
      );
    }
    notifyListeners();
    TaskStatus? outcome;
    try {
      await _runOne(task);
      final TaskStatus? current = await repository.readStatus(task.id);
      if (current == TaskStatus.running) {
        await repository.markCompleted(task.id);
        outcome = TaskStatus.completed;
      } else {
        outcome = current;
      }
    } on Object catch (e, s) {
      _logger.warn(
        'Task {task} ({action}) failed',
        {'task': task.id, 'action': task.action.name},
        e,
        s,
      );
      final TaskStatus? current = await repository.readStatus(task.id);
      if (current == TaskStatus.running) {
        await repository.markFailed(task.id, e.toString());
        outcome = TaskStatus.failed;
      } else {
        outcome = current;
      }
    } finally {
      _runningDone++;
      _countOutcome(outcome);
      _runningIds.remove(task.id);
      _progress.remove(task.id)?.dispose();
      if (!_disposed) {
        _recomputeProgress();
        notifyListeners();
      }
    }
  }

  /// Adds a task's outcome to the batch counters.
  void _countOutcome(TaskStatus? status) {
    switch (status) {
      case TaskStatus.completed:
        _runningSucceeded++;
      case TaskStatus.failed:
        _runningFailed++;
      case TaskStatus.canceled:
        _runningCanceled++;
      case null || TaskStatus.pending || TaskStatus.running:
        // released or dismissed mid-run; no batch outcome to count
        break;
    }
  }

  Future<void> _runOne(Task task) async {
    switch (task.action) {
      case TaskAction.download:
        await _runDownload(task);
      case TaskAction.favorite:
        final bool favorited = await _runApiRequest(
          task,
          (cancelToken) =>
              client.posts.addFavorite(task.postId, cancelToken: cancelToken),
        );
        // A canceled request must not look like a succeeded one: without
        // this gate the cache would claim a favorite the server never
        // made, and the optional upvote would fire for it.
        if (!favorited) break;
        _favoritesDirty = true;
        _updatePostCache(
          task.postId,
          (post) =>
              post.copyWith(isFavorited: true, favCount: post.favCount + 1),
        );
        if (settings.upvoteFavs.value) {
          try {
            await client.posts.vote(
              id: task.postId,
              upvote: true,
              replace: true,
            );
            _updatePostCache(
              task.postId,
              (post) => post.withVote(upvote: true, replace: true),
            );
          } on Object catch (e, s) {
            // upvote is best-effort once the favorite succeeded
            _logger.warn(
              'Upvote after favorite failed for post {post}',
              {'post': task.postId},
              e,
              s,
            );
          }
        }
      case TaskAction.unfavorite:
        final bool unfavorited = await _runApiRequest(
          task,
          (cancelToken) => client.posts.removeFavorite(
            task.postId,
            cancelToken: cancelToken,
          ),
        );
        if (!unfavorited) break;
        _favoritesDirty = true;
        _updatePostCache(
          task.postId,
          (post) =>
              post.copyWith(isFavorited: false, favCount: post.favCount - 1),
        );
    }
  }

  /// Runs the api call of a favorite or unfavorite task on a cancel token
  /// registered like a download's, so canceling the task aborts the http
  /// request itself instead of letting it run to completion unseen.
  ///
  /// Returns whether the request actually reached the server and came
  /// back successfully; a task canceled by the user or released by a
  /// disposed controller returns false, and the caller must then leave
  /// the post cache and the upvote alone.
  Future<bool> _runApiRequest(
    Task task,
    Future<void> Function(CancelToken cancelToken) request,
  ) async {
    final CancelToken cancelToken = CancelToken();
    _cancelTokens[task.id] = cancelToken;
    // the controller may have been disposed while this task waited for
    // the api lane; canceling right away aborts the request before it
    // starts
    if (_disposed) cancelToken.cancel();
    try {
      await request(cancelToken);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        if (_disposed) {
          // the request was aborted by disposal; the task goes back to the
          // queue instead of failing
          await repository.release(task.id);
          return false;
        }
        final TaskStatus? status = await repository.readStatus(task.id);
        if (status == TaskStatus.canceled) {
          // the user canceled; the terminal status is already set
          return false;
        }
        throw FileDownloadException('Favorite request was canceled');
      }
      rethrow;
    } finally {
      _cancelTokens.remove(task.id);
    }
    return true;
  }

  /// Applies a successful task's effect to the post cache, through the same
  /// bridge the single-item interface mutates posts with.
  ///
  /// The server call has already succeeded, so there is nothing to roll
  /// back; routing through the bridge's optimistic lane keeps this update
  /// ordered with any in-flight single-item mutation of the same post.
  void _updatePostCache(int postId, Post Function(Post post) update) {
    unawaited(client.posts.postCache.optimistic(postId, update, () async {}));
  }

  Future<void> _runDownload(Task task) async {
    final String? url = task.metadata?.fileUrl;
    final String? fileName = task.metadata?.fileName;
    if (url == null || fileName == null) {
      throw FileDownloadException(
        'Download task missing file metadata (post #${task.postId})',
      );
    }
    final ValueNotifier<TaskDownloadProgress>? progress = _progress[task.id];
    final CancelToken cancelToken = CancelToken();
    _cancelTokens[task.id] = cancelToken;
    // the controller may have been disposed while this task waited for a
    // worker; canceling right away aborts the fetch before it starts
    if (_disposed) cancelToken.cancel();
    // A network-fetched file is a temporary artifact owned by this
    // download; a cache hit is a shared file that must stay.
    File? fetched;
    try {
      File file;
      // a file that is already in the cache needs no network transfer
      FileInfo? cached;
      try {
        cached = await cacheManager.getFileFromCache(url);
      } on Object {
        // cache reads are best-effort; the network path still works
      }
      if (!_disposed && cached != null && cached.file.existsSync()) {
        file = cached.file;
        // A cache hit skips the transfer; the remaining work is the export.
        progress?.value = const TaskDownloadProgress(
          phase: TaskDownloadPhase.saving,
        );
        _recomputeProgress();
      } else {
        file = await fileFetcher(url, cancelToken, (int count, int? total) {
          // the controller may have been disposed while the transfer was in
          // flight; its progress notifier is gone by then
          if (_disposed) return;
          progress?.value = TaskDownloadProgress(
            transferred: count,
            total: total,
          );
          _recomputeProgress();
        });
        fetched = file;
      }
      if (_disposed) {
        // the controller is gone; put the task back so the next controller
        // can pick it up again
        await repository.release(task.id);
        return;
      }
      final TaskStatus? status = await repository.readStatus(task.id);
      if (status == TaskStatus.canceled) {
        // a canceled download must not land in the user's gallery
        return;
      }
      // The transfer itself is done; copying the file into the user's
      // gallery or folder is a separate phase, so the interface can tell
      // "still downloading" from "saving" instead of looking stuck at 100%.
      progress?.value = const TaskDownloadProgress(
        phase: TaskDownloadPhase.saving,
      );
      _recomputeProgress();
      try {
        final String? exported = await exporter(
          file: file,
          directory: settings.downloadPath.value,
          folderName: AppInfo.instance.appName,
          fileName: fileName,
          onDirectoryChanged: (p) => settings.downloadPath.value = p,
        );
        // the export itself is not cancelable; a cancel that raced it must
        // not leave the file behind
        if (await repository.readStatus(task.id) == TaskStatus.canceled) {
          FileDownloader.deleteExported(exported);
        }
      } on FileDownloadException {
        rethrow;
      } on Exception catch (e) {
        throw FileDownloadException.from(e);
      }
      return;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        if (_disposed) {
          // the transfer was aborted by disposal; the task goes back to the
          // queue instead of failing
          await repository.release(task.id);
          return;
        }
        final TaskStatus? status = await repository.readStatus(task.id);
        if (status == TaskStatus.canceled) {
          // the user canceled; the terminal status is already set
          return;
        }
        throw FileDownloadException('Download transfer was canceled');
      }
      throw FileDownloadException.from(e);
    } finally {
      _cancelTokens.remove(task.id);
      // Whether the export succeeded or threw, nothing needs the network
      // file anymore; leaving it behind would leak disk space until the
      // system clears its cache. Cache hits are shared and stay.
      if (fetched != null) {
        _deleteQuietly(fetched);
      }
    }
  }

  void _deleteQuietly(File file) {
    // the fetched file lives in a temporary directory; leaving it behind would
    // leak disk space until the system clears its cache
    file.delete().ignore();
  }

  Future<void> cancel(int taskId) async {
    final TaskStatus? status = await repository.markCanceled(taskId);
    if (status == TaskStatus.pending && !_runningIds.contains(taskId)) {
      // A task canceled while still queued never reaches a worker, so its
      // outcome is counted here; running tasks are classified by their
      // worker. The re-check closes the window where a worker claimed the
      // task while this call was writing.
      _countCanceledPending(1);
    }
    _cancelTokens[taskId]?.cancel();
  }

  /// Counts tasks that were canceled while still queued, and which no
  /// worker will ever report an outcome for.
  void _countCanceledPending(int count) {
    if (count <= 0) return;
    _runningCanceled += count;
    _runningDone += count;
    if (!_disposed) notifyListeners();
  }

  Future<void> dismiss(int taskId) => repository.remove(taskId);

  /// Removes the given tasks in one database write.
  ///
  /// Like the other id-based methods, this bypasses identity scoping:
  /// callers must pass ids they took from the current identity's list.
  Future<void> dismissTasks(Iterable<int> ids) =>
      repository.removeAll(ids.toList());

  /// Requeues one terminal task through the same hardened path as
  /// [retryTasks]: one directory preflight before anything is removed,
  /// and no transfer that finishes behind a waiting picker. Returns null
  /// when the task was not retryable or the user canceled the
  /// directory prompt, in which case the task stays in place.
  Future<Task?> retry(int taskId) => retryTasks([
    taskId,
  ]).then((queued) => queued.isEmpty ? null : queued.first);

  /// Cancels the given tasks in one database write, aborting the transfers
  /// of those that are already running.
  ///
  /// Id-based and therefore not identity-scoped; callers must pass ids
  /// taken from the current identity's list.
  Future<void> cancelTasks(Iterable<int> ids) async {
    final List<Task> canceled = await repository.cancelTasks(ids: ids.toList());
    _countCanceledPending(
      canceled.where((task) => task.status == TaskStatus.pending).length,
    );
    for (final Task task in canceled) {
      _cancelTokens[task.id]?.cancel();
    }
  }

  /// Retries the given tasks in one pass: one read, one delete and one
  /// insert for the whole selection, with a single directory preflight for
  /// the downloads among them.
  ///
  /// Tasks that have not reached a terminal state are ignored, and an
  /// explicit re-download after a task finished stays possible. A canceled
  /// directory picker leaves the failed tasks untouched. Returns the tasks
  /// that are queued again, which for an all-duplicate retry are the
  /// tasks that absorbed it.
  Future<List<Task>> retryTasks(Iterable<int> ids) async {
    final List<Task> tasks = await repository.getAll(ids.toList());
    final List<Task> retryable = tasks
        .where((task) => task.status.isTerminal)
        .toList();
    if (retryable.isEmpty) return const [];
    if (retryable.any((task) => task.action == TaskAction.download)) {
      // one directory prompt for the whole retry batch, resolved before
      // anything is removed: a canceled picker must not cost the user
      // their failed tasks
      if (!await _preflightDownloadDirectory()) return const [];
    }
    await repository.removeAll(retryable.map((task) => task.id).toList());
    return enqueueAll(
      retryable.map(
        (task) => TaskRequest(
          action: task.action,
          postId: task.postId,
          metadata: task.metadata,
        ),
      ),
    );
  }

  /// Cancels every queued and in-progress task. Canceled tasks stay in the
  /// list and can be retried.
  Future<void> cancelAll() async {
    final List<Task> canceled = await repository.cancelTasks(
      identity: identity,
    );
    _countCanceledPending(
      canceled.where((task) => task.status == TaskStatus.pending).length,
    );
    for (final CancelToken token in _cancelTokens.values) {
      token.cancel();
    }
  }

  /// Removes completed and canceled tasks. Failed tasks are kept so they stay
  /// visible for retry.
  Future<void> clearDone() => repository.clear(
    statuses: const {TaskStatus.completed, TaskStatus.canceled},
    identity: identity,
  );

  @override
  void dispose() {
    _disposed = true;
    _activeSub?.cancel();
    _hideTimer?.cancel();
    // abort the transfers of in-flight downloads; their tasks are released
    // back to the queue instead of failing
    for (final CancelToken token in _cancelTokens.values) {
      token.cancel();
    }
    for (final notifier in _progress.values) {
      notifier.dispose();
    }
    _progress.clear();
    // the shared transfer client ends with the controller; its transfers
    // were just aborted above
    _transferClient?.close(force: true);
    currentProgress.dispose();
    suppressBubble.dispose();
    super.dispose();
  }
}
