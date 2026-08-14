import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/routine_repository.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/shell/presentation/dashboard_screen.dart';

import '../../support/harness.dart';

/// F-A11Y-002 — the dashboard stacks several independent cards (today's
/// schedule, resume/start, recent workouts, weekly insights); each one needs
/// to keep its own shape at 200% rather than the page as a whole merely not
/// crashing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a scheduled day, a finished workout and a completed set render '
      'together with no overflow', (tester) async {
    final db = testDatabase();
    final clock = DateTime(2026, 8, 5); // a Wednesday
    final routines = RoutineRepository(db, clock: () => clock);
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

    final routine = await routines.create(name: 'Push Pull Legs');
    final day = await routines.addDay(routine.id, name: 'Push');
    await routines.setScheduledWeekdays(day.id, [3]);

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

    await pumpScreen(
      tester,
      const DashboardScreen(),
      db: db,
      now: clock,
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });
}
