import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_router.dart';
import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';

import '../../support/harness.dart';

/// Batch 2.3 — supersets in the routine day editor (`F-ROU-005`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seedExercises() async {
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
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'fly',
            name: 'Cable Fly',
            primaryMuscle: Muscle.chest,
            equipment: Equipment.cable,
            trackingType: TrackingType.weightReps,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
  }

  Future<ProviderContainer> openADayWithTwoExercises(
    WidgetTester tester,
  ) async {
    await seedExercises();
    final container = await pumpApp(tester, db: db);
    container.read(routerProvider).go(AppRoutes.routines);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('New routine'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Push Day');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add a day'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Day 1');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add exercises'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bench Press'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cable Fly'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add 2'));
    await tester.pumpAndSettle();

    return container;
  }

  testWidgets(
    'selecting two adjacent exercises and grouping shows the superset label',
    (tester) async {
      await openADayWithTwoExercises(tester);

      expect(find.text('Superset'), findsNothing);

      await tester.longPress(find.text('Bench Press'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cable Fly'));
      await tester.pumpAndSettle();

      expect(find.text('2 selected'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Group'));
      await tester.pumpAndSettle();

      expect(find.text('Superset'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Ungroup'), findsOneWidget);
    },
  );

  testWidgets('ungrouping removes the superset label', (tester) async {
    await openADayWithTwoExercises(tester);

    await tester.longPress(find.text('Bench Press'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cable Fly'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Group'));
    await tester.pumpAndSettle();
    expect(find.text('Superset'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Ungroup'));
    await tester.pumpAndSettle();

    expect(find.text('Superset'), findsNothing);
  });
}
