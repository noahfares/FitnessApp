import 'dart:convert';

import '../../core/app_version.dart';
import '../db/app_database.dart';

/// Serialises every table to a single JSON file (`F-DAT-011`).
///
/// **Insurance, not a feature.** The schema will change weekly through
/// Phases 0–2, and a migration bug discovered after real training data
/// exists is the worst failure mode available. Fidelity to the database beats
/// readability here — this is a rescue artefact, not the designed, versioned
/// export (`F-DAT-001`, Phase 5).
///
/// Canonical units, raw column names, no transformation: every row comes
/// straight from `SELECT * FROM <table>`, tombstoned rows included.
class JsonDumpService {
  JsonDumpService(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Writes the dump to [sink] one table at a time, so peak memory is bounded
  /// by the largest single table rather than the whole database (acceptance:
  /// "dumping a multi-year database does not exhaust memory").
  Future<void> writeTo(StringSink sink) async {
    sink.write('{');
    sink.write('"schemaVersion":${_db.schemaVersion},');
    sink.write('"appVersion":${jsonEncode(appVersion)},');
    sink.write('"exportedAt":${_clock().toUtc().millisecondsSinceEpoch},');
    sink.write('"tables":{');

    final tables = _db.allTables.toList();
    for (var i = 0; i < tables.length; i++) {
      if (i > 0) sink.write(',');
      final table = tables[i];
      sink.write(jsonEncode(table.actualTableName));
      sink.write(':[');

      // Every table, including tombstoned rows — a rescue dump that filters
      // `deleted_at` defeats its own purpose.
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
