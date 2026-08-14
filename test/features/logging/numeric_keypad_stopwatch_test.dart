import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/domain/logging/set_fields.dart';
import 'package:fitness_app/features/logging/presentation/numeric_keypad_sheet.dart';

import '../../support/harness.dart';

/// `F-TIM-009` — the count-up stopwatch on the duration field.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutSet set;

  setUp(() async {
    db = testDatabase();
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'plank',
            name: 'Plank',
            primaryMuscle: Muscle.abs,
            equipment: Equipment.bodyweight,
            trackingType: TrackingType.time,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    final workouts = WorkoutRepository(db);
    final sets = SetRepository(db);
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, ['plank']);
    final we = (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
    set = (await sets.getSets(we)).single;
  });

  Future<void> pumpKeypad(WidgetTester tester) => pumpScreen(
    tester,
    Scaffold(
      body: NumericKeypadSheet(
        set: set,
        fields: const [SetField.duration],
        initialField: SetField.duration,
        equipment: 'bodyweight',
      ),
    ),
    db: db,
  );

  testWidgets('starting the stopwatch shows a stop control', (tester) async {
    await pumpKeypad(tester);

    expect(find.byTooltip('Start stopwatch'), findsOneWidget);
    await tester.tap(find.byTooltip('Start stopwatch'));
    await tester.pump();

    expect(find.byTooltip('Stop stopwatch'), findsOneWidget);
    expect(find.byTooltip('Start stopwatch'), findsNothing);
  });

  testWidgets('stopping the stopwatch writes a duration through', (
    tester,
  ) async {
    await pumpKeypad(tester);

    await tester.tap(find.byTooltip('Start stopwatch'));
    await tester.pump();
    await tester.tap(find.byTooltip('Stop stopwatch'));
    await tester.pump();

    expect(find.byTooltip('Start stopwatch'), findsOneWidget);
    final db2 = db;
    final updated = await (db2.select(
      db2.sets,
    )..where((s) => s.id.equals(set.id))).getSingle();
    expect(updated.durationSeconds, isNotNull);
  });
}
