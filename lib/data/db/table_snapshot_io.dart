import 'app_database.dart';

/// Generic whole-database delete/reinsert, shared by restore (`F-DAT-004`)
/// and wipe (`F-DAT-010`) — both need to touch every table without knowing
/// its shape, the same reasoning `JsonDumpService` already uses for export.
///
/// Deletes go through `PRAGMA defer_foreign_keys`, so table order inside a
/// transaction never has to match the FK graph — the constraint is only
/// checked at commit, once every table is consistent again.
class TableSnapshotIo {
  TableSnapshotIo(this._db);

  final AppDatabase _db;

  /// Hard-deletes every row in every table. `F-DAT-010`'s wipe is the one
  /// deliberate exception to "nothing is ever hard-deleted" (ADR-0008) — a
  /// user-initiated full reset, not a normal delete path.
  Future<void> deleteAllRows() {
    return _db.transaction(() async {
      await _db.customStatement('PRAGMA defer_foreign_keys = TRUE');
      for (final table in _db.allTables) {
        await _db.customStatement('DELETE FROM ${table.actualTableName}');
      }
    });
  }

  /// Replaces every row in every table with [tables] (table name to list of
  /// raw column maps, the shape `JsonExportService`/`JsonDumpService` write).
  /// Transactional: any failure rolls the whole thing back, so a database
  /// mid-restore never ends up half-populated (`F-DAT-004` §3).
  Future<void> restoreFrom(Map<String, dynamic> tables) {
    return _db.transaction(() async {
      await _db.customStatement('PRAGMA defer_foreign_keys = TRUE');
      for (final table in _db.allTables) {
        await _db.customStatement('DELETE FROM ${table.actualTableName}');
      }
      for (final table in _db.allTables) {
        final rows = tables[table.actualTableName] as List? ?? const [];
        for (final row in rows) {
          final map = Map<String, dynamic>.from(row as Map);
          final columns = map.keys.toList();
          final values = columns.map((c) => _literal(map[c])).join(',');
          await _db.customStatement(
            'INSERT INTO ${table.actualTableName} '
            '(${columns.join(',')}) VALUES ($values)',
          );
        }
      }
    });
  }

  /// Permanently drops rows tombstoned before [cutoff] — the maintenance
  /// action `F-DAT-010`'s own spec names as its second job. Every table
  /// carries `deleted_at` (`SyncColumns`), so no table needs special-casing.
  Future<void> purgeTombstonesBefore(DateTime cutoff) {
    final cutoffMs = cutoff.toUtc().millisecondsSinceEpoch;
    return _db.transaction(() async {
      for (final table in _db.allTables) {
        await _db.customStatement(
          'DELETE FROM ${table.actualTableName} '
          'WHERE deleted_at IS NOT NULL AND deleted_at < $cutoffMs',
        );
      }
    });
  }

  /// Values come from our own exported JSON, not untrusted input, but are
  /// still embedded as escaped literals rather than driven through
  /// `Variable` — the row shape is fully dynamic (arbitrary tables, arbitrary
  /// columns), which parameter binding needs a static type for and this
  /// doesn't have.
  String _literal(Object? value) {
    if (value == null) return 'NULL';
    if (value is num) return value.toString();
    if (value is bool) return value ? '1' : '0';
    return "'${value.toString().replaceAll("'", "''")}'";
  }
}
