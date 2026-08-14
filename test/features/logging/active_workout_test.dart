import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/routing/app_routes.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/logging/application/active_workout_providers.dart';
import 'package:fitness_app/features/logging/presentation/active_workout_screen.dart';

import '../../support/harness.dart';

/// Batch 1.3 — session lifecycle (`F-LOG-001`), adding exercises
/// (`F-LOG-002`), and kill recovery (`F-LOG-007`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository repo;

  setUp(() {
    db = testDatabase();
    repo = WorkoutRepository(db);
  });

  Future<void> seedExercises() async {
    for (final (id, name, muscle) in [
      ('bench', 'Bench Press', Muscle.chest),
      ('squat', 'Back Squat', Muscle.quads),
      ('row', 'Barbell Row', Muscle.lats),
    ]) {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: id,
              name: name,
              primaryMuscle: muscle,
              equipment: Equipment.barbell,
              trackingType: TrackingType.weightReps,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
    }
  }

  /// The whole app, router included — these tests are about where navigation
  /// lands, so the shared `pumpScreen` is not enough.
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    String? startAt,
    DateTime? now,
  }) => pumpApp(tester, db: db, startAt: startAt, now: now);

  Future<void> openStartSheet(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
  }

  group('starting and finishing (F-LOG-001)', () {
    testWidgets('the centre tab opens a sheet, not a page', (tester) async {
      await pump(tester);
      await openStartSheet(tester);

      expect(find.text('Start empty workout'), findsOneWidget);
      // A sheet preserves what is behind it (docs/23-NAVIGATION.md), so Home
      // is still there.
      expect(find.text('Ready to train?'), findsOneWidget);
    });

    testWidgets('starting lands in the session', (tester) async {
      await pump(tester);
      await openStartSheet(tester);
      await tester.tap(find.text('Start empty workout'));
      await tester.pumpAndSettle();

      expect(find.text('No exercises yet'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);

      final active = await repo.findActive();
      expect(active, isNotNull);
      expect(active!.endedAt, isNull);
    });

    testWidgets('a second start is refused while one is running', (
      tester,
    ) async {
      await repo.start(name: 'Push A');
      await pump(tester);
      await openStartSheet(tester);

      // Which session was meant to survive is not the app's call
      // (`F-LOG-001` §3).
      expect(find.text('Already training'), findsOneWidget);
      expect(find.text('Start empty workout'), findsNothing);

      await tester.tap(find.text('Resume workout'));
      await tester.pumpAndSettle();
      expect(find.text('Push A'), findsOneWidget);
    });

    testWidgets('finishing an empty session offers to discard it instead', (
      tester,
    ) async {
      final workout = await repo.start(name: 'Push A');
      await pump(tester, startAt: AppRoutes.activeWorkout);

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing logged yet'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // No junk history entry — the acceptance criterion in F-LOG-001.
      expect(await repo.findById(workout.id), isNull);
      expect(await repo.findActive(), isNull);
    });

    testWidgets('"Finish anyway" keeps the session in history', (tester) async {
      final workout = await repo.start();
      await pump(tester, startAt: AppRoutes.activeWorkout);

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish anyway'));
      await tester.pumpAndSettle();

      final stored = await repo.findById(workout.id);
      expect(stored, isNotNull);
      expect(stored!.endedAt, isNotNull);
      expect(await repo.findActive(), isNull);
    });

    testWidgets('discarding names what will be lost, then tombstones it', (
      tester,
    ) async {
      await seedExercises();
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench', 'squat']);
      await pump(tester, startAt: AppRoutes.activeWorkout);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard workout'));
      await tester.pumpAndSettle();

      // Names what is being lost, per the navigation invariants.
      expect(
        find.textContaining('2 exercises and 0 completed sets'),
        findsOneWidget,
      );

      // A single tap must not be able to discard (`F-LOG-022` §2) — the
      // confirm is a held press, not a tap.
      await holdToConfirm(tester, find.text('Hold to discard'));

      expect(await repo.findActive(), isNull);
      // Tombstoned, not destroyed (ADR-0008).
      expect(await db.select(db.workouts).get(), hasLength(1));
    });

    testWidgets('cancelling a discard leaves the session alone', (
      tester,
    ) async {
      final workout = await repo.start();
      await pump(tester, startAt: AppRoutes.activeWorkout);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep training'));
      await tester.pumpAndSettle();

      expect((await repo.findActive())!.id, workout.id);
    });

    testWidgets('releasing early cancels the hold and discards nothing', (
      tester,
    ) async {
      final workout = await repo.start();
      await pump(tester, startAt: AppRoutes.activeWorkout);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard workout'));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Hold to discard')),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await gesture.up();
      await tester.pumpAndSettle();

      expect((await repo.findActive())!.id, workout.id);
    });
  });

  group('adding exercises (F-LOG-002)', () {
    testWidgets('three taps from the session, added in tick order', (
      tester,
    ) async {
      await seedExercises();
      await repo.start();
      await pump(tester, startAt: AppRoutes.activeWorkout);

      // 1 — open the picker.
      await tester.tap(find.text('Add exercises'));
      await tester.pumpAndSettle();
      // 2 — tick one.
      await tester.tap(find.text('Back Squat'));
      await tester.pumpAndSettle();
      // 3 — confirm.
      await tester.tap(find.text('Add 1'));
      await tester.pumpAndSettle();

      expect(find.text('Back Squat'), findsOneWidget);
      expect(find.text('0 of 1 set done'), findsOneWidget);
    });

    testWidgets('multi-select adds several in one pass, in order', (
      tester,
    ) async {
      await seedExercises();
      final workout = await repo.start();
      await pump(tester, startAt: AppRoutes.activeWorkout);

      await tester.tap(find.text('Add exercises'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Row'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add 2'));
      await tester.pumpAndSettle();

      final rows = await repo.watchExercises(workout.id).first;
      expect([for (final r in rows) r.name], ['Barbell Row', 'Bench Press']);
    });

    testWidgets('the picker searches, and starts clean each time', (
      tester,
    ) async {
      await seedExercises();
      await repo.start();
      await pump(tester, startAt: AppRoutes.activeWorkout);

      await tester.tap(find.text('Add exercises'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'squat');
      await tester.pumpAndSettle();
      expect(find.text('Back Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);

      // Dismiss without adding.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add exercises'));
      await tester.pumpAndSettle();
      // A filter left on from last time would silently hide exercises.
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Add exercises'), findsWidgets);
    });
  });

  group('kill recovery (F-LOG-007)', () {
    test('the startup location follows whether a session is open', () async {
      expect(
        startupLocationFor(onboardingCompleted: true, active: null),
        AppRoutes.home,
      );
      final workout = await repo.start();
      expect(
        startupLocationFor(onboardingCompleted: true, active: workout),
        AppRoutes.activeWorkout,
      );
    });

    test('onboarding wins over resuming a session on a first-run device', () {
      expect(
        startupLocationFor(onboardingCompleted: false, active: null),
        AppRoutes.onboarding,
      );
    });

    testWidgets('reopening lands in the session, with nothing lost', (
      tester,
    ) async {
      await seedExercises();
      final workout = await repo.start(name: 'Push A');
      await repo.addExercises(workout.id, ['bench', 'squat']);

      // Nothing was held in memory to begin with, so "relaunching" is just
      // building the app again against the same database.
      await pump(
        tester,
        startAt: startupLocationFor(onboardingCompleted: true, active: workout),
      );

      // No "restore session?" prompt — it just resumes (`F-LOG-007` §4).
      expect(find.text('Push A'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Back Squat'), findsOneWidget);
      expect(find.text('2 exercises'), findsOneWidget);
    });

    testWidgets('elapsed time is derived from started_at, not counted up', (
      tester,
    ) async {
      final start = DateTime(2026, 8, 6, 18);
      await WorkoutRepository(db, clock: () => start).start();

      // 25 minutes later, in a process that was not running for any of them.
      await pump(
        tester,
        startAt: AppRoutes.activeWorkout,
        now: start.add(const Duration(minutes: 25, seconds: 12)),
      );

      expect(find.text('25:12'), findsOneWidget);
    });

    testWidgets('a session open for over 12 hours says so', (tester) async {
      final start = DateTime(2026, 8, 6, 18);
      await WorkoutRepository(db, clock: () => start).start();

      await pump(
        tester,
        startAt: AppRoutes.activeWorkout,
        now: start.add(const Duration(hours: 14)),
      );

      // It still resumes — the notice is surfaced rather than prompted, so
      // neither finishing nor discarding is the default under stress.
      expect(
        find.textContaining('open for more than 12 hours'),
        findsOneWidget,
      );
    });

    testWidgets('a stale deep link into a finished session is not a crash', (
      tester,
    ) async {
      await pump(tester, startAt: AppRoutes.activeWorkout);

      expect(find.text('No workout in progress.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('supersets (F-LOG-015)', () {
    testWidgets('grouping two exercises shows the superset label and lets them '
        'ungroup', (tester) async {
      await seedExercises();
      final workout = await repo.start();
      await repo.addExercises(workout.id, ['bench', 'squat']);
      await pump(tester, startAt: AppRoutes.activeWorkout);

      expect(find.text('Superset'), findsNothing);
      expect(find.text('Group with next'), findsOneWidget);

      await tester.tap(find.text('Group with next'));
      await tester.pumpAndSettle();

      expect(find.text('Superset'), findsOneWidget);
      expect(find.text('Ungroup'), findsOneWidget);

      await tester.tap(find.text('Ungroup'));
      await tester.pumpAndSettle();

      expect(find.text('Superset'), findsNothing);
    });
  });

  group('formatElapsed', () {
    test('drops the hour until there is one', () {
      expect(formatElapsed(Duration.zero), '00:00');
      expect(formatElapsed(const Duration(seconds: 9)), '00:09');
      expect(formatElapsed(const Duration(minutes: 25, seconds: 12)), '25:12');
      expect(
        formatElapsed(const Duration(hours: 1, minutes: 5, seconds: 3)),
        '1:05:03',
      );
      expect(formatElapsed(const Duration(hours: 26)), '26:00:00');
    });
  });
}
