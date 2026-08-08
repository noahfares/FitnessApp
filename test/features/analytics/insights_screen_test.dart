import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/analytics/presentation/insights_screen.dart';
import 'package:fitness_app/features/shell/widgets/weekly_bar_chart.dart';

import '../../support/harness.dart';

/// Batch 3.3 — `F-ANA-004`/`F-ANA-005` reached through the real
/// `InsightsScreen`, complementing the domain-level fixture tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  final clock = DateTime(2026, 7, 15);

  setUp(() {
    db = testDatabase();
    workouts = WorkoutRepository(db, clock: () => clock);
    sets = SetRepository(db, clock: () => clock);
  });

  Future<void> makeExercise(
    String id, {
    Muscle primaryMuscle = Muscle.chest,
    List<String> secondaryMuscles = const [],
  }) => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: id,
          primaryMuscle: primaryMuscle,
          secondaryMuscles: Value(secondaryMuscles),
          equipment: Equipment.barbell,
          trackingType: TrackingType.weightReps,
          createdAt: 1,
          updatedAt: 1,
        ),
      );

  testWidgets('no sessions shows the empty state', (tester) async {
    await pumpScreen(tester, const InsightsScreen(), db: db, now: clock);
    expect(find.text('No sessions yet'), findsOneWidget);
  });

  testWidgets('a logged session renders the overall volume chart', (
    tester,
  ) async {
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

    await pumpScreen(tester, const InsightsScreen(), db: db, now: clock);

    expect(find.text('No sessions yet'), findsNothing);
    expect(find.text('Overall weekly volume'), findsOneWidget);
    expect(find.byType(WeeklyBarChart), findsWidgets);
    expect(find.text('Chest'), findsOneWidget);
  });
}
