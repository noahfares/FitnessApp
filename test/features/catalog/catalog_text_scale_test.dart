import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/features/catalog/presentation/exercise_catalog_screen.dart';
import 'package:fitness_app/features/catalog/presentation/exercise_editor_screen.dart';

import '../../support/harness.dart';

/// F-A11Y-002 — the catalogue's search-and-filter row and the editor's
/// notes/aliases/weight-source fields each carry enough controls to be
/// worth their own 200% check.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the catalogue, seeded, renders at 200% with no overflow', (
    tester,
  ) async {
    final db = testDatabase();
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

    await pumpScreen(
      tester,
      const ExerciseCatalogScreen(),
      db: db,
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the editor in create mode renders at 200% with no overflow', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const ExerciseEditorScreen(),
      db: testDatabase(),
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the editor in edit mode renders at 200% with no overflow', (
    tester,
  ) async {
    final db = testDatabase();
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'bench',
            name: 'Bench Press',
            primaryMuscle: Muscle.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
            notes: const Value('Elbows tucked.'),
            aliases: const Value(['bb bench']),
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await pumpScreen(
      tester,
      const ExerciseEditorScreen(exerciseId: 'bench'),
      db: db,
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });
}
