import 'package:drift/drift.dart';

import '../../core/ids/uuid.dart';
import '../../domain/analytics/personal_records.dart';
import '../db/app_database.dart';
import '../db/tables/enums.dart';

/// `personal_records` (`F-LOG-013`, `docs/40-ANALYTICS-SPEC.md` §4).
///
/// A **cache**, never a source of truth — every row is rebuildable from
/// `sets` (`docs/21-DATA-MODEL.md` §personal_records). Deletion is a
/// tombstone like everywhere else (`ADR-0008`): a stale record is superseded,
/// not patched, because a patch on delete can only ever demote incorrectly
/// (§4 rule 4) — the replacement is always a fresh scan from raw sets, never
/// arithmetic on the old cached value.
///
/// Scoped to `weightReps` tracking type only, matching the rest of Phase 1–2
/// (`lib/data/db/tables/enums.dart` — Phase 1 implements `weightReps` only).
class PersonalRecordRepository {
  PersonalRecordRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  int get _now => _clock().millisecondsSinceEpoch;

  /// Evaluates a just-completed set against its exercise's cached records,
  /// updating the cache for anything it beats (§4 rule 4 note: only ever
  /// additive here — full rebuild is what handles demotion).
  ///
  /// Returns what it beat, most-significant-first (§4 rule 5), for the caller
  /// to celebrate. Empty if it beat nothing, if it does not qualify (deleted,
  /// incomplete, a warm-up, missing weight/reps, or not `weightReps`), or if
  /// it is the exercise's first-ever counted set — technically a record on
  /// every kind, but recorded silently rather than celebrated (§4 rule 3).
  ///
  /// `maxSessionVolume` is deliberately not evaluated here — see
  /// [evaluateSessionVolume]. A per-set running total would keep beating its
  /// own more-recent self as the session progresses, "celebrating" nothing
  /// but arithmetic; the record only means something once the session's
  /// total for the exercise is final.
  Future<List<PrHit>> evaluateSet(String setId) async {
    final candidate = await _candidateFor(setId);
    if (candidate == null) return const [];

    final hadNoPriorSet = await _hasNoPriorCountedSet(
      candidate.exerciseId,
      excludingSetId: setId,
    );

    final existing = await _existingFor(
      candidate.exerciseId,
      candidate.weightGrams,
    );

    final hits = detectPrs(
      weightGrams: candidate.weightGrams,
      reps: candidate.reps,
      // Unused: filtered out below before it ever reaches the cache.
      sessionVolumeGrams: 0,
      existing: existing,
    ).where((hit) => hit.kind != PrDetectionKind.maxSessionVolume).toList();
    if (hits.isEmpty) return const [];

    for (final hit in hits) {
      await _replaceRecord(
        exerciseId: candidate.exerciseId,
        kind: hit.kind,
        qualifier: hit.qualifierGrams,
        value: hit.value,
        setId: setId,
        workoutId: candidate.workoutId,
        achievedAt: candidate.achievedAt,
      );
    }

    return hadNoPriorSet ? const [] : hits;
  }

  /// Evaluates one workout's exercises for a `maxSessionVolume` record
  /// (§4), once each exercise's total for the session is final. Idempotent —
  /// safe to call again for an already-evaluated workout, since a repeat
  /// total is a tie, not a new record (§4 rule 1).
  Future<void> evaluateSessionVolume(String workoutId) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT DISTINCT we.exercise_id AS exercise_id
            FROM sets s
            JOIN workout_exercises we ON we.id = s.workout_exercise_id
            JOIN exercises e          ON e.id  = we.exercise_id
           WHERE we.workout_id = ?
             AND e.tracking_type = 'weightReps'
             AND we.deleted_at IS NULL
             AND s.deleted_at IS NULL
             AND s.is_completed = 1
             AND s.set_type != 'warmup'
          ''',
          variables: [Variable<String>(workoutId)],
          readsFrom: {_db.sets, _db.workoutExercises, _db.exercises},
        )
        .get();

    for (final row in rows) {
      final exerciseId = row.read<String>('exercise_id');
      final volume = await _sessionVolumeGrams(workoutId, exerciseId);
      final existing = await _existingFor(exerciseId, 0);
      if (existing.maxSessionVolumeGrams != null &&
          volume <= existing.maxSessionVolumeGrams!) {
        continue;
      }
      await _replaceRecord(
        exerciseId: exerciseId,
        kind: PrDetectionKind.maxSessionVolume,
        qualifier: null,
        value: volume,
        setId: null,
        workoutId: workoutId,
        achievedAt: _now,
      );
    }
  }

  /// The cached records currently attributed to sets in [workoutId] — what
  /// the finish summary lists (`F-LOG-018` §3).
  Future<List<PersonalRecord>> recordsForWorkout(String workoutId) =>
      (_db.select(_db.personalRecords)
            ..where((p) => p.workoutId.equals(workoutId))
            ..where((p) => p.deletedAt.isNull()))
          .get();

  /// The set ids currently holding a cached record for [exerciseId], for the
  /// inline badge (`F-LOG-013` §2). Streamed so a demotion — from a later
  /// rebuild — removes the badge without the row needing to be told directly.
  Stream<Set<String>> watchRecordSetIds(String exerciseId) =>
      (_db.select(_db.personalRecords)
            ..where((p) => p.exerciseId.equals(exerciseId))
            ..where((p) => p.deletedAt.isNull())
            ..where((p) => p.setId.isNotNull()))
          .watch()
          .map((rows) => {for (final row in rows) row.setId!});

  /// Full recompute for one exercise from raw sets (§4 rule 4, §5) — the only
  /// correct response to a deleted or edited set, since a cache can be
  /// demoted but never knows the next-best value without rescanning.
  Future<void> rebuildForExercise(String exerciseId) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT s.id             AS set_id,
                 s.weight_grams   AS weight_grams,
                 s.reps           AS reps,
                 s.completed_at   AS achieved_at,
                 we.workout_id    AS workout_id
            FROM sets s
            JOIN workout_exercises we ON we.id = s.workout_exercise_id
            JOIN workouts w           ON w.id  = we.workout_id
            JOIN exercises e          ON e.id  = we.exercise_id
           WHERE we.exercise_id = ?
             AND e.tracking_type = 'weightReps'
             AND we.deleted_at IS NULL
             AND w.deleted_at IS NULL
             AND s.deleted_at IS NULL
             AND s.is_completed = 1
             AND s.set_type != 'warmup'
             AND s.weight_grams IS NOT NULL
             AND s.reps IS NOT NULL
           ORDER BY w.started_at, we.position, s.position
          ''',
          variables: [Variable<String>(exerciseId)],
          readsFrom: {
            _db.sets,
            _db.workoutExercises,
            _db.workouts,
            _db.exercises,
          },
        )
        .get();

    final winners = <PrDetectionKind, _Winner>{};
    final repsAtWeightWinners = <int, _Winner>{};
    // Chronological running totals. A session's true volume is only known
    // once its last set is swept, but the max across every partial sum seen
    // equals the max across every session's *final* sum: any earlier partial
    // sum from the eventually-winning session is, by definition, no higher
    // than that session's own final total, so it can only ever be overtaken
    // by that same session's later entries — never falsely stick as the
    // overall winner.
    final sessionVolumes = <String, int>{};

    for (final row in rows) {
      final setId = row.read<String>('set_id');
      final weightGrams = row.read<int>('weight_grams');
      final reps = row.read<int>('reps');
      final achievedAt = row.read<int?>('achieved_at') ?? _now;
      final workoutId = row.read<String>('workout_id');

      sessionVolumes[workoutId] =
          (sessionVolumes[workoutId] ?? 0) + weightGrams * reps;

      final hits = detectPrs(
        weightGrams: weightGrams,
        reps: reps,
        sessionVolumeGrams: sessionVolumes[workoutId]!,
        existing: ExistingPrs(
          maxWeightGrams: winners[PrDetectionKind.maxWeight]?.value,
          existingMaxRepsAtThisWeight: repsAtWeightWinners[weightGrams]?.value,
          bestE1rmGrams: winners[PrDetectionKind.bestE1rm]?.value,
          maxSessionVolumeGrams:
              winners[PrDetectionKind.maxSessionVolume]?.value,
        ),
      );

      for (final hit in hits) {
        // No badge attaches to a maxSessionVolume record (it belongs to the
        // session, not one set), matching evaluateSessionVolume's convention.
        final winner = _Winner(
          value: hit.value,
          setId: hit.kind == PrDetectionKind.maxSessionVolume ? null : setId,
          workoutId: workoutId,
          achievedAt: achievedAt,
        );
        if (hit.kind == PrDetectionKind.maxRepsAtWeight) {
          repsAtWeightWinners[weightGrams] = winner;
        } else {
          winners[hit.kind] = winner;
        }
      }
    }

    await _db.transaction(() async {
      await (_db.update(_db.personalRecords)
            ..where((p) => p.exerciseId.equals(exerciseId))
            ..where((p) => p.deletedAt.isNull()))
          .write(PersonalRecordsCompanion(deletedAt: Value(_now)));

      for (final entry in winners.entries) {
        await _insert(
          exerciseId: exerciseId,
          kind: entry.key,
          qualifier: null,
          winner: entry.value,
        );
      }
      for (final entry in repsAtWeightWinners.entries) {
        await _insert(
          exerciseId: exerciseId,
          kind: PrDetectionKind.maxRepsAtWeight,
          qualifier: entry.key,
          winner: entry.value,
        );
      }
    });
  }

  /// Every exercise with at least one counted set — the "rebuild PR cache"
  /// maintenance action (§4 rule 5), for when a bug in the incremental path
  /// leaves the cache wrong.
  Future<void> rebuildAll() async {
    final rows = await _db
        .customSelect(
          '''
          SELECT DISTINCT we.exercise_id AS exercise_id
            FROM sets s
            JOIN workout_exercises we ON we.id = s.workout_exercise_id
           WHERE we.deleted_at IS NULL AND s.deleted_at IS NULL
          ''',
          readsFrom: {_db.sets, _db.workoutExercises},
        )
        .get();
    for (final row in rows) {
      await rebuildForExercise(row.read<String>('exercise_id'));
    }
  }

  /// [rebuildForExercise] for whichever exercise [setId] belongs to — the
  /// call a set-row delete/restore/edit site makes, so it never has to thread
  /// an exercise id through just to invalidate the cache correctly
  /// (§4 rule 4). Works even on an already-tombstoned set: the foreign key to
  /// `workout_exercises` survives a soft delete.
  Future<void> rebuildForSet(String setId) async {
    final exerciseId = await _exerciseIdForSet(setId);
    if (exerciseId == null) return;
    await rebuildForExercise(exerciseId);
  }

  Future<String?> _exerciseIdForSet(String setId) async {
    final row = await _db
        .customSelect(
          '''
          SELECT we.exercise_id AS exercise_id
            FROM sets s
            JOIN workout_exercises we ON we.id = s.workout_exercise_id
           WHERE s.id = ?
          ''',
          variables: [Variable<String>(setId)],
          readsFrom: {_db.sets, _db.workoutExercises},
        )
        .getSingleOrNull();
    return row?.read<String>('exercise_id');
  }

  Future<void> _insert({
    required String exerciseId,
    required PrDetectionKind kind,
    required int? qualifier,
    required _Winner winner,
  }) {
    return _db
        .into(_db.personalRecords)
        .insert(
          PersonalRecordsCompanion.insert(
            id: newUuidV4(),
            exerciseId: exerciseId,
            kind: _toDataKind(kind),
            qualifier: Value(qualifier),
            value: winner.value,
            setId: Value(winner.setId),
            workoutId: Value(winner.workoutId),
            achievedAt: winner.achievedAt,
            createdAt: _now,
            updatedAt: _now,
          ),
        );
  }

  Future<void> _replaceRecord({
    required String exerciseId,
    required PrDetectionKind kind,
    required int? qualifier,
    required int value,
    required String? setId,
    required String workoutId,
    required int achievedAt,
  }) {
    return _db.transaction(() async {
      var query = _db.update(_db.personalRecords)
        ..where((p) => p.exerciseId.equals(exerciseId))
        ..where((p) => p.kind.equalsValue(_toDataKind(kind)))
        ..where((p) => p.deletedAt.isNull());
      query = qualifier == null
          ? (query..where((p) => p.qualifier.isNull()))
          : (query..where((p) => p.qualifier.equals(qualifier)));
      await query.write(PersonalRecordsCompanion(deletedAt: Value(_now)));

      await _db
          .into(_db.personalRecords)
          .insert(
            PersonalRecordsCompanion.insert(
              id: newUuidV4(),
              exerciseId: exerciseId,
              kind: _toDataKind(kind),
              qualifier: Value(qualifier),
              value: value,
              setId: Value(setId),
              workoutId: Value(workoutId),
              achievedAt: achievedAt,
              createdAt: _now,
              updatedAt: _now,
            ),
          );
    });
  }

  Future<bool> _hasNoPriorCountedSet(
    String exerciseId, {
    required String excludingSetId,
  }) async {
    final row = await _db
        .customSelect(
          '''
          SELECT COUNT(*) AS n
            FROM sets s
            JOIN workout_exercises we ON we.id = s.workout_exercise_id
            JOIN workouts w           ON w.id  = we.workout_id
           WHERE we.exercise_id = ?
             AND s.id != ?
             AND we.deleted_at IS NULL
             AND w.deleted_at IS NULL
             AND s.deleted_at IS NULL
             AND s.is_completed = 1
             AND s.set_type != 'warmup'
             AND s.weight_grams IS NOT NULL
             AND s.reps IS NOT NULL
          ''',
          variables: [
            Variable<String>(exerciseId),
            Variable<String>(excludingSetId),
          ],
          readsFrom: {_db.sets, _db.workoutExercises, _db.workouts},
        )
        .getSingle();
    return row.read<int>('n') == 0;
  }

  Future<int> _sessionVolumeGrams(String workoutId, String exerciseId) async {
    final row = await _db
        .customSelect(
          '''
          SELECT COALESCE(SUM(s.weight_grams * s.reps), 0) AS volume
            FROM sets s
            JOIN workout_exercises we ON we.id = s.workout_exercise_id
           WHERE we.workout_id = ? AND we.exercise_id = ?
             AND we.deleted_at IS NULL
             AND s.deleted_at IS NULL
             AND s.is_completed = 1
             AND s.set_type != 'warmup'
             AND s.weight_grams IS NOT NULL
             AND s.reps IS NOT NULL
          ''',
          variables: [
            Variable<String>(workoutId),
            Variable<String>(exerciseId),
          ],
          readsFrom: {_db.sets, _db.workoutExercises},
        )
        .getSingle();
    return row.read<int>('volume');
  }

  Future<ExistingPrs> _existingFor(String exerciseId, int weightGrams) async {
    final rows =
        await (_db.select(_db.personalRecords)
              ..where((p) => p.exerciseId.equals(exerciseId))
              ..where((p) => p.deletedAt.isNull()))
            .get();

    int? maxWeight;
    int? bestE1rm;
    int? maxSessionVolume;
    int? repsAtThisWeight;
    for (final row in rows) {
      switch (row.kind) {
        case PrKind.maxWeight:
          maxWeight = row.value;
        case PrKind.bestE1rm:
          bestE1rm = row.value;
        case PrKind.maxSessionVolume:
          maxSessionVolume = row.value;
        case PrKind.maxRepsAtWeight:
          if (row.qualifier == weightGrams) repsAtThisWeight = row.value;
      }
    }
    return ExistingPrs(
      maxWeightGrams: maxWeight,
      existingMaxRepsAtThisWeight: repsAtThisWeight,
      bestE1rmGrams: bestE1rm,
      maxSessionVolumeGrams: maxSessionVolume,
    );
  }

  Future<_Candidate?> _candidateFor(String setId) async {
    final row = await _db
        .customSelect(
          '''
          SELECT s.weight_grams    AS weight_grams,
                 s.reps            AS reps,
                 s.completed_at    AS achieved_at,
                 s.set_type        AS set_type,
                 s.is_completed    AS is_completed,
                 s.deleted_at      AS set_deleted_at,
                 we.exercise_id    AS exercise_id,
                 we.workout_id     AS workout_id,
                 we.deleted_at     AS we_deleted_at,
                 w.deleted_at      AS workout_deleted_at,
                 e.tracking_type   AS tracking_type
            FROM sets s
            JOIN workout_exercises we ON we.id = s.workout_exercise_id
            JOIN workouts w           ON w.id  = we.workout_id
            JOIN exercises e          ON e.id  = we.exercise_id
           WHERE s.id = ?
          ''',
          variables: [Variable<String>(setId)],
          readsFrom: {
            _db.sets,
            _db.workoutExercises,
            _db.workouts,
            _db.exercises,
          },
        )
        .getSingleOrNull();
    if (row == null) return null;

    if (row.read<int>('is_completed') != 1) return null;
    if (row.read<String>('set_type') == 'warmup') return null;
    if (row.read<int?>('set_deleted_at') != null) return null;
    if (row.read<int?>('we_deleted_at') != null) return null;
    if (row.read<int?>('workout_deleted_at') != null) return null;
    if (row.read<String>('tracking_type') != 'weightReps') return null;

    final weightGrams = row.read<int?>('weight_grams');
    final reps = row.read<int?>('reps');
    if (weightGrams == null || reps == null) return null;

    return _Candidate(
      exerciseId: row.read<String>('exercise_id'),
      workoutId: row.read<String>('workout_id'),
      weightGrams: weightGrams,
      reps: reps,
      achievedAt: row.read<int?>('achieved_at') ?? _now,
    );
  }
}

PrKind _toDataKind(PrDetectionKind kind) => switch (kind) {
  PrDetectionKind.maxWeight => PrKind.maxWeight,
  PrDetectionKind.maxRepsAtWeight => PrKind.maxRepsAtWeight,
  PrDetectionKind.bestE1rm => PrKind.bestE1rm,
  PrDetectionKind.maxSessionVolume => PrKind.maxSessionVolume,
};

class _Candidate {
  const _Candidate({
    required this.exerciseId,
    required this.workoutId,
    required this.weightGrams,
    required this.reps,
    required this.achievedAt,
  });

  final String exerciseId;
  final String workoutId;
  final int weightGrams;
  final int reps;
  final int achievedAt;
}

class _Winner {
  const _Winner({
    required this.value,
    required this.setId,
    required this.workoutId,
    required this.achievedAt,
  });

  final int value;
  final String? setId;
  final String workoutId;
  final int achievedAt;
}
