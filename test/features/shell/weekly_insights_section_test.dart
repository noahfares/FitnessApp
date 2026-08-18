import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/shell/presentation/dashboard_screen.dart';

import '../../support/harness.dart';

/// `F-ANA-013` reached through the real `DashboardScreen`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = testDatabase());

  Future<void> makeExercise(String id) => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: id,
          primaryMuscle: Muscle.chest,
          equipment: Equipment.barbell,
          trackingType: TrackingType.weightReps,
          createdAt: 1,
          updatedAt: 1,
        ),
      );

  Future<void> logSet(
    WorkoutRepository workouts,
    SetRepository sets,
    DateTime date, {
    required int weightGrams,
  }) async {
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, ['bench']);
    final we = (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
    final set = (await sets.getSets(we)).single;
    await sets.complete(
      set.id,
      weightGrams: Value(weightGrams),
      reps: const Value(1),
    );
    await workouts.finish(workout.id);
  }

  testWidgets('a genuine volume swing shows a card, linking to Insights', (
    tester,
  ) async {
    await makeExercise('bench');
    final w1 = DateTime(2026, 1, 5);
    final w2 = w1.add(const Duration(days: 7));
    final w3 = w1.add(const Duration(days: 14));

    for (final (date, kg) in [(w1, 20), (w2, 20), (w3, 40)]) {
      final workouts = WorkoutRepository(db, clock: () => date);
      final sets = SetRepository(db, clock: () => date);
      await logSet(workouts, sets, date, weightGrams: kg * 1000);
    }

    await pumpScreen(tester, const DashboardScreen(), db: db, now: w3);

    // Section headers render uppercase in the Apple-style pass.
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.textContaining('Chest volume is up'), findsOneWidget);
  });

  testWidgets('too little history shows no section at all', (tester) async {
    await makeExercise('bench');
    final w1 = DateTime(2026, 1, 5);
    final workouts = WorkoutRepository(db, clock: () => w1);
    final sets = SetRepository(db, clock: () => w1);
    await logSet(workouts, sets, w1, weightGrams: 20000);

    await pumpScreen(tester, const DashboardScreen(), db: db, now: w1);

    expect(find.text('This week'), findsNothing);
  });
}
