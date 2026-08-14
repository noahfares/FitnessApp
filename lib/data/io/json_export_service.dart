import 'dart:convert';

import '../../core/app_version.dart';
import '../db/app_database.dart';

/// The designed, versioned, round-trip-guaranteed export (`F-DAT-001`),
/// built on the same one-table-at-a-time streaming `JsonDumpService`
/// (`F-DAT-011`) already proved out — this is that format with one addition,
/// an explicit `"units":"canonical-v1"` marker, plus the guarantee that
/// `RestoreService` reads exactly what this writes.
///
/// Every column, raw, tombstoned rows included: `deleted_at`, `created_at`/
/// `updated_at` and any per-row UTC-offset column are ordinary columns, so a
/// `SELECT *` carries them without special-casing.
class JsonExportService {
  JsonExportService(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Future<void> writeTo(StringSink sink) async {
    sink.write('{');
    sink.write('"schemaVersion":${_db.schemaVersion},');
    sink.write('"appVersion":${jsonEncode(appVersion)},');
    sink.write('"exportedAt":${_clock().toUtc().millisecondsSinceEpoch},');
    sink.write('"units":"canonical-v1",');
    sink.write('"tables":{');

    final tables = _db.allTables.toList();
    for (var i = 0; i < tables.length; i++) {
      if (i > 0) sink.write(',');
      final table = tables[i];
      sink.write(jsonEncode(table.actualTableName));
      sink.write(':[');

      final rows = await _db
          .customSelect('SELECT * FROM ${table.actualTableName}')
          .get();
      for (var r = 0; r < rows.length; r++) {
        if (r > 0) sink.write(',');
        sink.write(jsonEncode(rows[r].data));
      }
      sink.write(']');
    }

    sink.write('}}');
  }
}
