/// One set parsed out of a third-party export (`F-DAT-005`, `F-DAT-006`),
/// before any exercise-name resolution or unit conversion to canonical
/// grams/metres/seconds has happened — that's `CsvImportAdapter`'s and
/// `ImportService`'s job respectively, kept separate so this stays a pure
/// data holder.
class ImportedSet {
  const ImportedSet({
    required this.workoutStartedAt,
    required this.workoutName,
    required this.exerciseName,
    required this.setOrder,
    this.weight,
    this.reps,
    this.distance,
    this.durationSeconds,
    this.rpe,
    this.isWarmup = false,
    this.notes,
  });

  /// Local wall-clock as read from the source file — no UTC offset is
  /// carried in a CSV, so the caller decides what offset to stamp it with.
  final DateTime workoutStartedAt;

  final String workoutName;
  final String exerciseName;
  final int setOrder;

  /// In whatever unit the source file used — resolved once per import, not
  /// per row, since a single export is one unit throughout.
  final double? weight;
  final int? reps;
  final double? distance;
  final int? durationSeconds;
  final double? rpe;
  final bool isWarmup;
  final String? notes;
}
