/// One counted-or-not set, with everything `F-ANA-004`'s muscle-group/overall
/// volume and `F-ANA-005`'s sets-per-muscle-per-week need to attribute it —
/// unlike `ExerciseHistorySession`, this isn't scoped to one exercise, so the
/// repository joins across the whole catalogue rather than one row.
library;

class AnalyticsSetRecord {
  const AnalyticsSetRecord({
    required this.date,
    required this.setType,
    required this.isCompleted,
    required this.trackingType,
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    this.weightGrams,
    this.reps,
    this.rpe,
  });

  /// The local calendar date of the session this set belongs to.
  final DateTime date;

  final String setType;
  final bool isCompleted;
  final String trackingType;

  /// Groups sets by exercise correctly even if two exercises share a name
  /// (`F-CAT-003` §4 allows that) — `exerciseName` alone is not a safe key
  /// for `F-ANA-011`'s per-exercise e1RM baseline.
  final String exerciseId;

  /// For the "which exercises contributed" drill-down (`F-ANA-005` §3).
  final String exerciseName;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final int? weightGrams;
  final int? reps;

  /// Set for `weightReps` sets logged with RPE (`F-LOG-014`) — the honest
  /// intensity measure `F-ANA-011` §"Rules" 3 prefers over an e1RM estimate.
  final double? rpe;
}
