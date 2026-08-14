import 'package:intl/intl.dart';

import '../../core/units/distance.dart';
import '../../core/units/length.dart';
import '../../core/units/mass.dart';
import '../../core/units/unit_preferences.dart';
import '../../data/db/tables/enums.dart';
import '../repositories/body_measurement_repository.dart';
import '../repositories/routine_repository.dart';
import '../repositories/set_repository.dart';
import 'csv_writer.dart';

/// For humans and spreadsheets, not for backup (`F-DAT-002`) — that's
/// `F-DAT-001`. Uses the **display** unit throughout, named in the column
/// header, since a spreadsheet has no other place to carry that context
/// (spec §2). Lossy on purpose: no ids, no soft-deleted rows, no schema
/// version — `JsonExportService` is the format that round-trips.
class CsvExportService {
  CsvExportService(this._setRepo, this._measurementRepo, this._routineRepo);

  final SetRepository _setRepo;
  final BodyMeasurementRepository _measurementRepo;
  final RoutineRepository _routineRepo;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  /// One row per set (spec §1).
  Future<String> setsCsv(UnitPreferences prefs) async {
    final sets = await _setRepo.getSetsForExport();
    return csvDocument(
      [
        'date',
        'exercise',
        'set_type',
        'completed',
        'weight_${prefs.load.symbol}',
        'reps',
        'rpe',
        'distance_${prefs.distance.symbol}',
        'duration_seconds',
      ],
      [
        for (final s in sets)
          [
            _dateFormat.format(s.workoutDate),
            s.exerciseName,
            s.setType,
            s.isCompleted,
            if (s.weightGrams != null)
              _round(Mass.grams(s.weightGrams!).toUnit(prefs.load))
            else
              null,
            s.reps,
            s.rpe,
            if (s.distanceMetres != null)
              _round(Distance.metres(s.distanceMetres!).toUnit(prefs.distance))
            else
              null,
            s.durationSeconds,
          ],
      ],
    );
  }

  /// One row per measurement, every type together — a single CSV, not one
  /// per type, since a spreadsheet pivot handles that split better than a
  /// pile of near-empty files would (spec §4 only requires measurements be
  /// separate *from* routines and sets, not from each other).
  Future<String> measurementsCsv(UnitPreferences prefs) async {
    final measurements = await _measurementRepo.getAllForExport();
    return csvDocument(
      ['date', 'type', 'value', 'unit', 'notes'],
      [
        for (final m in measurements)
          [
            _dateFormat.format(
              DateTime.fromMillisecondsSinceEpoch(
                m.measuredAt,
                isUtc: true,
              ).add(Duration(minutes: m.measuredAtTzOffsetMinutes)),
            ),
            m.type.name,
            ..._measurementValueAndUnit(m.type, m.valueCanonical, prefs),
            m.notes,
          ],
      ],
    );
  }

  List<Object?> _measurementValueAndUnit(
    MeasurementType type,
    int valueCanonical,
    UnitPreferences prefs,
  ) => switch (type) {
    MeasurementType.bodyweight => [
      _round(Mass.grams(valueCanonical).toUnit(prefs.body)),
      prefs.body.symbol,
    ],
    MeasurementType.bodyFatPercent => [_round(valueCanonical / 100), '%'],
    _ => [
      _round(Length.millimetres(valueCanonical).toUnit(prefs.length)),
      prefs.length.symbol,
    ],
  };

  /// One row per routine-day-exercise target (spec §4).
  Future<String> routinesCsv(UnitPreferences prefs) async {
    final rows = await _routineRepo.getAllForExport();
    return csvDocument(
      [
        'routine',
        'day',
        'exercise',
        'position',
        'target_sets',
        'target_reps_min',
        'target_reps_max',
        'target_weight_${prefs.load.symbol}',
        'target_rpe',
      ],
      [
        for (final r in rows)
          [
            r.routineName,
            r.dayName,
            r.exerciseName,
            r.position,
            r.targetSets,
            r.targetRepsMin,
            r.targetRepsMax,
            if (r.targetWeightGrams != null)
              _round(Mass.grams(r.targetWeightGrams!).toUnit(prefs.load))
            else
              null,
            r.targetRpe,
          ],
      ],
    );
  }

  static double _round(double value) => double.parse(value.toStringAsFixed(2));
}
