import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/routines/routine_preview.dart';

/// `F-ROU-011`.
void main() {
  group('estimateSessionDurationSeconds', () {
    test('sums sets × (avgSetSeconds + restSeconds) per exercise', () {
      final exercises = [
        const RoutinePreviewExercise(
          exerciseName: 'Bench Press',
          trackingType: 'weightReps',
          equipment: 'barbell',
          primaryMuscle: 'chest',
          secondaryMuscles: ['triceps'],
          targetSets: 4,
          routineRestSeconds: 120,
        ),
        const RoutinePreviewExercise(
          exerciseName: 'Cable Fly',
          trackingType: 'weightReps',
          equipment: 'cable',
          primaryMuscle: 'chest',
          secondaryMuscles: [],
          targetSets: 3,
          // Falls back to the built-in default: cable, chest is a compound
          // muscle → 90s.
        ),
      ];

      // Bench: 4 × (45 + 120) = 660. Fly: 3 × (45 + 90) = 405.
      expect(estimateSessionDurationSeconds(exercises), 660 + 405);
    });

    test('an exercise with no target set count contributes nothing', () {
      const exercise = RoutinePreviewExercise(
        exerciseName: 'Bench Press',
        trackingType: 'weightReps',
        equipment: 'barbell',
        primaryMuscle: 'chest',
        secondaryMuscles: [],
      );
      expect(estimateSessionDurationSeconds([exercise]), 0);
    });

    test('a non-last group member rests zero (F-ROU-005 §3)', () {
      final exercises = [
        const RoutinePreviewExercise(
          exerciseName: 'Bench Press',
          trackingType: 'weightReps',
          equipment: 'barbell',
          primaryMuscle: 'chest',
          secondaryMuscles: [],
          targetSets: 3,
          routineRestSeconds: 120,
          isGrouped: true,
          isLastInGroup: false,
        ),
      ];
      // 3 × (45 + 0) — the whole 120s rest never applies mid-superset.
      expect(estimateSessionDurationSeconds(exercises), 135);
    });
  });

  group('plannedSetsPerMuscle', () {
    test('matches the F-ANA-005 fixture, applied to targets', () {
      // Same numbers as docs/40-ANALYTICS-SPEC.md §3's `setsPerMuscle`
      // fixture: Bench Press (chest / triceps, frontDelts) × 4,
      // Overhead Press (frontDelts / triceps) × 3.
      final exercises = [
        const RoutinePreviewExercise(
          exerciseName: 'Bench Press',
          trackingType: 'weightReps',
          equipment: 'barbell',
          primaryMuscle: 'chest',
          secondaryMuscles: ['triceps', 'frontDelts'],
          targetSets: 4,
        ),
        const RoutinePreviewExercise(
          exerciseName: 'Overhead Press',
          trackingType: 'weightReps',
          equipment: 'barbell',
          primaryMuscle: 'frontDelts',
          secondaryMuscles: ['triceps'],
          targetSets: 3,
        ),
      ];

      final result = plannedSetsPerMuscle(exercises);
      expect(result['chest'], 4.0);
      expect(result['frontDelts'], 5.0);
      expect(result['triceps'], 3.5);
    });

    test('fullBody contributes to no specific muscle', () {
      final exercises = [
        const RoutinePreviewExercise(
          exerciseName: 'Burpees',
          trackingType: 'reps',
          equipment: 'bodyweight',
          primaryMuscle: 'fullBody',
          secondaryMuscles: [],
          targetSets: 3,
        ),
      ];
      expect(plannedSetsPerMuscle(exercises), isEmpty);
    });

    test('an exercise with no target set count contributes nothing', () {
      const exercise = RoutinePreviewExercise(
        exerciseName: 'Bench Press',
        trackingType: 'weightReps',
        equipment: 'barbell',
        primaryMuscle: 'chest',
        secondaryMuscles: [],
      );
      expect(plannedSetsPerMuscle([exercise]), isEmpty);
    });
  });

  group('plannedVolumeGrams', () {
    test('sets × weight × midpoint reps, summed across exercises', () {
      final exercises = [
        const RoutinePreviewExercise(
          exerciseName: 'Bench Press',
          trackingType: 'weightReps',
          equipment: 'barbell',
          primaryMuscle: 'chest',
          secondaryMuscles: [],
          targetSets: 4,
          targetRepsMin: 8,
          targetRepsMax: 12,
          targetWeightGrams: 60000,
        ),
      ];
      // 4 × 60000 × 10 (midpoint of 8-12) = 2,400,000.
      expect(plannedVolumeGrams(exercises), 2400000);
    });

    test('only one side of the rep range set still contributes', () {
      final exercises = [
        const RoutinePreviewExercise(
          exerciseName: 'Bench Press',
          trackingType: 'weightReps',
          equipment: 'barbell',
          primaryMuscle: 'chest',
          secondaryMuscles: [],
          targetSets: 2,
          targetRepsMin: 10,
          targetWeightGrams: 50000,
        ),
      ];
      expect(plannedVolumeGrams(exercises), 2 * 50000 * 10);
    });

    test('excludes exercises missing a required target, not as zero', () {
      final exercises = [
        const RoutinePreviewExercise(
          exerciseName: 'Bench Press',
          trackingType: 'weightReps',
          equipment: 'barbell',
          primaryMuscle: 'chest',
          secondaryMuscles: [],
          targetSets: 4,
          // No weight, no reps set.
        ),
      ];
      expect(plannedVolumeGrams(exercises), 0);
    });

    test('excludes tracking types with no meaningful weight × reps', () {
      final exercises = [
        const RoutinePreviewExercise(
          exerciseName: 'Plank',
          trackingType: 'time',
          equipment: 'bodyweight',
          primaryMuscle: 'abs',
          secondaryMuscles: [],
          targetSets: 3,
          targetRepsMin: 30,
          targetWeightGrams: 0,
        ),
      ];
      expect(plannedVolumeGrams(exercises), 0);
    });
  });
}
