/// Rolling rotation — "day 3 of 6" (`F-ROU-012`'s other half).
///
/// The open question was fixed weekdays *or* a rotation, and the answer here is
/// both, without a second scheduling model: a rotation needs no stored
/// position at all. Which day comes next is a fact about what was last trained,
/// and that is already recorded — `workouts.source_routine_day_id`. Storing a
/// cursor as well would give it two sources of truth, and the stored one would
/// be wrong the moment a session was deleted, edited, or logged retroactively.
///
/// Pure Dart: takes the day ids in order and the last-trained id, returns the
/// next one.
library;

/// The day after [lastTrainedDayId] in [orderedDayIds], wrapping at the end.
///
/// Null when the routine has no days. A [lastTrainedDayId] that is not in the
/// list — a day deleted since it was trained — starts again from the first
/// day rather than guessing where the deleted one sat: a rotation whose next
/// step is unknowable should restart visibly, not silently pick a neighbour.
String? nextRotationDayId({
  required List<String> orderedDayIds,
  String? lastTrainedDayId,
}) {
  if (orderedDayIds.isEmpty) return null;
  if (lastTrainedDayId == null) return orderedDayIds.first;

  final index = orderedDayIds.indexOf(lastTrainedDayId);
  if (index < 0) return orderedDayIds.first;
  return orderedDayIds[(index + 1) % orderedDayIds.length];
}

/// "Day 3 of 6" — the human-facing position, 1-based, for the day
/// [nextRotationDayId] just chose. Null when the day is not in the list.
({int position, int total})? rotationPosition({
  required List<String> orderedDayIds,
  required String dayId,
}) {
  final index = orderedDayIds.indexOf(dayId);
  if (index < 0) return null;
  return (position: index + 1, total: orderedDayIds.length);
}
