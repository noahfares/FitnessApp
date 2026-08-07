import 'package:drift/drift.dart';

import '../../core/ids/uuid.dart';
import '../db/app_database.dart';
import '../db/tables/enums.dart';

/// One set from the most recent completed session containing an exercise —
/// the "last time" values (`F-LOG-004`).
///
/// Carries only what the ghost renders. It is deliberately not a `WorkoutSet`:
/// nothing may write it back, and giving it an id would invite exactly that.
class GhostSet {
  const GhostSet({
    required this.setType,
    this.weightGrams,
    this.reps,
    this.distanceMetres,
    this.durationSeconds,
    required this.performedAt,
  });

  final String setType;
  final int? weightGrams;
  final int? reps;
  final int? distanceMetres;
  final int? durationSeconds;

  /// When the session it came from started, UTC ms. An exercise last done a
  /// year ago still shows its ghost (`F-LOG-004` edge cases); this is what lets
  /// the row say so.
  final int performedAt;

  @override
  bool operator ==(Object other) =>
      other is GhostSet &&
      other.setType == setType &&
      other.weightGrams == weightGrams &&
      other.reps == reps &&
      other.distanceMetres == distanceMetres &&
      other.durationSeconds == durationSeconds &&
      other.performedAt == performedAt;

  @override
  int get hashCode => Object.hash(
    setType,
    weightGrams,
    reps,
    distanceMetres,
    durationSeconds,
    performedAt,
  );
}

/// The `sets` table: the hot path of the whole app (`F-LOG-003`–`F-LOG-006`,
/// `F-LOG-023`).
///
/// **Every method writes through immediately** (`F-LOG-007`). There is no
/// pending-changes buffer to flush, because a buffer is exactly what gets lost
/// when a battery manager kills the app between sets.
class SetRepository {
  SetRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  int get _now => _clock().millisecondsSinceEpoch;

  /// The sets of one exercise within one session, in display order.
  Stream<List<WorkoutSet>> watchSets(String workoutExerciseId) =>
      _setsQuery(workoutExerciseId).watch();

  Future<List<WorkoutSet>> getSets(String workoutExerciseId) =>
      _setsQuery(workoutExerciseId).get();

  MultiSelectable<WorkoutSet> _setsQuery(String workoutExerciseId) =>
      _db.select(_db.sets)
        ..where((s) => s.workoutExerciseId.equals(workoutExerciseId))
        ..where((s) => s.deletedAt.isNull())
        ..orderBy([(s) => OrderingTerm(expression: s.position)]);

  Future<WorkoutSet?> findById(String id) =>
      (_db.select(_db.sets)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Appends a set, **pre-filled from the previous one** in the same exercise
  /// (`F-LOG-003` §5).
  ///
  /// The set type is copied along with the values. Straight sets are the
  /// overwhelming majority: after two warm-ups the next row is far more often a
  /// third warm-up than a working set, and the alternative — silently promoting
  /// it — writes a wrong `set_type`, which is the one thing on this row that
  /// cannot be recovered later (`F-LOG-005`).
  Future<String> addSet(String workoutExerciseId) async {
    final timestamp = _now;
    final existing = await getSets(workoutExerciseId);
    final previous = existing.isEmpty ? null : existing.last;
    final id = newUuidV4();

    await _db
        .into(_db.sets)
        .insert(
          SetsCompanion.insert(
            id: id,
            workoutExerciseId: workoutExerciseId,
            position: (previous?.position ?? -1) + 1,
            setType: Value(previous?.setType ?? SetType.working),
            weightGrams: Value(previous?.weightGrams),
            reps: Value(previous?.reps),
            distanceMetres: Value(previous?.distanceMetres),
            durationSeconds: Value(previous?.durationSeconds),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    return id;
  }

  /// Writes one or more measured values. Absent arguments are left alone;
  /// passing `Value(null)` clears a field.
  Future<void> updateValues(
    String id, {
    Value<int?> weightGrams = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> distanceMetres = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
  }) async {
    await (_db.update(_db.sets)..where((s) => s.id.equals(id))).write(
      SetsCompanion(
        weightGrams: weightGrams,
        reps: reps,
        distanceMetres: distanceMetres,
        durationSeconds: durationSeconds,
        updatedAt: Value(_now),
      ),
    );
  }

  /// Perceived effort, 6.0–10.0 in 0.5 steps, always stored as RPE regardless
  /// of the display setting (`F-LOG-014` §1–§2).
  Future<void> setRpe(String id, double? rpe) async {
    await (_db.update(_db.sets)..where((s) => s.id.equals(id))).write(
      SetsCompanion(rpe: Value(rpe), updatedAt: Value(_now)),
    );
  }

  Future<void> setType(String id, SetType type) async {
    await (_db.update(_db.sets)..where((s) => s.id.equals(id))).write(
      SetsCompanion(setType: Value(type), updatedAt: Value(_now)),
    );
  }

  /// Per-set note (`F-LOG-023`). An empty note is stored as null so that
  /// "has a note" stays a single null check everywhere it is asked.
  Future<void> setNote(String id, String? note) async {
    final trimmed = note?.trim();
    await (_db.update(_db.sets)..where((s) => s.id.equals(id))).write(
      SetsCompanion(
        notes: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
        updatedAt: Value(_now),
      ),
    );
  }

  /// Marks a set done, optionally adopting values in the same write.
  ///
  /// Adoption happens here rather than as a separate update because completing
  /// an empty row with the ghost's values (`F-LOG-003` §4, `F-LOG-004` §4) must
  /// be atomic: a kill between the two writes would otherwise leave a completed
  /// set with no numbers in it, which is unrecoverable — nobody remembers
  /// afterwards what the ghost said.
  Future<void> complete(
    String id, {
    Value<int?> weightGrams = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> distanceMetres = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
  }) async {
    final now = _clock();
    await (_db.update(_db.sets)..where((s) => s.id.equals(id))).write(
      SetsCompanion(
        isCompleted: const Value(true),
        completedAt: Value(now.millisecondsSinceEpoch),
        // Rest intervals are derived from these afterwards (`F-TIM-007`), and
        // an offset that was not stored at write time cannot be reconstructed.
        completedAtTzOffsetMinutes: Value(now.timeZoneOffset.inMinutes),
        weightGrams: weightGrams,
        reps: reps,
        distanceMetres: distanceMetres,
        durationSeconds: durationSeconds,
        updatedAt: Value(now.millisecondsSinceEpoch),
      ),
    );
  }

  /// Un-ticks a set. The values stay; only the completion does.
  ///
  /// `completed_at` is cleared with it, because a set that is not completed has
  /// no completion time, and leaving a stale one would corrupt the rest
  /// intervals derived from consecutive completions.
  Future<void> uncomplete(String id) async {
    await (_db.update(_db.sets)..where((s) => s.id.equals(id))).write(
      SetsCompanion(
        isCompleted: const Value(false),
        completedAt: const Value(null),
        completedAtTzOffsetMinutes: const Value(null),
        updatedAt: Value(_now),
      ),
    );
  }

  /// Tombstones a set (ADR-0008). Positions of the remaining rows are left
  /// alone: they are an ordering, not a numbering, and the labels shown to the
  /// user are derived on read (`labelSets`).
  Future<void> deleteSet(String id) async {
    final timestamp = _now;
    await (_db.update(_db.sets)..where((s) => s.id.equals(id))).write(
      SetsCompanion(deletedAt: Value(timestamp), updatedAt: Value(timestamp)),
    );
  }

  /// Undo for [deleteSet] (`F-LOG-003` §6). Costs a field update rather than a
  /// resurrection precisely because the delete was a tombstone.
  Future<void> restoreSet(String id) async {
    await (_db.update(_db.sets)..where((s) => s.id.equals(id))).write(
      SetsCompanion(deletedAt: const Value(null), updatedAt: Value(_now)),
    );
  }

  /// The completed sets of the most recent **finished** session containing
  /// [exerciseId] — the ghost values (`F-LOG-004` §1).
  ///
  /// Only completed sets count, so a session abandoned halfway through an
  /// exercise contributes what was actually done and nothing else. In-progress
  /// sessions are excluded by `ended_at IS NOT NULL`, which also excludes the
  /// current one without needing to know its id.
  ///
  /// Budget: under 50 ms over years of history (docs/60-ENGINEERING.md). Both
  /// the sub-select and the outer query ride
  /// `idx_workout_exercises_exercise` and `idx_sets_workout_exercise`.
  Future<List<GhostSet>> ghostSetsFor(String exerciseId) async {
    final rows = await _ghostQuery(exerciseId).get();
    return _mapGhosts(rows);
  }

  /// Streaming form, so a ghost updates when the session it came from is
  /// deleted (`F-LOG-004` acceptance) without anything having to remember to
  /// invalidate it.
  ///
  /// De-duplicated with [distinct]: the query re-runs on every write to `sets`,
  /// which during a session means every completion, and the answer is almost
  /// always the same one. Without this, ticking a set rebuilds the ghost of
  /// every exercise on screen.
  Stream<List<GhostSet>> watchGhostSetsFor(String exerciseId) =>
      _ghostQuery(exerciseId).watch().map(_mapGhosts).distinct(_sameGhosts);

  Selectable<QueryRow> _ghostQuery(String exerciseId) => _db.customSelect(
    '''
    SELECT s.set_type         AS set_type,
           s.weight_grams     AS weight_grams,
           s.reps             AS reps,
           s.distance_metres  AS distance_metres,
           s.duration_seconds AS duration_seconds,
           w.started_at       AS started_at
      FROM sets s
      JOIN workout_exercises we ON we.id = s.workout_exercise_id
      JOIN workouts w           ON w.id  = we.workout_id
     WHERE we.exercise_id = ?
       AND we.deleted_at IS NULL
       AND s.deleted_at IS NULL
       AND s.is_completed = 1
       AND w.id = (
             SELECT w2.id
               FROM workouts w2
               JOIN workout_exercises we2 ON we2.workout_id = w2.id
               JOIN sets s2 ON s2.workout_exercise_id = we2.id
              WHERE we2.exercise_id = ?
                AND w2.ended_at IS NOT NULL
                AND w2.deleted_at IS NULL
                AND we2.deleted_at IS NULL
                AND s2.deleted_at IS NULL
                AND s2.is_completed = 1
              ORDER BY w2.started_at DESC
              LIMIT 1
           )
     ORDER BY we.position, s.position
    ''',
    variables: [Variable<String>(exerciseId), Variable<String>(exerciseId)],
    readsFrom: {_db.sets, _db.workoutExercises, _db.workouts},
  );

  static List<GhostSet> _mapGhosts(List<QueryRow> rows) => [
    for (final row in rows)
      GhostSet(
        setType: row.read<String>('set_type'),
        weightGrams: row.read<int?>('weight_grams'),
        reps: row.read<int?>('reps'),
        distanceMetres: row.read<int?>('distance_metres'),
        durationSeconds: row.read<int?>('duration_seconds'),
        performedAt: row.read<int>('started_at'),
      ),
  ];

  static bool _sameGhosts(List<GhostSet> a, List<GhostSet> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
