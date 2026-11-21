import 'package:e1547/logs/logs.dart';

class LogRedactor {
  const LogRedactor({
    this.secrets = defaultSecrets,
    this.placeholder = '[redacted]',
  });

  static const Set<String> defaultSecrets = {
    'auth',
    'cookie',
    'credential',
    'key',
    'login',
    'password',
    'secret',
    'session',
    'token',
  };

  final Set<String> secrets;
  final String placeholder;

  LogEntry apply(LogEntry entry) => entry.copyWith(
    attributes: _redactMap(entry.attributes),
    error: entry.error == null
        ? null
        : LogError(
            type: entry.error!.type,
            message: redactUrl(entry.error!.message),
          ),
  );

  bool isSecret(String key) {
    final String normalized = key.toLowerCase().replaceAll(
      RegExp(r'[-_\s]'),
      '',
    );
    return secrets.any(normalized.contains);
  }

  Map<String, Object?> _redactMap(Map<String, Object?> value) => value.map(
    (k, v) => MapEntry(k, isSecret(k) ? placeholder : _redactValue(v)),
  );

  Object? _redactValue(Object? value) => switch (value) {
    null || bool() || num() => value,
    Map() => _redactMap(value.map((k, v) => MapEntry(k.toString(), v))),
    List() => value.map(_redactValue).toList(),
    String() => redactUrl(value),
    _ => redactUrl(value.toString()),
  };

  // The lookbehind anchors every match to the start of its whitespace
  // delimited segment: without it the engine retried the pattern at
  // every position of a long segment and swept the whole prefix once
  // per retry, which is quadratic (measured: 1.2s for a 10k line, in
  // the synchronous log sink on the ui isolate).
  static final RegExp _queried = RegExp(r'(?<=^|\s)\S+\?\S+=\S*');

  String redactUrl(String value) {
    if (!value.contains('?')) return value;
    return value.replaceAllMapped(_queried, (match) => _scrub(match.group(0)!));
  }

  String _scrub(String value) {
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || !uri.hasQuery) return value;
    final Map<String, List<String>> query = uri.queryParametersAll;
    if (!query.keys.any(isSecret)) return value;
    return uri
        .replace(
          queryParameters: query.map(
            (k, v) => MapEntry(k, isSecret(k) ? [placeholder] : v),
          ),
        )
        .toString();
  }
}
