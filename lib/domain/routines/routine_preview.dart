/// Estimated duration, planned volume, and planned sets per muscle for a
/// routine day, before it's ever run (`F-ROU-011`,
/// `docs/40-ANALYTICS-SPEC.md#11-estimated-session-duration`).
///
/// Pure Dart. Equipment, muscles and tracking type arrive as their stored
/// **names**, not the `Equipment`/`Muscle`/`TrackingType` enums, which live in
/// `lib/data/db/tables/` and the domain layer may not import — same
/// convention as `domain/timing/rest_defaults.dart`.
library;

import '../timing/rest_defaults.dart';

/// One routine exercise's targets, plus what resolving its rest and
/// attributing its muscles needs.
class RoutinePreviewExercise {
  const RoutinePreviewExercise({
    required this.exerciseName,
    required this.trackingType,
    required this.equipment,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    this.targetSets,
    this.targetRepsMin,
    this.targetRepsMax,
    this.targetWeightGrams,
    this.routineRestSeconds,
    this.exerciseDefaultRestSeconds,
    this.isGrouped = false,
    this.isLastInGroup = true,
  });

  final String exerciseName;
  final String trackingType;
  final String equipment;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final int? targetSets;
  final int? targetRepsMin;
  final int? targetRepsMax;
  final int? targetWeightGrams;
  final int? routineRestSeconds;
  final int? exerciseDefaultRestSeconds;

  /// Whether this exercise sits inside a superset, and whether it's the
  /// group's last member — only the last member's rest counts
  /// (`F-ROU-005` §3).
  final bool isGrouped;
  final bool isLastInGroup;
}

/// `sets × (avgSetSeconds + restSeconds)`, summed over every exercise
/// (spec §11). An exercise with no target set count contributes nothing —
/// there's no session length to estimate for a target that isn't there yet.
///
/// Rest is resolved the same way the active workout resolves it
/// (`resolveRestSeconds`, `restSecondsForGroupMember`), so the estimate
/// matches what a session actually run from this day would experience.
int estimateSessionDurationSeconds(
  List<RoutinePreviewExercise> exercises, {
  int avgSetSeconds = 45,
  int? globalRestSeconds,
}) {
  var total = 0;
  for (final exercise in exercises) {
    final sets = exercise.targetSets;
    if (sets == null || sets <= 0) continue;
    final restSeconds = restSecondsForGroupMember(
      isGrouped: exercise.isGrouped,
      isLastInGroup: exercise.isLastInGroup,
      resolvedSeconds: resolveRestSeconds(
        equipment: exercise.equipment,
        primaryMuscle: exercise.primaryMuscle,
        routineSeconds: exercise.routineRestSeconds,
        exerciseSeconds: exercise.exerciseDefaultRestSeconds,
        globalSeconds: globalRestSeconds,
      ),
    );
    total += sets * (avgSetSeconds + restSeconds);
  }
  return total;
}

/// Hard sets per muscle, using targeted (not logged) set counts and the same
/// 1.0-primary/0.5-secondary rule as `F-ANA-005`
/// (`docs/40-ANALYTICS-SPEC.md#3-hard-sets-per-muscle-group-per-week`).
/// `fullBody` contributes to no specific muscle, same as that spec's rule 4.
Map<String, double> plannedSetsPerMuscle(
  List<RoutinePreviewExercise> exercises,
) {
  final totals = <String, double>{};
  void add(String muscle, double amount) {
    totals[muscle] = (totals[muscle] ?? 0) + amount;
  }

  for (final exercise in exercises) {
    final sets = exercise.targetSets;
    if (sets == null || sets <= 0) continue;
    if (exercise.primaryMuscle != 'fullBody') {
      add(exercise.primaryMuscle, sets * 1.0);
    }
    for (final secondary in exercise.secondaryMuscles) {
      add(secondary, sets * 0.5);
    }
  }
  return totals;
}

/// Total planned volume load in grams (spec §2's `weight × reps`, applied to
/// targets rather than logged sets). Only `weightReps`/`weightTime` exercises
/// with a target weight, a target set count, and at least one side of the rep
/// range set contribute — anything else has no target to multiply, so it's
/// excluded rather than counted as zero (same reasoning as §2 rule 1).
int plannedVolumeGrams(List<RoutinePreviewExercise> exercises) {
  var total = 0.0;
  for (final exercise in exercises) {
    if (exercise.trackingType != 'weightReps' &&
        exercise.trackingType != 'weightTime') {
      continue;
    }
    final sets = exercise.targetSets;
    final weight = exercise.targetWeightGrams;
    final repsMin = exercise.targetRepsMin;
    final repsMax = exercise.targetRepsMax;
    if (sets == null || sets <= 0 || weight == null) continue;
    if (repsMin == null && repsMax == null) continue;
    final reps = repsMin == null
        ? repsMax!.toDouble()
        : repsMax == null
        ? repsMin.toDouble()
        : (repsMin + repsMax) / 2;
    total += sets * weight * reps;
  }
  return total.round();
}
