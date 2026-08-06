/// Volume load (docs/40-ANALYTICS-SPEC.md §2), used by `F-LOG-011` and
/// `F-LOG-018` for the totals shown in history and the finish summary.
library;

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
    if (set.setType == 'warmup') continue;
    if (!set.isCompleted) continue;
    if (set.trackingType != 'weightReps' && set.trackingType != 'weightTime') {
      continue;
    }
    final weight = set.weightGrams;
    final reps = set.reps;
    if (weight == null || reps == null) continue;
    total += weight * reps;
  }
  return total;
}
