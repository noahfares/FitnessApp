/// Progression engine core (`F-PRG-001`).
///
/// `computeTargets` is pure and deterministic: given the same rule, history
/// and context it always proposes the same target, with no clock and no
/// stored streak state of its own — the failure streak a linear rule needs
/// is derived by walking history backward each call, the same
/// recompute-from-raw-data philosophy `PersonalRecordRepository.rebuildAll`
/// already uses rather than an incrementally-patched counter (§4 rule 4 of
/// `docs/40-ANALYTICS-SPEC.md`, generalised to this rule).
///
/// Models the exercise's **top set only** — the heaviest logged weight in a
/// session is what progresses. Drop sets and backoff sets at a lighter
/// weight are counted toward the session's success/partial/failure verdict
/// (they're still counted sets) but do not become the progressed weight
/// themselves. A rule that progresses each set independently is out of
/// scope for `F-PRG-002`'s spec, which describes one weight per exercise.
library;

import '../analytics/exercise_history.dart';
import 'double_progression.dart';
import 'linear_progression.dart';
import 'progression_rationale.dart';
import 'progression_rule.dart';
import 'session_result.dart';

class TargetSet {
  const TargetSet({
    required this.weightGrams,
    required this.reps,
    required this.sets,
    required this.rationale,
  });

  final int? weightGrams;
  final int? reps;
  final int? sets;
  final ProgressionRationale rationale;
}

/// The routine exercise's own static configuration — the fallback for a
/// first-ever run (§5) and the source of the set count and, for a linear
/// rule, the fixed rep target every session is judged against.
class ProgressionContext {
  const ProgressionContext({
    this.staticWeightGrams,
    this.staticReps,
    this.staticRepsMax,
    this.staticSets,
  });

  final int? staticWeightGrams;

  /// The bottom of the rep range for a double-progression rule; the fixed
  /// rep target for a linear rule.
  final int? staticReps;

  /// The top of the rep range — only read by a double-progression rule.
  final int? staticRepsMax;
  final int? staticSets;
}

int _topSetWeight(List<ExerciseHistorySet> sets) =>
    sets.map((set) => set.weightGrams ?? 0).reduce((a, b) => a > b ? a : b);

TargetSet computeTargets({
  required ProgressionRule rule,

  /// Newest-first, matching `SetRepository.watchExerciseHistory`.
  required List<ExerciseHistorySession> exerciseHistory,
  required ProgressionContext context,
}) {
  final priorSessions = exerciseHistory
      .where((session) => session.countedSets.isNotEmpty)
      .toList();

  if (priorSessions.isEmpty) {
    return TargetSet(
      weightGrams: context.staticWeightGrams,
      reps: context.staticReps,
      sets: context.staticSets,
      rationale: ProgressionRationale(
        outcome: ProgressionOutcome.firstRun,
        targetReps: context.staticReps,
      ),
    );
  }

  switch (rule) {
    case ManualCarryForwardRule():
      final lastSets = priorSessions.first.countedSets;
      final topWeight = _topSetWeight(lastSets);
      final topSet = lastSets.firstWhere(
        (set) => (set.weightGrams ?? 0) == topWeight,
      );
      return TargetSet(
        weightGrams: topSet.weightGrams,
        reps: topSet.reps,
        sets: context.staticSets ?? lastSets.length,
        rationale: ProgressionRationale(
          outcome: ProgressionOutcome.manualCarryForward,
          previousWeightGrams: topSet.weightGrams,
          previousReps: topSet.reps,
        ),
      );

    case LinearProgressionRule(config: final config):
      final lastSets = priorSessions.first.countedSets;
      final currentWeight = _topSetWeight(lastSets);
      final targetReps =
          context.staticReps ??
          lastSets.map((set) => set.reps ?? 0).reduce((a, b) => a > b ? a : b);

      final lastResult = evaluateSession(
        lastSets,
        targetWeightGrams: currentWeight,
        targetReps: targetReps,
      );

      // Walk backward through sessions at this same weight, counting a
      // trailing run of failures — the streak `applyLinearProgression`
      // needs, derived rather than stored.
      var trailingFailures = 0;
      for (final session in priorSessions) {
        final sets = session.countedSets;
        if (_topSetWeight(sets) != currentWeight) break;
        final result = evaluateSession(
          sets,
          targetWeightGrams: currentWeight,
          targetReps: targetReps,
        );
        if (result != SessionResult.failure) break;
        trailingFailures++;
      }
      final failuresBeforeLastSession = lastResult == SessionResult.failure
          ? trailingFailures - 1
          : 0;

      final applied = applyLinearProgression(
        state: LinearProgressionState(
          weightGrams: currentWeight,
          consecutiveFailures: failuresBeforeLastSession,
        ),
        result: lastResult,
        config: config,
        previousReps: lastSets.first.reps ?? targetReps,
      );

      return TargetSet(
        weightGrams: applied.state.weightGrams,
        reps: targetReps,
        sets: context.staticSets ?? lastSets.length,
        rationale: applied.rationale,
      );

    case DoubleProgressionRule(config: final config):
      final lastSets = priorSessions.first.countedSets;
      final currentWeight = _topSetWeight(lastSets);
      final repsMin = context.staticReps ?? 1;
      final repsMax = context.staticRepsMax ?? repsMin;

      final lastTopResult = evaluateSession(
        lastSets,
        targetWeightGrams: currentWeight,
        targetReps: repsMax,
      );
      final lastFloorResult = evaluateSession(
        lastSets,
        targetWeightGrams: currentWeight,
        targetReps: repsMin,
      );

      // Walk backward through sessions at this same weight, counting a
      // trailing run of "every set below the floor" — the streak
      // `applyDoubleProgression`'s deload rule needs, derived rather than
      // stored, same reasoning as the linear rule's failure streak above.
      var trailingFloorMisses = 0;
      for (final session in priorSessions) {
        final sets = session.countedSets;
        if (_topSetWeight(sets) != currentWeight) break;
        final floorResult = evaluateSession(
          sets,
          targetWeightGrams: currentWeight,
          targetReps: repsMin,
        );
        if (floorResult != SessionResult.failure) break;
        trailingFloorMisses++;
      }
      final missesBeforeLastSession = lastFloorResult == SessionResult.failure
          ? trailingFloorMisses - 1
          : 0;

      final applied = applyDoubleProgression(
        state: DoubleProgressionState(
          weightGrams: currentWeight,
          floorMisses: missesBeforeLastSession,
        ),
        topResult: lastTopResult,
        floorResult: lastFloorResult,
        config: config,
        previousReps: lastSets.first.reps ?? repsMin,
        repsMin: repsMin,
      );

      return TargetSet(
        weightGrams: applied.state.weightGrams,
        reps: repsMin,
        sets: context.staticSets ?? lastSets.length,
        rationale: applied.rationale,
      );
  }
}
