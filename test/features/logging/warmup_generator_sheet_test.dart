import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/plate_repository.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/logging/presentation/warmup_generator_sheet.dart';

import '../../support/harness.dart';

/// `F-LOG-020`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late String workoutExerciseId;

  setUp(() async {
    db = testDatabase();
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
    final plates = PlateRepository(db);
    final barId = await plates.createBar(
      id: 'bar',
      name: 'Standard barbell',
      weightGrams: 20000,
      isDefault: true,
    );
    await (db.update(db.exercises)..where((e) => e.id.equals('bench'))).write(
      ExercisesCompanion(defaultBarId: Value(barId)),
    );

    final workouts = WorkoutRepository(db);
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, ['bench']);
    workoutExerciseId = (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
  });

  testWidgets('generating inserts warm-up sets ahead of what is logged', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showWarmupGeneratorSheet(
              context,
              exerciseId: 'bench',
              workoutExerciseId: workoutExerciseId,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
      db: db,
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Generate warm-ups'), findsOneWidget);
    // The default ramp's four steps are shown, editable.
    expect(find.byType(TextFormField), findsNWidgets(4 * 2));

    await tester.enterText(
      find.byKey(const Key('warmupWorkingWeightField')),
      '100',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Generate'));
    await tester.pumpAndSettle();

    expect(find.text('Generate warm-ups'), findsNothing);

    final sets = SetRepository(db);
    final rows = await sets.getSets(workoutExerciseId);
    // The original empty working set, plus four generated warm-ups.
    expect(rows, hasLength(5));
    expect(rows.where((s) => s.setType == SetType.warmup), hasLength(4));
    // The bar step floors at the configured bar weight.
    expect(rows.first.weightGrams, 20000);
  });

  testWidgets('a blank working weight is refused', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showWarmupGeneratorSheet(
              context,
              exerciseId: 'bench',
              workoutExerciseId: workoutExerciseId,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
      db: db,
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Generate'));
    await tester.pumpAndSettle();

    expect(find.text('Enter the working weight'), findsOneWidget);
    expect(find.text('Generate warm-ups'), findsOneWidget);
  });
}
