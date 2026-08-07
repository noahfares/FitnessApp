import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/personal_records.dart';

/// Batch 2.6 — PR detection (`F-LOG-013`, `docs/40-ANALYTICS-SPEC.md` §4,
/// fixture `prDetection`).
void main() {
  group('detectPrs', () {
    test('fixture: 102.5×5 against 100×5/105×3 history', () {
      const existing = ExistingPrs(
        maxWeightGrams: 105000,
        existingMaxRepsAtThisWeight: null, // no prior set at 102.5 kg
        bestE1rmGrams: 116667, // from 100×5, higher than 105×3's 115500
        maxSessionVolumeGrams: 999999999, // not under test here
      );

      final hits = detectPrs(
        weightGrams: 102500,
        reps: 5,
        sessionVolumeGrams: 512500,
        existing: existing,
      );

      expect(hits, hasLength(2));
      // Most significant first (rule 5): bestE1rm before maxRepsAtWeight.
      expect(hits[0].kind, PrDetectionKind.bestE1rm);
      expect(hits[0].value, 119583);
      expect(hits[1].kind, PrDetectionKind.maxRepsAtWeight);
      expect(hits[1].value, 5);
      expect(hits[1].qualifierGrams, 102500);
    });

    test('a heavier prior weight blocks maxWeight even though this set PRs '
        'elsewhere', () {
      final hits = detectPrs(
        weightGrams: 102500,
        reps: 5,
        sessionVolumeGrams: 512500,
        existing: const ExistingPrs(
          maxWeightGrams: 105000,
          bestE1rmGrams: 116667,
          maxSessionVolumeGrams: 999999999,
        ),
      );

      expect(
        hits.map((h) => h.kind),
        isNot(contains(PrDetectionKind.maxWeight)),
      );
    });

    test('ties are not records (rule 1)', () {
      final hits = detectPrs(
        weightGrams: 100000,
        reps: 5,
        sessionVolumeGrams: 500000,
        existing: const ExistingPrs(
          maxWeightGrams: 100000,
          existingMaxRepsAtThisWeight: 5,
          bestE1rmGrams: 116667,
          maxSessionVolumeGrams: 500000,
        ),
      );

      expect(hits, isEmpty);
    });

    test('first-ever set is technically a PR on every kind (rule 3)', () {
      final hits = detectPrs(
        weightGrams: 60000,
        reps: 10,
        sessionVolumeGrams: 600000,
        existing: const ExistingPrs(),
      );

      expect(hits.map((h) => h.kind), containsAll(PrDetectionKind.values));
    });

    test('zero weight yields no e1RM PR (rule 5) — never zero, excluded', () {
      final hits = detectPrs(
        weightGrams: 0,
        reps: 10,
        sessionVolumeGrams: 0,
        existing: const ExistingPrs(bestE1rmGrams: 116667),
      );

      expect(
        hits.map((h) => h.kind),
        isNot(contains(PrDetectionKind.bestE1rm)),
      );
    });
  });
}
