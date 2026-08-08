/// Weekly volume load (`F-ANA-004`, `docs/40-ANALYTICS-SPEC.md` §2).
library;

import '../../core/units/week_start.dart';
import 'analytics_boundary.dart';
import 'analytics_set_record.dart';
import 'exercise_history.dart';

class WeeklyVolumePoint {
  const WeeklyVolumePoint({required this.weekStart, required this.volumeGrams});

  final DateTime weekStart;
  final int volumeGrams;
}

/// Oldest-to-newest weekly totals. [muscle] scopes to one muscle group,
/// attributed by primary muscle only — §2 has no fractional-secondary rule
/// the way §3's set counting does, so a set's full volume belongs to the one
/// muscle it primarily trained. `null` sums every counted set (the "overall"
/// chart).
List<WeeklyVolumePoint> weeklyVolume(
  List<AnalyticsSetRecord> records, {
  required WeekStart weekStart,
  String? muscle,
}) {
  final totals = <DateTime, int>{};
  for (final record in records) {
    if (!isCountedSet(
      setType: record.setType,
      isCompleted: record.isCompleted,
    )) {
      continue;
    }
    if (!isVolumeEligible(record.trackingType)) continue;
    if (muscle != null && record.primaryMuscle != muscle) continue;
    final weight = record.weightGrams;
    final reps = record.reps;
    if (weight == null || reps == null) continue;

    final week = weekStart.weekStartFor(record.date);
    totals[week] = (totals[week] ?? 0) + weight * reps;
  }

  final weeks = totals.keys.toList()..sort();
  return [
    for (final week in weeks)
      WeeklyVolumePoint(weekStart: week, volumeGrams: totals[week]!),
  ];
}

/// The per-exercise volume chart (`F-ANA-004`) on `ExerciseDetailScreen`:
/// [sessions] are already scoped to one exercise, so this sums each
/// session's own `volumeGrams` (`F-ANA-002`) by week rather than
/// re-deriving it from individual sets.
List<WeeklyVolumePoint> weeklyVolumeFromSessions(
  List<ExerciseHistorySession> sessions, {
  required WeekStart weekStart,
}) {
  final totals = <DateTime, int>{};
  for (final session in sessions) {
    final volume = session.volumeGrams;
    if (volume == 0) continue;
    final week = weekStart.weekStartFor(session.localDate);
    totals[week] = (totals[week] ?? 0) + volume;
  }

  final weeks = totals.keys.toList()..sort();
  return [
    for (final week in weeks)
      WeeklyVolumePoint(weekStart: week, volumeGrams: totals[week]!),
  ];
}
