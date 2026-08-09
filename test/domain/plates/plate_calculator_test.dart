import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/plates/plate_calculator.dart';

/// `docs/40-ANALYTICS-SPEC.md` §13, `docs/fixtures/analytics.json#plateMaths`.
void main() {
  const barGrams = 20000;
  const inventory = [
    PlateSpec(weightGrams: 20000, pairsAvailable: 4),
    PlateSpec(weightGrams: 10000, pairsAvailable: 2),
    PlateSpec(weightGrams: 5000, pairsAvailable: 2),
  ];

  group('solvePlateLoad', () {
    test('exact: 100 kg assembles from two 20 kg pairs', () {
      final result = solvePlateLoad(
        targetGrams: 100000,
        barWeightGrams: barGrams,
        inventory: inventory,
      );

      expect(result.status, PlateSolveStatus.exact);
      expect(result.achievedGrams, 100000);
      expect(result.plates, hasLength(1));
      expect(result.plates.single.weightGrams, 20000);
      expect(result.plates.single.pairs, 2);
    });

    test('inexact: 103 kg reports closest below and above', () {
      final result = solvePlateLoad(
        targetGrams: 103000,
        barWeightGrams: barGrams,
        inventory: inventory,
      );

      expect(result.status, PlateSolveStatus.closest);
      expect(result.closestBelowGrams, 100000);
      expect(result.closestAboveGrams, 110000);
    });

    test('below bar: target lighter than the bar itself', () {
      final result = solvePlateLoad(
        targetGrams: 15000,
        barWeightGrams: barGrams,
        inventory: inventory,
      );

      expect(result.status, PlateSolveStatus.belowBar);
      expect(result.closestAboveGrams, barGrams);
    });

    test('odd load: cannot split one gram evenly per side', () {
      final result = solvePlateLoad(
        targetGrams: 20001,
        barWeightGrams: barGrams,
        inventory: inventory,
      );

      expect(result.status, PlateSolveStatus.oddLoad);
    });

    test('never proposes plates the user does not have', () {
      final result = solvePlateLoad(
        targetGrams: 200000,
        barWeightGrams: barGrams,
        inventory: inventory,
      );

      // 4 pairs of 20 kg + 2 of 10 kg + 2 of 5 kg = bar + 2*(80+20+10) kg = 240 kg max.
      final totalAvailable =
          barGrams +
          2 *
              inventory
                  .map((p) => p.weightGrams * p.pairsAvailable)
                  .reduce((a, b) => a + b);
      expect(result.achievedGrams! <= totalAvailable, isTrue);
      for (final usage in result.plates) {
        final spec = inventory.firstWhere(
          (p) => p.weightGrams == usage.weightGrams,
        );
        expect(usage.pairs <= spec.pairsAvailable, isTrue);
      }
    });
  });

  group('closestAchievableGrams', () {
    test('down (default) rounds to the load at or below target', () {
      expect(
        closestAchievableGrams(
          targetGrams: 103000,
          barWeightGrams: barGrams,
          inventory: inventory,
        ),
        100000,
      );
    });

    test('up rounds to the load at or above target', () {
      expect(
        closestAchievableGrams(
          targetGrams: 103000,
          barWeightGrams: barGrams,
          inventory: inventory,
          direction: RoundingDirection.up,
        ),
        110000,
      );
    });

    test('nearest picks whichever side is numerically closer', () {
      expect(
        closestAchievableGrams(
          targetGrams: 103000,
          barWeightGrams: barGrams,
          inventory: inventory,
          direction: RoundingDirection.nearest,
        ),
        100000,
      );
    });

    test('exact target returns itself under every direction', () {
      for (final direction in RoundingDirection.values) {
        expect(
          closestAchievableGrams(
            targetGrams: 100000,
            barWeightGrams: barGrams,
            inventory: inventory,
            direction: direction,
          ),
          100000,
        );
      }
    });
  });
}
