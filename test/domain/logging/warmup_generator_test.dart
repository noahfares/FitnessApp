import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/logging/warmup_generator.dart';

/// `F-LOG-020`.
void main() {
  group('generateWarmupSets', () {
    test('the default ramp: bar x8, 40% x5, 60% x3, 80% x1', () {
      final sets = generateWarmupSets(
        workingWeightGrams: 100000,
        minWeightGrams: 20000,
        roundToAchievable: (g) => g, // no rounding — exact percentages
      );

      expect(sets, hasLength(4));
      expect(sets[0].weightGrams, 20000); // the bar
      expect(sets[0].reps, 8);
      expect(sets[1].weightGrams, 40000);
      expect(sets[1].reps, 5);
      expect(sets[2].weightGrams, 60000);
      expect(sets[2].reps, 3);
      expect(sets[3].weightGrams, 80000);
      expect(sets[3].reps, 1);
    });

    test('rounding is delegated to the caller, never done here', () {
      final sets = generateWarmupSets(
        workingWeightGrams: 100000,
        minWeightGrams: 20000,
        // Rounds everything down to the nearest 2.5 kg, the way plate
        // rounding would for a real bar.
        roundToAchievable: (g) => (g ~/ 2500) * 2500,
      );

      expect(sets[1].weightGrams, 40000); // already a multiple of 2500
    });

    test(
      'a rounded step never lands below the minimum or above working weight',
      () {
        final sets = generateWarmupSets(
          workingWeightGrams: 100000,
          minWeightGrams: 20000,
          // A rounding function that (wrongly) proposes something absurd —
          // the clamp is what actually protects the caller.
          roundToAchievable: (g) => g < 50000 ? 1000 : 999000,
        );

        for (final s in sets) {
          expect(s.weightGrams, greaterThanOrEqualTo(20000));
          expect(s.weightGrams, lessThanOrEqualTo(100000));
        }
      },
    );

    test('a working weight lighter than the bar itself floors at the bar', () {
      final sets = generateWarmupSets(
        workingWeightGrams: 15000,
        minWeightGrams: 20000,
        roundToAchievable: (g) => g,
      );

      expect(sets.every((s) => s.weightGrams == 20000), isTrue);
    });

    test('a custom ruleset is used verbatim', () {
      final sets = generateWarmupSets(
        workingWeightGrams: 100000,
        minWeightGrams: 20000,
        roundToAchievable: (g) => g,
        ruleset: const [
          WarmupStep(percent: 0.5, reps: 5),
          WarmupStep(percent: 0.9, reps: 2),
        ],
      );

      expect(sets, hasLength(2));
      expect(sets[0].weightGrams, 50000);
      expect(sets[1].weightGrams, 90000);
    });
  });

  group('warmup ruleset JSON round-trip', () {
    test('encodes and decodes back to the same steps', () {
      const ruleset = [
        WarmupStep(percent: 0, reps: 8),
        WarmupStep(percent: 0.5, reps: 4),
      ];

      final decoded = decodeWarmupRuleset(encodeWarmupRuleset(ruleset));

      expect(decoded, ruleset);
    });

    test('null falls back to the default ruleset', () {
      expect(decodeWarmupRuleset(null), defaultWarmupRuleset);
    });

    test('malformed JSON falls back rather than throwing', () {
      expect(decodeWarmupRuleset('not json'), defaultWarmupRuleset);
      expect(decodeWarmupRuleset('{"not":"a list"}'), defaultWarmupRuleset);
      expect(decodeWarmupRuleset('[]'), defaultWarmupRuleset);
    });
  });
}
