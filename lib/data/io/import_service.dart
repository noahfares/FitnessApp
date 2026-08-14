import 'package:drift/drift.dart';

import '../../core/ids/uuid.dart';
import '../../core/units/mass.dart';
import '../../domain/catalog/exercise_search.dart';
import '../../domain/import/csv_import_adapter.dart';
import '../../domain/import/exercise_resolution.dart';
import '../../domain/import/import_exercise_matcher.dart';
import '../../domain/import/imported_set.dart';
import '../db/app_database.dart';
import '../db/tables/enums.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/personal_record_repository.dart';

export '../../domain/import/exercise_resolution.dart';

class ImportPreview {
  const ImportPreview({
    required this.parsed,
    required this.unmatchedExerciseNames,
    required this.workoutCount,
    required this.setCount,
  });

  final ParsedImport parsed;
  final List<String> unmatchedExerciseNames;
  final int workoutCount;
  final int setCount;
}

class ImportResult {
  const ImportResult({
    required this.workoutsImported,
    required this.setsImported,
    required this.workoutsSkippedAsDuplicate,
  });

  final int workoutsImported;
  final int setsImported;
  final int workoutsSkippedAsDuplicate;
}

/// Commits a [ParsedImport] into the database (`F-DAT-005` §1–2, 5).
///
/// Not built this batch: distance import — a source file's distance unit is
/// exactly as ambiguous as its weight unit (spec §3's own bar), and no
/// acceptance criterion here requires cardio-distance correctness the way it
/// requires "correct dates, weights and set types" — so distance is left
/// unset on every imported set rather than guessed. Weight, reps, duration
/// (unambiguously seconds), RPE, notes and warm-up status are imported.
class ImportService {
  ImportService(this._db, this._exerciseRepo, this._prRepo);

  final AppDatabase _db;
  final ExerciseRepository _exerciseRepo;
  final PersonalRecordRepository _prRepo;

  Future<List<ExerciseCandidate>> _catalogueCandidates() async {
    final all = await _exerciseRepo.getAll();
    return [
      for (final e in all)
        ExerciseCandidate(id: e.id, name: e.name, aliases: e.aliases),
    ];
  }

  /// Parses nothing, writes nothing — just what `F-DAT-005` §4 asks for:
  /// counts to show before committing.
  Future<ImportPreview> preview(ParsedImport parsed) async {
    final catalogue = await _catalogueCandidates();
    final names = [for (final s in parsed.sets) s.exerciseName];
    final unmatched = unmatchedExerciseNames(names, catalogue);
    final workoutKeys = <String>{
      for (final s in parsed.sets)
        '${s.workoutStartedAt.millisecondsSinceEpoch}|${s.workoutName}',
    };
    return ImportPreview(
      parsed: parsed,
      unmatchedExerciseNames: unmatched,
      workoutCount: workoutKeys.length,
      setCount: parsed.sets.length,
    );
  }

  /// Writes every workout in [parsed] that doesn't already exist.
  ///
  /// Idempotent (spec §5) at the workout level: a workout is skipped
  /// wholesale if one already exists with the exact same `started_at` — the
  /// source date is deterministic across re-imports of the same file, so
  /// this is the natural key without a schema change.
  ///
  /// A CSV carries no UTC offset. The parsed local wall-clock is stamped
  /// with the *device's* current offset at import time — the same
  /// best-effort choice this codebase already made once
  /// (`app_database.dart`'s `from < 3` migration backfill), and the only one
  /// available without asking the user to name a timezone for every row.
  Future<ImportResult> commit(
    ParsedImport parsed,
    Map<String, ExerciseResolution> resolutions, {
    required MassUnit sourceUnit,
    DateTime Function()? clock,
  }) async {
    final now = clock ?? DateTime.now;
    final catalogue = await _catalogueCandidates();

    final resolvedIds = <String, String?>{};
    for (final name in {for (final s in parsed.sets) s.exerciseName}) {
      final matched = matchImportedExerciseName(name, catalogue);
      if (matched != null) {
        resolvedIds[name] = matched;
        continue;
      }
      final resolution = resolutions[name];
      switch (resolution?.kind) {
        case ExerciseResolutionKind.useExisting:
          resolvedIds[name] = resolution!.exerciseId;
        case ExerciseResolutionKind.createCustom:
          final id = newUuidV4();
          await _exerciseRepo.createCustom(
            id: id,
            name: name,
            primaryMuscle: Muscle.fullBody,
            equipment: Equipment.other,
            trackingType: TrackingType.weightReps,
          );
          resolvedIds[name] = id;
        case ExerciseResolutionKind.skip:
        case null:
          resolvedIds[name] = null;
      }
    }

    final groups = <String, List<ImportedSet>>{};
    for (final s in parsed.sets) {
      final key =
          '${s.workoutStartedAt.millisecondsSinceEpoch}|${s.workoutName}';
      groups.putIfAbsent(key, () => []).add(s);
    }

    var workoutsImported = 0;
    var setsImported = 0;
    var workoutsSkipped = 0;
    final tzOffset = now().timeZoneOffset.inMinutes;

    await _db.transaction(() async {
      await _db.customStatement('PRAGMA defer_foreign_keys = TRUE');

      for (final sets in groups.values) {
        final startedAtMs = sets.first.workoutStartedAt.millisecondsSinceEpoch;
        final existing = await _db
            .customSelect(
              'SELECT id FROM workouts '
              'WHERE started_at = ? AND deleted_at IS NULL',
              variables: [Variable<int>(startedAtMs)],
              readsFrom: {_db.workouts},
            )
            .getSingleOrNull();
        if (existing != null) {
          workoutsSkipped++;
          continue;
        }

        final workoutId = newUuidV4();
        final ts = now().millisecondsSinceEpoch;
        final workoutName = sets.first.workoutName.trim();
        await _db
            .into(_db.workouts)
            .insert(
              WorkoutsCompanion.insert(
                id: workoutId,
                name: workoutName.isNotEmpty ? workoutName : 'Imported workout',
                startedAt: startedAtMs,
                startedAtTzOffsetMinutes: tzOffset,
                // No end time in a per-set row shape; zero-duration is the
                // same fallback `app_database.dart`'s own migration already
                // used for a workout with no other signal.
                endedAt: Value(startedAtMs),
                createdAt: ts,
                updatedAt: ts,
              ),
            );
        workoutsImported++;

        final byExercise = <String, List<ImportedSet>>{};
        final orderedNames = <String>[];
        for (final s in sets) {
          if (!byExercise.containsKey(s.exerciseName)) {
            orderedNames.add(s.exerciseName);
          }
          byExercise.putIfAbsent(s.exerciseName, () => []).add(s);
        }

        var position = 0;
        for (final exerciseName in orderedNames) {
          final exerciseId = resolvedIds[exerciseName];
          if (exerciseId == null) continue;

          final workoutExerciseId = newUuidV4();
          await _db
              .into(_db.workoutExercises)
              .insert(
                WorkoutExercisesCompanion.insert(
                  id: workoutExerciseId,
                  workoutId: workoutId,
                  exerciseId: exerciseId,
                  position: position++,
                  createdAt: ts,
                  updatedAt: ts,
                ),
              );

          final exerciseSets = byExercise[exerciseName]!
            ..sort((a, b) => a.setOrder.compareTo(b.setOrder));
          for (var i = 0; i < exerciseSets.length; i++) {
            final s = exerciseSets[i];
            await _db
                .into(_db.sets)
                .insert(
                  SetsCompanion.insert(
                    id: newUuidV4(),
                    workoutExerciseId: workoutExerciseId,
                    position: i,
                    setType: Value(
                      s.isWarmup ? SetType.warmup : SetType.working,
                    ),
                    weightGrams: Value(
                      s.weight == null
                          ? null
                          : Mass.inUnit(s.weight!, sourceUnit).grams,
                    ),
                    reps: Value(s.reps),
                    durationSeconds: Value(s.durationSeconds),
                    rpe: Value(s.rpe),
                    isCompleted: const Value(true),
                    completedAt: Value(startedAtMs),
                    completedAtTzOffsetMinutes: Value(tzOffset),
                    notes: Value(s.notes),
                    createdAt: ts,
                    updatedAt: ts,
                  ),
                );
            setsImported++;
          }
        }
      }
    });

    // The PR cache only ever advances incrementally on live logging
    // (`F-LOG-013`'s own note) — it cannot find the next-best value for a
    // bulk-inserted history without a full rescan.
    if (setsImported > 0) {
      await _prRepo.rebuildAll();
    }

    return ImportResult(
      workoutsImported: workoutsImported,
      setsImported: setsImported,
      workoutsSkippedAsDuplicate: workoutsSkipped,
    );
  }
}
