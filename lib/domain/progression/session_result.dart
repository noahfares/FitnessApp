/// Session result classification (`docs/40-ANALYTICS-SPEC.md` §12).
library;

import '../analytics/exercise_history.dart';

enum SessionResult { success, partial, failure }

/// A set is **met** if it was logged at or above the target weight and the
/// target reps. [countedSets] must already exclude warm-ups and incomplete
/// sets (`ExerciseHistorySession.countedSets` does this).
///
/// [countedSets] must be non-empty — callers handle the empty/first-run case
/// before reaching here, since "no sets logged" is not a failure, it's an
/// absence of data.
SessionResult evaluateSession(
  List<ExerciseHistorySet> countedSets, {
  required int targetWeightGrams,
  required int targetReps,
}) {
  assert(countedSets.isNotEmpty);
  final metCount = countedSets
      .where(
        (set) =>
            (set.weightGrams ?? 0) >= targetWeightGrams &&
            (set.reps ?? 0) >= targetReps,
      )
      .length;
  if (metCount == countedSets.length) return SessionResult.success;
  if (metCount == 0) return SessionResult.failure;
  return SessionResult.partial;
}
