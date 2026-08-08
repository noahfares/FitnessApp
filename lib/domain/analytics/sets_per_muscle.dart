/// Hard sets per muscle group per week (`F-ANA-005`,
/// `docs/40-ANALYTICS-SPEC.md` §3).
library;

import '../../core/units/week_start.dart';
import 'analytics_boundary.dart';
import 'analytics_set_record.dart';

class MuscleWeekPoint {
  const MuscleWeekPoint({required this.weekStart, required this.sets});

  final DateTime weekStart;

  /// 1.0 per set where this muscle is primary, 0.5 where it's secondary
  /// (§3 rules 1–2) — not necessarily a whole number.
  final double sets;
}

/// Oldest-to-newest weekly totals, one series per muscle that appears in
/// [records] at all. A muscle a person has never trained has no key, never a
/// zero-filled series — the caller decides whether "never appeared" and
/// "appeared with zero" should read differently.
Map<String, List<MuscleWeekPoint>> setsPerMuscleByWeek(
  List<AnalyticsSetRecord> records, {
  required WeekStart weekStart,
}) {
  final totals = <String, Map<DateTime, double>>{};

  void add(String muscle, DateTime week, double amount) {
    final byWeek = totals.putIfAbsent(muscle, () => {});
    byWeek[week] = (byWeek[week] ?? 0) + amount;
  }

  for (final record in records) {
    if (!isCountedSet(
      setType: record.setType,
      isCompleted: record.isCompleted,
    )) {
      continue;
    }
    // `fullBody` contributes to no specific muscle count (§3 rule 4).
    final week = weekStart.weekStartFor(record.date);
    if (record.primaryMuscle != 'fullBody') {
      add(record.primaryMuscle, week, 1.0);
    }
    for (final secondary in record.secondaryMuscles) {
      add(secondary, week, 0.5);
    }
  }

  return {
    for (final muscle in totals.keys)
      muscle: [
        for (final week in totals[muscle]!.keys.toList()..sort())
          MuscleWeekPoint(weekStart: week, sets: totals[muscle]![week]!),
      ],
  };
}

/// One exercise's contribution to a muscle's set count.
class MuscleContribution {
  const MuscleContribution({required this.exerciseName, required this.sets});

  final String exerciseName;
  final double sets;
}

/// Which exercises contributed to [muscle], most first (`F-ANA-005` §3's
/// drill-down) — over every counted set in [records], not scoped to one
/// week, since tap-through to a single bar is `F-ANA-016` (batch 3.6).
List<MuscleContribution> contributingExercises(
  List<AnalyticsSetRecord> records, {
  required String muscle,
}) {
  final totals = <String, double>{};
  for (final record in records) {
    if (!isCountedSet(
      setType: record.setType,
      isCompleted: record.isCompleted,
    )) {
      continue;
    }
    if (record.primaryMuscle == muscle) {
      totals[record.exerciseName] = (totals[record.exerciseName] ?? 0) + 1.0;
    }
    if (record.secondaryMuscles.contains(muscle)) {
      totals[record.exerciseName] = (totals[record.exerciseName] ?? 0) + 0.5;
    }
  }

  final sorted = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return [
    for (final entry in sorted)
      MuscleContribution(exerciseName: entry.key, sets: entry.value),
  ];
}
