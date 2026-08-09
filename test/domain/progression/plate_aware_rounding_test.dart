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

  test(
    'a raw increase that rounds back to the previous weight holds weight '
    'and adds a rep instead',
    () {
      final target = TargetSet(
        weightGrams: 102500,
        reps: 5,
        sets: 3,
        rationale: const ProgressionRationale(
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
    },
  );

  test('a raw target that is already assemblable is returned unchanged', () {
    final target = TargetSet(
      weightGrams: 100000,
      reps: 5,
      sets: 3,
      rationale: const ProgressionRationale(
        outcome: ProgressionOutcome.firstRun,
      ),
    );

    final result = applyPlateRounding(
      target: target,
      barWeightGrams: barGrams,
      inventory: inventory,
    );

    expect(result.weightGrams, 100000);
    expect(result.rationale.outcome, ProgressionOutcome.firstRun);
  });

  test('a rounded-down target that is not a full hold records the raw value', () {
    final target = TargetSet(
      weightGrams: 103000,
      reps: 5,
      sets: 3,
      rationale: const ProgressionRationale(
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
  });

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
}
