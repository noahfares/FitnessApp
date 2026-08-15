import 'package:drift/drift.dart';

import '../../core/ids/uuid.dart';
import '../../domain/health/health_connect_import.dart';
import '../db/app_database.dart';
import '../db/tables/enums.dart';
import '../platform/health_connect_service.dart';

/// Bodyweight and future body measurements (`F-BOD-001`).
///
/// Only bodyweight is logged from Phase 1 — it is unrecoverable data, unlike a
/// missing column, which is why it sits here rather than with the rest of body
/// metrics in Phase 4 (docs/30-features/BOD/F-BOD-001.md §Why).
class BodyMeasurementRepository {
  BodyMeasurementRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  int get _now => _clock().millisecondsSinceEpoch;

  /// Every bodyweight entry, most recent first.
  Stream<List<BodyMeasurement>> watchBodyweightHistory() =>
      _bodyweightQuery().watch();

  /// Every measurement of every type, oldest first — the CSV export
  /// (`F-DAT-002` §4). A one-shot `Future`, not a `Stream`: export is a
  /// single action.
  Future<List<BodyMeasurement>> getAllForExport() =>
      (_db.select(_db.bodyMeasurements)
            ..where((m) => m.deletedAt.isNull())
            ..orderBy([
              (m) => OrderingTerm(
                expression: m.measuredAt,
                mode: OrderingMode.asc,
              ),
            ]))
          .get();

  /// The single most recent entry, for the dashboard's quick-entry card
  /// (`F-BOD-001` §4).
  Stream<BodyMeasurement?> watchLatestBodyweight() =>
      (_bodyweightQuery()..limit(1)).watchSingleOrNull();

  SimpleSelectStatement<$BodyMeasurementsTable, BodyMeasurement>
  _bodyweightQuery() => (_db.select(_db.bodyMeasurements)
    ..where((m) => m.type.equalsValue(MeasurementType.bodyweight))
    ..where((m) => m.deletedAt.isNull())
    ..orderBy([
      (m) => OrderingTerm(expression: m.measuredAt, mode: OrderingMode.desc),
    ]));

  /// Logs a bodyweight entry (`F-BOD-001` §1). [measuredAt] defaults to now; a
  /// past date is a legitimate backfill, not an edge case.
  Future<String> logBodyweight({
    required int grams,
    DateTime? measuredAt,
    String? notes,
  }) async {
    final at = measuredAt ?? _clock();
    final id = newUuidV4();
    final timestamp = _now;
    final trimmedNotes = notes?.trim();

    await _db
        .into(_db.bodyMeasurements)
        .insert(
          BodyMeasurementsCompanion.insert(
            id: id,
            measuredAt: at.millisecondsSinceEpoch,
            measuredAtTzOffsetMinutes: at.timeZoneOffset.inMinutes,
            type: MeasurementType.bodyweight,
            valueCanonical: grams,
            notes: Value(
              trimmedNotes == null || trimmedNotes.isEmpty
                  ? null
                  : trimmedNotes,
            ),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    await _recomputeWorkoutBodyweights();
    return id;
  }

  /// Edits an entry — a mis-typed weight or a corrected date (`F-BOD-001` §1).
  Future<void> updateBodyweight(
    String id, {
    int? grams,
    DateTime? measuredAt,
    Value<String?> notes = const Value.absent(),
  }) async {
    await (_db.update(
      _db.bodyMeasurements,
    )..where((m) => m.id.equals(id))).write(
      BodyMeasurementsCompanion(
        valueCanonical: grams == null ? const Value.absent() : Value(grams),
        measuredAt: measuredAt == null
            ? const Value.absent()
            : Value(measuredAt.millisecondsSinceEpoch),
        measuredAtTzOffsetMinutes: measuredAt == null
            ? const Value.absent()
            : Value(measuredAt.timeZoneOffset.inMinutes),
        notes: notes,
        updatedAt: Value(_now),
      ),
    );
    await _recomputeWorkoutBodyweights();
  }

  /// Tombstones an entry (ADR-0008).
  Future<void> deleteBodyweight(String id) async {
    final timestamp = _now;
    await (_db.update(
      _db.bodyMeasurements,
    )..where((m) => m.id.equals(id))).write(
      BodyMeasurementsCompanion(
        deletedAt: Value(timestamp),
        updatedAt: Value(timestamp),
      ),
    );
    await _recomputeWorkoutBodyweights();
  }

  /// Every entry of [type], most recent first (`F-BOD-002`).
  ///
  /// [type] must not be [MeasurementType.bodyweight] — that has its own
  /// dedicated methods above, since only it triggers a workout-bodyweight
  /// recompute.
  Stream<List<BodyMeasurement>> watchHistory(MeasurementType type) =>
      (_db.select(_db.bodyMeasurements)
            ..where((m) => m.type.equalsValue(type))
            ..where((m) => m.deletedAt.isNull())
            ..orderBy([
              (m) => OrderingTerm(
                expression: m.measuredAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  /// The single most recent entry of [type], for a summary tile.
  Stream<BodyMeasurement?> watchLatest(MeasurementType type) =>
      (_db.select(_db.bodyMeasurements)
            ..where((m) => m.type.equalsValue(type))
            ..where((m) => m.deletedAt.isNull())
            ..orderBy([
              (m) => OrderingTerm(
                expression: m.measuredAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .watchSingleOrNull();

  /// Logs a measurement of any non-bodyweight [type] (`F-BOD-002`).
  /// [valueCanonical] is millimetres for circumferences, basis points for
  /// body-fat percentage.
  Future<String> logMeasurement({
    required MeasurementType type,
    required int valueCanonical,
    DateTime? measuredAt,
    String? notes,
  }) async {
    final at = measuredAt ?? _clock();
    final id = newUuidV4();
    final timestamp = _now;
    final trimmedNotes = notes?.trim();

    await _db
        .into(_db.bodyMeasurements)
        .insert(
          BodyMeasurementsCompanion.insert(
            id: id,
            measuredAt: at.millisecondsSinceEpoch,
            measuredAtTzOffsetMinutes: at.timeZoneOffset.inMinutes,
            type: type,
            valueCanonical: valueCanonical,
            notes: Value(
              trimmedNotes == null || trimmedNotes.isEmpty
                  ? null
                  : trimmedNotes,
            ),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    return id;
  }

  /// Edits a non-bodyweight measurement entry (`F-BOD-002`).
  Future<void> updateMeasurement(
    String id, {
    int? valueCanonical,
    DateTime? measuredAt,
    Value<String?> notes = const Value.absent(),
  }) async {
    await (_db.update(
      _db.bodyMeasurements,
    )..where((m) => m.id.equals(id))).write(
      BodyMeasurementsCompanion(
        valueCanonical: valueCanonical == null
            ? const Value.absent()
            : Value(valueCanonical),
        measuredAt: measuredAt == null
            ? const Value.absent()
            : Value(measuredAt.millisecondsSinceEpoch),
        measuredAtTzOffsetMinutes: measuredAt == null
            ? const Value.absent()
            : Value(measuredAt.timeZoneOffset.inMinutes),
        notes: notes,
        updatedAt: Value(_now),
      ),
    );
  }

  /// Tombstones a non-bodyweight measurement entry (ADR-0008).
  Future<void> deleteMeasurement(String id) async {
    final timestamp = _now;
    await (_db.update(
      _db.bodyMeasurements,
    )..where((m) => m.id.equals(id))).write(
      BodyMeasurementsCompanion(
        deletedAt: Value(timestamp),
        updatedAt: Value(timestamp),
      ),
    );
  }

  /// Imports new bodyweight readings from Health Connect (`F-HLT-002`).
  ///
  /// A manual entry always wins
  /// (`domain/health/health_connect_import.dart`'s conflict rule) — a day
  /// the user has already logged by hand never gets a Health Connect
  /// reading imported alongside or over it. Every reading's own UUID is
  /// also checked against what has already been imported, so calling this
  /// again (this app's own trigger is every time the body screen opens)
  /// never creates a duplicate. [healthConnect] is a call-site parameter,
  /// not a constructor dependency, for the same reason `WorkoutRepository`
  /// takes its opt-in flag the same way — `data/` never imports
  /// `features/`, and the enabled check lives in a `features/` provider.
  ///
  /// Returns the number of readings actually imported.
  Future<int> syncBodyweightFromHealthConnect(
    HealthConnectService healthConnect,
  ) async {
    if (!await healthConnect.hasPermissions()) return 0;

    // Health Connect's own default access window is 30 days back from grant
    // time; asking further back would need the extra history permission
    // `F-HLT-002` never requested (kept to the minimum this feature needs).
    final readings = await healthConnect.readWeightReadings(
      since: _clock().subtract(const Duration(days: 30)),
    );
    if (readings.isEmpty) return 0;

    final alreadyImported = await _importedHealthConnectRecordIds();
    final manualDates = await _manuallyMeasuredLocalDates();

    var imported = 0;
    for (final reading in readings) {
      if (alreadyImported.contains(reading.id)) continue;
      final local = reading.measuredAt.toLocal();
      if (!shouldImportHealthConnectReading(
        candidateLocalDate: local,
        manuallyMeasuredLocalDates: manualDates,
      )) {
        continue;
      }

      final timestamp = _now;
      await _db
          .into(_db.bodyMeasurements)
          .insert(
            BodyMeasurementsCompanion.insert(
              id: newUuidV4(),
              measuredAt: local.millisecondsSinceEpoch,
              measuredAtTzOffsetMinutes: local.timeZoneOffset.inMinutes,
              type: MeasurementType.bodyweight,
              valueCanonical: reading.grams,
              healthConnectRecordId: Value(reading.id),
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
      imported++;
    }
    if (imported > 0) await _recomputeWorkoutBodyweights();
    return imported;
  }

  Future<Set<String>> _importedHealthConnectRecordIds() async {
    final rows =
        await (_db.selectOnly(_db.bodyMeasurements)
              ..addColumns([_db.bodyMeasurements.healthConnectRecordId])
              ..where(
                _db.bodyMeasurements.type.equalsValue(
                  MeasurementType.bodyweight,
                ),
              )
              ..where(_db.bodyMeasurements.healthConnectRecordId.isNotNull())
              ..where(_db.bodyMeasurements.deletedAt.isNull()))
            .get();
    return {
      for (final row in rows)
        row.read(_db.bodyMeasurements.healthConnectRecordId)!,
    };
  }

  /// The local calendar date (ADR-0008) of every bodyweight entry the user
  /// entered by hand — never one only Health Connect has ever supplied.
  Future<Set<DateTime>> _manuallyMeasuredLocalDates() async {
    final rows =
        await (_db.selectOnly(_db.bodyMeasurements)
              ..addColumns([
                _db.bodyMeasurements.measuredAt,
                _db.bodyMeasurements.measuredAtTzOffsetMinutes,
              ])
              ..where(
                _db.bodyMeasurements.type.equalsValue(
                  MeasurementType.bodyweight,
                ),
              )
              ..where(_db.bodyMeasurements.healthConnectRecordId.isNull())
              ..where(_db.bodyMeasurements.deletedAt.isNull()))
            .get();
    return {
      for (final row in rows)
        DateTime.fromMillisecondsSinceEpoch(
          row.read(_db.bodyMeasurements.measuredAt)!,
          isUtc: true,
        ).add(
          Duration(
            minutes: row.read(_db.bodyMeasurements.measuredAtTzOffsetMinutes)!,
          ),
        ),
    };
  }

  /// Re-derives every workout's `bodyweight_grams` from the bodyweight log.
  ///
  /// Run after every write here, not just new ones: backfilling or correcting
  /// an older entry must update whichever workouts it is now the most recent
  /// entry *before* (`F-BOD-001` §3, acceptance). A single correlated
  /// subquery re-scores every workout in one statement rather than looping in
  /// Dart — simple, and fast enough at the row counts this table sees through
  /// Phase 1 (docs/21-DATA-MODEL.md §deletion-policy).
  ///
  /// Deliberately does not touch `updated_at`: this is a derived cache, the
  /// same way `personal_records` is, not a semantic edit to the workout.
  Future<void> _recomputeWorkoutBodyweights() async {
    await _db.customUpdate(
      '''
      UPDATE workouts
         SET bodyweight_grams = (
               SELECT m.value_canonical FROM body_measurements m
                WHERE m.type = 'bodyweight' AND m.deleted_at IS NULL
                  AND m.measured_at <= workouts.started_at
                ORDER BY m.measured_at DESC LIMIT 1
             )
       WHERE deleted_at IS NULL
      ''',
      updates: {_db.workouts},
    );
  }
}
