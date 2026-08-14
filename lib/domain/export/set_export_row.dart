/// One denormalised row for `F-DAT-002`'s sets CSV — one row per set, with
/// everything a spreadsheet needs and nothing it has to join for.
class SetExportRow {
  const SetExportRow({
    required this.workoutDate,
    required this.exerciseName,
    required this.setType,
    required this.isCompleted,
    this.weightGrams,
    this.reps,
    this.rpe,
    this.distanceMetres,
    this.durationSeconds,
  });

  final DateTime workoutDate;
  final String exerciseName;
  final String setType;
  final bool isCompleted;
  final int? weightGrams;
  final int? reps;
  final double? rpe;
  final int? distanceMetres;
  final int? durationSeconds;
}
