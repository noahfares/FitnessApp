import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/history/presentation/edit_past_workout_screen.dart';
import 'package:fitness_app/features/history/presentation/history_screen.dart';
import 'package:fitness_app/features/history/presentation/workout_detail_screen.dart';

import '../../support/harness.dart';

/// F-A11Y-002 — history's month grouping, the set-by-set detail view, and
/// the full past-workout editor are dense enough that each earns its own
/// 200%-scale check rather than trusting the active-workout screen's proof
/// to generalise.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<({AppDatabase db, String workoutId})> aFinishedWorkout() async {
    final db = testDatabase();
    final clock = DateTime(2026, 7, 20, 18, 0);
    final workouts = WorkoutRepository(db, clock: () => clock);
    final sets = SetRepository(db, clock: () => clock);

    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'bench',
            name: 'Bench Press',
            primaryMuscle: Muscle.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    final workout = await workouts.start(name: 'Push A');
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
    await workouts.finish(workout.id);

    return (db: db, workoutId: workout.id);
  }

  testWidgets('the month-grouped list renders at 200% with no overflow', (
    tester,
  ) async {
    final fixture = await aFinishedWorkout();

    await pumpScreen(
      tester,
      const HistoryScreen(),
      db: fixture.db,
      now: DateTime(2026, 7, 20),
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('workout detail renders at 200% with no overflow', (
    tester,
  ) async {
    final fixture = await aFinishedWorkout();

    await pumpScreen(
      tester,
      WorkoutDetailScreen(workoutId: fixture.workoutId),
      db: fixture.db,
      now: DateTime(2026, 7, 20),
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the past-workout editor renders at 200% with no overflow', (
    tester,
  ) async {
    final fixture = await aFinishedWorkout();

    await pumpScreen(
      tester,
      EditPastWorkoutScreen(workoutId: fixture.workoutId),
      db: fixture.db,
      now: DateTime(2026, 7, 20),
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });
}
