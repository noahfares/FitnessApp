import 'package:drift/drift.dart';

import 'catalog_tables.dart';
import 'enums.dart';
import 'routine_tables.dart';
import 'shared.dart';

/// A performed training session.
///
/// **Snapshots its routine day at start** (ADR-0004): [sourceRoutineDayId] is
/// weak provenance only and is never read to render the session. Without that,
/// editing a routine would silently rewrite months of history.
class Workouts extends Table with SyncColumns {
  TextColumn get name => text()();

  /// Provenance only. Nullable, and never used for display.
  TextColumn get sourceRoutineDayId => text()
      .named('source_routine_day_id')
      .nullable()
      .references(RoutineDays, #id)();

  /// UTC epoch milliseconds.
  IntColumn get startedAt => integer().named('started_at')();

  /// Local UTC offset in minutes at the moment of starting (ADR-0008).
  ///
  /// Determines the session's **local** calendar date, which is what every
  /// weekly aggregate and streak groups by. A 22:00 session in UTC+10 is not
  /// the next day, and this cannot be reconstructed from UTC alone.
  IntColumn get startedAtTzOffsetMinutes =>
      integer().named('started_at_tz_offset_minutes')();

  /// Null = in progress. At most one row may be null at a time (`F-LOG-007`),
  /// which is what makes crash recovery a query rather than a state restore.
  IntColumn get endedAt => integer().named('ended_at').nullable()();

  TextColumn get notes => text().nullable()();

  /// Captured at session time; needed for bodyweight-loaded exercises
  /// (`F-LOG-019`).
  IntColumn get bodyweightGrams =>
      integer().named('bodyweight_grams').nullable()();

  IntColumn get perceivedFatigue =>
      integer().named('perceived_fatigue').nullable()();
}

/// An exercise as performed within a session — the snapshot, not a reference.
class WorkoutExercises extends Table with SyncColumns {
  TextColumn get workoutId =>
      text().named('workout_id').references(Workouts, #id)();

  TextColumn get exerciseId =>
      text().named('exercise_id').references(Exercises, #id)();

  IntColumn get position => integer()();

  /// Snapshotted superset grouping.
  TextColumn get groupId => text().named('group_id').nullable()();

  /// Session-specific, distinct from the exercise's persistent sticky note.
  TextColumn get notes => text().nullable()();

  /// JSON of the routine targets as they were at start — what progression
  /// proposed, kept so it can be audited against what actually happened
  /// (`F-PRG-008`).
  TextColumn get targetSnapshot => text().named('target_snapshot').nullable()();
}

/// The hot table. Everything else exists to give these rows meaning.
///
/// **Row per set, never a JSON blob**: any query like "best 5-rep squat" is
/// otherwise impossible.
///
/// The row class is named `WorkoutSet` rather than drift's default `Set`, which
/// would shadow `dart:core`'s `Set<T>` throughout the generated code.
@DataClassName('WorkoutSet')
class Sets extends Table with SyncColumns {
  TextColumn get workoutExerciseId =>
      text().named('workout_exercise_id').references(WorkoutExercises, #id)();

  IntColumn get position => integer()();

  /// **Only `warmup` is excluded from analytics.** Must exist in v1: the
  /// information cannot be recovered later, and without it every volume, PR and
  /// e1RM figure is quietly wrong from the first session.
  TextColumn get setType => textEnum<SetType>()
      .named('set_type')
      .withDefault(const Constant('working'))();

  /// Canonical grams, and **always total load** — per-side entry is converted
  /// on input (`F-LOG-017`).
  IntColumn get weightGrams => integer().named('weight_grams').nullable()();

  IntColumn get reps => integer().nullable()();

  /// 6.0-10.0 in 0.5 steps (`F-LOG-014`). Nullable, and Phase 1 never populates
  /// it — but the column exists from v1, because a year of missing RPE cannot
  /// be backfilled.
  RealColumn get rpe => real().nullable()();

  IntColumn get distanceMetres =>
      integer().named('distance_metres').nullable()();

  IntColumn get durationSeconds =>
      integer().named('duration_seconds').nullable()();

  /// A row may exist as a planned-but-unfinished target. Incomplete sets are
  /// excluded from analytics.
  BoolColumn get isCompleted =>
      boolean().named('is_completed').withDefault(const Constant(false))();

  /// **The only way to derive actual rest intervals after the fact**
  /// (`F-TIM-007`).
  IntColumn get completedAt => integer().named('completed_at').nullable()();

  IntColumn get completedAtTzOffsetMinutes =>
      integer().named('completed_at_tz_offset_minutes').nullable()();

  IntColumn get restTakenSeconds =>
      integer().named('rest_taken_seconds').nullable()();

  /// Free text per set (`F-LOG-023`). The catch-all for what the schema did not
  /// anticipate — "left shoulder twinged", "belt too loose". Unrecoverable: the
  /// observation exists for about ten seconds and then it is gone.
  TextColumn get notes => text().nullable()();
}

/// Bodyweight and circumferences (`F-BOD-001`, `F-BOD-002`).
class BodyMeasurements extends Table with SyncColumns {
  IntColumn get measuredAt => integer().named('measured_at')();

  IntColumn get measuredAtTzOffsetMinutes =>
      integer().named('measured_at_tz_offset_minutes')();

  TextColumn get type => textEnum<MeasurementType>()();

  /// Grams for masses, millimetres for lengths, basis points for percentages —
  /// fixed per [type], never ambiguous.
  IntColumn get valueCanonical => integer().named('value_canonical')();

  TextColumn get notes => text().nullable()();
}

/// A **cache**, never a source of truth.
///
/// Rebuildable from `sets` at any time, and a maintenance action to do so must
/// exist — any bug here is otherwise permanent. Never patched incrementally on
/// delete: a patch can only ever demote incorrectly.
class PersonalRecords extends Table with SyncColumns {
  TextColumn get exerciseId =>
      text().named('exercise_id').references(Exercises, #id)();

  TextColumn get kind => textEnum<PrKind>()();

  /// For `maxRepsAtWeight`, the weight in grams.
  IntColumn get qualifier => integer().nullable()();

  IntColumn get value => integer()();

  TextColumn get setId =>
      text().named('set_id').nullable().references(Sets, #id)();

  TextColumn get workoutId =>
      text().named('workout_id').nullable().references(Workouts, #id)();

  IntColumn get achievedAt => integer().named('achieved_at')();
}

/// Single-row table for structured settings.
///
/// Scalars live in `SharedPreferences`; anything relational lives here.
class AppSettings extends Table with SyncColumns {
  TextColumn get key => text()();

  TextColumn get value => text()();
}
