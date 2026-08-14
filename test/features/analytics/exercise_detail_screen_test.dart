import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/repositories/set_repository.dart';
import 'package:fitness_app/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/analytics/presentation/exercise_detail_screen.dart';
import 'package:fitness_app/features/shell/widgets/empty_state.dart';
import 'package:fitness_app/features/shell/widgets/trend_chart.dart';

import '../../support/harness.dart';

/// Batch 3.2 — `F-ANA-003`'s trend chart, reached through the real
/// `ExerciseDetailScreen` rather than only at the domain layer, complementing
/// `e1rm_trend_test.dart`'s pure-function fixture coverage.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late WorkoutRepository workouts;
  late SetRepository sets;
  var clock = DateTime(2026, 8, 1);

  setUp(() {
    db = testDatabase();
    clock = DateTime(2026, 8, 1);
    workouts = WorkoutRepository(db, clock: () => clock);
    sets = SetRepository(db, clock: () => clock);
  });

  Future<void> makeExercise(String id) => db
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

  Future<void> loggedSession(String exerciseId, int weightGrams) async {
    final workout = await workouts.start();
    await workouts.addExercises(workout.id, [exerciseId]);
    final we = (await workouts.watchExercises(workout.id).first)
        .single
        .workoutExerciseId;
    final set = (await sets.getSets(we)).single;
    await sets.complete(
      set.id,
      weightGrams: Value(weightGrams),
      reps: const Value(5),
    );
    await workouts.finish(workout.id);
  }

  testWidgets(
    'fewer than three sessions shows "not enough data yet" for the trend',
    (tester) async {
      await makeExercise('bench');
      clock = DateTime(2026, 7, 1);
      await loggedSession('bench', 100000);
      clock = DateTime(2026, 7, 15);
      await loggedSession('bench', 102500);

      await pumpScreen(
        tester,
        const ExerciseDetailScreen(exerciseId: 'bench'),
        db: db,
        now: clock,
      );

      expect(find.text('Not enough data yet'), findsOneWidget);
      expect(find.byType(EmptyState), findsOneWidget);
    },
  );

  testWidgets('three or more sessions renders the trend chart and the '
      'session list', (tester) async {
    await makeExercise('bench');
    clock = DateTime(2026, 7, 1);
    await loggedSession('bench', 100000);
    clock = DateTime(2026, 7, 10);
    await loggedSession('bench', 102500);
    clock = DateTime(2026, 7, 20);
    await loggedSession('bench', 105000);

    await pumpScreen(
      tester,
      const ExerciseDetailScreen(exerciseId: 'bench'),
      db: db,
      now: clock,
    );

    expect(find.text('Not enough data yet'), findsNothing);
    expect(find.byType(TrendChart), findsOneWidget);
    expect(find.text('e1RM trend'), findsOneWidget);
    expect(find.text('Formula: Epley'), findsOneWidget);
  });

  testWidgets('renders at 200% text scale with no overflow (F-A11Y-002)', (
    tester,
  ) async {
    await makeExercise('bench');
    clock = DateTime(2026, 7, 1);
    await loggedSession('bench', 100000);
    clock = DateTime(2026, 7, 10);
    await loggedSession('bench', 102500);
    clock = DateTime(2026, 7, 20);
    await loggedSession('bench', 105000);

    await pumpScreen(
      tester,
      const ExerciseDetailScreen(exerciseId: 'bench'),
      db: db,
      now: clock,
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
  });

  group('stall detection (F-ANA-009, batch 4.5)', () {
    testWidgets('a flat e1RM over 5+ weekly sessions shows the stall banner', (
      tester,
    ) async {
      await makeExercise('bench');
      for (var i = 0; i < 5; i++) {
        clock = DateTime(2026, 7, 1).add(Duration(days: i * 7));
        await loggedSession('bench', 100000);
      }

      await pumpScreen(
        tester,
        const ExerciseDetailScreen(exerciseId: 'bench'),
        db: db,
        now: clock,
      );

      await tester.scrollUntilVisible(
        find.textContaining("hasn't moved in a while"),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining("hasn't moved in a while"), findsOneWidget);
    });

    testWidgets('a clearly progressing exercise shows no stall banner', (
      tester,
    ) async {
      await makeExercise('bench');
      for (var i = 0; i < 5; i++) {
        clock = DateTime(2026, 7, 1).add(Duration(days: i * 7));
        await loggedSession('bench', 100000 + i * 5000);
      }

      await pumpScreen(
        tester,
        const ExerciseDetailScreen(exerciseId: 'bench'),
        db: db,
        now: clock,
      );

      expect(find.textContaining("hasn't moved in a while"), findsNothing);
    });

    testWidgets('fewer than 5 sessions shows no stall banner either way', (
      tester,
    ) async {
      await makeExercise('bench');
      clock = DateTime(2026, 7, 1);
      await loggedSession('bench', 100000);
      clock = DateTime(2026, 7, 22);
      await loggedSession('bench', 100000);

      await pumpScreen(
        tester,
        const ExerciseDetailScreen(exerciseId: 'bench'),
        db: db,
        now: clock,
      );

      expect(find.textContaining("hasn't moved in a while"), findsNothing);
    });
  });
}
