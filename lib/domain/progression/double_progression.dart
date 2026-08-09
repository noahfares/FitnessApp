/// Double progression (`F-PRG-003`, `docs/40-ANALYTICS-SPEC.md` §12).
library;

import 'progression_rationale.dart';
import 'progression_rule.dart';
import 'session_result.dart';

class DoubleProgressionState {
  const DoubleProgressionState({
    required this.weightGrams,
    required this.floorMisses,
  });

  final int weightGrams;

  /// Consecutive trailing sessions, at this same weight, where every
  /// counted set fell below the bottom of the rep range.
  final int floorMisses;
}

/// One session's outcome applied to [state] (§12's double-progression
/// formula). [topResult] judges the session against the top of the rep
/// range, [floorResult] against the bottom — two different thresholds, not
/// one, unlike linear progression's single target.
({DoubleProgressionState state, ProgressionRationale rationale})
applyDoubleProgression({
  required DoubleProgressionState state,
  required SessionResult topResult,
  required SessionResult floorResult,
  required DoubleProgressionConfig config,
  required int previousReps,
  required int repsMin,
}) {
  if (topResult == SessionResult.success) {
    return (
      state: DoubleProgressionState(
        weightGrams: state.weightGrams + config.incrementGrams,
        floorMisses: 0,
      ),
      rationale: ProgressionRationale(
        outcome: ProgressionOutcome.repRangeTopMet,
        previousWeightGrams: state.weightGrams,
        previousReps: previousReps,
        targetReps: repsMin,
        deltaGrams: config.incrementGrams,
      ),
    );
  }

  if (floorResult == SessionResult.failure) {
    final nextMisses = state.floorMisses + 1;
    if (nextMisses >= config.floorMissThreshold) {
      final deloaded = (state.weightGrams * (1 - config.deloadFraction))
          .round();
      return (
        state: DoubleProgressionState(weightGrams: deloaded, floorMisses: 0),
        rationale: ProgressionRationale(
          outcome: ProgressionOutcome.deload,
          previousWeightGrams: state.weightGrams,
          previousReps: previousReps,
          targetReps: repsMin,
          deltaGrams: deloaded - state.weightGrams,
          consecutiveFailures: nextMisses,
        ),
      );
    }
    return (
      state: DoubleProgressionState(
        weightGrams: state.weightGrams,
        floorMisses: nextMisses,
      ),
      rationale: ProgressionRationale(
        outcome: ProgressionOutcome.failure,
        previousWeightGrams: state.weightGrams,
        previousReps: previousReps,
        targetReps: repsMin,
        consecutiveFailures: nextMisses,
      ),
    );
  }

  return (
    state: state,
    rationale: ProgressionRationale(
      outcome: ProgressionOutcome.partial,
      previousWeightGrams: state.weightGrams,
      previousReps: previousReps,
      targetReps: repsMin,
      consecutiveFailures: state.floorMisses,
    ),
  );
}
