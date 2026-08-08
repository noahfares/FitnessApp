/// Estimated 1RM trend (`F-ANA-003`).
///
/// One point per session: the best working set's e1RM under the selected
/// [E1rmFormula] (`F-SET-006`) — not necessarily the same set
/// `ExerciseHistorySession.bestSet` would pick, since that's always Epley
/// (`F-ANA-002`'s own docs). Sessions outside the selected [DateRange]
/// (`F-ANA-015`) never reach this function; date scoping happens at the call
/// site, once, the same way warm-up/incomplete filtering happens once at
/// [ExerciseHistorySession.countedSets].
library;

import 'date_range.dart';
import 'e1rm.dart';
import 'exercise_history.dart';

/// One plotted point.
class E1rmTrendPoint {
  const E1rmTrendPoint({
    required this.date,
    required this.e1rmGrams,
    required this.reliable,
  });

  final DateTime date;
  final int e1rmGrams;

  /// False when the set behind this point was above 12 reps, or Brzycki's
  /// undefined-range fallback fired (§1 rules 2–3). Charts may exclude these
  /// rather than plot a number nobody should trust (`F-ANA-003` §3).
  final bool reliable;
}

/// Oldest-to-newest trend points for [sessions] — already assumed to be
/// scoped to one exercise and the desired [range]; [sessions] may arrive in
/// either order, since this always sorts before returning.
List<E1rmTrendPoint> e1rmTrend(
  List<ExerciseHistorySession> sessions, {
  required E1rmFormula formula,
  DateRange? range,
}) {
  final points = <E1rmTrendPoint>[];
  for (final session in sessions) {
    if (range != null && !range.contains(session.localDate)) continue;

    E1rmEstimate? best;
    for (final set in session.countedSets) {
      final weight = set.weightGrams;
      final reps = set.reps;
      if (weight == null || reps == null) continue;
      final estimate = estimate1Rm(
        weightGrams: weight,
        reps: reps,
        formula: formula,
      );
      if (estimate == null) continue;
      if (best == null || estimate.weightGrams > best.weightGrams) {
        best = estimate;
      }
    }
    if (best != null) {
      points.add(
        E1rmTrendPoint(
          date: session.localDate,
          e1rmGrams: best.weightGrams,
          reliable: best.reliable,
        ),
      );
    }
  }
  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
}
