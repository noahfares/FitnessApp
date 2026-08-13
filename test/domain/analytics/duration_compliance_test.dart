import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/duration_compliance.dart';

/// Batch 4.5's second pass — `F-ANA-012`. Reuses the `restCompliance`
/// fixture (`docs/40-ANALYTICS-SPEC.md` §15).
void main() {
  group('sessionDurationTrend', () {
    test('excludes the in-progress session', () {
      final points = sessionDurationTrend([
        (date: DateTime(2026, 1, 1), startedAtMs: 0, endedAtMs: 3600000),
        (date: DateTime(2026, 1, 3), startedAtMs: 0, endedAtMs: null),
      ]);

      expect(points, hasLength(1));
      expect(points.single.durationSeconds, 3600);
    });

    test('sorts oldest to newest', () {
      final points = sessionDurationTrend([
        (date: DateTime(2026, 1, 3), startedAtMs: 0, endedAtMs: 1800000),
        (date: DateTime(2026, 1, 1), startedAtMs: 0, endedAtMs: 3600000),
      ]);

      expect(points[0].date, DateTime(2026, 1, 1));
      expect(points[1].date, DateTime(2026, 1, 3));
    });

    test('empty input is empty, not an error', () {
      expect(sessionDurationTrend(const []), isEmpty);
    });
  });

  group('averageRestComplianceRatio (fixture: restCompliance)', () {
    test('exact compliance averages to 1.0', () {
      final ratio = averageRestComplianceRatio([
        for (final actual in [100, 110, 130, 140])
          RestComplianceRecord(actualSeconds: actual, prescribedSeconds: 120),
      ]);

      expect(ratio, 1.0);
    });

    test('~5.6% under-resting with the fourth set dropped', () {
      final ratio = averageRestComplianceRatio([
        for (final actual in [100, 110, 130])
          RestComplianceRecord(actualSeconds: actual, prescribedSeconds: 120),
      ]);

      expect(ratio, closeTo(0.944, 0.001));
    });

    test('null for an empty sample, not zero', () {
      expect(averageRestComplianceRatio(const []), isNull);
    });
  });
}
