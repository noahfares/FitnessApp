/// Weekly insight cards (`F-ANA-013`, `docs/40-ANALYTICS-SPEC.md` §14).
///
/// Pure Dart. Composes three already-built signals — per-muscle weekly
/// volume (`F-ANA-004`), per-exercise e1RM (`F-ANA-002`/`F-ANA-003`), and
/// hard sets per muscle per week (`F-ANA-005`) — into a small, ranked list
/// of cards. Text formatting is a presentation-layer concern, same as
/// `ProgressionRationale`: this only produces structured deltas in
/// canonical units.
library;

import '../../core/units/week_start.dart';
import 'analytics_boundary.dart';
import 'analytics_set_record.dart';
import 'e1rm.dart';
import 'sets_per_muscle.dart';
import 'weekly_volume.dart';

enum InsightKind { muscleVolumeChange, exerciseE1rmNewHigh, muscleSetsLastWeek }

class WeeklyInsight {
  const WeeklyInsight({
    required this.kind,
    this.muscle,
    this.exerciseId,
    this.exerciseName,
    required this.currentValue,
    this.previousValue,
    required this.significance,
  });

  final InsightKind kind;

  /// Set for [InsightKind.muscleVolumeChange] and
  /// [InsightKind.muscleSetsLastWeek].
  final String? muscle;

  /// Set for [InsightKind.exerciseE1rmNewHigh]. Carried alongside the name
  /// because two exercises can share a name (`F-CAT-003` §4).
  final String? exerciseId;
  final String? exerciseName;

  /// Canonical grams for the volume/e1RM kinds; a plain set count for
  /// [InsightKind.muscleSetsLastWeek].
  final double currentValue;

  /// Null for [InsightKind.muscleSetsLastWeek], which states a fact rather
  /// than a comparison (§14 rule 3).
  final double? previousValue;

  /// What [generateWeeklyInsights] ranks by, most significant first. A
  /// fraction (`|percentChange|`) for the two comparison kinds, scaled well
  /// under any real threshold for [InsightKind.muscleSetsLastWeek] — a fact
  /// with no comparison behind it never outranks a genuine change, however
  /// large the raw set count.
  final double significance;
}

/// Volume must move at least this much, either direction, to be "genuinely
/// notable" rather than ordinary week-to-week noise (§14 rule 2).
const double _volumeChangeThreshold = 0.20;

/// An e1RM must clear the prior weeks' best by at least this much to be a
/// real new high, not rounding noise on an already-established weight.
const double _e1rmChangeThreshold = 0.03;

/// The whole history must span at least this many distinct weeks with any
/// counted set before a single card is shown — the rule the acceptance
/// criterion needs: a new user with two sessions, almost certainly inside
/// one or two calendar weeks, sees nothing rather than a fact dressed up as
/// an insight (§14 rule 4).
const int _minimumWeeksOfHistory = 3;

/// Ranked, most significant first, capped at [maxCards]. Empty with fewer
/// than [_minimumWeeksOfHistory] distinct weeks of counted-set history, or
/// when nothing clears any signal's own threshold — never invented.
List<WeeklyInsight> generateWeeklyInsights(
  List<AnalyticsSetRecord> records, {
  required WeekStart weekStart,
  required DateTime now,
  int maxCards = 5,
}) {
  final counted = [
    for (final r in records)
      if (isCountedSet(setType: r.setType, isCompleted: r.isCompleted)) r,
  ];
  final weeksTrained = {
    for (final r in counted) weekStart.weekStartFor(r.date),
  };
  if (weeksTrained.length < _minimumWeeksOfHistory) return const [];

  final currentWeek = weekStart.weekStartFor(now);
  final insights = <WeeklyInsight>[];

  // Muscle volume change: current week vs. the trailing average of the
  // (up to 4) prior weeks that actually have data — same trailing-window
  // convention `domain/analytics/muscle_balance.dart` and
  // `domain/analytics/consistency.dart` already use.
  final volumeByMuscle = weeklyVolumeAllMuscles(counted, weekStart: weekStart);
  for (final entry in volumeByMuscle.entries) {
    final points = entry.value;
    final currentPoint = points.where((p) => p.weekStart == currentWeek);
    if (currentPoint.isEmpty) continue;
    final priorPoints = points.where((p) => p.weekStart != currentWeek).toList()
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
    if (priorPoints.length < 2) continue;
    final baselineWindow = priorPoints.take(4);
    final baseline =
        baselineWindow.map((p) => p.volumeGrams).reduce((a, b) => a + b) /
        baselineWindow.length;
    if (baseline <= 0) continue;

    final current = currentPoint.first.volumeGrams.toDouble();
    final percentChange = (current - baseline) / baseline;
    if (percentChange.abs() < _volumeChangeThreshold) continue;

    insights.add(
      WeeklyInsight(
        kind: InsightKind.muscleVolumeChange,
        muscle: entry.key,
        currentValue: current,
        previousValue: baseline,
        significance: percentChange.abs(),
      ),
    );
  }

  // Exercise e1RM new high: this week's best vs. the max of prior weeks'
  // bests — an e1RM "insight" is always framed as a fresh high (the spec's
  // own example is "up 7.5 kg"), never a decline, which a single missed
  // session would otherwise report as spurious backsliding.
  final e1rmByExerciseWeek = <String, Map<DateTime, int>>{};
  final exerciseNames = <String, String>{};
  for (final r in counted) {
    final weight = r.weightGrams;
    final reps = r.reps;
    if (weight == null || reps == null) continue;
    final estimate = epley1Rm(weightGrams: weight, reps: reps);
    if (estimate == null) continue;
    exerciseNames[r.exerciseId] = r.exerciseName;
    final byWeek = e1rmByExerciseWeek.putIfAbsent(r.exerciseId, () => {});
    final week = weekStart.weekStartFor(r.date);
    final existing = byWeek[week];
    if (existing == null || estimate > existing) byWeek[week] = estimate;
  }
  for (final entry in e1rmByExerciseWeek.entries) {
    final currentBest = entry.value[currentWeek];
    if (currentBest == null) continue;
    final priorBests = [
      for (final e in entry.value.entries)
        if (e.key != currentWeek) e.value,
    ];
    if (priorBests.length < 2) continue;
    final priorMax = priorBests.reduce((a, b) => a > b ? a : b);
    if (priorMax <= 0) continue;

    final percentChange = (currentBest - priorMax) / priorMax;
    if (percentChange < _e1rmChangeThreshold) continue;

    insights.add(
      WeeklyInsight(
        kind: InsightKind.exerciseE1rmNewHigh,
        exerciseId: entry.key,
        exerciseName: exerciseNames[entry.key],
        currentValue: currentBest.toDouble(),
        previousValue: priorMax.toDouble(),
        significance: percentChange,
      ),
    );
  }

  // Hard sets last week: a plain fact, no baseline needed (§14 rule 3) — but
  // still gated by the global history-length check above, so it never fires
  // on a brand-new user's very first tracked week.
  final setsByMuscle = setsPerMuscleByWeek(counted, weekStart: weekStart);
  for (final entry in setsByMuscle.entries) {
    final currentPoint = entry.value.where((p) => p.weekStart == currentWeek);
    if (currentPoint.isEmpty) continue;
    final sets = currentPoint.first.sets;
    if (sets <= 0) continue;

    insights.add(
      WeeklyInsight(
        kind: InsightKind.muscleSetsLastWeek,
        muscle: entry.key,
        currentValue: sets,
        // A plain fact ranks below any real comparison — scaled well under
        // every threshold above, so a busy muscle's raw set count can never
        // crowd out a genuine volume or e1RM change (a bug the first draft
        // of this function had: unscaled, "40 sets last week" would always
        // outrank a 200% e1RM jump).
        significance: sets / 1000,
      ),
    );
  }

  insights.sort((a, b) => b.significance.compareTo(a.significance));
  return insights.take(maxCards).toList();
}
