import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/week_start.dart';
import 'package:fitness_app/domain/analytics/analytics_set_record.dart';
import 'package:fitness_app/domain/analytics/weekly_insights.dart';

/// Batch 4.5's second pass — `F-ANA-013`. Reuses the `weeklyInsights` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §14).
void main() {
  const weekStart = WeekStart.monday;
  final w1 = DateTime(2026, 1, 5);
  final w2 = w1.add(const Duration(days: 7));
  final w3 = w1.add(const Duration(days: 14));
  final w4 = w1.add(const Duration(days: 21));
  final w5 = w1.add(const Duration(days: 28));
  final now = w5;

  AnalyticsSetRecord counted({
    required DateTime date,
    required String exerciseId,
    required String muscle,
    int? weightGrams,
    int? reps,
  }) => AnalyticsSetRecord(
    date: date,
    setType: 'working',
    isCompleted: true,
    trackingType: 'weightReps',
    exerciseId: exerciseId,
    exerciseName: exerciseId,
    primaryMuscle: muscle,
    secondaryMuscles: const [],
    weightGrams: weightGrams,
    reps: reps,
  );

  test('fixture: weeklyInsights', () {
    final records = <AnalyticsSetRecord>[
      // Chest volume: W1 18000, W2 19000, W3 21000, W4 22000, W5 28000.
      for (final (date, kg) in [
        (w1, 18),
        (w2, 19),
        (w3, 21),
        (w4, 22),
        (w5, 28),
      ])
        counted(
          date: date,
          exerciseId: 'bench',
          muscle: 'chest',
          weightGrams: kg * 1000,
          reps: 1,
        ),
      // Squat e1RM: W1 140, W2 142.5, W3 141, W4 143, W5 148 (kg, reps=1 so
      // Epley returns the weight exactly).
      for (final (date, kg) in [
        (w1, 140.0),
        (w2, 142.5),
        (w3, 141.0),
        (w4, 143.0),
        (w5, 148.0),
      ])
        counted(
          date: date,
          exerciseId: 'squat',
          muscle: 'quads',
          weightGrams: (kg * 1000).round(),
          reps: 1,
        ),
      // Rear delts: 4 sets in W5 only.
      for (var i = 0; i < 4; i++)
        counted(
          date: w5,
          exerciseId: 'rear-delt-fly',
          muscle: 'rearDelts',
          weightGrams: 10000,
          reps: 12,
        ),
      // Biceps volume: a real change, but under the 20% threshold.
      for (final (date, kg) in [
        (w1, 10.0),
        (w2, 10.2),
        (w3, 9.9),
        (w4, 10.1),
        (w5, 10.3),
      ])
        counted(
          date: date,
          exerciseId: 'curl',
          muscle: 'biceps',
          weightGrams: (kg * 1000).round(),
          reps: 1,
        ),
    ];

    final insights = generateWeeklyInsights(
      records,
      weekStart: weekStart,
      now: now,
    );

    final chest = insights.firstWhere(
      (i) => i.kind == InsightKind.muscleVolumeChange && i.muscle == 'chest',
    );
    expect(chest.currentValue, 28000);
    expect(chest.previousValue, 20000);

    final squat = insights.firstWhere(
      (i) =>
          i.kind == InsightKind.exerciseE1rmNewHigh && i.exerciseId == 'squat',
    );
    expect(squat.currentValue, 148000);
    expect(squat.previousValue, 143000);

    final rearDelts = insights.firstWhere(
      (i) =>
          i.kind == InsightKind.muscleSetsLastWeek && i.muscle == 'rearDelts',
    );
    expect(rearDelts.currentValue, 4);
    expect(rearDelts.previousValue, isNull);

    // Biceps volume moved only ~2.5% — under threshold, never shown.
    expect(
      insights.any(
        (i) => i.kind == InsightKind.muscleVolumeChange && i.muscle == 'biceps',
      ),
      isFalse,
    );

    // A plain "sets last week" fact never crowds out a real comparison,
    // however busy the muscle — both comparison insights above rank ahead
    // of every fact-only card.
    final firstFactIndex = insights.indexOf(rearDelts);
    final lastComparisonIndex =
        insights.indexOf(squat) > insights.indexOf(chest)
        ? insights.indexOf(squat)
        : insights.indexOf(chest);
    expect(firstFactIndex, greaterThan(lastComparisonIndex));
  });

  test('fewer than 3 distinct weeks of history yields no insights at all', () {
    final records = [
      counted(
        date: w4,
        exerciseId: 'bench',
        muscle: 'chest',
        weightGrams: 60000,
        reps: 10,
      ),
      counted(
        date: w5,
        exerciseId: 'bench',
        muscle: 'chest',
        weightGrams: 60000,
        reps: 10,
      ),
    ];

    expect(
      generateWeeklyInsights(records, weekStart: weekStart, now: w5),
      isEmpty,
    );
  });

  test('empty input is empty, not an error', () {
    expect(
      generateWeeklyInsights(const [], weekStart: weekStart, now: now),
      isEmpty,
    );
  });
}
