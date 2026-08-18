import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/analytics_set_record.dart';
import 'package:fitness_app/domain/analytics/muscle_balance.dart';
import 'package:fitness_app/domain/catalog/muscle_taxonomy.dart';

/// Batch 3.4 — `F-ANA-008`. Reuses the `pushPullRatio` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §9).
void main() {
  group('pushPullRatio', () {
    test('fixture — 27:22, approximately 1.23:1', () {
      final ratio = pushPullRatio({
        'chest': 12,
        'frontDelts': 6,
        'triceps': 9,
        'lats': 10,
        'upperBack': 6,
        'biceps': 6,
      });

      expect(ratio.numeratorSets, 27);
      expect(ratio.denominatorSets, 22);
      expect(ratio.ratio, closeTo(1.227, 0.001));
    });

    test('zero pulling volume reports no ratio, not infinity', () {
      final ratio = pushPullRatio({'chest': 12});
      expect(ratio.denominatorSets, 0);
      expect(ratio.ratio, isNull);
    });

    test('sideDelts, traps, rearDelts and forearms are not counted', () {
      final withExtras = pushPullRatio({
        'chest': 12,
        'frontDelts': 6,
        'triceps': 9,
        'sideDelts': 100,
        'lats': 10,
        'upperBack': 6,
        'biceps': 6,
        'traps': 100,
      });
      expect(withExtras.numeratorSets, 27);
      expect(withExtras.denominatorSets, 22);
    });

    test('an empty map reports no ratio', () {
      final ratio = pushPullRatio(const {});
      expect(ratio.numeratorSets, 0);
      expect(ratio.denominatorSets, 0);
      expect(ratio.ratio, isNull);
    });
  });

  group('quadHamstringRatio', () {
    test('combines hamstrings and glutes in the denominator', () {
      final ratio = quadHamstringRatio({
        'quads': 10,
        'hamstrings': 4,
        'glutes': 4,
      });
      expect(ratio.numeratorSets, 10);
      expect(ratio.denominatorSets, 8);
      expect(ratio.ratio, 1.25);
    });

    test('zero leg volume reports no ratio', () {
      final ratio = quadHamstringRatio(const {});
      expect(ratio.ratio, isNull);
    });
  });

  group('volumeShareByCategory (F-ANA-008 radar)', () {
    AnalyticsSetRecord set(String muscle, int weightGrams, int reps) =>
        AnalyticsSetRecord(
          date: DateTime(2026, 3, 1),
          setType: 'working',
          isCompleted: true,
          trackingType: 'weightReps',
          exerciseId: 'ex',
          exerciseName: 'ex',
          primaryMuscle: muscle,
          secondaryMuscles: const [],
          weightGrams: weightGrams,
          reps: reps,
        );

    test('reports shares of total volume, not absolute load', () {
      final shares = volumeShareByCategory([
        set('chest', 100000, 10), // push, 1,000,000
        set('lats', 50000, 10), // pull,   500,000
        set('quads', 50000, 10), // legs,   500,000
      ]);

      expect(shares[MuscleCategory.push], closeTo(0.5, 1e-9));
      expect(shares[MuscleCategory.pull], closeTo(0.25, 1e-9));
      expect(shares[MuscleCategory.legs], closeTo(0.25, 1e-9));
      // Present at zero rather than missing: a dropped axis would change the
      // shape of the polygon and read as though core did not exist.
      expect(shares[MuscleCategory.core], 0);
    });

    test('every category is present even with no data at all', () {
      final shares = volumeShareByCategory(const []);
      expect(shares.keys.toSet(), MuscleCategory.values.toSet());
      expect(shares.values.every((v) => v == 0), isTrue);
    });

    test('uncategorised muscles are excluded, not forced into a category', () {
      final shares = volumeShareByCategory([
        set('chest', 100000, 10),
        set('neck', 100000, 10),
      ]);
      expect(shares[MuscleCategory.push], 1.0);
    });
  });
}
