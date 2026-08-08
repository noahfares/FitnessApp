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
    required this.exerciseName,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    this.weightGrams,
    this.reps,
  });

  /// The local calendar date of the session this set belongs to.
  final DateTime date;

  final String setType;
  final bool isCompleted;
  final String trackingType;

  /// For the "which exercises contributed" drill-down (`F-ANA-005` §3).
  final String exerciseName;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final int? weightGrams;
  final int? reps;
}
