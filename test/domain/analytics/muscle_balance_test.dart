import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/muscle_balance.dart';

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
}
