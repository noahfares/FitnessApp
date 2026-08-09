import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/progression/double_progression.dart';
import 'package:fitness_app/domain/progression/progression_rationale.dart';
import 'package:fitness_app/domain/progression/progression_rule.dart';
import 'package:fitness_app/domain/progression/session_result.dart';

/// `F-PRG-003`. Reuses the `doubleProgression` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §12,
/// `docs/fixtures/analytics.json#doubleProgression`).
void main() {
  const config = DoubleProgressionConfig(
    incrementGrams: 2500,
    floorMissThreshold: 3,
    deloadFraction: 0.10,
  );

  test(
    'every set at the top of the range: +increment, reps reset to floor',
    () {
      final result = applyDoubleProgression(
        state: const DoubleProgressionState(weightGrams: 20000, floorMisses: 0),
        topResult: SessionResult.success,
        floorResult: SessionResult.success,
        config: config,
        previousReps: 12,
        repsMin: 8,
      );

      expect(result.state.weightGrams, 22500);
      expect(result.state.floorMisses, 0);
      expect(result.rationale.outcome, ProgressionOutcome.repRangeTopMet);
      expect(result.rationale.targetReps, 8);
    },
  );

  test('some sets clear the floor but not the ceiling: repeat, no streak', () {
    final result = applyDoubleProgression(
      state: const DoubleProgressionState(weightGrams: 20000, floorMisses: 0),
      topResult: SessionResult.partial,
      floorResult: SessionResult.success,
      config: config,
      previousReps: 8,
      repsMin: 8,
    );

    expect(result.state.weightGrams, 20000);
    expect(result.state.floorMisses, 0);
    expect(result.rationale.outcome, ProgressionOutcome.partial);
  });

  test('every set below the floor: repeat weight, streak increments', () {
    final result = applyDoubleProgression(
      state: const DoubleProgressionState(weightGrams: 20000, floorMisses: 0),
      topResult: SessionResult.failure,
      floorResult: SessionResult.failure,
      config: config,
      previousReps: 7,
      repsMin: 8,
    );

    expect(result.state.weightGrams, 20000);
    expect(result.state.floorMisses, 1);
    expect(result.rationale.outcome, ProgressionOutcome.failure);
  });

  test('three consecutive floor misses trigger a 10% deload', () {
    final result = applyDoubleProgression(
      state: const DoubleProgressionState(weightGrams: 20000, floorMisses: 2),
      topResult: SessionResult.failure,
      floorResult: SessionResult.failure,
      config: config,
      previousReps: 7,
      repsMin: 8,
    );

    expect(result.state.weightGrams, 18000);
    expect(result.state.floorMisses, 0);
    expect(result.rationale.outcome, ProgressionOutcome.deload);
    expect(result.rationale.consecutiveFailures, 3);
  });
}
