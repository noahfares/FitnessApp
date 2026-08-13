import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/plates/plate_calculator.dart';
import 'package:fitness_app/domain/progression/plate_aware_rounding.dart';
import 'package:fitness_app/domain/progression/progression_engine.dart';
import 'package:fitness_app/domain/progression/progression_rationale.dart';

/// `docs/40-ANALYTICS-SPEC.md` §13,
/// `docs/fixtures/analytics.json#plateMaths.plateAwareRoundingCase`.
void main() {
  const barGrams = 20000;
  const inventory = [
    PlateSpec(weightGrams: 20000, pairsAvailable: 4),
    PlateSpec(weightGrams: 10000, pairsAvailable: 2),
    PlateSpec(weightGrams: 5000, pairsAvailable: 2),
  ];

  test('a raw increase that rounds back to the previous weight holds weight '
      'and adds a rep instead', () {
    const target = TargetSet(
      weightGrams: 102500,
      reps: 5,
      sets: 3,
      rationale: ProgressionRationale(
        outcome: ProgressionOutcome.success,
        previousWeightGrams: 100000,
        previousReps: 5,
        deltaGrams: 2500,
      ),
    );

    final result = applyPlateRounding(
      target: target,
      barWeightGrams: barGrams,
      inventory: inventory,
      previousWeightGrams: 100000,
    );

    expect(result.weightGrams, 100000);
    expect(result.reps, 6);
    expect(result.rationale.outcome, ProgressionOutcome.plateRoundingHeld);
    expect(result.rationale.rawWeightGrams, 102500);
  });

  test('a raw target that is already assemblable is returned unchanged', () {
    const target = TargetSet(
      weightGrams: 100000,
      reps: 5,
      sets: 3,
      rationale: ProgressionRationale(outcome: ProgressionOutcome.firstRun),
    );

    final result = applyPlateRounding(
      target: target,
      barWeightGrams: barGrams,
      inventory: inventory,
    );

    expect(result.weightGrams, 100000);
    expect(result.rationale.outcome, ProgressionOutcome.firstRun);
  });

  test(
    'a rounded-down target that is not a full hold records the raw value',
    () {
      const target = TargetSet(
        weightGrams: 103000,
        reps: 5,
        sets: 3,
        rationale: ProgressionRationale(
          outcome: ProgressionOutcome.success,
          previousWeightGrams: 96000,
        ),
      );

      final result = applyPlateRounding(
        target: target,
        barWeightGrams: barGrams,
        inventory: inventory,
        previousWeightGrams: 96000,
      );

      expect(result.weightGrams, 100000);
      expect(result.rationale.outcome, ProgressionOutcome.success);
      expect(result.rationale.rawWeightGrams, 103000);
    },
  );

  test('a null weight target passes through untouched', () {
    const target = TargetSet(
      weightGrams: null,
      reps: null,
      sets: null,
      rationale: ProgressionRationale(outcome: ProgressionOutcome.firstRun),
    );

    final result = applyPlateRounding(
      target: target,
      barWeightGrams: barGrams,
      inventory: inventory,
    );

    expect(result, same(target));
  });

  group('applyFixedIncrementRounding (`F-PLT-005`)', () {
    const rack = [5000, 10000, 15000, 20000];

    test('a raw increase that rounds back to the previous weight holds', () {
      const target = TargetSet(
        weightGrams: 17000,
        reps: 5,
        sets: 3,
        rationale: ProgressionRationale(
          outcome: ProgressionOutcome.success,
          previousWeightGrams: 15000,
          previousReps: 5,
          deltaGrams: 2000,
        ),
      );

      final result = applyFixedIncrementRounding(
        target: target,
        availableGrams: rack,
        previousWeightGrams: 15000,
      );

      expect(result.weightGrams, 15000);
      expect(result.reps, 6);
      expect(result.rationale.outcome, ProgressionOutcome.plateRoundingHeld);
    });

    test('rounds down to the nearest stocked weight', () {
      const target = TargetSet(
        weightGrams: 18000,
        reps: 5,
        sets: 3,
        rationale: ProgressionRationale(
          outcome: ProgressionOutcome.success,
          previousWeightGrams: 10000,
        ),
      );

      final result = applyFixedIncrementRounding(
        target: target,
        availableGrams: rack,
        previousWeightGrams: 10000,
      );

      expect(result.weightGrams, 15000);
      expect(result.rationale.rawWeightGrams, 18000);
    });
  });

  group('applyStackRounding (`F-PLT-005`)', () {
    test('a raw increase that rounds back to the previous weight holds', () {
      const target = TargetSet(
        weightGrams: 32500,
        reps: 5,
        sets: 3,
        rationale: ProgressionRationale(
          outcome: ProgressionOutcome.success,
          previousWeightGrams: 30000,
          previousReps: 5,
          deltaGrams: 2500,
        ),
      );

      final result = applyStackRounding(
        target: target,
        baseGrams: 10000,
        stepGrams: 10000,
        previousWeightGrams: 30000,
      );

      expect(result.weightGrams, 30000);
      expect(result.reps, 6);
      expect(result.rationale.outcome, ProgressionOutcome.plateRoundingHeld);
    });

    test('an exact match on the half-step magnet is returned unchanged', () {
      const target = TargetSet(
        weightGrams: 32500,
        reps: 5,
        sets: 3,
        rationale: ProgressionRationale(outcome: ProgressionOutcome.success),
      );

      final result = applyStackRounding(
        target: target,
        baseGrams: 10000,
        stepGrams: 10000,
        halfStepGrams: 2500,
      );

      expect(result.weightGrams, 32500);
    });
  });
}
