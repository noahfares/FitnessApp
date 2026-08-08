import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/exercise_history.dart';

/// Batch 3.1 — per-exercise history (`F-ANA-002`).
///
/// Reuses the session fixture from `docs/40-ANALYTICS-SPEC.md` §1
/// (`sessionE1rm`) and §2 (`volumeLoad`) — both built from the same four
/// sets (`warmup 60x10`, `100x5`, `100x5 or 105x3`, `95x8`), so one session
/// fixture proves both metrics agree with the spec.
void main() {
  ExerciseHistorySession sessionOf(List<ExerciseHistorySet> sets) =>
      ExerciseHistorySession(
        workoutId: 'w1',
        workoutName: 'Push day',
        startedAt: 0,
        startedAtTzOffsetMinutes: 0,
        sets: sets,
      );

  group('ExerciseHistorySession', () {
    test('excludes warm-up and incomplete sets from counted sets', () {
      final session = sessionOf([
        const ExerciseHistorySet(
          setType: 'warmup',
          isCompleted: true,
          weightGrams: 60000,
          reps: 10,
        ),
        const ExerciseHistorySet(
          setType: 'working',
          isCompleted: false,
          weightGrams: 100000,
          reps: 5,
        ),
        const ExerciseHistorySet(
          setType: 'working',
          isCompleted: true,
          weightGrams: 100000,
          reps: 5,
        ),
      ]);

      expect(session.countedSets, hasLength(1));
    });

    test('session e1RM fixture — best set is 95x8, not the heaviest set', () {
      final session = sessionOf([
        const ExerciseHistorySet(
          setType: 'warmup',
          isCompleted: true,
          weightGrams: 60000,
          reps: 10,
        ),
        const ExerciseHistorySet(
          setType: 'working',
          isCompleted: true,
          weightGrams: 100000,
          reps: 5,
        ),
        const ExerciseHistorySet(
          setType: 'working',
          isCompleted: true,
          weightGrams: 105000,
          reps: 3,
        ),
        const ExerciseHistorySet(
          setType: 'working',
          isCompleted: true,
          weightGrams: 95000,
          reps: 8,
        ),
      ]);

      expect(session.bestSet?.weightGrams, 95000);
      expect(session.bestSet?.reps, 8);
      expect(session.bestE1rmGrams, 120333);
    });

    test('volume load fixture — warm-up excluded, total 1760 kg', () {
      final session = sessionOf([
        const ExerciseHistorySet(
          setType: 'warmup',
          isCompleted: true,
          weightGrams: 60000,
          reps: 10,
        ),
        const ExerciseHistorySet(
          setType: 'working',
          isCompleted: true,
          weightGrams: 100000,
          reps: 5,
        ),
        const ExerciseHistorySet(
          setType: 'working',
          isCompleted: true,
          weightGrams: 100000,
          reps: 5,
        ),
        const ExerciseHistorySet(
          setType: 'working',
          isCompleted: true,
          weightGrams: 95000,
          reps: 8,
        ),
      ]);

      expect(session.volumeGrams, 1760000);
    });

    test('empty session returns defined empty results, never throws', () {
      final session = sessionOf(const []);

      expect(session.countedSets, isEmpty);
      expect(session.volumeGrams, 0);
      expect(session.bestSet, isNull);
      expect(session.bestE1rmGrams, isNull);
    });

    test('a set with no computable e1RM (zero weight) is excluded', () {
      final session = sessionOf([
        const ExerciseHistorySet(
          setType: 'working',
          isCompleted: true,
          weightGrams: 0,
          reps: 5,
        ),
      ]);

      expect(session.bestSet, isNull);
      expect(session.bestE1rmGrams, isNull);
    });
  });
}
