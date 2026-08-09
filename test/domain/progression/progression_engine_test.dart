import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/exercise_history.dart';
import 'package:fitness_app/domain/progression/progression_engine.dart';
import 'package:fitness_app/domain/progression/progression_rationale.dart';
import 'package:fitness_app/domain/progression/progression_rule.dart';

/// Batch 4.1 — `F-PRG-001`, `F-PRG-002`, `F-PRG-006`, `F-PRG-009`.
/// Reuses the `linearProgression` fixture (`docs/40-ANALYTICS-SPEC.md` §12,
/// `docs/fixtures/analytics.json#linearProgression`).
void main() {
  const config = LinearProgressionConfig(
    incrementGrams: 2500,
    failureThreshold: 3,
    deloadFraction: 0.10,
  );
  const context = ProgressionContext(
    staticWeightGrams: 100000,
    staticReps: 5,
    staticSets: 3,
  );

  ExerciseHistorySession session(List<(num, int)> sets) =>
      ExerciseHistorySession(
        workoutId: 'w',
        workoutName: 'Push',
        startedAt: 0,
        startedAtTzOffsetMinutes: 0,
        sets: [
          for (final (weightKg, reps) in sets)
            ExerciseHistorySet(
              setType: 'working',
              isCompleted: true,
              weightGrams: (weightKg * 1000).round(),
              reps: reps,
            ),
        ],
      );

  group('first run', () {
    test('no prior history falls back to the static target', () {
      final result = computeTargets(
        rule: const LinearProgressionRule(config: config),
        exerciseHistory: const [],
        context: context,
      );

      expect(result.weightGrams, 100000);
      expect(result.reps, 5);
      expect(result.sets, 3);
      expect(result.rationale.outcome, ProgressionOutcome.firstRun);
    });
  });

  group('linear progression', () {
    test('success: every set met target → +increment, streak resets', () {
      final result = computeTargets(
        rule: const LinearProgressionRule(config: config),
        exerciseHistory: [
          session([(100, 5), (100, 5), (100, 5)]),
        ],
        context: context,
      );

      expect(result.weightGrams, 102500);
      expect(result.rationale.outcome, ProgressionOutcome.success);
      expect(result.rationale.consecutiveFailures, 0);
    });

    test('partial: some sets missed → repeat weight, streak unaffected', () {
      final result = computeTargets(
        rule: const LinearProgressionRule(config: config),
        exerciseHistory: [
          session([(100, 5), (100, 5), (100, 3)]),
          session([(100, 3), (100, 3), (100, 3)]), // trailing failure, older
        ],
        context: context,
      );

      expect(result.weightGrams, 100000);
      expect(result.rationale.outcome, ProgressionOutcome.partial);
    });

    test('failure: no set met target → repeat weight, streak increments', () {
      final result = computeTargets(
        rule: const LinearProgressionRule(config: config),
        exerciseHistory: [
          session([(100, 3), (100, 3), (100, 3)]),
        ],
        context: context,
      );

      expect(result.weightGrams, 100000);
      expect(result.rationale.outcome, ProgressionOutcome.failure);
      expect(result.rationale.consecutiveFailures, 1);
    });

    test(
      'three consecutive failures at the same weight trigger a 10% deload',
      () {
        final result = computeTargets(
          rule: const LinearProgressionRule(config: config),
          exerciseHistory: [
            session([(100, 3), (100, 3), (100, 3)]),
            session([(100, 3), (100, 3), (100, 3)]),
            session([(100, 3), (100, 3), (100, 3)]),
          ],
          context: context,
        );

        expect(result.weightGrams, 90000);
        expect(result.rationale.outcome, ProgressionOutcome.deload);
        expect(result.rationale.consecutiveFailures, 3);
      },
    );

    test('a success between two failure runs breaks the streak, so a third '
        'failure alone does not deload', () {
      final result = computeTargets(
        rule: const LinearProgressionRule(config: config),
        exerciseHistory: [
          session([(100, 3), (100, 3), (100, 3)]), // failure, streak 1
        ],
        context: context,
      );
      // Sanity: this alone must not have deloaded.
      expect(result.weightGrams, 100000);
      expect(result.rationale.outcome, ProgressionOutcome.failure);
    });
  });

  group('double progression', () {
    const doubleConfig = DoubleProgressionConfig(
      incrementGrams: 2500,
      floorMissThreshold: 3,
      deloadFraction: 0.10,
    );
    const rangeContext = ProgressionContext(
      staticWeightGrams: 20000,
      staticReps: 8,
      staticRepsMax: 12,
      staticSets: 3,
    );

    test('every set at the top of the range: +increment, reps reset', () {
      final result = computeTargets(
        rule: const DoubleProgressionRule(config: doubleConfig),
        exerciseHistory: [
          session([(20, 12), (20, 12), (20, 12)]),
        ],
        context: rangeContext,
      );

      expect(result.weightGrams, 22500);
      expect(result.reps, 8);
      expect(result.rationale.outcome, ProgressionOutcome.repRangeTopMet);
    });

    test('mid-range sets: repeat weight, no streak', () {
      final result = computeTargets(
        rule: const DoubleProgressionRule(config: doubleConfig),
        exerciseHistory: [
          session([(20, 10), (20, 9), (20, 8)]),
        ],
        context: rangeContext,
      );

      expect(result.weightGrams, 20000);
      expect(result.rationale.outcome, ProgressionOutcome.partial);
    });

    test('every set below the floor: repeat weight, streak increments', () {
      final result = computeTargets(
        rule: const DoubleProgressionRule(config: doubleConfig),
        exerciseHistory: [
          session([(20, 7), (20, 6), (20, 5)]),
        ],
        context: rangeContext,
      );

      expect(result.weightGrams, 20000);
      expect(result.rationale.outcome, ProgressionOutcome.failure);
      expect(result.rationale.consecutiveFailures, 1);
    });

    test('three consecutive floor misses trigger a 10% deload', () {
      final result = computeTargets(
        rule: const DoubleProgressionRule(config: doubleConfig),
        exerciseHistory: [
          session([(20, 7), (20, 6), (20, 5)]),
          session([(20, 7), (20, 6), (20, 5)]),
          session([(20, 7), (20, 6), (20, 5)]),
        ],
        context: rangeContext,
      );

      expect(result.weightGrams, 18000);
      expect(result.rationale.outcome, ProgressionOutcome.deload);
      expect(result.rationale.consecutiveFailures, 3);
    });

    test('first run falls back to the static target', () {
      final result = computeTargets(
        rule: const DoubleProgressionRule(config: doubleConfig),
        exerciseHistory: const [],
        context: rangeContext,
      );

      expect(result.weightGrams, 20000);
      expect(result.reps, 8);
      expect(result.rationale.outcome, ProgressionOutcome.firstRun);
    });
  });

  group('manual carry-forward', () {
    test('carries the last session\'s top set forward verbatim', () {
      final result = computeTargets(
        rule: const ManualCarryForwardRule(),
        exerciseHistory: [
          session([(102.5, 5), (100, 5)]),
        ],
        context: context,
      );

      expect(result.weightGrams, 102500);
      expect(result.reps, 5);
      expect(result.rationale.outcome, ProgressionOutcome.manualCarryForward);
    });

    test('no automation applied even after a missed session', () {
      final result = computeTargets(
        rule: const ManualCarryForwardRule(),
        exerciseHistory: [
          session([(100, 3)]),
        ],
        context: context,
      );

      expect(result.weightGrams, 100000);
      expect(result.reps, 3);
    });
  });
}
