import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/analytics/presentation/consistency_screen.dart';
import 'package:fitness_app/features/shell/widgets/calendar_heatmap.dart';

import '../../support/harness.dart';

/// Batch 3.4 — `F-ANA-006` reached through the real `ConsistencyScreen`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  final clock = DateTime(2026, 8, 7);

  setUp(() {
    db = testDatabase();
    workouts = WorkoutRepository(db, clock: () => clock);
    sets = SetRepository(db, clock: () => clock);
  });

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

  testWidgets('renders the heatmap and stat tiles for a logged session', (
    tester,
  ) async {
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

    await pumpScreen(tester, const ConsistencyScreen(), db: db, now: clock);

    expect(find.byType(CalendarHeatmap), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('Sessions / week'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no sessions still renders without throwing', (tester) async {
    await pumpScreen(tester, const ConsistencyScreen(), db: db, now: clock);
    expect(tester.takeException(), isNull);
  });
}
