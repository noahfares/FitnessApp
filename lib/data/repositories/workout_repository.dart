import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/ids/uuid.dart';
import '../../domain/history/workout_history.dart';
import '../../domain/history/workout_volume.dart';
import '../../domain/plates/plate_calculator.dart';
import '../../domain/progression/plate_aware_rounding.dart';
import '../../domain/progression/progression_engine.dart';
import '../../domain/progression/progression_rationale.dart';
import '../../domain/progression/progression_rule.dart';
import '../db/app_database.dart';
import '../db/tables/enums.dart';
import 'plate_repository.dart';
import 'set_repository.dart';

/// Thrown when starting a workout while one is already in progress.
///
/// The database refuses it too (`idx_workouts_single_in_progress`); this exists
/// so the UI can say something useful instead of surfacing a constraint error.
class ActiveWorkoutExistsException implements Exception {
  const ActiveWorkoutExistsException(this.existing);

  final Workout existing;

  @override
  String toString() =>
      'A workout is already in progress (started ${existing.startedAt}).';
}

/// One exercise inside a session, joined to its catalogue row and set counts.
///
/// A read model, not a table: the active-workout screen needs all three in one
/// place, and three separate streams would tear against each other mid-write.
class SessionExercise {
  const SessionExercise({
    required this.workoutExerciseId,
    required this.exerciseId,
    required this.name,
    required this.primaryMuscle,
    required this.equipment,
    required this.trackingType,
    required this.weightEntryMode,
    required this.incrementGrams,
    required this.defaultRestSeconds,
    required this.position,
    required this.setCount,
    required this.completedSetCount,
    this.notes,
    this.exerciseNotes,
    this.target,
    this.groupId,
  });

  final String workoutExerciseId;
  final String exerciseId;
  final String name;
  final Muscle primaryMuscle;
  final Equipment equipment;

  /// Snapshotted superset grouping — same value as sibling exercises means
  /// same group, null means standalone (`F-LOG-015` §1, `ADR-0004`).
  final String? groupId;

  /// Session-specific, distinct from the exercise's persistent sticky note
  /// (`F-LOG-008`).
  final String? notes;

  /// The exercise's own persistent sticky note — seat height, pin position,
  /// grip width (`F-CAT-007`). Distinct from [notes], which is this session
  /// only.
  final String? exerciseNotes;

  /// Decides which inputs the set rows render (`F-CAT-002`, `F-LOG-003` §1).
  final TrackingType trackingType;

  /// Total or per-side weight entry (`F-LOG-017` §2). `sets.weight_grams` is
  /// always total regardless — this decides only how it is typed and shown.
  final WeightEntryMode weightEntryMode;

  /// Per-exercise stepper increment in canonical grams, or null to fall back to
  /// the equipment default (`F-SET-007`, `F-LOG-006` §2).
  final int? incrementGrams;

  /// This exercise's own rest duration, or null to fall through to the global
  /// setting and then to the built-in default for its kind (`F-TIM-005`).
  final int? defaultRestSeconds;

  final int position;
  final int setCount;
  final int completedSetCount;

  /// What the routine day proposed at start, for display alongside the ghost
  /// values (`F-ROU-010` §5). Null for an exercise added mid-session.
  final SessionExerciseTarget? target;
}

/// Decoded `workout_exercises.target_snapshot` (`F-ROU-010` §4).
class SessionExerciseTarget {
  const SessionExerciseTarget({
    this.sets,
    this.repsMin,
    this.repsMax,
    this.weightGrams,
    this.rpe,
    this.restSeconds,
    this.rationale,
  });

  factory SessionExerciseTarget.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return SessionExerciseTarget(
      sets: map['targetSets'] as int?,
      repsMin: map['targetRepsMin'] as int?,
      repsMax: map['targetRepsMax'] as int?,
      weightGrams: map['targetWeightGrams'] as int?,
      rpe: (map['targetRpe'] as num?)?.toDouble(),
      restSeconds: map['restSeconds'] as int?,
      rationale: ProgressionRationale.fromJson(map['rationale']),
    );
  }

  final int? sets;
  final int? repsMin;
  final int? repsMax;
  final int? weightGrams;
  final double? rpe;

  /// The routine exercise's own rest override — the first tier in
  /// `resolveRestSeconds`'s resolution order (`F-ROU-006`).
  final int? restSeconds;

  /// Why the engine proposed [weightGrams]/[repsMin], if it was proposed by
  /// a progression rule rather than left blank (`F-PRG-008`). Null for an
  /// exercise added mid-session, which never went through the engine.
  final ProgressionRationale? rationale;

  bool get isEmpty =>
      sets == null &&
      repsMin == null &&
      repsMax == null &&
      weightGrams == null &&
      rpe == null &&
      restSeconds == null;
}

/// Exercise and completed-set counts for one workout.
class WorkoutTally {
  const WorkoutTally({required this.exercises, required this.completedSets});

  final int exercises;
  final int completedSets;

  /// Nothing was logged, so finishing would leave a junk history entry
  /// (`F-LOG-001` §6).
  bool get isEmpty => completedSets == 0;
}

/// What the finish summary shows (`F-LOG-018`).
class WorkoutSummaryStats {
  const WorkoutSummaryStats({
    required this.duration,
    required this.totalVolumeGrams,
    required this.completedSetCount,
    required this.exerciseCount,
    required this.muscles,
    this.previous,
  });

  final Duration duration;
  final int totalVolumeGrams;
  final int completedSetCount;
  final int exerciseCount;

  /// Primary muscles of exercises with at least one counted set.
  final Set<Muscle> muscles;

  /// The last time a workout of this same name was done, or null on a first
  /// time (`F-LOG-018` §1). Matched by name only — routines, which would give
  /// a sturdier match, do not exist until `F-ROU-001`.
  final PreviousSessionStats? previous;
}

class PreviousSessionStats {
  const PreviousSessionStats({
    required this.startedAt,
    required this.totalVolumeGrams,
    required this.duration,
  });

  final int startedAt;
  final int totalVolumeGrams;
  final Duration duration;
}

/// Sessions, and everything hanging off them (`F-LOG-001`, `F-LOG-002`,
/// `F-LOG-007`).
///
/// **Write-through, always.** Nothing about a session is held in memory and
/// flushed later — the database *is* the session (docs/21-DATA-MODEL.md
/// §persistence-behaviour). That is what makes crash recovery a query rather
/// than a serialised-state restore, and it is why every method here writes
/// immediately rather than batching.
class WorkoutRepository {
  WorkoutRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  DateTime get _localNow => _clock();
  int get _now => _localNow.millisecondsSinceEpoch;

  /// The in-progress session, or null. At most one can exist.
  Stream<Workout?> watchActive() => _activeQuery().watchSingleOrNull();

  Future<Workout?> findActive() => _activeQuery().getSingleOrNull();

  SimpleSelectStatement<$WorkoutsTable, Workout> _activeQuery() =>
      _db.select(_db.workouts)
        ..where((w) => w.endedAt.isNull())
        ..where((w) => w.deletedAt.isNull());

  Future<Workout?> findById(String id) =>
      (_db.select(_db.workouts)
            ..where((w) => w.id.equals(id))
            ..where((w) => w.deletedAt.isNull()))
          .getSingleOrNull();

  /// Starts an empty session.
  ///
  /// Throws [ActiveWorkoutExistsException] rather than silently finishing the
  /// old one: which session someone meant to keep is not a decision this layer
  /// can make (`F-LOG-001` §3).
  Future<Workout> start({String? name}) async {
    final existing = await findActive();
    if (existing != null) throw ActiveWorkoutExistsException(existing);

    final now = _localNow;
    final id = newUuidV4();
    await _db
        .into(_db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            id: id,
            name: name?.trim().isNotEmpty ?? false
                ? name!.trim()
                : defaultNameFor(now),
            startedAt: now.millisecondsSinceEpoch,
            // Without the offset it is impossible to reconstruct afterwards
            // which local day a session belongs to (ADR-0008).
            startedAtTzOffsetMinutes: now.timeZoneOffset.inMinutes,
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
    await _backfillBodyweight(id);
    return (await findById(id))!;
  }

  /// Bodyweight-loaded exercises need an effective-load basis (`F-LOG-019`),
  /// supplied by the most recent bodyweight entry at or before the session's
  /// start (`F-BOD-001` §3). A single-row correlated subquery rather than a
  /// dependency on `BodyMeasurementRepository` — this table is the only other
  /// one starting a session needs to know about.
  Future<void> _backfillBodyweight(String workoutId) => _db.customUpdate(
    '''
    UPDATE workouts
       SET bodyweight_grams = (
             SELECT m.value_canonical FROM body_measurements m
              WHERE m.type = 'bodyweight' AND m.deleted_at IS NULL
                AND m.measured_at <= workouts.started_at
              ORDER BY m.measured_at DESC LIMIT 1
           )
     WHERE id = ?
    ''',
    variables: [Variable<String>(workoutId)],
    updates: {_db.workouts},
  );

  /// Starts a session pre-populated from a past one: exercises, order and
  /// superset groups carried across, targets derived from what was actually
  /// logged (not warm-ups), sets left empty (`F-LOG-016`). Covers training
  /// without formal routines — the fastest path to a second session of the
  /// same thing.
  ///
  /// A one-shot copy, same as [startFromRoutineDay] and
  /// `RoutineRepository.createFromWorkout`: nothing here stays linked back to
  /// the source workout (`ADR-0004`).
  Future<Workout> startFromWorkout(String workoutId) async {
    final existing = await findActive();
    if (existing != null) throw ActiveWorkoutExistsException(existing);

    final sourceRows = await _db
        .customSelect(
          'SELECT name FROM workouts WHERE id = ? AND deleted_at IS NULL',
          variables: [Variable<String>(workoutId)],
          readsFrom: {_db.workouts},
        )
        .get();
    if (sourceRows.isEmpty) {
      throw ArgumentError('No workout with id $workoutId');
    }
    final sourceName = sourceRows.first.read<String>('name');

    final exerciseRows = await _db
        .customSelect(
          '''
          SELECT we.id AS we_id, we.exercise_id AS exercise_id,
                 we.position AS position,
                 we.group_id AS group_id,
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

    final now = _localNow;
    final timestamp = now.millisecondsSinceEpoch;
    final newWorkoutId = newUuidV4();

    await _db.transaction(() async {
      await _db
          .into(_db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: newWorkoutId,
              name: sourceName,
              startedAt: timestamp,
              startedAtTzOffsetMinutes: now.timeZoneOffset.inMinutes,
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );

      // Superset grouping carries over, same reasoning as
      // `RoutineRepository.createFromWorkout` (`F-ROU-005` §1).
      final groupIdMap = <String, String>{};
      for (final row in exerciseRows) {
        final setCount = row.read<int>('set_count');
        final newGroupId = switch (row.read<String?>('group_id')) {
          null => null,
          final oldGroupId => groupIdMap.putIfAbsent(oldGroupId, newUuidV4),
        };
        final targetSnapshot = jsonEncode({
          'targetSets': setCount == 0 ? null : setCount,
          'targetRepsMin': row.read<int?>('reps_min'),
          'targetRepsMax': row.read<int?>('reps_max'),
          'targetWeightGrams': row.read<int?>('weight_grams'),
          'targetRpe': null,
          'restSeconds': null,
        });

        final workoutExerciseId = newUuidV4();
        await _db
            .into(_db.workoutExercises)
            .insert(
              WorkoutExercisesCompanion.insert(
                id: workoutExerciseId,
                workoutId: newWorkoutId,
                exerciseId: row.read<String>('exercise_id'),
                position: row.read<int>('position'),
                groupId: Value(newGroupId),
                targetSnapshot: Value(targetSnapshot),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );

        for (var i = 0; i < (setCount == 0 ? 1 : setCount); i++) {
          await _db
              .into(_db.sets)
              .insert(
                SetsCompanion.insert(
                  id: newUuidV4(),
                  workoutExerciseId: workoutExerciseId,
                  position: i,
                  createdAt: timestamp,
                  updatedAt: timestamp,
                ),
              );
        }
      }
    });

    await _backfillBodyweight(newWorkoutId);
    return (await findById(newWorkoutId))!;
  }

  /// Starts a session from a routine day, copying its exercises, order,
  /// superset groups and targets into fresh `workout_exercises` and `sets`
  /// rows (`F-ROU-010`).
  ///
  /// The copy is complete and one-shot: nothing here is ever read back from
  /// the routine (`ADR-0004`). Editing or deleting the routine afterwards —
  /// even mid-session — cannot alter or break the workout this created,
  /// because nothing about it depends on the routine still existing.
  Future<Workout> startFromRoutineDay(String routineDayId) async {
    final existing = await findActive();
    if (existing != null) throw ActiveWorkoutExistsException(existing);

    final dayRows = await _db
        .customSelect(
          'SELECT name FROM routine_days '
          'WHERE id = ? AND deleted_at IS NULL',
          variables: [Variable<String>(routineDayId)],
          readsFrom: {_db.routineDays},
        )
        .get();
    if (dayRows.isEmpty) {
      throw ArgumentError('No routine day with id $routineDayId');
    }
    final dayName = dayRows.first.read<String>('name');

    final exerciseRows = await _db
        .customSelect(
          '''
          SELECT re.id, re.exercise_id, re.position, re.group_id,
                 re.target_sets, re.target_reps_min, re.target_reps_max,
                 re.target_weight_grams, re.target_rpe, re.rest_seconds,
                 re.progression_rule, e.default_bar_id
            FROM routine_exercises re
            JOIN exercises e ON e.id = re.exercise_id
           WHERE re.routine_day_id = ? AND re.deleted_at IS NULL
           ORDER BY re.position
          ''',
          variables: [Variable<String>(routineDayId)],
          readsFrom: {_db.routineExercises, _db.exercises},
        )
        .get();

    // Read-only, and independent of the write transaction below — resolving
    // each exercise's proposed target needs its own full history, and
    // `computeTargets` (`F-PRG-001`) is pure Dart with no database access of
    // its own.
    final setRepository = SetRepository(_db);
    final plateRepository = PlateRepository(_db);
    // Shared across every exercise in the day — the plate inventory doesn't
    // vary per exercise, only which bar it's loaded on does.
    final usablePlates = await plateRepository.getUsablePlates();
    final inventory = [
      for (final p in usablePlates)
        PlateSpec(weightGrams: p.weightGrams, pairsAvailable: p.countAvailable),
    ];
    final proposals = <TargetSet>[];
    for (final row in exerciseRows) {
      final rule = ProgressionRule.fromJson(
        row.read<String?>('progression_rule'),
      );
      final history = await setRepository.getExerciseHistory(
        row.read<String>('exercise_id'),
      );
      var target = computeTargets(
        rule: rule,
        exerciseHistory: history,
        context: ProgressionContext(
          staticWeightGrams: row.read<int?>('target_weight_grams'),
          staticReps: row.read<int?>('target_reps_min'),
          staticRepsMax: row.read<int?>('target_reps_max'),
          staticSets: row.read<int?>('target_sets'),
          staticTargetRpe: row.read<double?>('target_rpe'),
        ),
      );

      // Plate-aware rounding (`F-PRG-012`) — applied after `computeTargets`,
      // never before (§13). Skipped entirely with no bar or empty inventory
      // configured, so a fresh install with no plates set up yet behaves
      // exactly as it did before this batch.
      if (target.weightGrams != null && inventory.isNotEmpty) {
        final bar = await plateRepository.resolveBar(
          row.read<String?>('default_bar_id'),
        );
        if (bar != null) {
          target = applyPlateRounding(
            target: target,
            barWeightGrams: bar.weightGrams,
            inventory: inventory,
            previousWeightGrams: target.rationale.previousWeightGrams,
          );
        }
      }
      proposals.add(target);
    }

    final now = _localNow;
    final timestamp = now.millisecondsSinceEpoch;
    final workoutId = newUuidV4();

    await _db.transaction(() async {
      await _db
          .into(_db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: workoutId,
              name: dayName,
              sourceRoutineDayId: Value(routineDayId),
              startedAt: timestamp,
              startedAtTzOffsetMinutes: now.timeZoneOffset.inMinutes,
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );

      for (var i = 0; i < exerciseRows.length; i++) {
        final row = exerciseRows[i];
        final proposal = proposals[i];
        final targetSets = proposal.sets;
        // The routine's own configured rep *range* is always kept as-is —
        // `TargetSet.reps` is a single number (the fixed rep target a linear
        // rule judges against, `docs/40-ANALYTICS-SPEC.md` §12), and
        // collapsing a deliberately configured `8–12` down to it on every
        // start after the first would silently destroy the range every
        // existing routine already has, which nothing in `F-PRG-002` or
        // `F-PRG-006` asks for — progression owns the weight, not the range.
        // Plate-aware rounding's "hold weight, add a rep" branch
        // (`F-PRG-012` §3) is the one case where the proposal's own rep
        // count must override the routine's static range — every other
        // outcome keeps the range exactly as configured, same reasoning as
        // the comment above.
        final repsMinOverride =
            proposal.rationale.outcome == ProgressionOutcome.plateRoundingHeld
            ? proposal.reps
            : row.read<int?>('target_reps_min');

        final targetSnapshot = jsonEncode({
          'targetSets': targetSets,
          'targetRepsMin': repsMinOverride,
          'targetRepsMax': row.read<int?>('target_reps_max'),
          'targetWeightGrams': proposal.weightGrams,
          'targetRpe': row.read<double?>('target_rpe'),
          'restSeconds': row.read<int?>('rest_seconds'),
          'rationale': proposal.rationale.toJson(),
        });

        final workoutExerciseId = newUuidV4();
        await _db
            .into(_db.workoutExercises)
            .insert(
              WorkoutExercisesCompanion.insert(
                id: workoutExerciseId,
                workoutId: workoutId,
                exerciseId: row.read<String>('exercise_id'),
                position: row.read<int>('position'),
                groupId: Value(row.read<String?>('group_id')),
                targetSnapshot: Value(targetSnapshot),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );

        // A target with no set count still gets one empty row, same as an
        // exercise added mid-session (`F-ROU-010` §3) — an exercise with no
        // targets behaves like an empty workout with the right exercises.
        for (var i = 0; i < (targetSets ?? 1); i++) {
          await _db
              .into(_db.sets)
              .insert(
                SetsCompanion.insert(
                  id: newUuidV4(),
                  workoutExerciseId: workoutExerciseId,
                  position: i,
                  createdAt: timestamp,
                  updatedAt: timestamp,
                ),
              );
        }
      }
    });

    await _backfillBodyweight(workoutId);

    return (await findById(workoutId))!;
  }

  /// A session needs a name before it has any content to name it after. Time of
  /// day is the one thing already known, and it is what people call sessions
  /// anyway. Overwritten wholesale once routine days supply one (`F-ROU-010`).
  static String defaultNameFor(DateTime local) {
    if (local.hour < 12) return 'Morning Workout';
    if (local.hour < 17) return 'Afternoon Workout';
    return 'Evening Workout';
  }

  /// Closes the session. PR evaluation (`F-LOG-013`) hangs off this in Phase 2.
  Future<void> finish(String id) async {
    await (_db.update(_db.workouts)..where((w) => w.id.equals(id))).write(
      WorkoutsCompanion(endedAt: Value(_now), updatedAt: Value(_now)),
    );
  }

  Future<void> rename(String id, String name) async {
    await (_db.update(_db.workouts)..where((w) => w.id.equals(id))).write(
      WorkoutsCompanion(name: Value(name.trim()), updatedAt: Value(_now)),
    );
  }

  /// Discards the session and everything in it.
  ///
  /// **Tombstoned, not hard-deleted.** `F-LOG-001` §5 was written before
  /// ADR-0008, which explicitly overrides it: destroying data the moment
  /// someone taps something sweaty-handed mid-set is the failure the soft-delete
  /// rule exists to prevent, and undo (`F-LOG-022`) then costs a field update
  /// instead of a resurrection.
  ///
  /// One transaction, so a discard interrupted halfway cannot leave orphaned
  /// sets attached to a vanished workout.
  Future<void> discard(String id) async {
    final timestamp = _now;
    await _db.transaction(() async {
      // `customUpdate`, not `customStatement`: only the former tells drift
      // which tables changed, which is what makes a live watcher of the
      // exercises or sets this touches refresh instead of going stale.
      await _db.customUpdate(
        'UPDATE sets SET deleted_at = ?, updated_at = ? '
        'WHERE deleted_at IS NULL AND workout_exercise_id IN '
        '(SELECT id FROM workout_exercises WHERE workout_id = ?)',
        variables: [
          Variable<int>(timestamp),
          Variable<int>(timestamp),
          Variable<String>(id),
        ],
        updates: {_db.sets},
      );
      await _db.customUpdate(
        'UPDATE workout_exercises SET deleted_at = ?, updated_at = ? '
        'WHERE deleted_at IS NULL AND workout_id = ?',
        variables: [
          Variable<int>(timestamp),
          Variable<int>(timestamp),
          Variable<String>(id),
        ],
        updates: {_db.workoutExercises},
      );
      await _db.customUpdate(
        'UPDATE workouts SET deleted_at = ?, updated_at = ? WHERE id = ?',
        variables: [
          Variable<int>(timestamp),
          Variable<int>(timestamp),
          Variable<String>(id),
        ],
        updates: {_db.workouts},
      );
    });
  }

  /// Appends [exerciseIds] to the session in the order given, each with one
  /// empty set row ready (`F-LOG-002` §3).
  ///
  /// The same exercise may be added twice — doing a movement again at the end
  /// of a session is legitimate, so this is deliberately not de-duplicated.
  Future<void> addExercises(String workoutId, List<String> exerciseIds) async {
    if (exerciseIds.isEmpty) return;
    final timestamp = _now;

    await _db.transaction(() async {
      final existing =
          await (_db.select(_db.workoutExercises)
                ..where((we) => we.workoutId.equals(workoutId))
                ..where((we) => we.deletedAt.isNull()))
              .get();
      var position = existing.fold<int>(
        -1,
        (max, row) => row.position > max ? row.position : max,
      );

      for (final exerciseId in exerciseIds) {
        final workoutExerciseId = newUuidV4();
        position++;
        await _db
            .into(_db.workoutExercises)
            .insert(
              WorkoutExercisesCompanion.insert(
                id: workoutExerciseId,
                workoutId: workoutId,
                exerciseId: exerciseId,
                position: position,
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );
        // One empty set, so the exercise is ready to log against rather than
        // needing an "add set" tap first.
        await _db
            .into(_db.sets)
            .insert(
              SetsCompanion.insert(
                id: newUuidV4(),
                workoutExerciseId: workoutExerciseId,
                position: 0,
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );
      }
    });
  }

  /// Persists the exercise order after a drag-to-reorder (`F-LOG-010` §1).
  ///
  /// [orderedWorkoutExerciseIds] must be the session's **complete** exercise
  /// list in its new order — the superset-contiguity check below reads group
  /// membership from positions *within this list*, so a partial list would
  /// misjudge adjacency and could dissolve groups that are actually still
  /// intact.
  Future<void> reorderExercises(List<String> orderedWorkoutExerciseIds) async {
    final timestamp = _now;
    await _db.transaction(() async {
      for (var i = 0; i < orderedWorkoutExerciseIds.length; i++) {
        await (_db.update(
          _db.workoutExercises,
        )..where((we) => we.id.equals(orderedWorkoutExerciseIds[i]))).write(
          WorkoutExercisesCompanion(
            position: Value(i),
            updatedAt: Value(timestamp),
          ),
        );
      }

      // A drag can pull a member out of its superset's block. A group only
      // means anything while its members stay adjacent (`F-ROU-005` §1) — if
      // reordering breaks that, dissolve it rather than render two
      // "Superset" blocks sharing one `group_id`.
      final rows =
          await (_db.select(_db.workoutExercises)..where(
                (we) =>
                    we.id.isIn(orderedWorkoutExerciseIds) &
                    we.deletedAt.isNull(),
              ))
              .get();
      final groupIdById = {for (final r in rows) r.id: r.groupId};
      final positionsByGroup = <String, List<int>>{};
      for (var i = 0; i < orderedWorkoutExerciseIds.length; i++) {
        final groupId = groupIdById[orderedWorkoutExerciseIds[i]];
        if (groupId != null) {
          (positionsByGroup[groupId] ??= []).add(i);
        }
      }
      for (final MapEntry(key: groupId, value: positions)
          in positionsByGroup.entries) {
        final isContiguous =
            positions.last - positions.first == positions.length - 1;
        if (!isContiguous) {
          await ungroupExercises(groupId);
        }
      }
    });
  }

  /// Swaps a session exercise for a different one, e.g. the squat rack is
  /// taken (`F-LOG-010` §2).
  ///
  /// **Never mutates `exercise_id` in place** — every set ever attached to
  /// [workoutExerciseId], completed or not, is joined back to whatever
  /// `exercise_id` its `workout_exercises` row carries, so rewriting it would
  /// silently reattribute logged history to a different exercise (`ADR-0004`).
  /// Instead: if nothing has been completed yet, the row is retired outright;
  /// if it has, it is left standing so its completed sets keep the exercise
  /// that was actually done. Either way a fresh row for [newExerciseId] is
  /// inserted immediately after, in the same superset group if there was one,
  /// with one empty set ready to log against.
  Future<void> swapExercise(
    String workoutExerciseId,
    String newExerciseId,
  ) async {
    final original = await (_db.select(
      _db.workoutExercises,
    )..where((we) => we.id.equals(workoutExerciseId))).getSingle();
    final completedCount = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM sets '
          'WHERE workout_exercise_id = ? AND deleted_at IS NULL '
          'AND is_completed = 1',
          variables: [Variable<String>(workoutExerciseId)],
          readsFrom: {_db.sets},
        )
        .getSingle()
        .then((row) => row.read<int>('n'));

    final timestamp = _now;
    final newWorkoutExerciseId = newUuidV4();

    await _db.transaction(() async {
      if (completedCount == 0) {
        await _db.customUpdate(
          'UPDATE sets SET deleted_at = ?, updated_at = ? '
          'WHERE deleted_at IS NULL AND workout_exercise_id = ?',
          variables: [
            Variable<int>(timestamp),
            Variable<int>(timestamp),
            Variable<String>(workoutExerciseId),
          ],
          updates: {_db.sets},
        );
        await (_db.update(
          _db.workoutExercises,
        )..where((we) => we.id.equals(workoutExerciseId))).write(
          WorkoutExercisesCompanion(
            deletedAt: Value(timestamp),
            updatedAt: Value(timestamp),
          ),
        );
      }

      // Everything from the swapped-out position onward shifts by one to
      // make room, same as inserting into a list.
      await _db.customUpdate(
        'UPDATE workout_exercises SET position = position + 1, '
        'updated_at = ? '
        'WHERE workout_id = ? AND deleted_at IS NULL AND position > ?',
        variables: [
          Variable<int>(timestamp),
          Variable<String>(original.workoutId),
          Variable<int>(original.position),
        ],
        updates: {_db.workoutExercises},
      );

      await _db
          .into(_db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: newWorkoutExerciseId,
              workoutId: original.workoutId,
              exerciseId: newExerciseId,
              position: original.position + 1,
              groupId: Value(original.groupId),
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
      await _db
          .into(_db.sets)
          .insert(
            SetsCompanion.insert(
              id: newUuidV4(),
              workoutExerciseId: newWorkoutExerciseId,
              position: 0,
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
    });
  }

  /// Groups adjacent session exercises into a superset (`F-LOG-015` §4).
  /// Mid-session grouping is independent of the routine the session may have
  /// snapshotted from — the workout owns its own list (`ADR-0004`).
  Future<void> groupExercises(List<String> workoutExerciseIds) async {
    if (workoutExerciseIds.length < 2) return;
    final groupId = newUuidV4();
    final timestamp = _now;
    await _db.transaction(() async {
      for (final id in workoutExerciseIds) {
        await (_db.update(
          _db.workoutExercises,
        )..where((we) => we.id.equals(id))).write(
          WorkoutExercisesCompanion(
            groupId: Value(groupId),
            updatedAt: Value(timestamp),
          ),
        );
      }
    });
  }

  /// Breaking a group mid-session never touches sets — grouping is purely
  /// about ordering and rest behaviour, not the logged data (`F-LOG-015`
  /// §4).
  Future<void> ungroupExercises(String groupId) async {
    await (_db.update(
      _db.workoutExercises,
    )..where((we) => we.groupId.equals(groupId))).write(
      WorkoutExercisesCompanion(
        groupId: const Value(null),
        updatedAt: Value(_now),
      ),
    );
  }

  /// Toggles the pairing between two adjacent session exercises
  /// (`F-LOG-015` §4) — the logger's per-tile "Group with next" control.
  /// Already-sharing-a-group breaks the whole group; otherwise the two
  /// exercises' existing groups (if any) are merged into one.
  Future<void> toggleGroupWithNext(
    String workoutExerciseId,
    String nextWorkoutExerciseId,
  ) async {
    final rows =
        await (_db.select(_db.workoutExercises)..where(
              (we) =>
                  we.id.equals(workoutExerciseId) |
                  we.id.equals(nextWorkoutExerciseId),
            ))
            .get();
    final a = rows.firstWhere((r) => r.id == workoutExerciseId);
    final b = rows.firstWhere((r) => r.id == nextWorkoutExerciseId);

    if (a.groupId != null && a.groupId == b.groupId) {
      await ungroupExercises(a.groupId!);
      return;
    }

    final memberIds = <String>{};
    for (final (row, groupId) in [(a, a.groupId), (b, b.groupId)]) {
      if (groupId == null) {
        memberIds.add(row.id);
      } else {
        final members =
            await (_db.select(_db.workoutExercises)..where(
                  (we) => we.groupId.equals(groupId) & we.deletedAt.isNull(),
                ))
                .get();
        memberIds.addAll(members.map((m) => m.id));
      }
    }
    await groupExercises(memberIds.toList());
  }

  /// The session's exercises, with set counts, ordered for display.
  ///
  /// Deliberately does **not** filter `exercises.deleted_at`: a tombstoned
  /// exercise must still render inside the history that references it
  /// (docs/21-DATA-MODEL.md §deletion-policy).
  Stream<List<SessionExercise>> watchExercises(String workoutId) {
    return _db
        .customSelect(
          '''
          SELECT we.id            AS we_id,
                 we.position      AS position,
                 we.notes         AS we_notes,
                 we.group_id      AS group_id,
                 we.target_snapshot AS target_snapshot,
                 e.id             AS exercise_id,
                 e.name           AS name,
                 e.notes          AS exercise_notes,
                 e.primary_muscle AS primary_muscle,
                 e.equipment      AS equipment,
                 e.tracking_type  AS tracking_type,
                 e.weight_entry_mode AS weight_entry_mode,
                 e.increment_grams AS increment_grams,
                 e.default_rest_seconds AS default_rest_seconds,
                 (SELECT COUNT(*) FROM sets s
                   WHERE s.workout_exercise_id = we.id
                     AND s.deleted_at IS NULL)                   AS set_count,
                 (SELECT COUNT(*) FROM sets s
                   WHERE s.workout_exercise_id = we.id
                     AND s.deleted_at IS NULL
                     AND s.is_completed = 1)                     AS done_count
            FROM workout_exercises we
            JOIN exercises e ON e.id = we.exercise_id
           WHERE we.workout_id = ? AND we.deleted_at IS NULL
           ORDER BY we.position
          ''',
          variables: [Variable<String>(workoutId)],
          readsFrom: {_db.workoutExercises, _db.exercises, _db.sets},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              SessionExercise(
                workoutExerciseId: row.read<String>('we_id'),
                exerciseId: row.read<String>('exercise_id'),
                name: row.read<String>('name'),
                exerciseNotes: row.read<String?>('exercise_notes'),
                primaryMuscle: _enumByName(
                  Muscle.values,
                  row.read<String>('primary_muscle'),
                  Muscle.fullBody,
                ),
                equipment: _enumByName(
                  Equipment.values,
                  row.read<String>('equipment'),
                  Equipment.other,
                ),
                trackingType: _enumByName(
                  TrackingType.values,
                  row.read<String>('tracking_type'),
                  TrackingType.weightReps,
                ),
                weightEntryMode: _enumByName(
                  WeightEntryMode.values,
                  row.read<String>('weight_entry_mode'),
                  WeightEntryMode.total,
                ),
                incrementGrams: row.read<int?>('increment_grams'),
                defaultRestSeconds: row.read<int?>('default_rest_seconds'),
                position: row.read<int>('position'),
                setCount: row.read<int>('set_count'),
                completedSetCount: row.read<int>('done_count'),
                notes: row.read<String?>('we_notes'),
                groupId: row.read<String?>('group_id'),
                target: switch (row.read<String?>('target_snapshot')) {
                  null => null,
                  final json => SessionExerciseTarget.fromJson(json),
                },
              ),
          ],
        );
  }

  /// What a discard would destroy, and whether a finish would be empty.
  Future<WorkoutTally> tally(String workoutId) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT
            (SELECT COUNT(*) FROM workout_exercises we
              WHERE we.workout_id = ? AND we.deleted_at IS NULL) AS exercises,
            (SELECT COUNT(*) FROM sets s
               JOIN workout_exercises we ON we.id = s.workout_exercise_id
              WHERE we.workout_id = ?
                AND we.deleted_at IS NULL
                AND s.deleted_at IS NULL
                AND s.is_completed = 1)                          AS done
          ''',
          variables: [Variable<String>(workoutId), Variable<String>(workoutId)],
          readsFrom: {_db.workoutExercises, _db.sets},
        )
        .getSingle();

    return WorkoutTally(
      exercises: rows.read<int>('exercises'),
      completedSets: rows.read<int>('done'),
    );
  }

  /// Any workout by id, active or finished. Unlike [watchActive], not limited
  /// to the in-progress session — the history detail and edit screens need to
  /// watch a session that has already ended.
  Stream<Workout?> watchById(String id) =>
      (_db.select(_db.workouts)
            ..where((w) => w.id.equals(id))
            ..where((w) => w.deletedAt.isNull()))
          .watchSingleOrNull();

  /// Finished sessions, newest first, optionally filtered by workout or
  /// exercise name (`F-LOG-011`).
  ///
  /// [limit] bounds how many rows come back; the screen raises it as the list
  /// is scrolled rather than this repository paging internally, so growing the
  /// limit is just a new query on an already-indexed table.
  Stream<List<WorkoutHistoryEntry>> watchHistory({
    String query = '',
    int limit = 50,
  }) {
    final trimmed = query.trim();
    final pattern = '%${trimmed.replaceAll('%', r'\%')}%';
    return _db
        .customSelect(
          r'''
          SELECT w.id                            AS id,
                 w.name                           AS name,
                 w.started_at                     AS started_at,
                 w.started_at_tz_offset_minutes    AS tz_offset,
                 w.ended_at                        AS ended_at,
                 w.notes                           AS notes,
                 (SELECT COUNT(*) FROM workout_exercises we
                   WHERE we.workout_id = w.id AND we.deleted_at IS NULL)
                   AS exercise_count,
                 (SELECT COUNT(*) FROM sets s
                    JOIN workout_exercises we ON we.id = s.workout_exercise_id
                   WHERE we.workout_id = w.id AND we.deleted_at IS NULL
                     AND s.deleted_at IS NULL AND s.is_completed = 1
                     AND s.set_type != 'warmup') AS completed_set_count,
                 (SELECT COALESCE(SUM(s.weight_grams * s.reps), 0) FROM sets s
                    JOIN workout_exercises we ON we.id = s.workout_exercise_id
                    JOIN exercises e ON e.id = we.exercise_id
                   WHERE we.workout_id = w.id AND we.deleted_at IS NULL
                     AND s.deleted_at IS NULL AND s.is_completed = 1
                     AND s.set_type != 'warmup'
                     AND e.tracking_type IN ('weightReps', 'weightTime')
                     AND s.weight_grams IS NOT NULL AND s.reps IS NOT NULL)
                   AS total_volume_grams
            FROM workouts w
           WHERE w.deleted_at IS NULL AND w.ended_at IS NOT NULL
             AND (
                   ? = ''
                   OR w.name LIKE ? ESCAPE '\'
                   OR EXISTS (
                        SELECT 1 FROM workout_exercises we2
                        JOIN exercises e2 ON e2.id = we2.exercise_id
                       WHERE we2.workout_id = w.id AND we2.deleted_at IS NULL
                         AND e2.name LIKE ? ESCAPE '\'
                      )
                 )
           ORDER BY w.started_at DESC
           LIMIT ?
          ''',
          variables: [
            Variable<String>(trimmed),
            Variable<String>(pattern),
            Variable<String>(pattern),
            Variable<int>(limit),
          ],
          readsFrom: {
            _db.workouts,
            _db.workoutExercises,
            _db.exercises,
            _db.sets,
          },
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              WorkoutHistoryEntry(
                id: row.read<String>('id'),
                name: row.read<String>('name'),
                startedAt: row.read<int>('started_at'),
                startedAtTzOffsetMinutes: row.read<int>('tz_offset'),
                endedAt: row.read<int?>('ended_at'),
                exerciseCount: row.read<int>('exercise_count'),
                completedSetCount: row.read<int>('completed_set_count'),
                totalVolumeGrams: row.read<int>('total_volume_grams'),
                hasNotes: row.read<String?>('notes') != null,
              ),
          ],
        );
  }

  /// The workout's own free-text note, distinct from each exercise's
  /// (`F-LOG-008`).
  Future<void> setWorkoutNotes(String id, String? notes) async {
    final trimmed = notes?.trim();
    await (_db.update(_db.workouts)..where((w) => w.id.equals(id))).write(
      WorkoutsCompanion(
        notes: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
        updatedAt: Value(_now),
      ),
    );
  }

  /// One exercise's session-specific note, distinct from the exercise's
  /// persistent sticky note (`F-LOG-008`).
  Future<void> setExerciseNotes(String workoutExerciseId, String? notes) async {
    final trimmed = notes?.trim();
    await (_db.update(
      _db.workoutExercises,
    )..where((we) => we.id.equals(workoutExerciseId))).write(
      WorkoutExercisesCompanion(
        notes: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
        updatedAt: Value(_now),
      ),
    );
  }

  /// Moves a past workout to a different date and time (`F-LOG-009` §1, §4).
  ///
  /// [startedAt] is local wall-clock; the offset stored beside it is the one
  /// in effect right now, same as at creation (ADR-0008) — editing history
  /// does not attempt to reconstruct what the offset actually was on the
  /// original date.
  Future<void> reschedule(String id, DateTime startedAt) async {
    await (_db.update(_db.workouts)..where((w) => w.id.equals(id))).write(
      WorkoutsCompanion(
        startedAt: Value(startedAt.millisecondsSinceEpoch),
        startedAtTzOffsetMinutes: Value(startedAt.timeZoneOffset.inMinutes),
        updatedAt: Value(_now),
      ),
    );
  }

  /// Logs an already-finished session at a chosen date and time
  /// (`F-LOG-009` §4) — for a session remembered after the fact rather than
  /// timed live.
  Future<Workout> createRetroactive({
    required String name,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final id = newUuidV4();
    final timestamp = _now;
    await _db
        .into(_db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            id: id,
            name: name.trim().isNotEmpty
                ? name.trim()
                : defaultNameFor(startedAt),
            startedAt: startedAt.millisecondsSinceEpoch,
            startedAtTzOffsetMinutes: startedAt.timeZoneOffset.inMinutes,
            endedAt: Value(endedAt.millisecondsSinceEpoch),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    return (await findById(id))!;
  }

  /// Deletes a past workout, cascading the tombstone to its exercises and
  /// sets (`F-LOG-009` §2, docs/21-DATA-MODEL.md §deletion-policy). Same
  /// tombstone cascade as [discard]; kept as a separate name because the two
  /// happen from very different places for very different reasons.
  Future<void> deleteWorkout(String id) => discard(id);

  /// Removes one exercise from a workout, cascading to its sets — exercises
  /// are as editable as the sets within them (`F-LOG-009` §1, `F-LOG-010` §1).
  ///
  /// Returns the tombstone timestamp it wrote, so a caller can offer undo
  /// (`F-LOG-022` §3) via [restoreExercise] without guessing which rows this
  /// particular removal touched.
  Future<int> removeExerciseFromWorkout(String workoutExerciseId) async {
    final removed = await (_db.select(
      _db.workoutExercises,
    )..where((we) => we.id.equals(workoutExerciseId))).getSingleOrNull();
    final timestamp = _now;
    await _db.transaction(() async {
      await _db.customUpdate(
        'UPDATE sets SET deleted_at = ?, updated_at = ? '
        'WHERE deleted_at IS NULL AND workout_exercise_id = ?',
        variables: [
          Variable<int>(timestamp),
          Variable<int>(timestamp),
          Variable<String>(workoutExerciseId),
        ],
        updates: {_db.sets},
      );
      await _db.customUpdate(
        'UPDATE workout_exercises SET deleted_at = ?, updated_at = ? '
        'WHERE id = ?',
        variables: [
          Variable<int>(timestamp),
          Variable<int>(timestamp),
          Variable<String>(workoutExerciseId),
        ],
        updates: {_db.workoutExercises},
      );
      final groupId = removed?.groupId;
      if (groupId != null) {
        final remaining =
            await (_db.select(_db.workoutExercises)..where(
                  (we) =>
                      we.groupId.equals(groupId) &
                      we.id.equals(workoutExerciseId).not() &
                      we.deletedAt.isNull(),
                ))
                .get();
        if (remaining.length < 2) {
          await (_db.update(
            _db.workoutExercises,
          )..where((we) => we.groupId.equals(groupId))).write(
            WorkoutExercisesCompanion(
              groupId: const Value(null),
              updatedAt: Value(timestamp),
            ),
          );
        }
      }
    });
    return timestamp;
  }

  /// Undo for [removeExerciseFromWorkout] (`F-LOG-022` §3). [tombstonedAt]
  /// is the exact timestamp that call returned — restoring only rows stamped
  /// with it avoids resurrecting sets that were already deleted (by a swipe,
  /// say) before the exercise itself was removed.
  ///
  /// A group the removal dissolved is not re-formed: that dissolution was a
  /// side effect of membership dropping below two, not something this
  /// specific tombstone recorded, so there is nothing here to read it back
  /// from.
  Future<void> restoreExercise(
    String workoutExerciseId,
    int tombstonedAt,
  ) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.workoutExercises,
      )..where((we) => we.id.equals(workoutExerciseId))).write(
        WorkoutExercisesCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(_now),
        ),
      );
      await _db.customUpdate(
        'UPDATE sets SET deleted_at = NULL, updated_at = ? '
        'WHERE workout_exercise_id = ? AND deleted_at = ?',
        variables: [
          Variable<int>(_now),
          Variable<String>(workoutExerciseId),
          Variable<int>(tombstonedAt),
        ],
        updates: {_db.sets},
      );
    });
  }

  /// Totals for the finish summary (`F-LOG-018`), plus a comparison against
  /// the last workout of the same name, if there is one.
  Future<WorkoutSummaryStats> summaryStats(String workoutId) async {
    final workout = await findById(workoutId);
    if (workout == null) {
      throw ArgumentError('No workout with id $workoutId');
    }

    final own = await _countedSetsFor(workoutId);
    final tally = await this.tally(workoutId);

    PreviousSessionStats? previous;
    final previousRow =
        await (_db.select(_db.workouts)
              ..where((w) => w.id.equals(workoutId).not())
              ..where((w) => w.deletedAt.isNull())
              ..where((w) => w.endedAt.isNotNull())
              ..where((w) => w.name.equals(workout.name))
              ..orderBy([
                (w) => OrderingTerm(
                  expression: w.startedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();

    if (previousRow != null) {
      final previousSets = await _countedSetsFor(previousRow.id);
      previous = PreviousSessionStats(
        startedAt: previousRow.startedAt,
        totalVolumeGrams: totalVolumeGrams(previousSets.sets),
        duration: previousRow.endedAt == null
            ? Duration.zero
            : Duration(
                milliseconds: previousRow.endedAt! - previousRow.startedAt,
              ),
      );
    }

    return WorkoutSummaryStats(
      duration: workout.endedAt == null
          ? Duration.zero
          : Duration(milliseconds: workout.endedAt! - workout.startedAt),
      totalVolumeGrams: totalVolumeGrams(own.sets),
      completedSetCount: own.completedSetCount,
      exerciseCount: tally.exercises,
      muscles: own.muscles,
      previous: previous,
    );
  }

  /// Raw counted-set data for [workoutId], for [summaryStats]. A single query
  /// shared by both the current session and its comparison target, so the two
  /// figures are computed by the exact same rule.
  Future<_CountedSetStats> _countedSetsFor(String workoutId) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT s.set_type      AS set_type,
                 s.is_completed  AS is_completed,
                 s.weight_grams  AS weight_grams,
                 s.reps          AS reps,
                 e.tracking_type AS tracking_type,
                 e.primary_muscle AS primary_muscle
            FROM sets s
            JOIN workout_exercises we ON we.id = s.workout_exercise_id
            JOIN exercises e ON e.id = we.exercise_id
           WHERE we.workout_id = ? AND we.deleted_at IS NULL
             AND s.deleted_at IS NULL
          ''',
          variables: [Variable<String>(workoutId)],
          readsFrom: {_db.sets, _db.workoutExercises, _db.exercises},
        )
        .get();

    final sets = <CountedSet>[];
    final muscles = <Muscle>{};
    var completedSetCount = 0;
    for (final row in rows) {
      final isCompleted = row.read<int>('is_completed') == 1;
      final setType = row.read<String>('set_type');
      if (isCompleted && setType != 'warmup') {
        completedSetCount++;
        muscles.add(
          _enumByName(
            Muscle.values,
            row.read<String>('primary_muscle'),
            Muscle.fullBody,
          ),
        );
      }
      sets.add(
        CountedSet(
          setType: setType,
          trackingType: row.read<String>('tracking_type'),
          isCompleted: isCompleted,
          weightGrams: row.read<int?>('weight_grams'),
          reps: row.read<int?>('reps'),
        ),
      );
    }
    return _CountedSetStats(
      sets: sets,
      muscles: muscles,
      completedSetCount: completedSetCount,
    );
  }

  /// An unknown stored value means a downgrade or a corrupt write. Falling back
  /// beats throwing: a session is never worth failing to render over one
  /// mislabelled muscle.
  static T _enumByName<T extends Enum>(
    List<T> values,
    String name,
    T fallback,
  ) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}

/// Intermediate result of [WorkoutRepository._countedSetsFor].
class _CountedSetStats {
  const _CountedSetStats({
    required this.sets,
    required this.muscles,
    required this.completedSetCount,
  });

  final List<CountedSet> sets;
  final Set<Muscle> muscles;
  final int completedSetCount;
}
