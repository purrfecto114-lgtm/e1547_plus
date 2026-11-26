import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:e1547/task/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../_support/fake_e621.dart';
import '../../_support/harness.dart';

class _TempPathProvider extends PathProviderPlatform {
  String? _path;

  @override
  Future<String?> getTemporaryPath() async => _path ??=
      (await Directory.systemTemp.createTemp('e1547-fetcher-test')).path;
}

/// Serves a fixed body for every request, as a cdn would.
class _ServingAdapter implements HttpClientAdapter {
  _ServingAdapter(this.body);

  final List<int> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromBytes(body, 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() async {
    await initializeTestApp();
    PathProviderPlatform.instance = _TempPathProvider();
  });

  test('fetches a remote file into a named temporary file', () async {
    final fake = await FakeE621.start();
    addTearDown(() => fake.stop());

    // A remote url is not a file: uri, and the temp file name is built
    // from the url's extension: fetching from an http origin used to
    // throw before the first byte was ever requested.
    final file = await fetchFileToTemp(
      '${fake.url}/data/59/80/59806192859806192859806192859806.jpg',
      CancelToken(),
      null,
    );

    expect(file.path, endsWith('.jpg'));
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(0));
  });

  test('reports transfer progress of the fetched file', () async {
    final fake = await FakeE621.start();
    addTearDown(() => fake.stop());

    final events = <int>[];
    final file = await fetchFileToTemp(
      '${fake.url}/data/59/80/59806192859806192859806192859806.jpg',
      CancelToken(),
      (count, total) => events.add(count),
    );

    expect(file.existsSync(), isTrue);
    expect(events, isNotEmpty);
    expect(events.last, file.lengthSync());
  });

  test('a transfer past the size cap is aborted and cleaned up', () async {
    final dir = Directory(
      (await PathProviderPlatform.instance.getTemporaryPath())!,
    );
    // Earlier tests leave their finished files behind; only files
    // created after this point matter. FileSystemEntity has no value
    // equality, so the sets compare paths.
    final before = dir.listSync().map((e) => e.path).toSet();

    final dio = Dio()
      ..httpClientAdapter = _ServingAdapter(List.filled(2048, 65));
    await expectLater(
      fetchFileToTemp(
        'https://cdn.example.org/file.bin',
        CancelToken(),
        null,
        client: dio,
        maxBytes: 1024,
      ),
      throwsA(isA<DioException>()),
    );
    final created = dir
        .listSync()
        .map((e) => e.path)
        .toSet()
        .difference(before);
    expect(created, isEmpty);
  });
}
