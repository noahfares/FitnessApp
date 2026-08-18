import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/analytics/presentation/insights_screen.dart';
import 'package:fitness_app/features/shell/widgets/weekly_bar_chart.dart';

import '../../support/harness.dart';

/// Batch 3.3 — `F-ANA-004`/`F-ANA-005` reached through the real
/// `InsightsScreen`, complementing the domain-level fixture tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  final clock = DateTime(2026, 7, 15);

  setUp(() {
    db = testDatabase();
    workouts = WorkoutRepository(db, clock: () => clock);
    sets = SetRepository(db, clock: () => clock);
  });

  Future<void> makeExercise(
    String id, {
    Muscle primaryMuscle = Muscle.chest,
    List<String> secondaryMuscles = const [],
  }) => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: id,
          primaryMuscle: primaryMuscle,
          secondaryMuscles: Value(secondaryMuscles),
          equipment: Equipment.barbell,
          trackingType: TrackingType.weightReps,
          createdAt: 1,
          updatedAt: 1,
        ),
      );

  testWidgets('no sessions shows the empty state', (tester) async {
    await pumpScreen(tester, const InsightsScreen(), db: db, now: clock);
    expect(find.text('No sessions yet'), findsOneWidget);
  });

  testWidgets('a logged session renders the overall volume chart', (
    tester,
  ) async {
    await makeExercise('bench', secondaryMuscles: const ['triceps']);
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, ['bench']);
    final we = (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
    final set = (await sets.getSets(we)).single;
    await sets.complete(
      set.id,
      weightGrams: const Value(100000),
      reps: const Value(5),
    );

    await pumpScreen(tester, const InsightsScreen(), db: db, now: clock);

    expect(find.text('No sessions yet'), findsNothing);
    // The muscle-balance, radar and training-load sections above push this
    // well past the initial viewport — and past what a lazy list has built,
    // so it has to be scrolled to rather than merely ensured visible.
    await tester.scrollUntilVisible(
      find.text('Overall weekly volume'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Overall weekly volume'), findsOneWidget);
    expect(find.byType(WeeklyBarChart), findsWidgets);
    // The dropdown's non-selected menu items render offstage for sizing.
    expect(find.text('Chest', skipOffstage: false), findsWidgets);
  });

  testWidgets(
    'training load and rep-range/intensity sections render (F-ANA-010, F-ANA-011)',
    (tester) async {
      await makeExercise('bench', secondaryMuscles: const ['triceps']);
      final workout = await workouts.start();
      await workouts.addExercises(workout.id, ['bench']);
      final we = (await workouts.watchExercises(workout.id).first)
          .single
          .workoutExerciseId;
      final set = (await sets.getSets(we)).single;
      await sets.complete(
        set.id,
        weightGrams: const Value(100000),
        reps: const Value(5),
      );

      await pumpScreen(tester, const InsightsScreen(), db: db, now: clock);

      expect(find.text('Training load'), findsOneWidget);
      expect(
        find.text('Needs at least 28 days of logged training to show.'),
        findsOneWidget,
      );

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Rep ranges'),
        500,
        scrollable: scrollable,
      );
      expect(find.text('Rep ranges'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Intensity (% of e1RM)'),
        500,
        scrollable: scrollable,
      );
      expect(find.text('Intensity (% of e1RM)'), findsOneWidget);
      // No prior session for this exercise, so it has no e1RM baseline yet —
      // the single logged set is excluded, not bucketed as zero (§10 rule 2).
      expect(find.text('Intensity (RPE)'), findsNothing);
    },
  );

  Future<void> logAndFinishOneSet(WidgetTester tester) async {
    await makeExercise('bench');
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, ['bench']);
    final we = (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
    final set = (await sets.getSets(we)).single;
    await sets.complete(
      set.id,
      weightGrams: const Value(100000),
      reps: const Value(5),
    );
    await workouts.finish(workout.id);
  }

  testWidgets('duration/rest compliance section renders, collapsed by default '
      '(F-ANA-012)', (tester) async {
    await logAndFinishOneSet(tester);

    await pumpScreen(tester, const InsightsScreen(), db: db, now: clock);

    final scrollable = find.byType(Scrollable).first;
    // Collapsed by default (`F-ROU-011`'s own starvation fix, same
    // reasoning here) — the header is always present, the chart only
    // after expanding.
    await tester.scrollUntilVisible(
      find.text('Duration & rest'),
      500,
      scrollable: scrollable,
    );
    expect(find.text('Duration & rest'), findsOneWidget);
    // No rest was recorded on a session's very first set.
    expect(find.text('not enough logged rest yet'), findsOneWidget);

    await tester.tap(find.text('Duration & rest'));
    await tester.pumpAndSettle();
    expect(find.text('Session duration'), findsOneWidget);
  });

  testWidgets(
    'muscle heat map section renders, collapsed by default (F-ANA-014)',
    (tester) async {
      await logAndFinishOneSet(tester);

      await pumpScreen(tester, const InsightsScreen(), db: db, now: clock);

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Muscle heat map'),
        500,
        scrollable: scrollable,
      );
      expect(find.text('Muscle heat map'), findsOneWidget);

      // scrollUntilVisible stops as soon as the widget exists, which can leave
      // it half off the bottom edge; the tap needs it fully on screen.
      await tester.ensureVisible(find.text('Muscle heat map'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Muscle heat map'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Front'),
        200,
        scrollable: scrollable,
      );
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      // No exception thrown switching views — the painter redraws cleanly.
      expect(find.text('Muscle heat map'), findsOneWidget);
    },
  );
}
