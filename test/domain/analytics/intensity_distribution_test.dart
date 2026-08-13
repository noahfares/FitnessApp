import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/intensity_distribution.dart';

/// `docs/40-ANALYTICS-SPEC.md` §10.
void main() {
  group('repRangeBucketFor', () {
    test('buckets match the spec\'s five ranges', () {
      expect(repRangeBucketFor(1), RepRangeBucket.strength);
      expect(repRangeBucketFor(3), RepRangeBucket.strength);
      expect(repRangeBucketFor(4), RepRangeBucket.strengthHypertrophy);
      expect(repRangeBucketFor(6), RepRangeBucket.strengthHypertrophy);
      expect(repRangeBucketFor(7), RepRangeBucket.hypertrophy);
      expect(repRangeBucketFor(12), RepRangeBucket.hypertrophy);
      expect(repRangeBucketFor(13), RepRangeBucket.hypertrophyEndurance);
      expect(repRangeBucketFor(20), RepRangeBucket.hypertrophyEndurance);
      expect(repRangeBucketFor(21), RepRangeBucket.endurance);
      expect(repRangeBucketFor(50), RepRangeBucket.endurance);
    });
  });

  group('repRangeDistribution', () {
    test('counts sets per bucket', () {
      final result = repRangeDistribution([1, 5, 5, 8, 8, 8, 25]);
      expect(result[RepRangeBucket.strength], 1);
      expect(result[RepRangeBucket.strengthHypertrophy], 2);
      expect(result[RepRangeBucket.hypertrophy], 3);
      expect(result[RepRangeBucket.hypertrophyEndurance], 0);
      expect(result[RepRangeBucket.endurance], 1);
    });
  });

  group('intensityZoneFor', () {
    test('buckets by percentage of e1RM', () {
      const e1rm = 100000;
      expect(
        intensityZoneFor(weightGrams: 50000, e1rmGrams: e1rm),
        IntensityZone.under60,
      );
      expect(
        intensityZoneFor(weightGrams: 65000, e1rmGrams: e1rm),
        IntensityZone.from60to70,
      );
      expect(
        intensityZoneFor(weightGrams: 75000, e1rmGrams: e1rm),
        IntensityZone.from70to80,
      );
      expect(
        intensityZoneFor(weightGrams: 85000, e1rmGrams: e1rm),
        IntensityZone.from80to90,
      );
      expect(
        intensityZoneFor(weightGrams: 95000, e1rmGrams: e1rm),
        IntensityZone.over90,
      );
    });

    test('no e1RM baseline excludes the set rather than bucketing as zero', () {
      expect(intensityZoneFor(weightGrams: 50000, e1rmGrams: null), isNull);
      expect(intensityZoneFor(weightGrams: 50000, e1rmGrams: 0), isNull);
    });
  });

  group('intensityZoneDistribution', () {
    test(
      'a first-ever session has no baseline yet — its sets are excluded',
      () {
        final samples = [
          IntensitySample(
            exerciseId: 'bench',
            date: DateTime(2026, 1, 1),
            weightGrams: 100000,
            reps: 5,
          ),
        ];

        final result = intensityZoneDistribution(samples);

        expect(result.values.every((n) => n == 0), isTrue);
      },
    );

    test(
      'a later session is classified against the prior session\'s best e1RM',
      () {
        final samples = [
          // Session 1: 100kg x5 -> e1RM ~116.7kg, no prior baseline.
          IntensitySample(
            exerciseId: 'bench',
            date: DateTime(2026, 1, 1),
            weightGrams: 100000,
            reps: 5,
          ),
          // Session 2, a week later: 90kg x5 against the 116.7kg baseline
          // from session 1 -> ~77%, the 70-80% zone.
          IntensitySample(
            exerciseId: 'bench',
            date: DateTime(2026, 1, 8),
            weightGrams: 90000,
            reps: 5,
          ),
        ];

        final result = intensityZoneDistribution(samples);

        expect(result[IntensityZone.from70to80], 1);
        expect(result.values.reduce((a, b) => a + b), 1);
      },
    );

    test('today\'s own sets never classify against today\'s own e1RM', () {
      final samples = [
        // Two sets logged the same day; the second must not be classified
        // using the e1RM the first one just established.
        IntensitySample(
          exerciseId: 'bench',
          date: DateTime(2026, 1, 1),
          weightGrams: 100000,
          reps: 5,
        ),
        IntensitySample(
          exerciseId: 'bench',
          date: DateTime(2026, 1, 1),
          weightGrams: 90000,
          reps: 5,
        ),
      ];

      final result = intensityZoneDistribution(samples);

      expect(result.values.every((n) => n == 0), isTrue);
    });

    test('different exercises never share a baseline', () {
      final samples = [
        IntensitySample(
          exerciseId: 'bench',
          date: DateTime(2026, 1, 1),
          weightGrams: 100000,
          reps: 5,
        ),
        // A brand-new exercise on the same day: no baseline of its own yet.
        IntensitySample(
          exerciseId: 'squat',
          date: DateTime(2026, 1, 1),
          weightGrams: 150000,
          reps: 5,
        ),
      ];

      final result = intensityZoneDistribution(samples);

      expect(result.values.every((n) => n == 0), isTrue);
    });
  });

  group('rpeDistribution', () {
    test('counts by RPE, excluding sets logged without one', () {
      final samples = [
        IntensitySample(
          exerciseId: 'bench',
          date: DateTime(2026, 1, 1),
          weightGrams: 100000,
          reps: 5,
          rpe: 8,
        ),
        IntensitySample(
          exerciseId: 'bench',
          date: DateTime(2026, 1, 1),
          weightGrams: 100000,
          reps: 5,
          rpe: 8,
        ),
        IntensitySample(
          exerciseId: 'bench',
          date: DateTime(2026, 1, 1),
          weightGrams: 100000,
          reps: 5,
        ),
      ];

      final result = rpeDistribution(samples);

      expect(result[8], 2);
      expect(result.values.reduce((a, b) => a + b), 2);
    });
  });
}
