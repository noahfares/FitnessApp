import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/e1rm.dart';

/// Batch 2.6 — Epley e1RM (`docs/40-ANALYTICS-SPEC.md` §1, fixture `e1rm`).
void main() {
  group('epley1Rm', () {
    test('a genuine single returns the weight exactly (rule 1)', () {
      expect(epley1Rm(weightGrams: 100000, reps: 1), 100000);
    });

    test('fixture values', () {
      expect(epley1Rm(weightGrams: 100000, reps: 5), 116667);
      expect(epley1Rm(weightGrams: 100000, reps: 8), 126667);
      expect(epley1Rm(weightGrams: 100000, reps: 10), 133333);
      expect(epley1Rm(weightGrams: 60000, reps: 12), 84000);
    });

    test('zero or negative weight yields no e1RM, not zero (rule 5)', () {
      expect(epley1Rm(weightGrams: 0, reps: 5), isNull);
      expect(epley1Rm(weightGrams: -1000, reps: 5), isNull);
    });
  });

  group('estimate1Rm (F-SET-006, fixture `e1rm`)', () {
    test('a genuine single returns the weight exactly, every formula', () {
      for (final formula in E1rmFormula.values) {
        expect(
          estimate1Rm(
            weightGrams: 100000,
            reps: 1,
            formula: formula,
          )?.weightGrams,
          100000,
          reason: '$formula',
        );
      }
    });

    test('epley matches the fixture', () {
      expect(
        estimate1Rm(
          weightGrams: 100000,
          reps: 5,
          formula: E1rmFormula.epley,
        )?.weightGrams,
        116667,
      );
    });

    test('brzycki matches the fixture', () {
      expect(
        estimate1Rm(
          weightGrams: 100000,
          reps: 5,
          formula: E1rmFormula.brzycki,
        )?.weightGrams,
        112500,
      );
      expect(
        estimate1Rm(
          weightGrams: 100000,
          reps: 8,
          formula: E1rmFormula.brzycki,
        )?.weightGrams,
        124138,
      );
      expect(
        estimate1Rm(
          weightGrams: 60000,
          reps: 12,
          formula: E1rmFormula.brzycki,
        )?.weightGrams,
        86400,
      );
    });

    test('lombardi matches the fixture', () {
      expect(
        estimate1Rm(
          weightGrams: 100000,
          reps: 5,
          formula: E1rmFormula.lombardi,
        )?.weightGrams,
        117462,
      );
      expect(
        estimate1Rm(
          weightGrams: 100000,
          reps: 8,
          formula: E1rmFormula.lombardi,
        )?.weightGrams,
        123114,
      );
      expect(
        estimate1Rm(
          weightGrams: 100000,
          reps: 10,
          formula: E1rmFormula.lombardi,
        )?.weightGrams,
        125893,
      );
      expect(
        estimate1Rm(
          weightGrams: 60000,
          reps: 12,
          formula: E1rmFormula.lombardi,
        )?.weightGrams,
        76925,
      );
    });

    test('above 12 reps is unreliable, for every formula (rule 2)', () {
      for (final formula in E1rmFormula.values) {
        expect(
          estimate1Rm(weightGrams: 60000, reps: 15, formula: formula)?.reliable,
          isFalse,
          reason: '$formula',
        );
      }
    });

    test("brzycki at r >= 37 falls back to epley and is never reliable "
        '(rule 3)', () {
      final fallback = estimate1Rm(
        weightGrams: 100000,
        reps: 37,
        formula: E1rmFormula.brzycki,
      );
      final epley = epley1Rm(weightGrams: 100000, reps: 37);
      expect(fallback?.weightGrams, epley);
      expect(fallback?.reliable, isFalse);
    });

    test('zero or negative weight yields no estimate, not zero (rule 5)', () {
      expect(
        estimate1Rm(weightGrams: 0, reps: 5, formula: E1rmFormula.epley),
        isNull,
      );
    });
  });
}
