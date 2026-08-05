import 'package:drift/drift.dart';

/// The universal columns every table carries (ADR-0008).
///
/// Free to add now, impossible to reconstruct once real training history
/// exists — which is the entire argument for putting them in v1 even though
/// this app is local-only and single-user.
///
/// Mixed into every table in the schema. If a new table does not use this,
/// that is a bug: `test/data/db/schema_test.dart` asserts every table has them.
mixin SyncColumns on Table {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  TextColumn get id => text()();

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  TextColumn get userId =>
      text().named('user_id').withDefault(const Constant('local-user'))();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer().named('created_at')();

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  IntColumn get updatedAt => integer().named('updated_at')();

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stores a `List<String>` as a JSON array.
///
/// Used for genuinely list-shaped attributes that are never queried
/// individually — exercise aliases, secondary muscles. Anything that needs
/// filtering or joining gets a real table instead.
class StringListConverter extends TypeConverter<List<String>, String>
    with JsonTypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    return fromDb.split(_separator).where((part) => part.isNotEmpty).toList();
  }

  @override
  String toSql(List<String> value) => value.join(_separator);

  /// ASCII unit separator (U+001F) rather than JSON: these lists hold short
  /// identifiers we control, not free text, so escaping is not a concern and
  /// the stored form stays greppable. A character no exercise name can
  /// contain, unlike a comma.
  static const String _separator = '\u001F';
}

/// Stores a `List<int>` the same way — scheduled weekdays (`F-ROU-012`).
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    return fromDb.split(',').where((p) => p.isNotEmpty).map(int.parse).toList();
  }

  @override
  String toSql(List<int> value) => value.join(',');
}
