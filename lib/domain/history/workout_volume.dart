/// Volume load (docs/40-ANALYTICS-SPEC.md §2), used by `F-LOG-011` and
/// `F-LOG-018` for the totals shown in history and the finish summary.
library;

import '../analytics/analytics_boundary.dart';

/// The measured values of one counted set, stripped down to what the formula
/// needs. Not a `WorkoutSet`: this must stay constructible without Drift so
/// the maths is testable in isolation (docs/20-ARCHITECTURE.md).
class CountedSet {
  const CountedSet({
    required this.setType,
    required this.trackingType,
    required this.isCompleted,
    this.weightGrams,
    this.reps,
  });

  final String setType;
  final String trackingType;
  final bool isCompleted;
  final int? weightGrams;
  final int? reps;
}

/// `volumeLoad = Σ (weight × reps)` over counted sets.
///
/// Warm-ups, incomplete sets, and tracking types other than `weightReps` and
/// `weightTime` are excluded — never counted as zero, which would understate
/// the truth and drag an average down (docs/40-ANALYTICS-SPEC.md §2 rule 1).
int totalVolumeGrams(Iterable<CountedSet> sets) {
  var total = 0;
  for (final set in sets) {
    if (!isCountedSet(setType: set.setType, isCompleted: set.isCompleted)) {
      continue;
    }
    if (!isVolumeEligible(set.trackingType)) continue;
    final weight = set.weightGrams;
    final reps = set.reps;
    if (weight == null || reps == null) continue;
    total += weight * reps;
  }
  return total;
}

/// The live volume of one set as it's being logged (`F-LOG-024`) — weight ×
/// reps, or null when there is nothing to show yet.
///
/// Deliberately *not* gated on `isCompleted`: this is a running preview shown
/// while the lifter is still typing, not a contribution to any aggregate.
/// Warm-ups and non-volume-eligible tracking types are still excluded, same
/// as [totalVolumeGrams] — this row's number must never disagree with what
/// the totals it feeds into would say (docs/40-ANALYTICS-SPEC.md §2 rule 1).
int? setVolumeGrams({
  required String setType,
  required String trackingType,
  required int? weightGrams,
  required int? reps,
}) {
  if (setType == 'warmup') return null;
  if (!isVolumeEligible(trackingType)) return null;
  if (weightGrams == null || reps == null) return null;
  return weightGrams * reps;
}
