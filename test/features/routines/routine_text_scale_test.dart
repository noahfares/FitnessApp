import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/routine_repository.dart';
import 'package:fitness_app/features/routines/presentation/routine_day_editor_screen.dart';
import 'package:fitness_app/features/routines/presentation/routine_editor_screen.dart';
import 'package:fitness_app/features/routines/presentation/routine_list_screen.dart';
import 'package:fitness_app/features/routines/presentation/starter_program_gallery_screen.dart';

import '../../support/harness.dart';

/// F-A11Y-002 — the routine list, the multi-day editor, and the day editor's
/// target sheet (already the site of one real 200% layout starvation bug,
/// `F-ROU-011`'s own status note) are dense list-plus-card screens each
/// worth checking on their own, not assumed safe from the day editor's own
/// existing `routine_flow_test.dart` coverage at the default text scale.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> seedExercises(AppDatabase db) async {
    for (final id in ['bench', 'squat', 'row']) {
      await db
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
    }
  }

  testWidgets('the routine list renders at 200% with no overflow', (
    tester,
  ) async {
    final db = testDatabase();
    final routines = RoutineRepository(db);
    await routines.create(name: 'Push Pull Legs');
    await routines.create(name: 'Upper Lower');

    await pumpScreen(tester, const RoutineListScreen(), db: db, textScale: 2.0);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the routine editor renders at 200% with no overflow', (
    tester,
  ) async {
    final db = testDatabase();
    final routines = RoutineRepository(db);
    final routine = await routines.create(name: 'Push Pull Legs');
    await routines.addDay(routine.id, name: 'Push');
    await routines.addDay(routine.id, name: 'Pull');
    await routines.addDay(routine.id, name: 'Legs');

    await pumpScreen(
      tester,
      RoutineEditorScreen(routineId: routine.id),
      db: db,
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'the day editor, with its Preview card, renders at 200% with no overflow',
    (tester) async {
      final db = testDatabase();
      await seedExercises(db);
      final routines = RoutineRepository(db);
      final routine = await routines.create(name: 'Push Pull Legs');
      final day = await routines.addDay(routine.id, name: 'Push');
      await routines.addExercises(day.id, ['bench', 'squat', 'row']);

      await pumpScreen(
        tester,
        RoutineDayEditorScreen(routineId: routine.id, dayId: day.id),
        db: db,
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the starter program gallery renders at 200% with no '
      'overflow', (tester) async {
    await pumpScreen(
      tester,
      const StarterProgramGalleryScreen(),
      db: testDatabase(),
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });
}
