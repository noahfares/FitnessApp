import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/platform/rest_timer_service.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/logging/presentation/active_workout_screen.dart';

import '../../support/harness.dart';

/// Batch 1.5 — the rest timer on the screen it lives on (`F-TIM-001`,
/// `F-TIM-002`, `F-TIM-005`, `F-SET-003`).
///
/// The clock is pinned by the harness, so "3:00" here means the timer was
/// started with exactly 180 seconds — not that 180 seconds happen to be left.
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

  /// A barbell chest exercise — 180 s by the built-in defaults (`F-TIM-005`).
  Future<void> makeExercise(
    String id, {
    Equipment equipment = Equipment.barbell,
    Muscle muscle = Muscle.chest,
    int? restSeconds,
  }) async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: id,
            name: id,
            primaryMuscle: muscle,
            equipment: equipment,
            trackingType: TrackingType.weightReps,
            defaultRestSeconds: Value(restSeconds),
            createdAt: 1,
            updatedAt: 1,
          ),
        );
  }

  Future<String> startWith(String exerciseId) async {
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, [exerciseId]);
    return (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
  }

  Future<ProviderContainer> pumpSession(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) => pumpScreen(
    tester,
    const ActiveWorkoutScreen(),
    db: db,
    now: clock,
    prefs: prefs,
  );

  Future<void> tapComplete(WidgetTester tester) async {
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
  }

  group('auto-start (F-TIM-002)', () {
    testWidgets('completing a set starts the rest timer', (tester) async {
      await makeExercise('bench');
      await startWith('bench');
      await pumpSession(tester);

      expect(find.text('3:00'), findsNothing);
      await tapComplete(tester);

      expect(find.text('3:00'), findsOneWidget);
    });

    testWidgets('un-completing that set cancels the rest it started', (
      tester,
    ) async {
      await makeExercise('bench');
      await startWith('bench');
      await pumpSession(tester);

      await tapComplete(tester);
      await tapComplete(tester);

      expect(find.text('3:00'), findsNothing);
    });

    testWidgets('un-completing a different set leaves the rest alone', (
      tester,
    ) async {
      await makeExercise('bench');
      final we = await startWith('bench');
      final first = (await sets.getSets(we)).single;
      await sets.addSet(we);
      await pumpSession(tester);

      // Complete the second row, then un-tick the first: the running rest
      // belongs to the second and must survive (`F-TIM-002` §5).
      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();
      await sets.complete(first.id);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(find.text('3:00'), findsOneWidget);
    });

    testWidgets('completing another set restarts rather than stacking', (
      tester,
    ) async {
      await makeExercise('bench');
      final we = await startWith('bench');
      await sets.addSet(we);
      await pumpSession(tester);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();

      // One bar, back at the top (`F-TIM-002` §4).
      expect(find.text('3:00'), findsOneWidget);
    });

    testWidgets('turning auto-start off leaves the bar away', (tester) async {
      await makeExercise('bench');
      await startWith('bench');
      await pumpSession(tester, prefs: {'rest.autoStart': false});

      await tapComplete(tester);

      expect(find.text('3:00'), findsNothing);
    });
  });

  group('within a superset (F-ROU-005 §3, F-LOG-015 §3)', () {
    testWidgets('the full rest does not start for a non-last group member', (
      tester,
    ) async {
      await makeExercise('bench');
      await makeExercise('fly');
      final workout = await workouts.start();
      await workouts.addExercises(workout.id, ['bench', 'fly']);
      final rows = await workouts.watchExercises(workout.id).first;
      await workouts.toggleGroupWithNext(
        rows[0].workoutExerciseId,
        rows[1].workoutExerciseId,
      );
      await pumpSession(tester);

      // Completing the first (non-last) member's only set must not start
      // the exercise's own 3-minute rest — there is no dedicated
      // within-group rest column, so it is fixed at zero
      // (`restSecondsForGroupMember`, unit-tested in
      // `test/domain/timing/rest_defaults_test.dart`).
      await tapComplete(tester);
      expect(find.text('3:00'), findsNothing);
    });
  });

  group('duration resolution (F-TIM-005, F-SET-003)', () {
    testWidgets('an isolation lift gets a shorter built-in rest', (
      tester,
    ) async {
      await makeExercise(
        'curl',
        equipment: Equipment.cable,
        muscle: Muscle.biceps,
      );
      await startWith('curl');
      await pumpSession(tester);

      await tapComplete(tester);

      expect(find.text('1:00'), findsOneWidget);
    });

    testWidgets('the global setting overrides the built-in', (tester) async {
      await makeExercise('bench');
      await startWith('bench');
      await pumpSession(tester, prefs: {'rest.defaultSeconds': 45});

      await tapComplete(tester);

      expect(find.text('0:45'), findsOneWidget);
    });

    testWidgets('the exercise overrides the global setting', (tester) async {
      await makeExercise('bench', restSeconds: 240);
      await startWith('bench');
      await pumpSession(tester, prefs: {'rest.defaultSeconds': 45});

      await tapComplete(tester);

      expect(find.text('4:00'), findsOneWidget);
    });
  });

  group('the controls (F-TIM-001 §2)', () {
    testWidgets('±15 adjusts the running rest', (tester) async {
      await makeExercise('bench');
      await startWith('bench');
      await pumpSession(tester);
      await tapComplete(tester);

      await tester.tap(find.text('+15'));
      await tester.pumpAndSettle();
      expect(find.text('3:15'), findsOneWidget);

      await tester.tap(find.text('−15'));
      await tester.pumpAndSettle();
      expect(find.text('3:00'), findsOneWidget);
    });

    testWidgets('pause holds the countdown, and resume restores it', (
      tester,
    ) async {
      await makeExercise('bench');
      await startWith('bench');
      await pumpSession(tester);
      await tapComplete(tester);

      await tester.tap(find.byTooltip('Pause'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Resume'), findsOneWidget);
      expect(find.text('3:00'), findsOneWidget);

      await tester.tap(find.byTooltip('Resume'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Pause'), findsOneWidget);
    });

    testWidgets('skip ends the rest', (tester) async {
      await makeExercise('bench');
      await startWith('bench');
      await pumpSession(tester);
      await tapComplete(tester);

      await tester.tap(find.byTooltip('Skip rest'));
      await tester.pumpAndSettle();

      expect(find.text('3:00'), findsNothing);
    });
  });

  group('the platform seam (F-TIM-003)', () {
    testWidgets('a start schedules the alert at the target instant', (
      tester,
    ) async {
      await makeExercise('bench');
      await startWith('bench');
      final container = await pumpSession(tester);
      await tapComplete(tester);

      final service =
          container.read(restTimerServiceProvider) as FakeRestTimerService;
      expect(service.scheduledFor, clock.add(const Duration(seconds: 180)));

      await tester.tap(find.byTooltip('Skip rest'));
      await tester.pumpAndSettle();

      // Skipping cancels the scheduled alert rather than leaving one armed for
      // a rest that is over.
      expect(service.scheduledFor, isNull);
    });
  });
}
