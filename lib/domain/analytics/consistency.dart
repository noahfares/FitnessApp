/// Consistency (`F-ANA-006`, `docs/40-ANALYTICS-SPEC.md` §5).
library;

import '../../core/units/week_start.dart';
import 'analytics_boundary.dart';
import 'analytics_set_record.dart';

/// Every local calendar date with at least one counted set (§5's "Training
/// day" definition).
Set<DateTime> trainingDays(List<AnalyticsSetRecord> records) {
  final days = <DateTime>{};
  for (final record in records) {
    if (isCountedSet(
      setType: record.setType,
      isCompleted: record.isCompleted,
    )) {
      days.add(record.date);
    }
  }
  return days;
}

/// One count per week from the earliest training day through the current
/// week, oldest first — zero-filled for any week with no training days, so
/// [consistencyStats] sees a continuous series rather than gaps that would
/// silently glue two streaks together.
List<int> weeklySessionCounts(
  Set<DateTime> trainingDays, {
  required WeekStart weekStart,
  required DateTime now,
}) {
  if (trainingDays.isEmpty) return const [];

  final perWeek = <DateTime, int>{};
  for (final day in trainingDays) {
    final week = weekStart.weekStartFor(day);
    perWeek[week] = (perWeek[week] ?? 0) + 1;
  }

  final firstWeek = perWeek.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  final currentWeek = weekStart.weekStartFor(now);

  final counts = <int>[];
  var week = firstWeek;
  while (!week.isAfter(currentWeek)) {
    counts.add(perWeek[week] ?? 0);
    week = week.add(const Duration(days: 7));
  }
  return counts;
}

class ConsistencyStats {
  const ConsistencyStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.sessionsPerWeek,
  });

  /// Consecutive **complete** weeks meeting [weeklyTarget], counting
  /// backward from the week before the current one (§5 rule 3 — the
  /// in-progress week never breaks a streak, whatever it currently reads).
  final int currentStreak;

  /// The longest such run anywhere in history, including the current week
  /// if it happens to extend one (it can only ever help, never break it,
  /// same as any other week in this pass).
  final int longestStreak;

  /// Trailing 4 weeks (including the current, partial one) ÷ 4 — a fixed
  /// divisor, per §5's own wording, even in someone's first month, where it
  /// understates the true average until 4 weeks of history exist.
  final double sessionsPerWeek;
}

/// [weeklyCounts] must be oldest → newest with the **last entry being the
/// current, still-in-progress week** — the shape [weeklySessionCounts]
/// produces, and the shape the `streak` fixture uses.
ConsistencyStats consistencyStats(
  List<int> weeklyCounts, {
  int weeklyTarget = 3,
}) {
  if (weeklyCounts.isEmpty) {
    return const ConsistencyStats(
      currentStreak: 0,
      longestStreak: 0,
      sessionsPerWeek: 0,
    );
  }

  var longest = 0;
  var running = 0;
  for (final count in weeklyCounts) {
    if (count >= weeklyTarget) {
      running++;
      if (running > longest) longest = running;
    } else {
      running = 0;
    }
  }

  final completeWeeks = weeklyCounts.sublist(0, weeklyCounts.length - 1);
  var current = 0;
  for (var i = completeWeeks.length - 1; i >= 0; i--) {
    if (completeWeeks[i] < weeklyTarget) break;
    current++;
  }

  final trailing = weeklyCounts.length <= 4
      ? weeklyCounts
      : weeklyCounts.sublist(weeklyCounts.length - 4);
  final sessionsPerWeek =
      trailing.fold<int>(0, (sum, count) => sum + count) / 4;

  return ConsistencyStats(
    currentStreak: current,
    longestStreak: longest,
    sessionsPerWeek: sessionsPerWeek,
  );
}
