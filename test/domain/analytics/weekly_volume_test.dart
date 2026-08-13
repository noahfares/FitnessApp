import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/week_start.dart';
import 'package:fitness_app/domain/analytics/analytics_set_record.dart';
import 'package:fitness_app/domain/analytics/exercise_history.dart';
import 'package:fitness_app/domain/analytics/weekly_volume.dart';

/// Batch 3.3 — `F-ANA-004`. Reuses the `volumeLoad` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §2).
void main() {
  AnalyticsSetRecord recordOn(
    DateTime date, {
    required String setType,
    required int weightGrams,
    required int reps,
    String primaryMuscle = 'chest',
    String trackingType = 'weightReps',
  }) => AnalyticsSetRecord(
    date: date,
    setType: setType,
    isCompleted: true,
    trackingType: trackingType,
    exerciseId: 'ex-1',
    exerciseName: 'Exercise',
    primaryMuscle: primaryMuscle,
    secondaryMuscles: const [],
    weightGrams: weightGrams,
    reps: reps,
  );

  AnalyticsSetRecord bodyweightRecordOn(
    DateTime date, {
    required int reps,
    int addedGrams = 0,
    int? workoutBodyweightGrams,
    double? bodyweightCoefficient,
  }) => AnalyticsSetRecord(
    date: date,
    setType: 'working',
    isCompleted: true,
    trackingType: 'bodyweightReps',
    exerciseId: 'ex-1',
    exerciseName: 'Pull-up',
    primaryMuscle: 'back',
    secondaryMuscles: const [],
    weightGrams: addedGrams,
    reps: reps,
    workoutBodyweightGrams: workoutBodyweightGrams,
    bodyweightCoefficient: bodyweightCoefficient,
  );

  group('weeklyVolume', () {
    test(
      'bodyweightReps uses effective load (`F-LOG-019`), not added weight alone',
      () {
        final monday = DateTime(2026, 8, 3);
        final points = weeklyVolume([
          bodyweightRecordOn(
            monday,
            reps: 5,
            addedGrams: 10000,
            workoutBodyweightGrams: 80000,
          ),
        ], weekStart: WeekStart.monday);

        // (80 kg bodyweight + 10 kg added) x 5 reps.
        expect(points.single.volumeGrams, 450000);
      },
    );

    test(
      'bodyweightReps with no captured bodyweight falls back to added weight alone',
      () {
        final monday = DateTime(2026, 8, 3);
        final points = weeklyVolume([
          bodyweightRecordOn(monday, reps: 5, addedGrams: 10000),
        ], weekStart: WeekStart.monday);

        expect(points.single.volumeGrams, 50000);
      },
    );

    test('fixture `volumeLoad` — warm-up excluded, total 1760 kg', () {
      final monday = DateTime(2026, 8, 3);
      final records = [
        recordOn(monday, setType: 'warmup', weightGrams: 60000, reps: 10),
        recordOn(monday, setType: 'working', weightGrams: 100000, reps: 5),
        recordOn(monday, setType: 'working', weightGrams: 100000, reps: 5),
        recordOn(monday, setType: 'working', weightGrams: 95000, reps: 8),
      ];

      final points = weeklyVolume(records, weekStart: WeekStart.monday);

      expect(points, hasLength(1));
      expect(points.single.weekStart, monday);
      expect(points.single.volumeGrams, 1760000);
    });

    test('non-weight tracking types are excluded, not counted as zero', () {
      final records = [
        recordOn(
          DateTime(2026, 8, 3),
          setType: 'working',
          weightGrams: 0,
          reps: 20,
          trackingType: 'reps',
        ),
      ];

      final points = weeklyVolume(records, weekStart: WeekStart.monday);

      expect(points, isEmpty);
    });

    test('scoping to a muscle attributes by primary muscle only', () {
      final monday = DateTime(2026, 8, 3);
      final records = [
        recordOn(
          monday,
          setType: 'working',
          weightGrams: 100000,
          reps: 5,
          primaryMuscle: 'chest',
        ),
        recordOn(
          monday,
          setType: 'working',
          weightGrams: 50000,
          reps: 10,
          primaryMuscle: 'quads',
        ),
      ];

      final chestOnly = weeklyVolume(
        records,
        weekStart: WeekStart.monday,
        muscle: 'chest',
      );

      expect(chestOnly, hasLength(1));
      expect(chestOnly.single.volumeGrams, 500000);
    });

    test('sums across weeks, oldest to newest', () {
      final week1 = DateTime(2026, 8, 3);
      final week2 = DateTime(2026, 8, 10);
      final points = weeklyVolume([
        recordOn(week2, setType: 'working', weightGrams: 100000, reps: 5),
        recordOn(week1, setType: 'working', weightGrams: 80000, reps: 5),
      ], weekStart: WeekStart.monday);

      expect(points.map((p) => p.weekStart), [week1, week2]);
    });

    test('empty input returns an empty result, never throws', () {
      expect(weeklyVolume(const [], weekStart: WeekStart.monday), isEmpty);
    });
  });

  group('dailyVolume (F-ANA-010)', () {
    test('sums same-day sets and excludes warm-ups', () {
      final day = DateTime(2026, 8, 3);
      final records = [
        recordOn(day, setType: 'warmup', weightGrams: 60000, reps: 10),
        recordOn(day, setType: 'working', weightGrams: 100000, reps: 5),
        recordOn(day, setType: 'working', weightGrams: 100000, reps: 5),
      ];

      final points = dailyVolume(records);

      expect(points, hasLength(1));
      expect(points.single.date, day);
      expect(points.single.volumeGrams, 1000000);
    });

    test('keeps separate days apart, oldest to newest', () {
      final day1 = DateTime(2026, 8, 3);
      final day2 = DateTime(2026, 8, 4);
      final points = dailyVolume([
        recordOn(day2, setType: 'working', weightGrams: 100000, reps: 5),
        recordOn(day1, setType: 'working', weightGrams: 80000, reps: 5),
      ]);

      expect(points.map((p) => p.date), [day1, day2]);
    });

    test('empty input returns an empty result', () {
      expect(dailyVolume(const []), isEmpty);
    });
  });

  group('weeklyVolumeFromSessions', () {
    ExerciseHistorySession sessionOn(
      DateTime date,
      List<ExerciseHistorySet> sets,
    ) => ExerciseHistorySession(
      workoutId: date.toIso8601String(),
      workoutName: 'Session',
      startedAt: date.millisecondsSinceEpoch,
      startedAtTzOffsetMinutes: 0,
      sets: sets,
    );

    const set = ExerciseHistorySet(
      setType: 'working',
      isCompleted: true,
      weightGrams: 100000,
      reps: 5,
    );

    test('sums sessions within the same week', () {
      final points = weeklyVolumeFromSessions([
        sessionOn(DateTime(2026, 8, 3), [set]),
        sessionOn(DateTime(2026, 8, 5), [set]),
      ], weekStart: WeekStart.monday);

      expect(points, hasLength(1));
      expect(points.single.volumeGrams, 1000000);
    });

    test('a session with zero volume is excluded, not counted as zero', () {
      final points = weeklyVolumeFromSessions([
        sessionOn(DateTime(2026, 8, 3), const [
          ExerciseHistorySet(
            setType: 'warmup',
            isCompleted: true,
            weightGrams: 60000,
            reps: 10,
          ),
        ]),
      ], weekStart: WeekStart.monday);

      expect(points, isEmpty);
    });

    test('empty input returns an empty result, never throws', () {
      expect(
        weeklyVolumeFromSessions(const [], weekStart: WeekStart.monday),
        isEmpty,
      );
    });
  });
}
