import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/plates/plate_calculator.dart';
import 'package:fitness_app/domain/plates/weight_source_calculator.dart';

/// `F-PLT-005`, `docs/40-ANALYTICS-SPEC.md` §13.
void main() {
  group('closestAchievableFixedIncrement', () {
    // A rack that skips a rung — 5, 10, 15, 22.5, 30 kg — deliberately
    // unevenly spaced, the exact case a fixed step size can't represent.
    const rack = [5000, 10000, 15000, 22500, 30000];

    test('returns the exact match when the target is stocked', () {
      expect(
        closestAchievableFixedIncrement(
          targetGrams: 15000,
          availableGrams: rack,
        ),
        15000,
      );
    });

    test('down rounds to the next weight actually on the rack', () {
      expect(
        closestAchievableFixedIncrement(
          targetGrams: 20000,
          availableGrams: rack,
        ),
        15000,
      );
    });

    test('up rounds to the next weight up', () {
      expect(
        closestAchievableFixedIncrement(
          targetGrams: 20000,
          availableGrams: rack,
          direction: RoundingDirection.up,
        ),
        22500,
      );
    });

    test(
      'nearest picks whichever is numerically closer, ties favouring down',
      () {
        expect(
          closestAchievableFixedIncrement(
            targetGrams: 18750,
            availableGrams: rack,
            direction: RoundingDirection.nearest,
          ),
          15000,
        );
        expect(
          closestAchievableFixedIncrement(
            targetGrams: 20000,
            availableGrams: rack,
            direction: RoundingDirection.nearest,
          ),
          22500,
        );
      },
    );

    test('below the lightest weight, down returns null and up returns it', () {
      expect(
        closestAchievableFixedIncrement(
          targetGrams: 2000,
          availableGrams: rack,
        ),
        isNull,
      );
      expect(
        closestAchievableFixedIncrement(
          targetGrams: 2000,
          availableGrams: rack,
          direction: RoundingDirection.up,
        ),
        5000,
      );
    });

    test('an empty rack has nothing achievable', () {
      expect(
        closestAchievableFixedIncrement(targetGrams: 10000, availableGrams: []),
        isNull,
      );
    });
  });

  group('closestAchievableStack', () {
    // 10 kg base, 10 kg steps, an optional 2.5 kg add-on magnet.
    const base = 10000;
    const step = 10000;
    const halfStep = 2500;

    test('exact match on a plain step', () {
      expect(
        closestAchievableStack(
          targetGrams: 30000,
          baseGrams: base,
          stepGrams: step,
        ),
        30000,
      );
    });

    test('exact match using the half-step magnet', () {
      expect(
        closestAchievableStack(
          targetGrams: 32500,
          baseGrams: base,
          stepGrams: step,
          halfStepGrams: halfStep,
        ),
        32500,
      );
    });

    test('without a configured half step, 32.5 kg rounds down to 30 kg', () {
      expect(
        closestAchievableStack(
          targetGrams: 32500,
          baseGrams: base,
          stepGrams: step,
        ),
        30000,
      );
    });

    test('up rounds to the next reachable pin', () {
      expect(
        closestAchievableStack(
          targetGrams: 33000,
          baseGrams: base,
          stepGrams: step,
          halfStepGrams: halfStep,
          direction: RoundingDirection.up,
        ),
        40000,
      );
    });

    test('below the base, down is unachievable and up returns the base', () {
      expect(
        closestAchievableStack(
          targetGrams: 5000,
          baseGrams: base,
          stepGrams: step,
        ),
        isNull,
      );
      expect(
        closestAchievableStack(
          targetGrams: 5000,
          baseGrams: base,
          stepGrams: step,
          direction: RoundingDirection.up,
        ),
        base,
      );
    });
  });
}
