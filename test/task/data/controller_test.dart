import 'dart:async';
import 'dart:io';

import 'package:cached_query/cached_query.dart';
import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/task/task.dart';
import 'package:e1547/traits/traits.dart';
// ignore: depend_on_referenced_packages
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

import '../../_support/harness.dart';

class FakeCacheManager implements BaseCacheManager {
  FakeCacheManager(this.responses);

  final StreamController<FileResponse> responses;

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) => responses.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class GatedTaskRepository extends TaskRepository {
  GatedTaskRepository({required super.database, required this.gate});

  final Completer<void> gate;

  @override
  Future<Task?> claimNext({int? identity, Set<TaskAction>? actions}) async {
    await gate.future;
    return super.claimNext(identity: identity, actions: actions);
  }
}

void main() {
  late AppDatabase sqlite;
  late TaskRepository repository;
  late ValueNotifier<Traits> traits;
  late Client client;
  late Settings settings;
  late int identity;

  setUp(() async {
    await initializeTestApp();
    SharedPreferences.setMockInitialValues({});
    sqlite = AppDatabase(NativeDatabase.memory());
    repository = TaskRepository(database: sqlite);
    identity = (await IdentityRepository(
      sqlite,
    ).add(const IdentityRequest(host: 'e621.net', username: 'tester'))).id;
    traits = ValueNotifier(
      Traits(
        id: identity,
        userId: null,
        denylist: [],
        homeTags: '',
        avatar: null,
        perPage: null,
      ),
    );
    client = Client(
      identity: Identity(
        id: identity,
        host: 'e621.net',
        username: null,
        headers: null,
      ),
      traits: traits,
      storage: AppStorage(
        preferences: await SharedPreferences.getInstance(),
        temporaryFiles: '.',
        queryCache: CachedQuery.asNewInstance(),
        sqlite: sqlite,
      ),
    );
    // The fake clock would otherwise leave dio's timeout timers pending
    // on requests that are still in flight when the test ends.
    client.dio.options.connectTimeout = null;
    client.dio.options.receiveTimeout = null;
    settings = Settings(await SharedPreferences.getInstance());
  });

  tearDown(() async {
    traits.dispose();
    await sqlite.close();
  });

  TasksController controller({
    BaseCacheManager? cacheManager,
    TaskRepository? taskRepository,
  }) => TasksController(
    repository: taskRepository ?? repository,
    client: client,
    cacheManager: cacheManager ?? FakeCacheManager(StreamController()),
    settings: settings,
    identity: identity,
  );

  TaskRequest downloadRequest(String fileName) => TaskRequest(
    action: TaskAction.download,
    postId: 1,
    metadata: TaskMetadata(
      fileUrl: 'https://example.com/$fileName',
      fileName: fileName,
    ),
  );

  test('does not revive its active watch when disposed during init', () async {
    final instance = controller();
    instance.dispose();
    await pumpEventQueue();
  });

  test('returns claimed tasks when disposed mid-claim', () async {
    final gate = Completer<void>();
    final gated = GatedTaskRepository(database: sqlite, gate: gate);
    final instance = controller(taskRepository: gated);

    final task = await repository.add(
      downloadRequest('claimed.webm'),
      identity,
    );
    await pumpEventQueue();

    instance.dispose();
    gate.complete();
    await pumpEventQueue();

    expect(await repository.readStatus(task.id), TaskStatus.pending);
  });

  test('returns in-flight downloads when disposed mid-download', () async {
    final responses = StreamController<FileResponse>.broadcast();
    final instance = controller(cacheManager: FakeCacheManager(responses));

    final task = await instance.enqueue(downloadRequest('in-flight.webm'));
    await pumpEventQueue();

    responses.add(const DownloadProgress('https://example.com', 100, 50));
    await pumpEventQueue();

    instance.dispose();
    responses.add(const DownloadProgress('https://example.com', 100, 60));
    await pumpEventQueue();

    expect(await repository.readStatus(task.id), TaskStatus.pending);

    await responses.close();
  });

  test('does not export canceled downloads', () async {
    final dir = await Directory.systemTemp.createTemp('task-cancel');
    addTearDown(() => dir.delete(recursive: true));
    settings.downloadPath.value = dir.path;

    final responses = StreamController<FileResponse>.broadcast();
    final instance = controller(cacheManager: FakeCacheManager(responses));

    final task = await instance.enqueue(downloadRequest('canceled.webm'));
    await pumpEventQueue();

    await instance.cancel(task.id);
    await pumpEventQueue();

    final source = const LocalFileSystem().file('${dir.path}/source.bin');
    await source.writeAsBytes([1, 2, 3]);
    addTearDown(() => source.delete());

    responses.add(
      FileInfo(
        source,
        FileSource.Online,
        DateTime.now().add(const Duration(hours: 1)),
        'https://example.com/canceled.webm',
      ),
    );
    await pumpEventQueue();
    await pumpEventQueue();

    expect(await repository.readStatus(task.id), TaskStatus.canceled);
    expect(File('${dir.path}/canceled.webm').existsSync(), isFalse);

    instance.dispose();
    await responses.close();
  });

  test('does not revive canceled tasks when released', () async {
    final task = await repository.add(
      downloadRequest('canceled-release.webm'),
      identity,
    );
    final claimed = await repository.claimNext(identity: identity);
    expect(claimed!.id, task.id);

    await repository.markCanceled(task.id);
    await repository.release(task.id);

    expect(await repository.readStatus(task.id), TaskStatus.canceled);
  });

  test(
    'does not revive canceled downloads when disposed mid-download',
    () async {
      final responses = StreamController<FileResponse>.broadcast();
      final instance = controller(cacheManager: FakeCacheManager(responses));

      final task = await instance.enqueue(
        downloadRequest('canceled-dispose.webm'),
      );
      await pumpEventQueue();

      responses.add(const DownloadProgress('https://example.com', 100, 50));
      await pumpEventQueue();

      await instance.cancel(task.id);
      await pumpEventQueue();

      instance.dispose();
      responses.add(const DownloadProgress('https://example.com', 100, 60));
      await pumpEventQueue();
      await pumpEventQueue();

      expect(await repository.readStatus(task.id), TaskStatus.canceled);

      await responses.close();
    },
  );
}
