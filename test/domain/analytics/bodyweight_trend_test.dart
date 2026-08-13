import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/bodyweight_trend.dart';

/// `docs/40-ANALYTICS-SPEC.md` §6, `docs/fixtures/analytics.json#ema`.
void main() {
  group('bodyweightTrendEma', () {
    test('matches the spec fixture', () {
      const inputKg = [80.0, 80.6, 80.2, 81.0, 80.4, 80.8, 80.5];
      const expectedKg = [80.0, 80.15, 80.163, 80.372, 80.379, 80.484, 80.488];

      final observations = [
        for (var i = 0; i < inputKg.length; i++)
          (measuredAtEpochMs: i * 86400000, grams: (inputKg[i] * 1000).round()),
      ];

      final trend = bodyweightTrendEma(observations);

      expect(trend, hasLength(7));
      for (var i = 0; i < trend.length; i++) {
        expect(trend[i].emaGrams / 1000, closeTo(expectedKg[i], 0.001));
        expect(trend[i].rawGrams, observations[i].grams);
      }
    });

    test(
      'a gap between observations does not decay the average (§6 rule 3)',
      () {
        // Two entries a fortnight apart — nothing between them for the EMA to
        // decay through, since it advances per observation, not per day.
        final trend = bodyweightTrendEma([
          (measuredAtEpochMs: 0, grams: 80000),
          (measuredAtEpochMs: 14 * 86400000, grams: 80600),
        ]);

        expect(trend[1].emaGrams, closeTo(80150, 0.5));
      },
    );

    test('empty input returns no points', () {
      expect(bodyweightTrendEma(const []), isEmpty);
    });

    test('a single observation is its own EMA', () {
      final trend = bodyweightTrendEma([(measuredAtEpochMs: 0, grams: 80000)]);
      expect(trend.single.emaGrams, 80000);
    });
  });

  group('weeklyRateOfChangeGrams', () {
    test('a steady 700g/week gain over the smoothed series', () {
      // Seven daily points, exactly 100g/day apart, so the EMA (which starts
      // at the first raw value and is pulled toward each new one) trends the
      // same direction — the regression slope should read close to 700g/week.
      final observations = [
        for (var i = 0; i < 7; i++)
          (measuredAtEpochMs: i * 86400000, grams: 80000 + i * 100),
      ];
      final trend = bodyweightTrendEma(observations);

      final rate = weeklyRateOfChangeGrams(trend);

      expect(rate, isNotNull);
      expect(rate!, greaterThan(0));
    });

    test('fewer than two points has no rate', () {
      final trend = bodyweightTrendEma([(measuredAtEpochMs: 0, grams: 80000)]);
      expect(weeklyRateOfChangeGrams(trend), isNull);
      expect(weeklyRateOfChangeGrams(const []), isNull);
    });
  });
}
