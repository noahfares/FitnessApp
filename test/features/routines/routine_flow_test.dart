import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_router.dart';
import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/database_provider.dart';
import 'package:fitness_app/data/db/tables/enums.dart';

import '../../support/harness.dart';

/// Batch 2.1 — routine CRUD, days, targets, and starting a workout from a
/// day (`F-ROU-001`, `F-ROU-002`, `F-ROU-003`, `F-ROU-010`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seedExercise() => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: 'row',
          name: 'Cable Row',
          primaryMuscle: Muscle.upperBack,
          equipment: Equipment.cable,
          trackingType: TrackingType.weightReps,
          createdAt: 1,
          updatedAt: 1,
        ),
      );

  Future<ProviderContainer> openRoutines(WidgetTester tester) async {
    final container = await pumpApp(tester, db: db);
    container.read(routerProvider).go(AppRoutes.routines);
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> saveDialog(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).last, text);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'create a routine, a day, an exercise with targets, and start it',
    (tester) async {
      await seedExercise();
      await openRoutines(tester);

      // F-ROU-001: create.
      await tester.tap(find.byTooltip('New routine'));
      await tester.pumpAndSettle();
      await saveDialog(tester, 'Push Day');

      // F-ROU-002: a fresh routine has no days yet.
      expect(find.text('No days yet'), findsOneWidget);
      await tester.tap(find.text('Add a day'));
      await tester.pumpAndSettle();
      await saveDialog(tester, 'Day 1');

      // Adding the first day pushes straight into it.
      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('No exercises yet'), findsOneWidget);

      await tester.tap(find.text('Add exercises'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cable Row'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add 1'));
      await tester.pumpAndSettle();

      // F-ROU-003: targets are optional — none set yet.
      expect(find.text('No targets set'), findsOneWidget);

      await tester.tap(find.text('Cable Row'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '3'); // sets
      await tester.enterText(fields.at(1), '8'); // reps min
      await tester.enterText(fields.at(2), '12'); // reps max
      await tester.enterText(fields.at(3), '100'); // weight, kg by default
      await tester.tap(find.text('Save targets'));
      await tester.pumpAndSettle();

      // Rep ranges render as "min–max" (`F-ROU-003` acceptance).
      expect(find.textContaining('3×8–12'), findsOneWidget);
      expect(find.textContaining('100 kg'), findsOneWidget);

      // F-ROU-010: start the workout from the day.
      await tester.tap(find.text('Start workout'));
      await tester.pumpAndSettle();

      expect(find.text('Cable Row'), findsOneWidget);
      expect(find.textContaining('Target: 3×8–12 · 100 kg'), findsOneWidget);

      final sets = await db.select(db.sets).get();
      expect(sets, hasLength(3));
      expect(sets.every((s) => !s.isCompleted), isTrue);

      final workouts = await db.select(db.workouts).get();
      expect(workouts.single.name, 'Day 1');
      expect(workouts.single.sourceRoutineDayId, isNotNull);
    },
  );

  testWidgets(
    'assigning a linear progression rule proposes an incremented target on '
    'a second start (F-PRG-007, batch 4.1)',
    (tester) async {
      await seedExercise();
      await openRoutines(tester);

      await tester.tap(find.byTooltip('New routine'));
      await tester.pumpAndSettle();
      await saveDialog(tester, 'Pull Day');
      await tester.tap(find.text('Add a day'));
      await tester.pumpAndSettle();
      await saveDialog(tester, 'Day 1');
      await tester.tap(find.text('Add exercises'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cable Row'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cable Row'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '3');
      await tester.enterText(fields.at(1), '5');
      await tester.enterText(fields.at(2), '5');
      await tester.enterText(fields.at(3), '100');
      await tester.tap(find.text('Add weight on success'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Save targets'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Save targets'));
      await tester.pumpAndSettle();

      // First start: no history yet, so the static 100 kg target is used.
      await tester.tap(find.text('Start workout'));
      await tester.pumpAndSettle();
      expect(find.textContaining('100 kg'), findsWidgets);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final workouts = container.read(workoutRepositoryProvider);
      final sets = container.read(setRepositoryProvider);
      final workoutId = (await db.select(db.workouts).get()).single.id;
      final workoutExercise =
          (await db.select(db.workoutExercises).get()).single;
      for (final set in await sets.getSets(workoutExercise.id)) {
        await sets.complete(
          set.id,
          weightGrams: const Value(100000),
          reps: const Value(5),
        );
      }
      await workouts.finish(workoutId);

      // Back to the day and start again — the routine's own progression
      // engine should now propose 102.5 kg, not the static 100 kg target.
      final routineId = (await db.select(db.routines).get()).single.id;
      container.read(routerProvider).go(AppRoutes.routine(routineId));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start workout'));
      await tester.pumpAndSettle();

      expect(find.textContaining('102.5 kg'), findsWidgets);
    },
  );

  testWidgets(
    'a single-day routine collapses straight into its day (F-ROU-002 §4)',
    (tester) async {
      await seedExercise();
      await openRoutines(tester);

      await tester.tap(find.byTooltip('New routine'));
      await tester.pumpAndSettle();
      await saveDialog(tester, 'Leg Day');
      await tester.tap(find.text('Add a day'));
      await tester.pumpAndSettle();
      await saveDialog(tester, 'Only Day');

      // Back out of the day editor into the routine itself — with exactly
      // one day, that lands straight on the exercise list, not a day list.
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Leg Day'), findsOneWidget); // the app bar title
      expect(find.text('No exercises yet'), findsOneWidget);
      expect(find.text('Start workout'), findsOneWidget);
      // No day-list tile to tap through first.
      expect(find.text('Only Day'), findsNothing);
    },
  );

  testWidgets('starter program gallery imports a program and reports skipped '
      'exercises (F-ROU-015)', (tester) async {
    // Only one of the PPL program's exercises exists in this catalogue —
    // the rest must be silently skipped and reported, not crash the import.
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'bench',
            externalId: const Value('barbell-bench-press'),
            name: 'Bench Press',
            primaryMuscle: Muscle.chest,
            equipment: Equipment.barbell,
            trackingType: TrackingType.weightReps,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await openRoutines(tester);

    // The empty state offers the gallery before any routine exists.
    expect(find.text('No routines yet'), findsOneWidget);
    await tester.tap(find.text('Browse starter programs'));
    await tester.pumpAndSettle();

    expect(find.text('Starter programs'), findsOneWidget);
    expect(find.text('Push/Pull/Legs'), findsOneWidget);

    await tester
        .tap(find.widgetWithText(FilledButton, 'Add to my routines').first)
        .then((_) => tester.pumpAndSettle());
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    // Lands on the new routine, not the gallery.
    expect(find.text('Push/Pull/Legs'), findsOneWidget);
    expect(find.textContaining('could not be added'), findsOneWidget);

    final routines = await db.select(db.routines).get();
    expect(routines.single.name, 'Push/Pull/Legs');
  });
}
