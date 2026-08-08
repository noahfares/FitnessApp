import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/date_range.dart';
import 'package:fitness_app/domain/analytics/e1rm.dart';
import 'package:fitness_app/domain/analytics/e1rm_trend.dart';
import 'package:fitness_app/domain/analytics/exercise_history.dart';

/// Batch 3.2 — `F-ANA-003`. Reuses the `sessionE1rm` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §1) that `F-ANA-002`'s own test already
/// covers for Epley, and adds formula selection and date scoping on top.
void main() {
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

  const fixtureSets = [
    ExerciseHistorySet(
      setType: 'warmup',
      isCompleted: true,
      weightGrams: 60000,
      reps: 10,
    ),
    ExerciseHistorySet(
      setType: 'working',
      isCompleted: true,
      weightGrams: 100000,
      reps: 5,
    ),
    ExerciseHistorySet(
      setType: 'working',
      isCompleted: true,
      weightGrams: 105000,
      reps: 3,
    ),
    ExerciseHistorySet(
      setType: 'working',
      isCompleted: true,
      weightGrams: 95000,
      reps: 8,
    ),
  ];

  group('e1rmTrend', () {
    test('fixture `sessionE1rm` under Epley — one point, 95x8 wins', () {
      final points = e1rmTrend([
        sessionOn(DateTime(2026, 1, 1), fixtureSets),
      ], formula: E1rmFormula.epley);

      expect(points, hasLength(1));
      expect(points.single.e1rmGrams, 120333);
      expect(points.single.reliable, isTrue);
    });

    test('sorts oldest to newest regardless of input order', () {
      final points = e1rmTrend([
        sessionOn(DateTime(2026, 3, 1), fixtureSets),
        sessionOn(DateTime(2026, 1, 1), fixtureSets),
        sessionOn(DateTime(2026, 2, 1), fixtureSets),
      ], formula: E1rmFormula.epley);

      expect(points.map((p) => p.date), [
        DateTime(2026, 1, 1),
        DateTime(2026, 2, 1),
        DateTime(2026, 3, 1),
      ]);
    });

    test('sessions outside the range are excluded', () {
      final points = e1rmTrend(
        [
          sessionOn(DateTime(2026, 1, 1), fixtureSets),
          sessionOn(DateTime(2026, 6, 1), fixtureSets),
        ],
        formula: E1rmFormula.epley,
        range: DateRange(
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 7, 1),
        ),
      );

      expect(points, hasLength(1));
      expect(points.single.date, DateTime(2026, 6, 1));
    });

    test('a session with no computable e1RM produces no point', () {
      final points = e1rmTrend([
        sessionOn(DateTime(2026, 1, 1), const [
          ExerciseHistorySet(
            setType: 'warmup',
            isCompleted: true,
            weightGrams: 60000,
            reps: 10,
          ),
        ]),
      ], formula: E1rmFormula.epley);

      expect(points, isEmpty);
    });

    test('reps above 12 mark the point unreliable', () {
      final points = e1rmTrend([
        sessionOn(DateTime(2026, 1, 1), const [
          ExerciseHistorySet(
            setType: 'working',
            isCompleted: true,
            weightGrams: 40000,
            reps: 15,
          ),
        ]),
      ], formula: E1rmFormula.epley);

      expect(points.single.reliable, isFalse);
    });
  });
}
