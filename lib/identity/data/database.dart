import 'dart:math';

import 'package:drift/drift.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';

class NullToEmptyStringSqlConverter extends TypeConverter<String?, String> {
  const NullToEmptyStringSqlConverter();

  @override
  String? fromSql(String fromDb) => fromDb.isEmpty ? null : fromDb;

  @override
  String toSql(String? value) => value ?? '';
}

@UseRowClass(Identity, generateInsertable: true)
class IdentitiesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get host => text()();
  TextColumn get username =>
      text().map(const NullToEmptyStringSqlConverter())();
  TextColumn get headers =>
      text().nullable().map(JsonSqlConverter.map<String>())();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {host, username},
  ];
}

@DriftAccessor(tables: [IdentitiesTable])
class IdentityRepository extends DatabaseAccessor<GeneratedDatabase>
    with $IdentityRepositoryMixin {
  IdentityRepository(super.db);

  StreamFuture<int> length() {
    final Expression<int> count = identitiesTable.id.count();

    return (selectOnly(
      identitiesTable,
    )..addColumns([count])).map((row) => row.read(count)!).watchSingle().future;
  }

  StreamFuture<Identity?> getOrNull(int id) => (select(
    identitiesTable,
  )..where((tbl) => tbl.id.equals(id))).watchSingleOrNull().future;

  StreamFuture<Identity> get(int id) =>
      getOrNull(id).stream.map((e) => e!).future;

  SimpleSelectStatement<IdentitiesTable, Identity> _queryExpression({
    String? nameRegex,
    String? hostRegex,
    int? limit,
    int? offset,
  }) {
    final selectable = select(identitiesTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.host),
        (t) => OrderingTerm(expression: t.username),
      ]);
    if (nameRegex != null) {
      selectable.where(
        (tbl) => tbl.username.regexp(nameRegex, caseSensitive: false),
      );
    }
    if (hostRegex != null) {
      selectable.where(
        (tbl) => tbl.host.regexp(hostRegex, caseSensitive: false),
      );
    }
    assert(
      offset == null || limit != null,
      'Cannot specify offset without limit!',
    );
    if (limit != null) {
      selectable.limit(limit, offset: offset);
    }
    return selectable;
  }

  StreamFuture<List<Identity>> page({
    required int page,
    int? limit,
    String? nameRegex,
    String? hostRegex,
  }) {
    limit ??= 80;
    int offset = (max(1, page) - 1) * limit;
    return _queryExpression(
      nameRegex: nameRegex,
      hostRegex: hostRegex,
      limit: limit,
      offset: offset,
    ).watch().future;
  }

  StreamFuture<List<Identity>> all({String? nameRegex, String? hostRegex}) {
    return _queryExpression(
      nameRegex: nameRegex,
      hostRegex: hostRegex,
    ).watch().future;
  }

  Future<Identity> add(IdentityRequest item) async =>
      into(identitiesTable).insertReturning(item.toCompanion());

  Future<void> addAll(List<IdentityRequest> items) async => batch(
    (batch) => batch.insertAll(
      identitiesTable,
      items.map((item) => item.toCompanion()),
    ),
  );

  Future<void> remove(Identity item) async =>
      (delete(identitiesTable)..where((tbl) => tbl.id.equals(item.id))).go();

  Future<void> removeAll(List<Identity> items) async => (delete(
    identitiesTable,
  )..where((tbl) => tbl.id.isIn(items.map((e) => e.id)))).go();

  Future<void> replace(Identity item) async => (update(
    identitiesTable,
  )..where((tbl) => tbl.id.equals(item.id))).write(item.toInsertable());

  /// Strips credential-like headers from every identity row.
  ///
  /// Used by database export and import, so account credentials never
  /// travel through database files.
  Future<int> removeCredentials() async {
    final rows = await select(identitiesTable).get();
    // Clearing a credential row's username turns it into an anonymous
    // row for its host, and only one anonymous row per host survives
    // the host+username unique key. The first anonymous slot on each
    // host wins: either the row that already was anonymous, or the
    // first credential row this pass clears. Every other row for the
    // same host hands its data over before it is deleted — its
    // follows, histories and tasks hang off its id in a real backup,
    // so deleting it outright would orphan them (foreign keys off) or
    // fail the delete outright (foreign keys on).
    final Map<String, int> slots = {
      for (final row in rows)
        if (row.username == null) normalizeHostUrl(row.host): row.id,
    };
    var updated = 0;
    for (final row in rows) {
      final headers = row.headers;
      if (headers == null) continue;
      final sanitized = Map.of(headers)
        ..removeWhere((name, _) => !isExportableHeader(name));
      if (sanitized.length == headers.length) continue;
      // write '{}' rather than null: avoids the nullable-map-converter edge
      //
      // Keeping the username would show a logged-in account whose
      // every write the server bounces with 403 InvalidAuthenticity-
      // Token — the CSRF guard skips itself only for credentialed
      // requests. Clearing it shows the account as signed out, the
      // honest state after the credentials were stripped.
      final String host = normalizeHostUrl(row.host);
      final int? slot = slots[host];
      if (row.username != null && slot != null && slot != row.id) {
        await _moveIdentityData(row.id, slot);
        await (delete(
          identitiesTable,
        )..where((tbl) => tbl.id.equals(row.id))).go();
      } else {
        await (update(
          identitiesTable,
        )..where((tbl) => tbl.id.equals(row.id))).write(
          IdentityCompanion(
            headers: Value(
              sanitized.isEmpty ? const <String, String>{} : sanitized,
            ),
            username: row.username != null
                ? const Value(null)
                : const Value.absent(),
          ),
        );
        if (row.username != null) slots[host] = row.id;
      }
      updated++;
    }
    return updated;
  }

  /// Moves everything anchored to identity [from] onto identity [to],
  /// so [from]'s row can be deleted without orphaning or losing data.
  Future<void> _moveIdentityData(int from, int to) async {
    // Association rows: the sibling adopts the ones it does not have
    // yet, the duplicates are ignored, and the rest detach — the
    // {identity, follow} composite keys make one account's follow and
    // the sibling's coexist as one adopted row.
    for (final (table, column) in const [
      ('follows_identities_table', 'follow'),
      ('histories_identities_table', 'history'),
      ('tasks_identities_table', 'task'),
    ]) {
      await customStatement(
        'INSERT OR IGNORE INTO $table (identity, $column) '
        'SELECT ?, $column FROM $table WHERE identity = ?',
        [to, from],
      );
      await customStatement('DELETE FROM $table WHERE identity = ?', [from]);
    }
    // Traits are one-to-one with the identity: the sibling adopts the
    // account's denylist and home tags unless it keeps its own.
    await customStatement(
      'UPDATE traits_table SET id = ? WHERE id = ? '
      'AND NOT EXISTS (SELECT 1 FROM traits_table WHERE id = ?)',
      [to, from, to],
    );
    await customStatement('DELETE FROM traits_table WHERE id = ?', [from]);
  }

  /// Returns the normalized hosts of all identities.
  Future<Set<String>> hosts() async => (await select(
    identitiesTable,
  ).get()).map((row) => normalizeHostUrl(row.host)).toSet();
}

extension IdentityRequestCompanion on IdentityRequest {
  IdentityCompanion toCompanion() => IdentityCompanion(
    host: Value(normalizeHostUrl(host)),
    username: Value(username),
    headers: Value(headers),
  );
}
