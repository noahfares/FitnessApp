import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/week_start.dart';
import 'package:fitness_app/domain/analytics/analytics_set_record.dart';
import 'package:fitness_app/domain/analytics/sets_per_muscle.dart';

/// Batch 3.3 — `F-ANA-005`. Reuses the `setsPerMuscle` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §3).
void main() {
  AnalyticsSetRecord workingSet({
    required String primaryMuscle,
    required List<String> secondaryMuscles,
    String exerciseName = 'Exercise',
  }) => AnalyticsSetRecord(
    date: DateTime(2026, 8, 3),
    setType: 'working',
    isCompleted: true,
    trackingType: 'weightReps',
    exerciseName: exerciseName,
    primaryMuscle: primaryMuscle,
    secondaryMuscles: secondaryMuscles,
    weightGrams: 60000,
    reps: 8,
  );

  test('fixture `setsPerMuscle` — bench 4 sets, overhead press 3 sets', () {
    final records = [
      for (var i = 0; i < 4; i++)
        workingSet(
          primaryMuscle: 'chest',
          secondaryMuscles: const ['triceps', 'frontDelts'],
        ),
      for (var i = 0; i < 3; i++)
        workingSet(
          primaryMuscle: 'frontDelts',
          secondaryMuscles: const ['triceps'],
        ),
    ];

    final byMuscle = setsPerMuscleByWeek(records, weekStart: WeekStart.monday);
    final week = DateTime(2026, 8, 3);

    expect(byMuscle['chest']!.single.sets, 4.0);
    expect(byMuscle['frontDelts']!.single.sets, 5.0);
    expect(byMuscle['triceps']!.single.sets, 3.5);
    expect(byMuscle['chest']!.single.weekStart, week);
  });

  test('warm-up and incomplete sets are excluded', () {
    final records = [
      AnalyticsSetRecord(
        date: DateTime(2026, 8, 3),
        setType: 'warmup',
        isCompleted: true,
        trackingType: 'weightReps',
        exerciseName: 'Exercise',
        primaryMuscle: 'chest',
        secondaryMuscles: const [],
        weightGrams: 60000,
        reps: 10,
      ),
      AnalyticsSetRecord(
        date: DateTime(2026, 8, 3),
        setType: 'working',
        isCompleted: false,
        trackingType: 'weightReps',
        exerciseName: 'Exercise',
        primaryMuscle: 'chest',
        secondaryMuscles: const [],
        weightGrams: 100000,
        reps: 5,
      ),
    ];

    expect(setsPerMuscleByWeek(records, weekStart: WeekStart.monday), isEmpty);
  });

  test('fullBody as primary contributes to no specific muscle (rule 4)', () {
    final records = [
      workingSet(primaryMuscle: 'fullBody', secondaryMuscles: const ['abs']),
    ];

    final byMuscle = setsPerMuscleByWeek(records, weekStart: WeekStart.monday);

    expect(byMuscle.containsKey('fullBody'), isFalse);
    expect(byMuscle['abs']!.single.sets, 0.5);
  });

  test('a muscle never trained has no key at all, not a zero entry', () {
    final records = [
      workingSet(primaryMuscle: 'chest', secondaryMuscles: const []),
    ];

    final byMuscle = setsPerMuscleByWeek(records, weekStart: WeekStart.monday);

    expect(byMuscle.containsKey('quads'), isFalse);
  });

  test('empty input returns an empty map, never throws', () {
    expect(setsPerMuscleByWeek(const [], weekStart: WeekStart.monday), isEmpty);
  });

  group('contributingExercises', () {
    test('ranks exercises by contribution, primary and secondary combined', () {
      final records = [
        workingSet(
          exerciseName: 'Bench Press',
          primaryMuscle: 'chest',
          secondaryMuscles: const [],
        ),
        workingSet(
          exerciseName: 'Bench Press',
          primaryMuscle: 'chest',
          secondaryMuscles: const [],
        ),
        workingSet(
          exerciseName: 'Overhead Press',
          primaryMuscle: 'frontDelts',
          secondaryMuscles: const ['chest'],
        ),
      ];

      final result = contributingExercises(records, muscle: 'chest');

      expect(result[0].exerciseName, 'Bench Press');
      expect(result[0].sets, 2.0);
      expect(result[1].exerciseName, 'Overhead Press');
      expect(result[1].sets, 0.5);
    });

    test('a muscle with no contributors returns an empty list', () {
      final records = [
        workingSet(primaryMuscle: 'chest', secondaryMuscles: const []),
      ];
      expect(contributingExercises(records, muscle: 'quads'), isEmpty);
    });

    test('scopes to one tapped week when week/weekStart are given', () {
      final records = [
        AnalyticsSetRecord(
          date: DateTime(2026, 8, 3),
          setType: 'working',
          isCompleted: true,
          trackingType: 'weightReps',
          exerciseName: 'Bench Press',
          primaryMuscle: 'chest',
          secondaryMuscles: const [],
          weightGrams: 60000,
          reps: 8,
        ),
        AnalyticsSetRecord(
          date: DateTime(2026, 8, 10),
          setType: 'working',
          isCompleted: true,
          trackingType: 'weightReps',
          exerciseName: 'Incline Press',
          primaryMuscle: 'chest',
          secondaryMuscles: const [],
          weightGrams: 50000,
          reps: 8,
        ),
      ];

      final result = contributingExercises(
        records,
        muscle: 'chest',
        week: DateTime(2026, 8, 3),
        weekStart: WeekStart.monday,
      );

      expect(result.single.exerciseName, 'Bench Press');
    });
  });
}
