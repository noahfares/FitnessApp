import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/history/workout_volume.dart';

/// Batch 1.6 — worked fixture from docs/40-ANALYTICS-SPEC.md §2 and
/// docs/fixtures/analytics.json#volumeLoad.
void main() {
  group('totalVolumeGrams (F-LOG-011, F-LOG-018)', () {
    test('excludes the warm-up: 1760 kg, not 2360', () {
      final sets = [
        const CountedSet(
          setType: 'warmup',
          trackingType: 'weightReps',
          isCompleted: true,
          weightGrams: 60000,
          reps: 10,
        ),
        const CountedSet(
          setType: 'working',
          trackingType: 'weightReps',
          isCompleted: true,
          weightGrams: 100000,
          reps: 5,
        ),
        const CountedSet(
          setType: 'working',
          trackingType: 'weightReps',
          isCompleted: true,
          weightGrams: 100000,
          reps: 5,
        ),
        const CountedSet(
          setType: 'working',
          trackingType: 'weightReps',
          isCompleted: true,
          weightGrams: 95000,
          reps: 8,
        ),
      ];

      expect(totalVolumeGrams(sets), 1760000);
    });

    test('excludes incomplete sets', () {
      final sets = [
        const CountedSet(
          setType: 'working',
          trackingType: 'weightReps',
          isCompleted: false,
          weightGrams: 100000,
          reps: 5,
        ),
      ];
      expect(totalVolumeGrams(sets), 0);
    });

    test('excludes tracking types other than weightReps and weightTime', () {
      final sets = [
        const CountedSet(
          setType: 'working',
          trackingType: 'reps',
          isCompleted: true,
          weightGrams: 100000,
          reps: 5,
        ),
      ];
      expect(totalVolumeGrams(sets), 0);
    });

    test(
      'weightTime counts, and null weight or reps is excluded not zeroed',
      () {
        final sets = [
          const CountedSet(
            setType: 'working',
            trackingType: 'weightTime',
            isCompleted: true,
            weightGrams: 20000,
            reps: 10,
          ),
          const CountedSet(
            setType: 'working',
            trackingType: 'weightReps',
            isCompleted: true,
            reps: 5,
          ),
        ];
        expect(totalVolumeGrams(sets), 200000);
      },
    );

    test('empty input is zero', () {
      expect(totalVolumeGrams(const []), 0);
    });
  });

  group('setVolumeGrams (F-LOG-024)', () {
    test('weight × reps for a volume-eligible working set', () {
      expect(
        setVolumeGrams(
          setType: 'working',
          trackingType: 'weightReps',
          weightGrams: 100000,
          reps: 5,
        ),
        500000,
      );
    });

    test('warm-ups are excluded, same as the aggregate', () {
      expect(
        setVolumeGrams(
          setType: 'warmup',
          trackingType: 'weightReps',
          weightGrams: 100000,
          reps: 5,
        ),
        isNull,
      );
    });

    test(
      'bodyweightReps is not volume-eligible despite having both fields',
      () {
        expect(
          setVolumeGrams(
            setType: 'working',
            trackingType: 'bodyweightReps',
            weightGrams: 20000,
            reps: 10,
          ),
          isNull,
        );
      },
    );

    test('null weight or reps is excluded, not treated as zero', () {
      expect(
        setVolumeGrams(
          setType: 'working',
          trackingType: 'weightReps',
          weightGrams: null,
          reps: 5,
        ),
        isNull,
      );
      expect(
        setVolumeGrams(
          setType: 'working',
          trackingType: 'weightReps',
          weightGrams: 100000,
          reps: null,
        ),
        isNull,
      );
    });
  });
}
