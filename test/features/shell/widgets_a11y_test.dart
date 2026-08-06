import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/shell/widgets/active_workout_banner.dart';
import 'package:fitness_app/features/shell/widgets/confirm_sheet.dart';
import 'package:fitness_app/features/shell/widgets/empty_state.dart';

import '../../support/harness.dart';

/// Batch 1.7 — the shared chrome introduced for `F-NAV-003`, `F-NAV-005` and
/// `F-NAV-006` all carry interactive elements, so they inherit `F-A11Y-004`'s
/// 48 dp minimum the same as the set row does.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EmptyState action button meets the 48dp minimum', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: EmptyState(
          icon: Icons.fitness_center,
          title: 'Nothing here',
          actionLabel: 'Do something',
          onAction: () {},
        ),
      ),
    );

    final size = tester.getSize(
      find.widgetWithText(FilledButton, 'Do something'),
    );
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('ConfirmSheet buttons meet the 48dp minimum', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: ConfirmSheet(
          title: 'Delete this?',
          message: 'It will be gone.',
          confirmLabel: 'Delete',
          cancelLabel: 'Keep it',
          isDestructive: true,
        ),
      ),
    );

    final confirmSize = tester.getSize(
      find.widgetWithText(FilledButton, 'Delete'),
    );
    final cancelSize = tester.getSize(
      find.widgetWithText(OutlinedButton, 'Keep it'),
    );
    expect(confirmSize.height, greaterThanOrEqualTo(48));
    expect(cancelSize.height, greaterThanOrEqualTo(48));
  });

  testWidgets('ActiveWorkoutBanner is at least 48dp tall when shown', (
    tester,
  ) async {
    final db = testDatabase();
    final workouts = WorkoutRepository(db, clock: () => DateTime(2026, 8, 6));
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

    await pumpScreen(
      tester,
      const Scaffold(
        body: SizedBox(),
        bottomNavigationBar: ActiveWorkoutBanner(),
      ),
      db: db,
    );

    final size = tester.getSize(find.byType(ActiveWorkoutBanner));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(find.textContaining('exercise'), findsOneWidget);
  });
}
