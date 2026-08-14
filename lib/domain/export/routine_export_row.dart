/// One denormalised row for `F-DAT-002`'s routines CSV — a routine's day's
/// exercise, with its target.
class RoutineExportRow {
  const RoutineExportRow({
    required this.routineName,
    required this.dayName,
    required this.exerciseName,
    required this.position,
    this.targetSets,
    this.targetRepsMin,
    this.targetRepsMax,
    this.targetWeightGrams,
    this.targetRpe,
  });

  final String routineName;
  final String dayName;
  final String exerciseName;
  final int position;
  final int? targetSets;
  final int? targetRepsMin;
  final int? targetRepsMax;
  final int? targetWeightGrams;
  final double? targetRpe;
}
