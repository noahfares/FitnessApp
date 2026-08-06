import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';

/// Phase 0 exit criterion: "database created at v1 with a passing migration
/// test".
///
/// These assert the invariants from ADR-0003 and ADR-0008 hold in the schema
/// itself, not just in the documents. Every one of them is expensive or
/// impossible to fix once real training history exists.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Every table in the schema, so new ones cannot skip the universal columns.
  List<TableInfo> allTables() => db.allTables.toList();

  group('creation at the current version', () {
    test('opens and creates every table', () async {
      await db.customSelect('SELECT 1').get(); // force open

      // Migrations from earlier versions are covered in migration_test.dart.
      expect(db.schemaVersion, 2);
      expect(allTables(), hasLength(13));

      final names = allTables().map((t) => t.actualTableName).toSet();
      expect(
        names,
        containsAll([
          'exercises',
          'bars',
          'plates',
          'routine_folders',
          'routines',
          'routine_days',
          'routine_exercises',
          'workouts',
          'workout_exercises',
          'sets',
          'body_measurements',
          'personal_records',
          'app_settings',
        ]),
      );
    });

    test('indexes exist, including the ghost-value path', () async {
      await db.customSelect('SELECT 1').get();
      final indexes = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
          .get();
      final names = indexes.map((r) => r.read<String>('name')).toSet();

      // F-LOG-004 runs on every exercise open with a sub-50ms budget.
      expect(names, contains('idx_sets_workout_exercise'));
      expect(names, contains('idx_workouts_in_progress'));
      expect(names, contains('idx_workouts_started'));
    });

    test('foreign keys are actually enforced, not just declared', () async {
      // SQLite disables them per connection by default, so a declared reference
      // is documentation until the PRAGMA is set in beforeOpen.
      final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(result.data.values.first, 1);

      await expectLater(
        db
            .into(db.routineDays)
            .insert(
              RoutineDaysCompanion.insert(
                id: 'day-1',
                routineId: 'does-not-exist',
                name: 'Push',
                position: 0,
                createdAt: 0,
                updatedAt: 0,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('ADR-0008 — sync-ready foundations on every table', () {
    test('every table carries the universal columns', () async {
      for (final table in allTables()) {
        final columns = table.$columns.map((c) => c.name).toSet();
        for (final required in [
          'id',
          'user_id',
          'created_at',
          'updated_at',
          'deleted_at',
        ]) {
          expect(
            columns,
            contains(required),
            reason: '${table.actualTableName} is missing $required',
          );
        }
      }
    });

    test('every primary key is a text UUID, never an integer', () async {
      for (final table in allTables()) {
        final pk = table.$primaryKey;
        expect(pk, hasLength(1), reason: table.actualTableName);
        expect(
          pk.single.type,
          DriftSqlType.string,
          reason:
              '${table.actualTableName} must use a UUID primary key so IDs '
              'can be generated before the insert completes',
        );
      }
    });

    test('user_id defaults to the local constant', () async {
      await _insertExercise(db, id: 'ex-1');
      final row = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('ex-1'))).getSingle();
      expect(row.userId, 'local-user');
    });
  });

  group('timezone offsets are stored beside UTC', () {
    test('workouts and sets carry an offset column', () async {
      final workoutColumns = db.workouts.$columns.map((c) => c.name).toSet();
      expect(workoutColumns, contains('started_at_tz_offset_minutes'));

      final setColumns = db.sets.$columns.map((c) => c.name).toSet();
      expect(setColumns, contains('completed_at_tz_offset_minutes'));
    });

    test('a session keeps the local offset it was recorded with', () async {
      // 22:00 in UTC+10 is not the next day. Reconstructing that from UTC alone
      // is impossible, which is why the offset is captured at write time.
      await _insertWorkout(db, id: 'w-1', offsetMinutes: 600);
      final row = await (db.select(
        db.workouts,
      )..where((w) => w.id.equals('w-1'))).getSingle();
      expect(row.startedAtTzOffsetMinutes, 600);
    });
  });

  group('ADR-0003 — canonical units', () {
    test('every weight column is an integer, never a real', () async {
      final weightColumns = <String, GeneratedColumn>{
        'sets.weight_grams': db.sets.weightGrams,
        'routine_exercises.target_weight_grams':
            db.routineExercises.targetWeightGrams,
        'workouts.bodyweight_grams': db.workouts.bodyweightGrams,
        'bars.weight_grams': db.bars.weightGrams,
        'plates.weight_grams': db.plates.weightGrams,
        'body_measurements.value_canonical': db.bodyMeasurements.valueCanonical,
      };

      weightColumns.forEach((name, column) {
        expect(
          column.type,
          DriftSqlType.int,
          reason:
              '$name must be integer grams — a double drifts under repeated '
              '+2.5 kg increments (ADR-0003)',
        );
      });
    });

    test('there is no per-row unit column anywhere', () async {
      for (final table in allTables()) {
        for (final column in table.$columns) {
          expect(
            column.name,
            isNot(anyOf('unit', 'units', 'weight_unit')),
            reason:
                '${table.actualTableName}.${column.name} — units are a '
                'display concern, never stored per row',
          );
        }
      }
    });
  });

  group('set types', () {
    test('default is working, and warmup is representable from v1', () async {
      await _insertExercise(db, id: 'ex-1');
      await _insertWorkout(db, id: 'w-1');
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: 'we-1',
              workoutId: 'w-1',
              exerciseId: 'ex-1',
              position: 0,
              createdAt: 0,
              updatedAt: 0,
            ),
          );

      await db
          .into(db.sets)
          .insert(
            SetsCompanion.insert(
              id: 's-1',
              workoutExerciseId: 'we-1',
              position: 0,
              createdAt: 0,
              updatedAt: 0,
            ),
          );
      await db
          .into(db.sets)
          .insert(
            SetsCompanion.insert(
              id: 's-2',
              workoutExerciseId: 'we-1',
              position: 1,
              setType: const Value(SetType.warmup),
              createdAt: 0,
              updatedAt: 0,
            ),
          );

      final rows = await db.select(db.sets).get();
      expect(rows.firstWhere((s) => s.id == 's-1').setType, SetType.working);
      expect(rows.firstWhere((s) => s.id == 's-2').setType, SetType.warmup);
    });

    test('all six types round-trip', () async {
      // Stored by name, so reordering the Dart enum cannot silently reassign
      // historical rows.
      for (final type in SetType.values) {
        expect(SetType.values.byName(type.name), type);
      }
      expect(SetType.values, hasLength(6));
    });
  });

  group('soft delete', () {
    test('deleting sets a tombstone rather than removing the row', () async {
      await _insertExercise(db, id: 'ex-1');

      await (db.update(db.exercises)..where((e) => e.id.equals('ex-1'))).write(
        const ExercisesCompanion(deletedAt: Value(1234)),
      );

      // Still physically present — that is what makes undo a field update
      // (`F-LOG-022`) rather than a resurrection problem.
      final all = await db.select(db.exercises).get();
      expect(all, hasLength(1));
      expect(all.single.deletedAt, 1234);

      final live = await (db.select(
        db.exercises,
      )..where((e) => e.deletedAt.isNull())).get();
      expect(live, isEmpty);
    });
  });

  group('nullable measurements', () {
    test('all four set measurement columns are nullable', () async {
      // Not every exercise is weight x reps. Planks are time, running is
      // distance. Making these nullable in v1 means adding a tracking type
      // later needs no migration.
      for (final column in [
        db.sets.weightGrams,
        db.sets.reps,
        db.sets.durationSeconds,
        db.sets.distanceMetres,
        db.sets.rpe,
      ]) {
        expect(column.$nullable, isTrue, reason: column.name);
      }
    });
  });
}

Future<void> _insertExercise(AppDatabase db, {required String id}) {
  return db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: 'Bench Press',
          primaryMuscle: Muscle.chest,
          equipment: Equipment.barbell,
          trackingType: TrackingType.weightReps,
          createdAt: 0,
          updatedAt: 0,
        ),
      );
}

Future<void> _insertWorkout(
  AppDatabase db, {
  required String id,
  int offsetMinutes = 0,
}) {
  return db
      .into(db.workouts)
      .insert(
        WorkoutsCompanion.insert(
          id: id,
          name: 'Push',
          startedAt: 1000,
          startedAtTzOffsetMinutes: offsetMinutes,
          createdAt: 0,
          updatedAt: 0,
        ),
      );
}
