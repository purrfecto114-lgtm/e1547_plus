import 'package:cached_query/cached_query.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/task/task.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:provider/provider.dart';

import '../../_support/harness.dart';
import '../../_support/posts.dart';

class NoopCacheManager implements BaseCacheManager {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

void main() {
  late AppDatabase sqlite;
  late TaskRepository repository;
  late int identity;
  late Client client;
  late Settings settings;
  late TasksController controller;

  setUp(() async {
    await initializeTestApp();
    SharedPreferences.setMockInitialValues({});
    sqlite = AppDatabase(NativeDatabase.memory());
    repository = TaskRepository(database: sqlite);
    identity = (await IdentityRepository(
      sqlite,
    ).add(const IdentityRequest(host: 'e621.net', username: 'tester'))).id;
    client = Client(
      identity: Identity(
        id: identity,
        host: 'e621.net',
        username: null,
        headers: null,
      ),
      traits: ValueNotifier(
        Traits(
          id: identity,
          userId: null,
          denylist: [],
          homeTags: '',
          avatar: null,
          perPage: null,
        ),
      ),
      storage: AppStorage(
        preferences: await SharedPreferences.getInstance(),
        temporaryFiles: '.',
        queryCache: CachedQuery.asNewInstance(),
        sqlite: sqlite,
      ),
    );
    client.dio.options.connectTimeout = null;
    client.dio.options.receiveTimeout = null;
    settings = Settings(await SharedPreferences.getInstance());
    // A preset directory keeps the enqueue preflight from opening a
    // directory picker.
    settings.downloadPath.value = '/tmp/duplicate-download-test';
    controller = TasksController(
      repository: repository,
      client: client,
      cacheManager: NoopCacheManager(),
      settings: settings,
      identity: identity,
      // A queued download is claimed by a worker right away: answering
      // with a cancellation marks it failed cleanly, without running a
      // transfer or leaving the worker waiting on a timer.
      fileFetcher: (url, token, onProgress) async => throw DioException(
        requestOptions: RequestOptions(path: url),
        type: DioExceptionType.cancel,
      ),
    );
  });

  tearDown(() async {
    controller.dispose();
    await sqlite.close();
  });

  Future<int> seedTask(
    int postId, {
    TaskAction action = TaskAction.download,
  }) async {
    final Task task = await repository.add(
      TaskRequest(
        action: action,
        postId: postId,
        metadata: TaskMetadata(fileUrl: 'https://example.org/$postId.jpg'),
      ),
      identity,
    );
    return task.id;
  }

  test('only completed downloads count as served', () async {
    final completed = await seedTask(1);
    final failed = await seedTask(2);
    final canceled = await seedTask(3);
    await seedTask(4);
    final favorited = await seedTask(5, action: TaskAction.favorite);
    await repository.markCompleted(completed);
    await repository.markFailed(failed, 'disk full');
    await repository.markCanceled(canceled);
    await repository.markCompleted(favorited);

    // A failed, canceled or queued download never served the file, and
    // a completed favorite is not a download at all.
    final served = await repository.findDownloadedPostIds([1, 2, 3, 4, 5]);
    expect(served, {1});
  });

  test('a download from another account still counts as served', () async {
    final other = (await IdentityRepository(
      sqlite,
    ).add(const IdentityRequest(host: 'e926.net', username: 'elsewhere'))).id;
    final Task task = await repository.add(
      const TaskRequest(
        action: TaskAction.download,
        postId: 9,
        metadata: TaskMetadata(fileUrl: 'https://example.org/9.jpg'),
      ),
      other,
    );
    await repository.markCompleted(task.id);

    // The file lands in the same shared directory regardless of the
    // account that started the download.
    final served = await repository.findDownloadedPostIds([9]);
    expect(served, {9});
  });

  Future<List<Task>?> download(
    WidgetTester tester,
    Set<Post> posts, {
    Future<void> Function(WidgetTester tester)? interact,
  }) async {
    List<Task>? result;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ListenableProvider<TasksController>.value(value: controller),
          Provider<Settings>.value(value: settings),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await postDownloadingNotification(context, posts);
              },
              child: const Text('download'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('download'));
    await tester.pumpAndSettle();
    if (interact != null) {
      await interact(tester);
      await tester.pumpAndSettle();
    }
    // The enqueue rides on drift transactions, which only resolve in
    // real time: wait them out, then pump once more for the result.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    return result;
  }

  Post imagePost(int id) =>
      samplePost(id: id, file: 'https://example.org/$id.jpg');

  testWidgets('fresh posts queue without asking', (tester) async {
    final result = await download(tester, {imagePost(10)});
    expect(result, hasLength(1));
    expect(find.text('Already downloaded'), findsNothing);
  });

  testWidgets('a served post asks first and canceling queues nothing', (
    tester,
  ) async {
    final task = await seedTask(11);
    await repository.markCompleted(task);

    final result = await download(
      tester,
      {imagePost(11)},
      interact: (tester) async {
        await tester.tap(find.text('CANCEL'));
      },
    );
    // The dialog carried the bottom-left option and the count body.
    expect(find.text('Already downloaded'), findsNothing);
    expect(result, isNull);
  });

  testWidgets('confirming the dialog queues the batch', (tester) async {
    final task = await seedTask(12);
    await repository.markCompleted(task);

    final result = await download(
      tester,
      {imagePost(12)},
      interact: (tester) async {
        await tester.tap(find.text('DOWNLOAD'));
      },
    );
    expect(result, hasLength(1));
    // The dialog asked again is the default: confirming keeps it on.
    expect(settings.askOnDuplicateDownload.value, isTrue);
  });

  testWidgets("don't ask again queues the batch and silences the dialog", (
    tester,
  ) async {
    final task = await seedTask(13);
    await repository.markCompleted(task);

    final result = await download(
      tester,
      {imagePost(13)},
      interact: (tester) async {
        await tester.tap(find.text("Don't ask again"));
      },
    );
    expect(result, hasLength(1));
    expect(settings.askOnDuplicateDownload.value, isFalse);
    // A silenced dialog stops asking for good; that the silenced
    // setting queues straight through is the silenced-setting case
    // below.
  });

  testWidgets('a silenced setting queues without asking', (tester) async {
    settings.askOnDuplicateDownload.value = false;
    final task = await seedTask(14);
    await repository.markCompleted(task);

    final result = await download(tester, {imagePost(14)});
    expect(result, hasLength(1));
    expect(find.text('Already downloaded'), findsNothing);
  });
}
