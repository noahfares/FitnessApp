/// Linear progression (`F-PRG-002`, `F-PRG-009`,
/// `docs/40-ANALYTICS-SPEC.md` §12).
library;

import '../catalog/muscle_taxonomy.dart';
import 'progression_rationale.dart';
import 'progression_rule.dart';
import 'session_result.dart';

/// Default increment for an exercise with no per-exercise override (§12
/// rule 2): smaller joints, smaller jumps.
int defaultIncrementGrams(String primaryMuscle) =>
    categoryOf(primaryMuscle) == MuscleCategory.legs ? 5000 : 2500;

class LinearProgressionState {
  const LinearProgressionState({
    required this.weightGrams,
    required this.consecutiveFailures,
  });

  final int weightGrams;
  final int consecutiveFailures;
}

/// One session's outcome applied to [state] (§12's linear-progression
/// formula). Pure: same state and result always produce the same next state.
({LinearProgressionState state, ProgressionRationale rationale})
applyLinearProgression({
  required LinearProgressionState state,
  required SessionResult result,
  required LinearProgressionConfig config,
  required int previousReps,
}) {
  switch (result) {
    case SessionResult.success:
      return (
        state: LinearProgressionState(
          weightGrams: state.weightGrams + config.incrementGrams,
          consecutiveFailures: 0,
        ),
        rationale: ProgressionRationale(
          outcome: ProgressionOutcome.success,
          previousWeightGrams: state.weightGrams,
          previousReps: previousReps,
          deltaGrams: config.incrementGrams,
        ),
      );
    case SessionResult.partial:
      return (
        state: state,
        rationale: ProgressionRationale(
          outcome: ProgressionOutcome.partial,
          previousWeightGrams: state.weightGrams,
          previousReps: previousReps,
          consecutiveFailures: state.consecutiveFailures,
        ),
      );
    case SessionResult.failure:
      final nextFailures = state.consecutiveFailures + 1;
      if (nextFailures >= config.failureThreshold) {
        final deloaded = (state.weightGrams * (1 - config.deloadFraction))
            .round();
        return (
          state: LinearProgressionState(
            weightGrams: deloaded,
            consecutiveFailures: 0,
          ),
          rationale: ProgressionRationale(
            outcome: ProgressionOutcome.deload,
            previousWeightGrams: state.weightGrams,
            previousReps: previousReps,
            deltaGrams: deloaded - state.weightGrams,
            consecutiveFailures: nextFailures,
          ),
        );
      }
      return (
        state: LinearProgressionState(
          weightGrams: state.weightGrams,
          consecutiveFailures: nextFailures,
        ),
        rationale: ProgressionRationale(
          outcome: ProgressionOutcome.failure,
          previousWeightGrams: state.weightGrams,
          previousReps: previousReps,
          consecutiveFailures: nextFailures,
        ),
      );
  }
}
