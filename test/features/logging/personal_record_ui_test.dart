import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/logging/presentation/active_workout_screen.dart';
import 'package:fitness_app/features/shell/widgets/pr_badge.dart';

import '../../support/harness.dart';

/// Phase 2 exit criterion — "PRs are detected and celebrated in-session"
/// (`F-LOG-013`, `docs/50-ROADMAP.md` §Phase 2). Complements the
/// repository-level proof in `personal_record_repository_test.dart`
/// (detection, and demotion on delete) with the actual set-row wiring: does
/// completing a record-setting set really show `PrBadge` on screen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  final clock = DateTime(2026, 8, 6, 18, 30);

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

  testWidgets('completing a set that beats an existing record shows PrBadge', (
    tester,
  ) async {
    await makeExercise('bench');

    // A first session establishes a baseline record — deliberately not
    // asserted on here, since a first-ever set is recorded silently, not
    // celebrated (`F-LOG-013` §4 rule 3); this is just history to beat.
    final firstWorkout = await workouts.start();
    await workouts.addExercises(firstWorkout.id, ['bench']);
    final firstWe = (await workouts.watchExercises(firstWorkout.id).first)
        .single
        .workoutExerciseId;
    final firstSet = (await sets.getSets(firstWe)).single;
    await sets.complete(
      firstSet.id,
      weightGrams: const Value(100000),
      reps: const Value(5),
    );
    await workouts.finish(firstWorkout.id);

    // A second session's set is pre-filled heavier than the first —
    // set through the repository directly, the same as a keypad edit
    // would, so completing it via the UI adopts what is already there
    // rather than overwriting it with ghost values.
    final second = await workouts.start();
    await workouts.addExercises(second.id, ['bench']);
    final secondWe = (await workouts.watchExercises(second.id).first)
        .single
        .workoutExerciseId;
    final secondSet = (await sets.getSets(secondWe)).single;
    await sets.updateValues(
      secondSet.id,
      weightGrams: const Value(110000),
      reps: const Value(5),
    );

    await pumpScreen(tester, const ActiveWorkoutScreen(), db: db, now: clock);

    expect(find.byType(PrBadge), findsNothing);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(find.byType(PrBadge), findsOneWidget);
  });
}
