import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

String encodeBasicAuth(String username, String password) =>
    'Basic ${base64Encode(utf8.encode('$username:$password'))}';

(String username, String password)? parseBasicAuth(String? auth) {
  if (auth == null) return null;
  RegExpMatch? fullBasicMatch = RegExp(
    r'Basic (?<encoded>[A-Za-z\d/=]+)',
  ).firstMatch(auth);
  if (fullBasicMatch == null) return null;
  RegExpMatch? credentialMatch = RegExp(r'(?<username>.+):(?<password>.+)')
      .firstMatch(
        utf8.decode(base64Decode(fullBasicMatch.namedGroup('encoded')!)),
      );
  if (credentialMatch == null) return null;
  return (
    credentialMatch.namedGroup('username')!,
    credentialMatch.namedGroup('password')!,
  );
}

/// Headers an identity may keep through database export/import.
///
/// Historically, cookie capture stored cookies as top-level headers
/// (e.g. `cf_clearance`, `__cf_bm`), which a keyword blocklist misses.
/// An explicit allowlist treats every unknown header name as a
/// credential, so legacy and future secret-bearing names are
/// stripped by default.
const Set<String> exportableHeaderAllowlist = {
  'accept',
  'accept-language',
  'user-agent',
};

/// Whether [name] may travel through database export/import.
bool isExportableHeader(String name) =>
    exportableHeaderAllowlist.contains(name.toLowerCase());

/// Returns a new URL which is guaranteed to
/// - have a scheme (defaults to https)
/// - not have a trailing slash
/// - not contain a query or fragment
String normalizeHostUrl(String url) {
  Uri uri = Uri.parse(url);
  if (uri.host.isEmpty && uri.path.isNotEmpty) {
    uri = Uri.https(uri.path);
  }
  if (uri.path.endsWith('/')) {
    uri = uri.replace(path: uri.path.substring(0, uri.path.length - 1));
  }
  if (uri.scheme.isEmpty) {
    uri = uri.replace(scheme: 'https');
  }
  uri = Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo,
    host: uri.host,
    port: uri.port,
    path: uri.path,
  );
  return uri.toString();
}

String assembleHostedUrl(String host, String path) {
  Uri uri = Uri.parse(normalizeHostUrl(host));
  Uri other = Uri.parse(path);

  path = other.path;
  if (!path.startsWith('/')) path = '/$path';
  path = '${uri.path}$path';

  Map<String, dynamic>? queryParameters = other.queryParameters;
  if (queryParameters.isEmpty) queryParameters = null;

  String? fragment = other.fragment;
  if (fragment.isEmpty) fragment = null;

  return uri
      .replace(path: path, queryParameters: queryParameters, fragment: fragment)
      .toString();
}

extension HostedUrlsExtenstion on Identity {
  String withHost(String path) => assembleHostedUrl(host, path);
}

extension IdentityUsernaming on Identity {
  String get usernameOrAnon => username ?? 'Anonymous';
}

/// The outcome of a lightweight credential verification.
enum CredentialCheckResult {
  /// The server accepted the credentials.
  ok,

  /// The server rejected the credentials (401/403).
  rejected,

  /// The credentials could not be verified: network failure, timeout or
  /// a server error.
  unavailable,
}

/// Verifies [headers] against [host] before they are stored.
///
/// A login must not report success on credentials the server rejects:
/// the identity would show as logged in until a favorite, vote or sync
/// exposes the failure. A HEAD request to the site's status endpoint
/// carries the assembled headers; a 2xx proves the credentials, a 401
/// or 403 disproves them, and anything else leaves them unverified.
///
/// The probe rides the same stack the app's real traffic does — the
/// native adapter and the application user agent — because a challenge
/// or a pass from a generic Dart client proves nothing about what the
/// app's own requests will meet. A Cloudflare challenge classifies as
/// [CredentialCheckResult.unavailable], not as a rejection: the site
/// never saw the credentials, so the form stays open for a retry.
///
/// Pass [dio] to reuse an existing client; the default one is created
/// with login-appropriate timeouts and closed afterwards.
Future<CredentialCheckResult> checkCredentials({
  required String host,
  Map<String, String>? headers,
  Dio? dio,
}) async {
  final Dio client =
      dio ??
            Dio(
              BaseOptions(
                headers: {
                  HttpHeaders.userAgentHeader: AppInfo.instance.userAgent,
                  ...?headers,
                },
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            )
        ..httpClientAdapter = NativeAdapter();
  try {
    final Response<void> response = await client.head(
      '${normalizeHostUrl(host)}/status.json',
      options: Options(
        headers: dio == null ? null : headers,
        // A 4xx is the answer being probed for, not a transport failure.
        validateStatus: (status) => status != null,
        followRedirects: false,
      ),
    );
    if (response.statusCode! < 300) return CredentialCheckResult.ok;
    if (response.statusCode == 401 || response.statusCode == 403) {
      // A Cloudflare challenge is not the site rejecting the
      // credentials; claiming a rejection would lock a working key
      // out of its own login form.
      if (isCloudflareChallenge(response)) {
        return CredentialCheckResult.unavailable;
      }
      return CredentialCheckResult.rejected;
    }
    return CredentialCheckResult.unavailable;
  } on DioException {
    return CredentialCheckResult.unavailable;
  } finally {
    if (dio == null) client.close();
  }
}
