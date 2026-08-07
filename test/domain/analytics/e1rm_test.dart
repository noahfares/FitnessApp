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
}
