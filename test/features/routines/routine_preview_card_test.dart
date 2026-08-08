import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/routine_repository.dart';
import 'package:fitness_app/features/routines/presentation/routine_day_editor_screen.dart';

import '../../support/harness.dart';

/// `F-ROU-011` — the day editor's "Preview" card.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<RoutineDay> seedDayWithTargets() async {
    final repo = RoutineRepository(db);
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
    final routine = await repo.create(name: 'Push Day');
    final day = await repo.addDay(routine.id, name: 'Push');
    await repo.addExercises(day.id, ['bench']);
    final [row] = await repo.watchExercises(day.id).first;
    await repo.setTargets(
      row.routineExerciseId,
      targetSets: const Value(4),
      targetRepsMin: const Value(8),
      targetRepsMax: const Value(12),
      targetWeightGrams: const Value(60000),
    );
    return day;
  }

  testWidgets(
    'collapsed by default: duration and volume show, exercises stay visible',
    (tester) async {
      final day = await seedDayWithTargets();

      await pumpScreen(
        tester,
        RoutineDayEditorScreen(routineId: day.routineId, dayId: day.id),
        db: db,
      );

      expect(find.textContaining('min ·'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
    },
  );

  testWidgets('expanding the preview keeps the exercise list visible too', (
    tester,
  ) async {
    final day = await seedDayWithTargets();

    await pumpScreen(
      tester,
      RoutineDayEditorScreen(routineId: day.routineId, dayId: day.id),
      db: db,
    );

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
  });
}
