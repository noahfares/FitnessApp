/// The workout history list (`F-LOG-011`) groups sessions by the local
/// calendar month they were trained in, never by their raw UTC timestamp — a
/// session just after midnight local time must land in the month it was
/// actually trained in (docs/21-DATA-MODEL.md §5).
library;

/// One row of the history list — a read model, not a table.
class WorkoutHistoryEntry {
  const WorkoutHistoryEntry({
    required this.id,
    required this.name,
    required this.startedAt,
    required this.startedAtTzOffsetMinutes,
    required this.endedAt,
    required this.exerciseCount,
    required this.completedSetCount,
    required this.totalVolumeGrams,
    required this.hasNotes,
  });

  final String id;
  final String name;

  /// UTC epoch milliseconds.
  final int startedAt;
  final int startedAtTzOffsetMinutes;

  /// Null only for the in-progress session, which the history list excludes.
  final int? endedAt;

  final int exerciseCount;
  final int completedSetCount;
  final int totalVolumeGrams;
  final bool hasNotes;

  Duration get duration => endedAt == null
      ? Duration.zero
      : Duration(milliseconds: endedAt! - startedAt);

  /// The local calendar date the session started on, derived from the UTC
  /// instant and the offset recorded at write time — never from UTC alone,
  /// which cannot be corrected for afterwards (ADR-0008).
  DateTime get localDate {
    final utc = DateTime.fromMillisecondsSinceEpoch(startedAt, isUtc: true);
    final local = utc.add(Duration(minutes: startedAtTzOffsetMinutes));
    return DateTime(local.year, local.month, local.day);
  }
}

/// One calendar month's worth of entries, in the order they were given.
class MonthGroup {
  MonthGroup({required this.year, required this.month, required this.entries});

  final int year;
  final int month;
  final List<WorkoutHistoryEntry> entries;
}

/// Splits already reverse-chronological [entries] into calendar months
/// without reordering them (`F-LOG-011` §2).
List<MonthGroup> groupByMonth(List<WorkoutHistoryEntry> entries) {
  final groups = <MonthGroup>[];
  for (final entry in entries) {
    final date = entry.localDate;
    final current = groups.isEmpty ? null : groups.last;
    if (current != null &&
        current.year == date.year &&
        current.month == date.month) {
      current.entries.add(entry);
    } else {
      groups.add(
        MonthGroup(year: date.year, month: date.month, entries: [entry]),
      );
    }
  }
  return groups;
}
