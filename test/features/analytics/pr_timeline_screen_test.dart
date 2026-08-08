import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/personal_record_repository.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/analytics/presentation/pr_timeline_screen.dart';
import 'package:fitness_app/features/shell/widgets/empty_state.dart';

import '../../support/harness.dart';

/// Batch 3.4 — `F-ANA-007` reached through the real `PrTimelineScreen`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  late PersonalRecordRepository records;
  final clock = DateTime(2026, 8, 7);

  setUp(() {
    db = testDatabase();
    workouts = WorkoutRepository(db, clock: () => clock);
    sets = SetRepository(db, clock: () => clock);
    records = PersonalRecordRepository(db, clock: () => clock);
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

  testWidgets('no records shows the empty state', (tester) async {
    await pumpScreen(tester, const PrTimelineScreen(), db: db, now: clock);
    expect(find.text('No records yet'), findsOneWidget);
  });

  testWidgets('a recorded PR shows the exercise name and description', (
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
    await records.evaluateSet(set.id);

    await pumpScreen(tester, const PrTimelineScreen(), db: db, now: clock);

    expect(find.byType(EmptyState), findsNothing);
    expect(find.text('bench'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
