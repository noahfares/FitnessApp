import 'package:drift/drift.dart';

import '../../core/ids/uuid.dart';
import '../db/app_database.dart';

/// One exercise inside a routine day, joined to its catalogue row
/// (`F-ROU-003`).
///
/// A read model, not a table — the day editor needs the exercise's name and
/// tracking type alongside its targets in one place, same reasoning as
/// `SessionExercise` in `WorkoutRepository`.
class RoutineExerciseDetail {
  const RoutineExerciseDetail({
    required this.routineExerciseId,
    required this.exerciseId,
    required this.exerciseName,
    required this.position,
    this.groupId,
    this.targetSets,
    this.targetRepsMin,
    this.targetRepsMax,
    this.targetWeightGrams,
    this.targetRpe,
    this.restSeconds,
    this.notes,
  });

  final String routineExerciseId;
  final String exerciseId;
  final String exerciseName;
  final int position;
  final String? groupId;
  final int? targetSets;
  final int? targetRepsMin;
  final int? targetRepsMax;
  final int? targetWeightGrams;
  final double? targetRpe;
  final int? restSeconds;
  final String? notes;
}

/// Routines, their days, and the per-exercise targets within each day
/// (`F-ROU-001`, `F-ROU-002`, `F-ROU-003`).
///
/// Same invariants as every other repository
/// ([`CLAUDE.md`](../../../CLAUDE.md#invariants)): every read filters
/// `deleted_at IS NULL`, every write stamps `updated_at`. Deleting a routine,
/// a day, or an exercise here **never** touches `workouts` — `ADR-0004`
/// snapshots everything a session needs at start, so nothing downstream reads
/// these tables again.
class RoutineRepository {
  RoutineRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  int get _now => _clock().millisecondsSinceEpoch;

  // ---------------------------------------------------------------- Routines

  Stream<List<Routine>> watchAll({bool includeArchived = false}) {
    final query = _db.select(_db.routines)
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm(expression: r.position)]);
    if (!includeArchived) {
      query.where((r) => r.archivedAt.isNull());
    }
    return query.watch();
  }

  Future<Routine?> findById(String id) => (_db.select(
    _db.routines,
  )..where((r) => r.id.equals(id) & r.deletedAt.isNull())).getSingleOrNull();

  /// Creates an empty routine, appended after every other routine
  /// (`F-ROU-001` §2).
  Future<Routine> create({required String name, String? notes}) async {
    final id = newUuidV4();
    final timestamp = _now;
    final position = await _nextPositionIn('routines');
    await _db
        .into(_db.routines)
        .insert(
          RoutinesCompanion.insert(
            id: id,
            name: name.trim(),
            notes: Value(notes?.trim().isEmpty ?? true ? null : notes!.trim()),
            position: position,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    return (await findById(id))!;
  }

  Future<void> rename(String id, String name) => _updateRoutine(
    id,
    RoutinesCompanion(name: Value(name.trim())),
  );

  Future<void> setNotes(String id, String? notes) {
    final trimmed = notes?.trim();
    return _updateRoutine(
      id,
      RoutinesCompanion(
        notes: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
      ),
    );
  }

  /// Hides from the start-a-workout flow without touching history
  /// (`F-ROU-009`) — same organisational-act-versus-tombstone split as
  /// `ExerciseRepository.setArchived`.
  Future<void> setArchived(String id, {required bool isArchived}) =>
      _updateRoutine(
        id,
        RoutinesCompanion(archivedAt: Value(isArchived ? _now : null)),
      );

  Future<void> _updateRoutine(String id, RoutinesCompanion changes) async {
    await (_db.update(_db.routines)..where((r) => r.id.equals(id))).write(
      changes.copyWith(updatedAt: Value(_now)),
    );
  }

  /// Tombstones the routine and everything under it. Workouts already
  /// started from it are untouched — `source_routine_day_id` is provenance
  /// only and is never read to render a session (`ADR-0004`, `F-ROU-001`
  /// §4).
  Future<void> delete(String id) async {
    final timestamp = _now;
    await _db.transaction(() async {
      final days =
          await (_db.select(_db.routineDays)
                ..where((d) => d.routineId.equals(id) & d.deletedAt.isNull()))
              .get();
      for (final day in days) {
        await _deleteDay(day.id, timestamp);
      }
      await _db.customUpdate(
        'UPDATE routines SET deleted_at = ?, updated_at = ? WHERE id = ?',
        variables: [
          Variable<int>(timestamp),
          Variable<int>(timestamp),
          Variable<String>(id),
        ],
        updates: {_db.routines},
      );
    });
  }

  /// A fully independent copy — new ids throughout, so editing or deleting
  /// either routine never touches the other (`F-ROU-001` §2,
  /// `F-ROU-008`).
  Future<Routine> duplicate(String id) async {
    final source = await findById(id);
    if (source == null) throw ArgumentError('No routine with id $id');

    final newRoutineId = newUuidV4();
    final timestamp = _now;
    final position = await _nextPositionIn('routines');

    await _db.transaction(() async {
      await _db
          .into(_db.routines)
          .insert(
            RoutinesCompanion.insert(
              id: newRoutineId,
              name: '${source.name} copy',
              notes: Value(source.notes),
              position: position,
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );

      final days =
          await (_db.select(_db.routineDays)
                ..where(
                  (d) => d.routineId.equals(id) & d.deletedAt.isNull(),
                )
                ..orderBy([(d) => OrderingTerm(expression: d.position)]))
              .get();

      for (final day in days) {
        final newDayId = newUuidV4();
        await _db
            .into(_db.routineDays)
            .insert(
              RoutineDaysCompanion.insert(
                id: newDayId,
                routineId: newRoutineId,
                name: day.name,
                position: day.position,
                scheduledWeekdays: Value(day.scheduledWeekdays),
                notes: Value(day.notes),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );

        final exercises =
            await (_db.select(_db.routineExercises)..where(
                  (re) =>
                      re.routineDayId.equals(day.id) & re.deletedAt.isNull(),
                ))
                .get();
        for (final exercise in exercises) {
          await _db
              .into(_db.routineExercises)
              .insert(
                RoutineExercisesCompanion.insert(
                  id: newUuidV4(),
                  routineDayId: newDayId,
                  exerciseId: exercise.exerciseId,
                  position: exercise.position,
                  groupId: Value(exercise.groupId),
                  targetSets: Value(exercise.targetSets),
                  targetRepsMin: Value(exercise.targetRepsMin),
                  targetRepsMax: Value(exercise.targetRepsMax),
                  targetWeightGrams: Value(exercise.targetWeightGrams),
                  targetRpe: Value(exercise.targetRpe),
                  restSeconds: Value(exercise.restSeconds),
                  notes: Value(exercise.notes),
                  createdAt: timestamp,
                  updatedAt: timestamp,
                ),
              );
        }
      }
    });

    return (await findById(newRoutineId))!;
  }

  /// Saves a logged session as a reusable routine (`F-ROU-001` §3,
  /// `F-LOG-012` §3) — a single day carrying each exercise's logged (not
  /// warm-up) set count, rep range, and heaviest completed weight as its
  /// starting targets. A one-shot copy, same as [duplicate]: nothing here
  /// stays linked to the workout it came from.
  Future<Routine> createFromWorkout(String workoutId, {String? name}) async {
    final workoutRows = await _db
        .customSelect(
          'SELECT name FROM workouts WHERE id = ? AND deleted_at IS NULL',
          variables: [Variable<String>(workoutId)],
          readsFrom: {_db.workouts},
        )
        .get();
    if (workoutRows.isEmpty) {
      throw ArgumentError('No workout with id $workoutId');
    }
    final routineName = name?.trim().isNotEmpty ?? false
        ? name!.trim()
        : workoutRows.first.read<String>('name');

    final exerciseRows = await _db
        .customSelect(
          '''
          SELECT we.id AS we_id, we.exercise_id AS exercise_id,
                 we.position AS position,
                 (SELECT COUNT(*) FROM sets s
                   WHERE s.workout_exercise_id = we.id AND s.deleted_at IS NULL
                     AND s.is_completed = 1 AND s.set_type != 'warmup')
                   AS set_count,
                 (SELECT MIN(s.reps) FROM sets s
                   WHERE s.workout_exercise_id = we.id AND s.deleted_at IS NULL
                     AND s.is_completed = 1 AND s.set_type != 'warmup')
                   AS reps_min,
                 (SELECT MAX(s.reps) FROM sets s
                   WHERE s.workout_exercise_id = we.id AND s.deleted_at IS NULL
                     AND s.is_completed = 1 AND s.set_type != 'warmup')
                   AS reps_max,
                 (SELECT MAX(s.weight_grams) FROM sets s
                   WHERE s.workout_exercise_id = we.id AND s.deleted_at IS NULL
                     AND s.is_completed = 1 AND s.set_type != 'warmup')
                   AS weight_grams
            FROM workout_exercises we
           WHERE we.workout_id = ? AND we.deleted_at IS NULL
           ORDER BY we.position
          ''',
          variables: [Variable<String>(workoutId)],
          readsFrom: {_db.workoutExercises, _db.sets},
        )
        .get();

    final routineId = newUuidV4();
    final dayId = newUuidV4();
    final timestamp = _now;
    final position = await _nextPositionIn('routines');

    await _db.transaction(() async {
      await _db
          .into(_db.routines)
          .insert(
            RoutinesCompanion.insert(
              id: routineId,
              name: routineName,
              position: position,
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
      await _db
          .into(_db.routineDays)
          .insert(
            RoutineDaysCompanion.insert(
              id: dayId,
              routineId: routineId,
              name: routineName,
              position: 0,
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
      for (final row in exerciseRows) {
        final setCount = row.read<int>('set_count');
        await _db
            .into(_db.routineExercises)
            .insert(
              RoutineExercisesCompanion.insert(
                id: newUuidV4(),
                routineDayId: dayId,
                exerciseId: row.read<String>('exercise_id'),
                position: row.read<int>('position'),
                targetSets: Value(setCount == 0 ? null : setCount),
                targetRepsMin: Value(row.read<int?>('reps_min')),
                targetRepsMax: Value(row.read<int?>('reps_max')),
                targetWeightGrams: Value(row.read<int?>('weight_grams')),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );
      }
    });

    return (await findById(routineId))!;
  }

  // -------------------------------------------------------------------- Days

  Stream<List<RoutineDay>> watchDays(String routineId) =>
      (_db.select(_db.routineDays)
            ..where(
              (d) => d.routineId.equals(routineId) & d.deletedAt.isNull(),
            )
            ..orderBy([(d) => OrderingTerm(expression: d.position)]))
          .watch();

  Future<RoutineDay?> findDayById(String id) => (_db.select(
    _db.routineDays,
  )..where((d) => d.id.equals(id) & d.deletedAt.isNull())).getSingleOrNull();

  Future<RoutineDay> addDay(String routineId, {required String name}) async {
    final id = newUuidV4();
    final timestamp = _now;
    final position = await _nextPositionIn(
      'routine_days',
      whereColumn: 'routine_id',
      whereValue: routineId,
    );
    await _db
        .into(_db.routineDays)
        .insert(
          RoutineDaysCompanion.insert(
            id: id,
            routineId: routineId,
            name: name.trim(),
            position: position,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    return (await findDayById(id))!;
  }

  Future<void> renameDay(String id, String name) async {
    await (_db.update(_db.routineDays)..where((d) => d.id.equals(id))).write(
      RoutineDaysCompanion(name: Value(name.trim()), updatedAt: Value(_now)),
    );
  }

  /// Persists the day order after a drag-to-reorder (`F-ROU-004`).
  Future<void> reorderDays(List<String> orderedDayIds) async {
    final timestamp = _now;
    await _db.transaction(() async {
      for (var i = 0; i < orderedDayIds.length; i++) {
        await (_db.update(
          _db.routineDays,
        )..where((d) => d.id.equals(orderedDayIds[i]))).write(
          RoutineDaysCompanion(position: Value(i), updatedAt: Value(timestamp)),
        );
      }
    });
  }

  Future<void> deleteDay(String id) async {
    final timestamp = _now;
    await _db.transaction(() => _deleteDay(id, timestamp));
  }

  Future<void> _deleteDay(String id, int timestamp) async {
    await _db.customUpdate(
      'UPDATE routine_exercises SET deleted_at = ?, updated_at = ? '
      'WHERE deleted_at IS NULL AND routine_day_id = ?',
      variables: [
        Variable<int>(timestamp),
        Variable<int>(timestamp),
        Variable<String>(id),
      ],
      updates: {_db.routineExercises},
    );
    await _db.customUpdate(
      'UPDATE routine_days SET deleted_at = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable<int>(timestamp),
        Variable<int>(timestamp),
        Variable<String>(id),
      ],
      updates: {_db.routineDays},
    );
  }

  // --------------------------------------------------- Exercises & targets

  Stream<List<RoutineExerciseDetail>> watchExercises(String dayId) {
    return _db
        .customSelect(
          '''
          SELECT re.id                AS re_id,
                 re.exercise_id       AS exercise_id,
                 e.name               AS exercise_name,
                 re.position          AS position,
                 re.group_id          AS group_id,
                 re.target_sets       AS target_sets,
                 re.target_reps_min   AS target_reps_min,
                 re.target_reps_max   AS target_reps_max,
                 re.target_weight_grams AS target_weight_grams,
                 re.target_rpe        AS target_rpe,
                 re.rest_seconds      AS rest_seconds,
                 re.notes             AS notes
            FROM routine_exercises re
            JOIN exercises e ON e.id = re.exercise_id
           WHERE re.routine_day_id = ? AND re.deleted_at IS NULL
           ORDER BY re.position
          ''',
          variables: [Variable<String>(dayId)],
          readsFrom: {_db.routineExercises, _db.exercises},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              RoutineExerciseDetail(
                routineExerciseId: row.read<String>('re_id'),
                exerciseId: row.read<String>('exercise_id'),
                exerciseName: row.read<String>('exercise_name'),
                position: row.read<int>('position'),
                groupId: row.read<String?>('group_id'),
                targetSets: row.read<int?>('target_sets'),
                targetRepsMin: row.read<int?>('target_reps_min'),
                targetRepsMax: row.read<int?>('target_reps_max'),
                targetWeightGrams: row.read<int?>('target_weight_grams'),
                targetRpe: row.read<double?>('target_rpe'),
                restSeconds: row.read<int?>('rest_seconds'),
                notes: row.read<String?>('notes'),
              ),
          ],
        );
  }

  /// Appends [exerciseIds] to the day with no targets set — targets are
  /// optional throughout (`F-ROU-003` §3).
  Future<void> addExercises(String dayId, List<String> exerciseIds) async {
    if (exerciseIds.isEmpty) return;
    final timestamp = _now;
    await _db.transaction(() async {
      var position = await _nextPositionIn(
        'routine_exercises',
        whereColumn: 'routine_day_id',
        whereValue: dayId,
      );
      for (final exerciseId in exerciseIds) {
        await _db
            .into(_db.routineExercises)
            .insert(
              RoutineExercisesCompanion.insert(
                id: newUuidV4(),
                routineDayId: dayId,
                exerciseId: exerciseId,
                position: position,
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );
        position++;
      }
    });
  }

  Future<void> removeExercise(String routineExerciseId) async {
    await (_db.update(
      _db.routineExercises,
    )..where((re) => re.id.equals(routineExerciseId))).write(
      RoutineExercisesCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  }

  Future<void> reorderExercises(List<String> orderedRoutineExerciseIds) async {
    final timestamp = _now;
    await _db.transaction(() async {
      for (var i = 0; i < orderedRoutineExerciseIds.length; i++) {
        await (_db.update(_db.routineExercises)
              ..where((re) => re.id.equals(orderedRoutineExerciseIds[i])))
            .write(
              RoutineExercisesCompanion(
                position: Value(i),
                updatedAt: Value(timestamp),
              ),
            );
      }
    });
  }

  /// Sets one exercise's targets (`F-ROU-003` §1). Every field is
  /// independently nullable — clearing a field means "no target for this",
  /// not zero.
  Future<void> setTargets(
    String routineExerciseId, {
    Value<int?> targetSets = const Value.absent(),
    Value<int?> targetRepsMin = const Value.absent(),
    Value<int?> targetRepsMax = const Value.absent(),
    Value<int?> targetWeightGrams = const Value.absent(),
    Value<double?> targetRpe = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
  }) async {
    await (_db.update(
      _db.routineExercises,
    )..where((re) => re.id.equals(routineExerciseId))).write(
      RoutineExercisesCompanion(
        targetSets: targetSets,
        targetRepsMin: targetRepsMin,
        targetRepsMax: targetRepsMax,
        targetWeightGrams: targetWeightGrams,
        targetRpe: targetRpe,
        restSeconds: restSeconds,
        updatedAt: Value(_now),
      ),
    );
  }

  Future<void> setExerciseNotes(String routineExerciseId, String? notes) {
    final trimmed = notes?.trim();
    return (_db.update(_db.routineExercises)
          ..where((re) => re.id.equals(routineExerciseId)))
        .write(
          RoutineExercisesCompanion(
            notes: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
            updatedAt: Value(_now),
          ),
        );
  }

  /// One past the highest existing `position` in [table], so appends never
  /// collide with what is already there. Never inferred from row count — a
  /// soft-deleted gap must not be reused (`docs/21-DATA-MODEL.md`
  /// §routines).
  Future<int> _nextPositionIn(
    String table, {
    String? whereColumn,
    String? whereValue,
  }) async {
    final clause = whereColumn == null
        ? 'deleted_at IS NULL'
        : 'deleted_at IS NULL AND $whereColumn = ?';
    final rows = await _db
        .customSelect(
          'SELECT MAX(position) AS max_position FROM $table WHERE $clause',
          variables: [if (whereValue != null) Variable<String>(whereValue)],
          readsFrom: {
            switch (table) {
              'routines' => _db.routines,
              'routine_days' => _db.routineDays,
              'routine_exercises' => _db.routineExercises,
              _ => throw ArgumentError('Unknown table $table'),
            },
          },
        )
        .getSingle();
    final max = rows.read<int?>('max_position');
    return (max ?? -1) + 1;
  }
}
