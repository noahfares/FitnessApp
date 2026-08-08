import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';

/// Batch 3.3 — `SetRepository.watchAllAnalyticsSets` (`F-ANA-004`, `F-ANA-005`).
void main() {
  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  var clock = DateTime(2026, 8, 3, 18, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 8, 3, 18, 30);
    workouts = WorkoutRepository(db, clock: () => clock);
    sets = SetRepository(db, clock: () => clock);
  });
  tearDown(() => db.close());

  Future<void> makeExercise(
    String id, {
    List<String> secondaryMuscles = const [],
  }) => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: id,
          primaryMuscle: Muscle.chest,
          secondaryMuscles: Value(secondaryMuscles),
          equipment: Equipment.barbell,
          trackingType: TrackingType.weightReps,
          createdAt: 1,
          updatedAt: 1,
        ),
      );

  test('carries muscle attribution and the local session date', () async {
    await makeExercise('bench', secondaryMuscles: const ['triceps']);
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, ['bench']);
    final we = (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
    final set = (await sets.getSets(we)).single;
    await sets.complete(
      set.id,
      weightGrams: const Value(100000),
      reps: const Value(5),
    );

    final records = await sets.watchAllAnalyticsSets().first;

    expect(records, hasLength(1));
    expect(records.single.primaryMuscle, 'chest');
    expect(records.single.secondaryMuscles, ['triceps']);
    expect(records.single.date, DateTime(2026, 8, 3));
    expect(records.single.weightGrams, 100000);
    expect(records.single.reps, 5);
  });

  test('excludes sets whose exercise has been deleted', () async {
    await makeExercise('bench');
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, ['bench']);
    final we = (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
    final set = (await sets.getSets(we)).single;
    await sets.complete(
      set.id,
      weightGrams: const Value(100000),
      reps: const Value(5),
    );

    await (db.update(db.exercises)..where((e) => e.id.equals('bench'))).write(
      ExercisesCompanion(deletedAt: Value(clock.millisecondsSinceEpoch)),
    );

    expect(await sets.watchAllAnalyticsSets().first, isEmpty);
  });
}
