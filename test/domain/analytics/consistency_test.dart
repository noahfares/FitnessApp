import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/week_start.dart';
import 'package:fitness_app/domain/analytics/analytics_set_record.dart';
import 'package:fitness_app/domain/analytics/consistency.dart';

/// Batch 3.4 — `F-ANA-006`. Reuses the `streak` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §5).
void main() {
  group('trainingDays', () {
    test('a date with a counted set is a training day', () {
      final record = AnalyticsSetRecord(
        date: DateTime(2026, 8, 3),
        setType: 'working',
        isCompleted: true,
        trackingType: 'weightReps',
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
        primaryMuscle: 'chest',
        secondaryMuscles: const [],
        weightGrams: 100000,
        reps: 5,
      );
      expect(trainingDays([record]), {DateTime(2026, 8, 3)});
    });

    test('warm-up-only or incomplete-only days are excluded', () {
      final warmupOnly = AnalyticsSetRecord(
        date: DateTime(2026, 8, 3),
        setType: 'warmup',
        isCompleted: true,
        trackingType: 'weightReps',
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
        primaryMuscle: 'chest',
        secondaryMuscles: const [],
        weightGrams: 60000,
        reps: 10,
      );
      expect(trainingDays([warmupOnly]), isEmpty);
    });
  });

  group('consistencyStats — fixture `streak`', () {
    // Weekly session counts, oldest -> newest, target 3, last entry current.
    const weeklyCounts = [3, 4, 3, 2, 3, 3, 3, 1];

    test('current streak is 3 — the in-progress week does not break it', () {
      final stats = consistencyStats(weeklyCounts, weeklyTarget: 3);
      expect(stats.currentStreak, 3);
    });

    test('longest streak is 3', () {
      final stats = consistencyStats(weeklyCounts, weeklyTarget: 3);
      expect(stats.longestStreak, 3);
    });

    test('sessions per week is 2.5', () {
      final stats = consistencyStats(weeklyCounts, weeklyTarget: 3);
      expect(stats.sessionsPerWeek, 2.5);
    });

    test('empty input returns zeroed stats, never throws', () {
      final stats = consistencyStats(const []);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.sessionsPerWeek, 0);
    });

    test('a single, still-in-progress week has no current streak yet', () {
      final stats = consistencyStats([3], weeklyTarget: 3);
      expect(stats.currentStreak, 0);
    });
  });

  group('weeklySessionCounts', () {
    test('zero-fills a week with no training in the middle of a range', () {
      final days = {
        DateTime(2026, 8, 3), // week of Aug 3
        DateTime(2026, 8, 17), // week of Aug 17 — Aug 10 has nothing
      };

      final counts = weeklySessionCounts(
        days,
        weekStart: WeekStart.monday,
        now: DateTime(2026, 8, 17),
      );

      expect(counts, [1, 0, 1]);
    });

    test('empty training days returns an empty list', () {
      expect(
        weeklySessionCounts(
          const {},
          weekStart: WeekStart.monday,
          now: DateTime(2026, 8, 17),
        ),
        isEmpty,
      );
    });
  });
}
