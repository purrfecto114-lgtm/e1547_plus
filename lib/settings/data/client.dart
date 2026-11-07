import 'dart:convert';
import 'dart:io';

import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:xml/xml.dart';

class AppInfoClient {
  AppInfoClient({required this.queryCache, Dio? dio}) : _externalDio = dio {
    _dio.httpClientAdapter = NativeAdapter();
    _dio.interceptors.add(LoggingDioInterceptor());
  }

  /// A dio instance which is used instead of the default one when set.
  ///
  /// Exists so tests can provide a mock transport.
  final Dio? _externalDio;

  final AppInfo info = AppInfo.instance;
  final CachedQuery queryCache;
  late final Dio _dio =
      _externalDio ??
      Dio(
        BaseOptions(
          headers: {HttpHeaders.userAgentHeader: info.userAgent},
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

  /// Returns all versions released on GitHub.
  ///
  /// Does nothing in debug mode, unless [beta] is set, which lets
  /// developers exercise the updater from debug builds.
  Future<List<AppVersion>> getVersions({bool beta = false}) async {
    if (kDebugMode && !beta) {
      return []; // Do not check for updates in debug mode
    }
    return fetchVersions();
  }

  /// Returns all versions released on GitHub.
  ///
  /// Requests the GitHub API first, falling back to the releases Atom feed
  /// when the API is unavailable.
  ///
  /// Anonymous API requests are rate limited per IP address, which strands
  /// users behind shared addresses (like carrier grade NAT) with a permanently
  /// failing update check. The Atom feed is served by the website itself and
  /// is not subject to API rate limits.
  @visibleForTesting
  Future<List<AppVersion>> fetchVersions() async {
    try {
      return await _getVersionsFromApi();
    } on DioException {
      return _getVersionsFromAtom();
    }
  }

  Future<List<AppVersion>> _getVersionsFromApi() {
    return _dio
        .get('https://api.github.com/repos/${info.github}/releases')
        .then((response) {
          try {
            // A repository tag is not guaranteed to be a semver version
            // ("nightly", "v2"...), and Version.parse throws a plain
            // FormatException outside the picker's own exception type.
            // Unparseable entries are skipped one by one, like the atom
            // fallback below does, instead of failing the whole check.
            final List<AppVersion> versions = [];
            final List<dynamic> releases = pick(
              response.data,
            ).asListOrEmpty((e) => e.value);
            for (final entry in releases) {
              try {
                versions.add(
                  pick(entry).letOrThrow(
                    (e) => AppVersion(
                      version: Version.parse(e('tag_name').asStringOrThrow()),
                      name: e('name').asStringOrThrow(),
                      description: e('body').asStringOrThrow(),
                      date: e('published_at').asDateTimeOrThrow(),
                      binaries: e('assets').asListOrEmpty(
                        (e) => e('name').asStringOrThrow().split('.').last,
                      ),
                    ),
                  ),
                );
              } on FormatException {
                continue;
              }
            }
            return versions;
          } on PickException catch (e) {
            throw AppUpdaterException(
              requestOptions: response.requestOptions,
              response: response,
              error: e,
            );
          }
        });
  }

  Future<List<AppVersion>> _getVersionsFromAtom() {
    return _dio
        .get<String>(
          'https://github.com/${info.github}/releases.atom',
          options: Options(responseType: ResponseType.plain),
        )
        .then((response) {
          try {
            const atomNamespace = 'http://www.w3.org/2005/Atom';
            XmlDocument document = XmlDocument.parse(response.data!);
            List<AppVersion> versions = [];
            // getElement does not resolve default namespaces, so
            // children are matched by their local names instead.
            String? childText(XmlElement parent, String name) {
              for (final XmlElement child in parent.childElements) {
                if (child.name.local == name) return child.innerText;
              }
              return null;
            }

            for (final XmlElement entry in document.findAllElements(
              'entry',
              namespace: atomNamespace,
            )) {
              String? id = childText(entry, 'id');
              if (id == null) continue;
              String tag = id.substring(id.lastIndexOf('/') + 1);
              Version version;
              try {
                version = Version.parse(tag);
              } on FormatException {
                continue;
              }
              versions.add(
                AppVersion(
                  version: version,
                  name: childText(entry, 'title'),
                  description: childText(entry, 'content'),
                  date: DateTime.tryParse(childText(entry, 'updated') ?? ''),
                ),
              );
            }
            return versions;
          } on XmlException catch (e) {
            throw AppUpdaterException(
              requestOptions: response.requestOptions,
              response: response,
              error: e,
            );
          }
        });
  }

  /// Retrieves versions which are newer than the currently installed one.
  ///
  /// If the app was installed via a store,
  /// versions newer than 7 days will be ignored.
  ///
  /// This is because we give the store a chance to automatically update the app.
  Future<List<AppVersion>> getNewVersions({bool beta = false}) async {
    List<AppVersion> versions = await getVersions(beta: beta);
    AppVersion current = AppVersion(
      version: Version.parse('${info.version}+${info.buildNumber}'),
    );

    // Remove prior versions
    versions.removeWhere(
      (e) =>
          e.version.compareTo(current.version) < 1 ||
          (!beta && Version.prioritize(e.version, current.version) < 1),
    );

    String? binary;
    if (Platform.isAndroid) {
      binary = 'apk';
    } else if (Platform.isIOS) {
      binary = 'ipa';
    } else if (Platform.isWindows) {
      binary = 'exe';
    } else if (Platform.isLinux) {
      // Asset names resolve by their last extension, so the deb
      // stands for the linux channel and tar.gz archives stay out
      // of the comparison.
      binary = 'deb';
    }

    return filterNewVersions(
      versions,
      current: current.version,
      binary: binary,
      beta: beta,
      fromStore: info.source.isFromStore,
    );
  }

  /// Removes versions which should not be offered to a user.
  ///
  /// * removes prior versions, and prereleases unless [beta] is set
  /// * removes versions without the desired [binary] in their assets,
  ///   keeping versions with unknown assets
  /// * for store installs, removes versions younger than 7 days,
  ///   giving the store a chance to deliver its own update
  @visibleForTesting
  static List<AppVersion> filterNewVersions(
    List<AppVersion> versions, {
    required Version current,
    bool beta = false,
    String? binary,
    bool fromStore = false,
    DateTime? now,
  }) {
    final DateTime checkTime = now ?? DateTime.now();
    return versions.where((e) {
      if (e.version.compareTo(current) < 1) return false;
      if (!beta && Version.prioritize(e.version, current) < 1) {
        return false;
      }
      if (binary != null && e.binaries?.contains(binary) == false) {
        return false;
      }
      if (fromStore &&
          (e.date?.isAfter(checkTime.subtract(const Duration(days: 7))) ??
              false)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Returns the releases page URL.
  ///
  /// The releases list is used instead of /releases/latest so prereleases,
  /// which beta users update to, stay reachable.
  String latestReleaseUrl() =>
      'https://github.com/${AppInfo.instance.github!}/releases';

  /// Returns donors bundled statically with the app.
  ///
  /// These can be used as a fallback in case the GitHub API is not available.
  Future<List<Donor>> getBundledDonors() async {
    String raw = await rootBundle.loadString('assets/static/donations.json');
    return (json.decode(raw) as List<dynamic>)
        .map((e) => Donor.fromJson(e))
        .toList();
  }

  /// Returns donors from the GitHub repository.
  Future<List<Donor>> getDonors() async {
    List<dynamic> donors = await _dio
        .get(
          'https://raw.githubusercontent.com/${AppInfo.instance.github}/master/assets/static/donations.json',
        )
        .then((e) => jsonDecode(e.data));
    return donors.map((e) => Donor.fromJson(e)).toList();
  }
}

class AppVersion {
  /// Represents an App version with name, description and version number.
  AppVersion({
    required this.version,
    this.name,
    this.description,
    this.date,
    this.binaries,
  });

  /// Name of this version.
  final String? name;

  /// Description of this version.
  final String? description;

  /// The version. Should follow pub.dev semver standards.
  final Version version;

  /// Date of the release.
  final DateTime? date;

  /// List of file extensions of available binaries.
  final List<String>? binaries;
}

typedef AppUpdaterException = DioException;
