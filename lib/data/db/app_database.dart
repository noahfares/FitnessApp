import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/catalog_tables.dart';
// Enum types and type converters are referenced by the generated part file,
// which resolves them through this library rather than through the table files.
// Both look unused here; removing either breaks code generation.
import 'tables/enums.dart';
import 'tables/routine_tables.dart';
import 'tables/shared.dart';
import 'tables/workout_tables.dart';

part 'app_database.g.dart';

/// The application database (docs/21-DATA-MODEL.md).
///
/// Everything the app knows lives here, including in-progress sessions:
/// persistence is **write-through**, so the database *is* the session state
/// rather than a mirror of it. That is what makes crash recovery a query
/// (`F-LOG-007`) instead of a serialised-state restore.
@DriftDatabase(
  tables: [
    Exercises,
    Bars,
    Plates,
    RoutineFolders,
    Routines,
    RoutineDays,
    RoutineExercises,
    Workouts,
    WorkoutExercises,
    Sets,
    BodyMeasurements,
    PersonalRecords,
    AppSettings,
    ProgressPhotos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'fitness_app'));

  /// Bump in the same commit as any schema change, alongside `VERSION`.
  ///
  /// A shipped migration is **never edited** — fix forward with a new one. Every
  /// migration gets a test that opens a database at version *n*, migrates, and
  /// asserts on the *data*, not merely that nothing threw
  /// (docs/60-ENGINEERING.md §schema changes).
  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
    },
    onUpgrade: (m, from, to) async {
      // Each step is an explicit block, never edited once shipped, and covered
      // by its own test in test/data/db/migration_test.dart.
      if (from < 2) {
        // exercises.seed_updated_at — makes "the user edited this seeded row"
        // decidable across repeated re-seeds (F-CAT-001).
        await m.addColumn(exercises, exercises.seedUpdatedAt);
      }
      if (from < 3) {
        // At most one workout may be in progress (`F-LOG-001` §3). The new
        // partial unique index in _createIndexes() enforces it, but it cannot
        // be created while duplicates exist — and a database written before
        // the constraint could hold several. Close out all but the most
        // recently started first, rather than failing to open.
        await customStatement('''
          UPDATE workouts
             SET ended_at = started_at,
                 updated_at = CAST(strftime('%s', 'now') AS INTEGER) * 1000
           WHERE ended_at IS NULL
             AND deleted_at IS NULL
             AND id NOT IN (
                   SELECT id FROM workouts
                    WHERE ended_at IS NULL AND deleted_at IS NULL
                    ORDER BY started_at DESC
                    LIMIT 1
                 )
        ''');
      }
      if (from < 4) {
        // Per-exercise weight source — plate-loaded, fixed dumbbells, or a
        // weight stack (`F-PLT-005`). Existing rows default to `plateLoaded`,
        // which is exactly how every exercise behaved before this column
        // existed, so no backfill is needed.
        await m.addColumn(exercises, exercises.weightSource);
        await m.addColumn(exercises, exercises.fixedIncrementsGrams);
        await m.addColumn(exercises, exercises.stackBaseGrams);
        await m.addColumn(exercises, exercises.stackStepGrams);
        await m.addColumn(exercises, exercises.stackHalfStepGrams);
      }
      if (from < 5) {
        // Per-exercise warm-up ramp override (`F-LOG-020`). Null on every
        // existing row, which falls through to the app-wide default ramp —
        // no exercise behaved any differently before this column existed.
        await m.addColumn(exercises, exercises.warmupRuleset);
      }
      if (from < 6) {
        // Training max for percentage-based progression (`F-PRG-010`). Null
        // on every existing row — a percentage-based rule can't be assigned
        // to an exercise without one anyway, so nothing behaves differently
        // before this column is ever set.
        await m.addColumn(exercises, exercises.trainingMaxGrams);
      }
      if (from < 7) {
        // Progress photos (`F-BOD-004`) — a new table, nothing to backfill.
        await m.createTable(progressPhotos);
      }
      if (from < 8) {
        // Configurable rest between superset members (`F-ROU-005` §3).
        // Null on every existing row, which is exactly how supersets behaved
        // before the column existed: no pause between members at all.
        await m.addColumn(
          routineExercises,
          routineExercises.withinGroupRestSeconds,
        );
        await m.addColumn(
          workoutExercises,
          workoutExercises.withinGroupRestSeconds,
        );
      }
      await _createIndexes();
    },
    beforeOpen: (details) async {
      // Foreign keys are off by default in SQLite and must be enabled per
      // connection, not once at creation. Without this, the references declared
      // above are documentation rather than constraints.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createIndexes() async {
    // The ghost-value query (`F-LOG-004`): "most recent completed sets for
    // exercise X". Runs on every exercise open, is the app's hottest path, and
    // has a sub-50ms budget over years of history
    // (docs/60-ENGINEERING.md §performance budgets).
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sets_workout_exercise '
      'ON sets (workout_exercise_id, position) WHERE deleted_at IS NULL',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sets_completed '
      'ON sets (completed_at) WHERE deleted_at IS NULL AND is_completed = 1',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workout_exercises_exercise '
      'ON workout_exercises (exercise_id) WHERE deleted_at IS NULL',
    );
    // History and calendar views order by this constantly.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workouts_started '
      'ON workouts (started_at) WHERE deleted_at IS NULL',
    );
    // Resolving the single in-progress session on launch.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workouts_in_progress '
      'ON workouts (ended_at) WHERE ended_at IS NULL AND deleted_at IS NULL',
    );
    // **The** single-in-progress constraint (`F-LOG-001` §3). In the database
    // rather than only in the repository, because a second in-progress workout
    // does not fail loudly — it makes crash recovery pick one of two sessions
    // at random, which surfaces as "the app lost my workout".
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_workouts_single_in_progress '
      'ON workouts (user_id) WHERE ended_at IS NULL AND deleted_at IS NULL',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_exercises_name '
      'ON exercises (name) WHERE deleted_at IS NULL',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_measurements_type_date '
      'ON body_measurements (type, measured_at) WHERE deleted_at IS NULL',
    );
  }
}
