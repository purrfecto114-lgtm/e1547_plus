import 'package:cached_query/cached_query.dart';
import 'package:dio/dio.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../_support/harness.dart';

const String apiBody = '''
[
  {
    "tag_name": "21.3.0+121",
    "name": "21.3.0 stable",
    "body": "stable body",
    "published_at": "2026-10-31T15:52:14Z",
    "assets": [{"name": "e1547-arm64.apk"}]
  },
  {
    "tag_name": "21.3.0-rc.5+120",
    "name": "21.3.0-rc.5",
    "body": "rc body",
    "published_at": "2026-10-31T11:35:08Z",
    "assets": [{"name": "e1547-arm64.apk"}]
  }
]
''';

const String atomBody = '''
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en-US">
  <id>tag:github.com,2008:https://github.com/purrfecto114-lgtm/e1547_plus/releases</id>
  <title>Release notes from e1547_plus</title>
  <updated>2026-10-31T15:52:14Z</updated>
  <entry>
    <id>tag:github.com,2008:Repository/1389066535/21.3.0+121</id>
    <updated>2026-10-31T15:52:14Z</updated>
    <title>21.3.0 stable</title>
    <content type="html">&lt;p&gt;stable &amp;amp; body&lt;/p&gt;</content>
  </entry>
  <entry>
    <id>tag:github.com,2008:Repository/1389066535/21.3.0-rc.5+120</id>
    <updated>2026-10-31T11:35:13Z</updated>
    <title>21.3.0-rc.5</title>
    <content type="html">rc body</content>
  </entry>
  <entry>
    <id>tag:github.com,2008:Repository/1389066535/not-a-version</id>
    <updated>2026-10-01T00:00:00Z</updated>
    <title>weird tag</title>
    <content type="html">skipped</content>
  </entry>
</feed>
''';

class _RoutingAdapter implements HttpClientAdapter {
  _RoutingAdapter({required this.api, required this.atom});

  final ({int status, String body}) api;
  final ({int status, String body}) atom;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final ({int status, String body}) response =
        options.uri.host == 'api.github.com' ? api : atom;
    Map<String, List<String>> headers = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    };
    if (options.uri.host != 'api.github.com') {
      headers[Headers.contentTypeHeader] = ['application/atom+xml'];
    }
    return ResponseBody.fromString(
      response.body,
      response.status,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}

AppInfoClient updatableClient({
  required ({int status, String body}) api,
  required ({int status, String body}) atom,
}) {
  Dio dio = Dio();
  AppInfoClient client = AppInfoClient(
    queryCache: CachedQuery.asNewInstance(),
    dio: dio,
  );
  dio.httpClientAdapter = _RoutingAdapter(api: api, atom: atom);
  return client;
}

void main() {
  setUpAll(() async {
    await initializeTestApp();
  });

  group('fetching releases', () {
    test('an api response is used as-is', () async {
      AppInfoClient client = updatableClient(
        api: (status: 200, body: apiBody),
        atom: (status: 500, body: ''),
      );
      List<AppVersion> versions = await client.fetchVersions();
      expect(versions.length, 2);
      expect(versions.first.version.toString(), '21.3.0+121');
      expect(versions.first.binaries, ['apk']);
      expect(versions.first.date, DateTime.parse('2026-10-31T15:52:14Z'));
    });

    test('a rate limited api falls back to the atom feed', () async {
      AppInfoClient client = updatableClient(
        api: (status: 403, body: '{"message": "API rate limit exceeded"}'),
        atom: (status: 200, body: atomBody),
      );
      List<AppVersion> versions = await client.fetchVersions();
      expect(versions.length, 2);
      expect(versions.first.version.toString(), '21.3.0+121');
      expect(versions.first.name, '21.3.0 stable');
      expect(versions.first.description, '<p>stable &amp; body</p>');
      expect(versions.first.date, DateTime.parse('2026-10-31T15:52:14Z'));
      expect(versions.first.binaries, isNull);
      expect(versions[1].version.toString(), '21.3.0-rc.5+120');
    });

    test('a failing fallback propagates an updater exception', () async {
      AppInfoClient client = updatableClient(
        api: (status: 403, body: '{"message": "API rate limit exceeded"}'),
        atom: (status: 403, body: ''),
      );
      await expectLater(
        client.fetchVersions(),
        throwsA(isA<AppUpdaterException>()),
      );
    });
  });

  group('filtering new versions', () {
    final DateTime now = DateTime.parse('2026-11-06T15:00:00Z');

    AppVersion version(
      String version, {
      DateTime? date,
      List<String>? binaries,
    }) => AppVersion(
      version: Version.parse(version),
      date: date,
      binaries: binaries,
    );

    test('stable users do not see prereleases unless they opted in', () {
      List<AppVersion> input = [
        version('21.3.1-rc.1+122', binaries: ['apk']),
        version('21.3.0+121', binaries: ['apk']),
      ];
      List<AppVersion> result = AppInfoClient.filterNewVersions(
        input,
        current: Version.parse('21.3.0+121'),
        binary: 'apk',
        now: now,
      );
      expect(result, isEmpty);
      result = AppInfoClient.filterNewVersions(
        input,
        current: Version.parse('21.3.0+121'),
        binary: 'apk',
        beta: true,
        now: now,
      );
      expect(result.map((e) => e.version.toString()), ['21.3.1-rc.1+122']);
    });

    test('prerelease users see stable releases', () {
      List<AppVersion> input = [
        version('21.3.0+121', binaries: ['apk']),
        version('21.3.0-rc.5+120', binaries: ['apk']),
      ];
      List<AppVersion> result = AppInfoClient.filterNewVersions(
        input,
        current: Version.parse('21.3.0-rc.5+120'),
        binary: 'apk',
        now: now,
      );
      expect(result.map((e) => e.version.toString()), ['21.3.0+121']);
    });

    test('releases without the platform binary are hidden', () {
      List<AppVersion> input = [
        version('21.3.1+122', binaries: ['exe']),
        version('21.3.2+123'),
      ];
      List<AppVersion> result = AppInfoClient.filterNewVersions(
        input,
        current: Version.parse('21.3.0+121'),
        binary: 'apk',
        now: now,
      );
      expect(result.map((e) => e.version.toString()), ['21.3.2+123']);
    });

    test('store installs only see releases older than 7 days', () {
      List<AppVersion> input = [
        version('21.3.1+122', date: now.subtract(const Duration(days: 3))),
        version('21.3.2+123', date: now.subtract(const Duration(days: 10))),
      ];
      List<AppVersion> result = AppInfoClient.filterNewVersions(
        input,
        current: Version.parse('21.3.0+121'),
        fromStore: true,
        now: now,
      );
      expect(result.map((e) => e.version.toString()), ['21.3.2+123']);
      result = AppInfoClient.filterNewVersions(
        input,
        current: Version.parse('21.3.0+121'),
        now: now,
      );
      expect(result.map((e) => e.version.toString()), [
        '21.3.1+122',
        '21.3.2+123',
      ]);
    });
  });
}
