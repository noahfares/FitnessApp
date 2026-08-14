import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/logging/presentation/session_summary_screen.dart';
import 'package:fitness_app/features/logging/presentation/start_workout_screen.dart';

import '../../support/harness.dart';

/// F-A11Y-002 — `active_workout_text_scale_test.dart` already covers the
/// densest logging screen; this rounds out the other two — starting a
/// session, and its finish summary, including a celebrated PR.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('starting a workout renders at 200% with no overflow', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const StartWorkoutScreen(),
      db: testDatabase(),
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'the finish summary, with a PR, renders at 200% with no overflow',
    (tester) async {
      final db = testDatabase();
      final clock = DateTime(2026, 7, 15);
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
      await workouts.finish(workout.id);

      await pumpScreen(
        tester,
        SessionSummaryScreen(workoutId: workout.id),
        db: db,
        now: clock,
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
    },
  );
}
