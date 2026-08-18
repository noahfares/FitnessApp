/// Adherence against a routine's own schedule (`F-ANA-006`).
///
/// The spec asks for this "once `F-ROU-012` exists" — it does now
/// (`routine_days.scheduled_weekdays`), so this is the metric that closes it.
///
/// Deliberately generous in one direction and strict in the other: training on
/// a day nothing was scheduled counts as *training*, never as a deviation,
/// because a spontaneous extra session is not a failure. Only scheduled days
/// with nothing logged count against the ratio. "No shame" (§5 rule 4) is a
/// maths decision here, not only a copy one.
library;

/// How many scheduled sessions were actually trained.
class ScheduleAdherence {
  const ScheduleAdherence({
    required this.scheduled,
    required this.trained,
    required this.unscheduledSessions,
  });

  /// Scheduled days that fell inside the window.
  final int scheduled;

  /// Of those, how many have a training day.
  final int trained;

  /// Sessions on days nothing was scheduled — reported, never subtracted.
  final int unscheduledSessions;

  /// Null when nothing was scheduled in the window: there is no ratio to
  /// report, and 0% would be a lie about someone with no schedule at all.
  double? get ratio => scheduled == 0 ? null : trained / scheduled;
}

/// [scheduledWeekdays] is the set of ISO weekdays (1 = Monday) any routine day
/// is scheduled for — matching `DateTime.weekday` and `F-ROU-012`'s storage.
ScheduleAdherence scheduleAdherence({
  required Set<int> scheduledWeekdays,
  required Set<DateTime> trainingDays,
  required DateTime from,
  required DateTime to,
}) {
  final trained = {
    for (final day in trainingDays) DateTime(day.year, day.month, day.day),
  };

  var scheduledCount = 0;
  var trainedCount = 0;
  final scheduledDays = <DateTime>{};

  var cursor = DateTime(from.year, from.month, from.day);
  final end = DateTime(to.year, to.month, to.day);
  while (!cursor.isAfter(end)) {
    if (scheduledWeekdays.contains(cursor.weekday)) {
      scheduledCount++;
      scheduledDays.add(cursor);
      if (trained.contains(cursor)) trainedCount++;
    }
    cursor = cursor.add(const Duration(days: 1));
  }

  final unscheduled = trained
      .where((day) => !day.isBefore(from) && !day.isAfter(end))
      .where((day) => !scheduledDays.contains(day))
      .length;

  return ScheduleAdherence(
    scheduled: scheduledCount,
    trained: trainedCount,
    unscheduledSessions: unscheduled,
  );
}
