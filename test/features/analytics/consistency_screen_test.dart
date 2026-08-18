import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/routine_repository.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/settings/application/weekly_target_provider.dart';

import '../../support/harness.dart';

/// `F-ANA-006`'s two remaining clauses: a **user-configurable** weekly target
/// (§5 rule 2) and adherence against a schedule, which waited on `F-ROU-012`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = testDatabase());

  Future<void> logSessionOn(DateTime day) async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'bench-${day.millisecondsSinceEpoch}',
            name: 'Bench Press',
            primaryMuscle: Muscle.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    final workouts = WorkoutRepository(db, clock: () => day);
    final workout = await workouts.start(name: 'Push');
    await workouts.addExercises(workout.id, [
      'bench-${day.millisecondsSinceEpoch}',
    ]);
    final sets = SetRepository(db, clock: () => day);
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
  }

  testWidgets('the weekly target is chosen, not assumed', (tester) async {
    final now = DateTime(2026, 3, 15, 12);
    final container = await pumpApp(
      tester,
      db: db,
      startAt: AppRoutes.consistency,
      now: now,
    );

    expect(container.read(weeklyTargetProvider), defaultWeeklyTarget);

    // A bare '5' also matches numbers inside the stat tiles, so the chip is
    // located by its widget type.
    final chip = find.widgetWithText(ChoiceChip, '5');
    await tester.scrollUntilVisible(
      chip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(container.read(weeklyTargetProvider), 5);
    // And it is the number the explainer quotes, not a hard-coded 3.
    expect(find.textContaining('Target: 5 sessions a week'), findsOneWidget);
  });

  testWidgets('adherence appears once a routine day is scheduled', (
    tester,
  ) async {
    final now = DateTime(2026, 3, 15, 12); // a Sunday
    await logSessionOn(DateTime(2026, 3, 9, 18)); // Monday

    await pumpApp(tester, db: db, startAt: AppRoutes.consistency, now: now);
    // Nothing scheduled yet, so there is no ratio to report — and reporting 0%
    // to someone who never set a schedule would be a lie.
    expect(find.text('Against your schedule'), findsNothing);

    final routines = RoutineRepository(db);
    final routine = await routines.create(name: 'PPL');
    final day = await routines.addDay(routine.id, name: 'Push');
    await routines.setScheduledWeekdays(day.id, const [1]);

    await pumpApp(tester, db: db, startAt: AppRoutes.consistency, now: now);
    await tester.scrollUntilVisible(
      find.text('Against your schedule'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Against your schedule'), findsOneWidget);
  });
}
