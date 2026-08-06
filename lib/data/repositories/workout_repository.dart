import 'package:drift/drift.dart';

import '../../core/ids/uuid.dart';
import '../db/app_database.dart';
import '../db/tables/enums.dart';

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
    required this.incrementGrams,
    required this.defaultRestSeconds,
    required this.position,
    required this.setCount,
    required this.completedSetCount,
  });

  final String workoutExerciseId;
  final String exerciseId;
  final String name;
  final Muscle primaryMuscle;
  final Equipment equipment;

  /// Decides which inputs the set rows render (`F-CAT-002`, `F-LOG-003` §1).
  final TrackingType trackingType;

  /// Per-exercise stepper increment in canonical grams, or null to fall back to
  /// the equipment default (`F-SET-007`, `F-LOG-006` §2).
  final int? incrementGrams;

  /// This exercise's own rest duration, or null to fall through to the global
  /// setting and then to the built-in default for its kind (`F-TIM-005`).
  final int? defaultRestSeconds;

  final int position;
  final int setCount;
  final int completedSetCount;
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
    return (await findById(id))!;
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
      await _db.customStatement(
        'UPDATE sets SET deleted_at = ?, updated_at = ? '
        'WHERE deleted_at IS NULL AND workout_exercise_id IN '
        '(SELECT id FROM workout_exercises WHERE workout_id = ?)',
        [timestamp, timestamp, id],
      );
      await _db.customStatement(
        'UPDATE workout_exercises SET deleted_at = ?, updated_at = ? '
        'WHERE deleted_at IS NULL AND workout_id = ?',
        [timestamp, timestamp, id],
      );
      await _db.customStatement(
        'UPDATE workouts SET deleted_at = ?, updated_at = ? WHERE id = ?',
        [timestamp, timestamp, id],
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
                 e.id             AS exercise_id,
                 e.name           AS name,
                 e.primary_muscle AS primary_muscle,
                 e.equipment      AS equipment,
                 e.tracking_type  AS tracking_type,
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
                incrementGrams: row.read<int?>('increment_grams'),
                defaultRestSeconds: row.read<int?>('default_rest_seconds'),
                position: row.read<int>('position'),
                setCount: row.read<int>('set_count'),
                completedSetCount: row.read<int>('done_count'),
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
