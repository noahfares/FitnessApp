import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/analytics/presentation/consistency_screen.dart';
import 'package:fitness_app/features/analytics/presentation/insights_screen.dart';
import 'package:fitness_app/features/analytics/presentation/pr_timeline_screen.dart';

import '../../support/harness.dart';

/// F-A11Y-002 — the three analytics screens `ExerciseDetailScreen` didn't
/// already cover in batch 6.1: consistency's heatmap-plus-stats, the PR
/// timeline list, and Insights' stack of chart sections.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the consistency screen, with a logged session, renders at 200% '
      'with no overflow', (tester) async {
    final db = testDatabase();
    final clock = DateTime(2026, 7, 15);
    final workouts = WorkoutRepository(db, clock: () => clock);
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
    await workouts.finish(workout.id);

    await pumpScreen(
      tester,
      const ConsistencyScreen(),
      db: db,
      now: clock,
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'the PR timeline, with a record, renders at 200% with no overflow',
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
        const PrTimelineScreen(),
        db: db,
        now: clock,
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'insights, with a logged session, renders at 200% with no overflow',
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
              secondaryMuscles: const Value(['triceps']),
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

      await pumpScreen(
        tester,
        const InsightsScreen(),
        db: db,
        now: clock,
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
    },
  );
}
