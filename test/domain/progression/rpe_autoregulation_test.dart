import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/progression/progression_rationale.dart';
import 'package:fitness_app/domain/progression/progression_rule.dart';
import 'package:fitness_app/domain/progression/rpe_autoregulation.dart';

/// `F-PRG-005`. Reuses the `rpeAutoregulation` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §12,
/// `docs/fixtures/analytics.json#rpeAutoregulation`).
void main() {
  const config = RpeAutoregulationConfig(
    incrementGrams: 2500,
    backoffFraction: 0.10,
  );

  test('came in well under target: +2x increment', () {
    final result = applyRpeAutoregulation(
      weightGrams: 100000,
      gap: 1.5,
      config: config,
      previousReps: 5,
    );
    expect(result.weightGrams, 105000);
    expect(result.rationale.outcome, ProgressionOutcome.success);
  });

  test('came in under target: +increment', () {
    final result = applyRpeAutoregulation(
      weightGrams: 100000,
      gap: 0.5,
      config: config,
      previousReps: 5,
    );
    expect(result.weightGrams, 102500);
    expect(result.rationale.outcome, ProgressionOutcome.success);
  });

  test('exactly at target: +increment', () {
    final result = applyRpeAutoregulation(
      weightGrams: 100000,
      gap: 0,
      config: config,
      previousReps: 5,
    );
    expect(result.weightGrams, 102500);
    expect(result.rationale.outcome, ProgressionOutcome.success);
  });

  test('came in over target: repeat weight', () {
    final result = applyRpeAutoregulation(
      weightGrams: 100000,
      gap: -0.5,
      config: config,
      previousReps: 5,
    );
    expect(result.weightGrams, 100000);
    expect(result.rationale.outcome, ProgressionOutcome.partial);
  });

  test('came in well over target: 10% back-off', () {
    final result = applyRpeAutoregulation(
      weightGrams: 100000,
      gap: -1.5,
      config: config,
      previousReps: 5,
    );
    expect(result.weightGrams, 90000);
    expect(result.rationale.outcome, ProgressionOutcome.deload);
  });
}
