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
  int get schemaVersion => 2;

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
