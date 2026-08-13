import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/acwr.dart';

/// `docs/40-ANALYTICS-SPEC.md` §8, `docs/fixtures/analytics.json#acwr`.
void main() {
  group('computeAcwr', () {
    test('matches the spec fixture', () {
      // Weekly volumes, oldest -> newest: 10000, 11000, 10500, 15000 kg,
      // each logged on the first day of its 7-day block.
      final dailyVolumes = [
        (date: DateTime(2026, 1, 1), volumeGrams: 10000000),
        (date: DateTime(2026, 1, 8), volumeGrams: 11000000),
        (date: DateTime(2026, 1, 15), volumeGrams: 10500000),
        (date: DateTime(2026, 1, 22), volumeGrams: 15000000),
      ];

      final result = computeAcwr(dailyVolumes, asOf: DateTime(2026, 1, 29));

      expect(result, isNotNull);
      expect(result!.acuteGrams, 15000000);
      expect(result.chronicGrams, closeTo(11625000, 1));
      expect(result.ratio, closeTo(1.290, 0.001));
    });

    test('fewer than 28 days of history is not shown', () {
      final dailyVolumes = [
        (date: DateTime(2026, 1, 1), volumeGrams: 10000000),
        (date: DateTime(2026, 1, 15), volumeGrams: 10000000),
      ];

      final result = computeAcwr(dailyVolumes, asOf: DateTime(2026, 1, 20));

      expect(result, isNull);
    });

    test('a zero chronic volume yields no ratio, never a division by zero', () {
      final dailyVolumes = [
        (date: DateTime(2026, 1, 1), volumeGrams: 0),
        (date: DateTime(2026, 1, 29), volumeGrams: 0),
      ];

      final result = computeAcwr(dailyVolumes, asOf: DateTime(2026, 1, 29));

      expect(result, isNotNull);
      expect(result!.ratio, isNull);
    });

    test('empty input returns null', () {
      expect(computeAcwr(const []), isNull);
    });

    test('volume outside the 28-day chronic window is not counted', () {
      final dailyVolumes = [
        (date: DateTime(2025, 1, 1), volumeGrams: 999000000), // ancient
        (date: DateTime(2026, 1, 1), volumeGrams: 10000000),
        (date: DateTime(2026, 1, 29), volumeGrams: 10000000),
      ];

      final result = computeAcwr(dailyVolumes, asOf: DateTime(2026, 1, 29));

      expect(result!.chronicGrams, closeTo(5000000, 1));
    });
  });
}
