import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/analytics/analytics_set_record.dart';
import 'package:fitness_app/domain/analytics/muscle_heat.dart';

/// Batch 4.5's second pass — `F-ANA-014`. Reuses the `muscleHeat` fixture
/// (`docs/40-ANALYTICS-SPEC.md` §16).
void main() {
  AnalyticsSetRecord counted({
    required String muscle,
    required int weightGrams,
    required int reps,
  }) => AnalyticsSetRecord(
    date: DateTime(2026, 1, 1),
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

  group('volumeByMuscle', () {
    test('sums by primary muscle only', () {
      final volumes = volumeByMuscle([
        counted(muscle: 'chest', weightGrams: 100000, reps: 5),
        counted(muscle: 'chest', weightGrams: 50000, reps: 10),
        counted(muscle: 'quads', weightGrams: 200000, reps: 5),
      ]);

      expect(volumes['chest'], 1000000);
      expect(volumes['quads'], 1000000);
    });

    test('excludes fullBody', () {
      final volumes = volumeByMuscle([
        counted(muscle: 'fullBody', weightGrams: 100000, reps: 5),
      ]);
      expect(volumes, isEmpty);
    });

    test('excludes warm-ups and incomplete sets', () {
      final warmup = AnalyticsSetRecord(
        date: DateTime(2026, 1, 1),
        setType: 'warmup',
        isCompleted: true,
        trackingType: 'weightReps',
        exerciseId: 'ex',
        exerciseName: 'ex',
        primaryMuscle: 'chest',
        secondaryMuscles: const [],
        weightGrams: 100000,
        reps: 5,
      );
      expect(volumeByMuscle([warmup]), isEmpty);
    });
  });

  group('muscleHeatIntensity (fixture: muscleHeat)', () {
    test('the hottest muscle is always 1.0, everything else relative', () {
      final intensity = muscleHeatIntensity([
        counted(muscle: 'chest', weightGrams: 100000, reps: 10), // 1,000,000
        counted(muscle: 'quads', weightGrams: 100000, reps: 5), // 500,000
      ]);

      expect(intensity['chest'], 1.0);
      expect(intensity['quads'], 0.5);
    });

    test('an untrained muscle has no key, not zero', () {
      final intensity = muscleHeatIntensity([
        counted(muscle: 'chest', weightGrams: 100000, reps: 10),
      ]);
      expect(intensity.containsKey('biceps'), isFalse);
    });

    test('empty input is empty, not an error', () {
      expect(muscleHeatIntensity(const []), isEmpty);
    });
  });
}
