import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_app/app.dart';
import 'package:fitness_app/core/routing/app_router.dart';
import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/database_provider.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/features/settings/application/unit_preferences_provider.dart';

/// Batch 1.2 — the catalogue screen (`F-CAT-004`, `F-CAT-005`) and the editor
/// it finally makes reachable (`F-CAT-003`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> insert(
    String id,
    String name, {
    required Muscle muscle,
    required Equipment equipment,
    List<String> aliases = const [],
  }) => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: name,
          primaryMuscle: muscle,
          equipment: equipment,
          trackingType: TrackingType.weightReps,
          aliases: Value(aliases),
          externalId: Value('seed-$id'),
          createdAt: 1,
          updatedAt: 1,
        ),
      );

  Future<void> seedCatalogue() async {
    await insert(
      'bench',
      'Bench Press',
      muscle: Muscle.chest,
      equipment: Equipment.barbell,
      aliases: ['bp'],
    );
    await insert(
      'incline',
      'Incline Bench Press',
      muscle: Muscle.chest,
      equipment: Equipment.barbell,
    );
    await insert(
      'chest-press',
      'Chest Press',
      muscle: Muscle.chest,
      equipment: Equipment.machine,
    );
    await insert(
      'squat',
      'Back Squat',
      muscle: Muscle.quads,
      equipment: Equipment.barbell,
    );
    await insert(
      'rdl',
      'Romanian Deadlift',
      muscle: Muscle.hamstrings,
      equipment: Equipment.barbell,
      aliases: ['RDL'],
    );
  }

  Future<ProviderContainer> openCatalogue(
    WidgetTester tester, {
    String route = AppRoutes.exercises,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const FitnessApp(),
      ),
    );
    await tester.pumpAndSettle();

    container.read(routerProvider).go(route);
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> type(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField).first, query);
    await tester.pumpAndSettle();
  }

  Future<void> openFilterSheet(WidgetTester tester) async {
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
  }

  Future<void> dismissSheet(WidgetTester tester) async {
    // Tap the barrier above the sheet.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
  }

  group('catalogue', () {
    testWidgets('reachable from Home and lists the catalogue', (tester) async {
      await seedCatalogue();
      await openCatalogue(tester, route: AppRoutes.home);

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Romanian Deadlift'), findsOneWidget);
      // No count until something is actually filtering.
      expect(find.textContaining('of 5 exercises'), findsNothing);
    });

    testWidgets('typing narrows the list with no search action', (
      tester,
    ) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await type(tester, 'bench');
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Incline Bench Press'), findsOneWidget);
      expect(find.text('Back Squat'), findsNothing);

      // The count appears only while filtering (`F-CAT-005` acceptance).
      expect(find.text('2 of 5 exercises'), findsOneWidget);
    });

    testWidgets('an alias finds its exercise', (tester) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await type(tester, 'rdl');

      expect(find.text('Romanian Deadlift'), findsOneWidget);
      expect(find.text('1 of 5 exercises'), findsOneWidget);
    });

    testWidgets('clearing the search restores the catalogue', (tester) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await type(tester, 'rdl');
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();

      expect(find.text('Back Squat'), findsOneWidget);
      expect(find.textContaining('of 5 exercises'), findsNothing);
    });

    testWidgets('no match says so rather than showing an empty screen', (
      tester,
    ) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await type(tester, 'zercher');

      expect(find.text('No exercises match'), findsOneWidget);
    });

    testWidgets('a facet filter composes with the search text', (tester) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await type(tester, 'press');
      expect(find.text('3 of 5 exercises'), findsOneWidget);

      await openFilterSheet(tester);
      await tester.tap(find.text('Machine'));
      await tester.pumpAndSettle();
      await dismissSheet(tester);

      // AND across categories, composed with the query (`F-CAT-005` §2).
      expect(find.text('Chest Press'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
      expect(find.text('1 of 5 exercises'), findsOneWidget);
    });

    testWidgets('an active facet is visible and clearable in one tap', (
      tester,
    ) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await openFilterSheet(tester);
      await tester.tap(find.text('Machine'));
      await tester.pumpAndSettle();
      await dismissSheet(tester);

      // Visible as its own chip, and the button says how many are on.
      expect(find.text('Filters (1)'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Machine'), findsOneWidget);
      expect(find.text('Back Squat'), findsNothing);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Back Squat'), findsOneWidget);
      expect(find.text('Filters'), findsOneWidget);
    });

    testWidgets('filter selections survive leaving and returning', (
      tester,
    ) async {
      // `F-CAT-005` §4: filters persist within a session. They are held in a
      // provider rather than widget state, which is what makes this true.
      await seedCatalogue();
      final container = await openCatalogue(tester);

      await type(tester, 'squat');
      expect(find.text('Back Squat'), findsOneWidget);

      // Leave the screen entirely — the state survives its widget being
      // disposed, which widget state would not.
      container.read(routerProvider).go(AppRoutes.home);
      await tester.pumpAndSettle();
      container.read(routerProvider).go(AppRoutes.exercises);
      await tester.pumpAndSettle();

      expect(find.text('Back Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
      // ...and the field is re-seeded from it, rather than showing an empty box
      // over a filtered list.
      expect(find.text('squat'), findsOneWidget);
    });
  });

  group('custom exercise editor (F-CAT-003)', () {
    testWidgets('a created exercise is immediately in the list', (
      tester,
    ) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await tester.tap(find.text('New exercise'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hack Squat');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create exercise'));
      await tester.pumpAndSettle();

      // Back on the catalogue, no manual refresh anywhere: the list is a
      // stream (`F-CAT-003` acceptance).
      expect(find.text('Exercises'), findsOneWidget);
      expect(find.text('Hack Squat'), findsOneWidget);

      final stored = await db.select(db.exercises).get();
      final created = stored.firstWhere((e) => e.name == 'Hack Squat');
      expect(created.isCustom, isTrue);
      // Never seeded, so re-seeding can never touch it.
      expect(created.externalId, isNull);
      expect(created.seedUpdatedAt, isNull);
    });

    testWidgets('a duplicate name warns but does not block', (tester) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await tester.tap(find.text('New exercise'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Bench Press');
      await tester.pumpAndSettle();

      expect(
        find.text('Another exercise already has this name. That is allowed.'),
        findsOneWidget,
      );

      // "Bench Press (Smith)" is legitimate, so Create stays enabled.
      await tester.tap(find.text('Create exercise'));
      await tester.pumpAndSettle();
      expect(await db.select(db.exercises).get(), hasLength(6));
    });

    testWidgets('editing a seeded exercise marks it edited for the seeder', (
      tester,
    ) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Built-in exercise'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Comp Bench');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final row = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('bench'))).getSingle();
      expect(row.name, 'Comp Bench');
      // updatedAt now differs from seedUpdatedAt, so the next re-seed leaves
      // this row alone (`F-CAT-001`).
      expect(row.updatedAt, isNot(row.seedUpdatedAt));
      expect(find.text('Comp Bench'), findsOneWidget);
    });

    testWidgets('deleting an unused exercise asks first, then removes it', (
      tester,
    ) async {
      await seedCatalogue();
      await openCatalogue(tester);

      await tester.tap(find.text('Back Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      // Names what is being lost (docs/23-NAVIGATION.md §invariants).
      expect(find.text('Delete Back Squat?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Back Squat'), findsNothing);
      // Soft delete only — nothing is ever hard-deleted (ADR-0008).
      expect(await db.select(db.exercises).get(), hasLength(5));
    });

    testWidgets('deleting one with history is refused, archive offered', (
      tester,
    ) async {
      await seedCatalogue();
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'w-1',
              name: 'Push',
              startedAt: 1,
              startedAtTzOffsetMinutes: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: 'we-1',
              workoutId: 'w-1',
              exerciseId: 'bench',
              position: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );

      await openCatalogue(tester);
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Used in past workouts'), findsOneWidget);
      await tester.tap(find.text('Archive instead'));
      await tester.pumpAndSettle();

      final row = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('bench'))).getSingle();
      expect(row.archivedAt, isNotNull, reason: 'archived, not deleted');
      expect(row.deletedAt, isNull);
      // Gone from the picker, history intact.
      expect(find.text('Bench Press'), findsNothing);
    });
  });
}
