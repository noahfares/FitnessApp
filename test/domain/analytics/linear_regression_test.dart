import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/linear_regression.dart';

/// Batch 3.2 — shared least-squares slope, first used by `F-ANA-003`'s
/// regression overlay. Validated against the `slope` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §7), which is the same computation on
/// different data — `F-ANA-009` (Phase 4) will reuse this function rather
/// than reimplementing it.
void main() {
  group('linearRegression', () {
    test('fixture `slope` — five session e1RMs', () {
      final xs = [0.0, 1.0, 2.0, 3.0, 4.0];
      final ys = [126.7, 127.5, 127.0, 127.2, 126.9];

      final line = linearRegression(xs, ys);

      expect(line, isNotNull);
      expect(line!.slope, closeTo(0.01, 0.001));
    });

    test('fewer than two points returns null', () {
      expect(linearRegression([], []), isNull);
      expect(linearRegression([1.0], [1.0]), isNull);
    });

    test('identical x values return null rather than dividing by zero', () {
      expect(linearRegression([1.0, 1.0, 1.0], [2.0, 3.0, 4.0]), isNull);
    });

    test('a perfect line is reproduced exactly', () {
      final line = linearRegression([0.0, 1.0, 2.0, 3.0], [1.0, 3.0, 5.0, 7.0]);

      expect(line, isNotNull);
      expect(line!.slope, closeTo(2.0, 1e-9));
      expect(line.intercept, closeTo(1.0, 1e-9));
    });
  });
}
