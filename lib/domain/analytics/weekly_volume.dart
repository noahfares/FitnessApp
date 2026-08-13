/// Weekly volume load (`F-ANA-004`, `docs/40-ANALYTICS-SPEC.md` §2).
library;

import '../../core/units/week_start.dart';
import '../logging/bodyweight_load.dart';
import 'analytics_boundary.dart';
import 'analytics_set_record.dart';
import 'exercise_history.dart';

class WeeklyVolumePoint {
  const WeeklyVolumePoint({required this.weekStart, required this.volumeGrams});

  final DateTime weekStart;
  final int volumeGrams;
}

/// The volume-load contribution of one counted [record], or null when its
/// tracking type carries no assessable load (§2 rule 1) — never zero, which
/// would understate the truth and drag an average down.
///
/// `bodyweightReps` uses its effective load (`F-LOG-019` §1, §3) rather than
/// the added weight alone — the added weight is what the set row logs, but
/// most of the load is the lifter.
int? _setVolumeGrams(AnalyticsSetRecord record) {
  final reps = record.reps;
  if (reps == null) return null;

  switch (record.trackingType) {
    case 'weightReps':
    case 'weightTime':
      final weight = record.weightGrams;
      return weight == null ? null : weight * reps;
    case 'bodyweightReps':
      final effective = effectiveLoadGrams(
        bodyweightGrams: record.workoutBodyweightGrams,
        coefficient: record.bodyweightCoefficient,
        addedGrams: record.weightGrams ?? 0,
      );
      return effective * reps;
    default:
      return null;
  }
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
    if (muscle != null && record.primaryMuscle != muscle) continue;
    final volume = _setVolumeGrams(record);
    if (volume == null) continue;

    final week = weekStart.weekStartFor(record.date);
    totals[week] = (totals[week] ?? 0) + volume;
  }

  final weeks = totals.keys.toList()..sort();
  return [
    for (final week in weeks)
      WeeklyVolumePoint(weekStart: week, volumeGrams: totals[week]!),
  ];
}

/// Oldest-to-newest **daily** totals — `F-ANA-010`'s ACWR needs day
/// granularity, unlike the weekly charts above.
List<({DateTime date, int volumeGrams})> dailyVolume(
  List<AnalyticsSetRecord> records,
) {
  final totals = <DateTime, int>{};
  for (final record in records) {
    if (!isCountedSet(
      setType: record.setType,
      isCompleted: record.isCompleted,
    )) {
      continue;
    }
    final volume = _setVolumeGrams(record);
    if (volume == null) continue;

    totals[record.date] = (totals[record.date] ?? 0) + volume;
  }

  final dates = totals.keys.toList()..sort();
  return [for (final date in dates) (date: date, volumeGrams: totals[date]!)];
}

/// [weeklyVolume] for every muscle that appears in [records] at all, in one
/// pass — what the weekly insight cards (`F-ANA-013`) need to scan every
/// muscle for a notable change without re-scanning the full record list once
/// per muscle. A muscle never trained has no key, the same "never appeared
/// vs. appeared with zero" distinction `setsPerMuscleByWeek` already makes.
Map<String, List<WeeklyVolumePoint>> weeklyVolumeAllMuscles(
  List<AnalyticsSetRecord> records, {
  required WeekStart weekStart,
}) {
  final totals = <String, Map<DateTime, int>>{};
  for (final record in records) {
    if (!isCountedSet(
      setType: record.setType,
      isCompleted: record.isCompleted,
    )) {
      continue;
    }
    final volume = _setVolumeGrams(record);
    if (volume == null) continue;

    final week = weekStart.weekStartFor(record.date);
    final byWeek = totals.putIfAbsent(record.primaryMuscle, () => {});
    byWeek[week] = (byWeek[week] ?? 0) + volume;
  }

  return {
    for (final muscle in totals.keys)
      muscle: [
        for (final week in totals[muscle]!.keys.toList()..sort())
          WeeklyVolumePoint(
            weekStart: week,
            volumeGrams: totals[muscle]![week]!,
          ),
      ],
  };
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
