import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';

import '../../support/harness.dart';

/// F-A11Y-002 — the app's densest screen (multiple set rows, each with a
/// note button, ghost, values and a completion toggle) must stay usable, not
/// just non-crashing, at 200% system text scale. `SetRow` itself already
/// switches to a two-line layout above ~1.375x (`F-LOG-003` acceptance); this
/// is the screen-level proof that switch actually prevents an overflow, not
/// just a unit test of the threshold in isolation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'an in-progress session with sets renders at 200% with no overflow',
    (tester) async {
      final db = testDatabase();
      final repo = WorkoutRepository(db);
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
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench']);

      await pumpApp(
        tester,
        db: db,
        startAt: AppRoutes.activeWorkout,
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
    },
  );
}
