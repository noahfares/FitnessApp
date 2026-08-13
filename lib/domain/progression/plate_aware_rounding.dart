/// Weight-source-aware rounding (`F-PRG-012`), `docs/40-ANALYTICS-SPEC.md`
/// §13.
///
/// Applied to a [TargetSet] *after* `computeTargets`, never folded into it —
/// the progression rules stay in canonical, weight-source-free arithmetic,
/// and this is a separate, optional pass. One function per `WeightSource`
/// (`F-PLT-005`), sharing the same hold-or-round decision.
library;

import '../plates/plate_calculator.dart';
import '../plates/weight_source_calculator.dart';
import 'progression_engine.dart';
import 'progression_rationale.dart';

/// Rounds [target]'s weight to the nearest load assemblable from [inventory]
/// on [barWeightGrams] (`WeightSource.plateLoaded`).
TargetSet applyPlateRounding({
  required TargetSet target,
  required int barWeightGrams,
  required List<PlateSpec> inventory,
  int? previousWeightGrams,
  RoundingDirection direction = RoundingDirection.down,
}) {
  final proposed = target.weightGrams;
  if (proposed == null) return target;
  final rounded = closestAchievableGrams(
    targetGrams: proposed,
    barWeightGrams: barWeightGrams,
    inventory: inventory,
    direction: direction,
  );
  return _applyRounding(target, proposed, rounded, previousWeightGrams);
}

/// Rounds [target]'s weight to the nearest weight in [availableGrams]
/// (`WeightSource.fixedIncrement` — a dumbbell rack's actual stock).
TargetSet applyFixedIncrementRounding({
  required TargetSet target,
  required List<int> availableGrams,
  int? previousWeightGrams,
  RoundingDirection direction = RoundingDirection.down,
}) {
  final proposed = target.weightGrams;
  if (proposed == null) return target;
  final rounded = closestAchievableFixedIncrement(
    targetGrams: proposed,
    availableGrams: availableGrams,
    direction: direction,
  );
  return _applyRounding(target, proposed, rounded, previousWeightGrams);
}

/// Rounds [target]'s weight to the nearest weight a stack of [baseGrams] and
/// [stepGrams] (plus an optional [halfStepGrams] add-on) can reach
/// (`WeightSource.stack`).
TargetSet applyStackRounding({
  required TargetSet target,
  required int baseGrams,
  required int stepGrams,
  int? halfStepGrams,
  int? previousWeightGrams,
  RoundingDirection direction = RoundingDirection.down,
}) {
  final proposed = target.weightGrams;
  if (proposed == null) return target;
  final rounded = closestAchievableStack(
    targetGrams: proposed,
    baseGrams: baseGrams,
    stepGrams: stepGrams,
    halfStepGrams: halfStepGrams,
    direction: direction,
  );
  return _applyRounding(target, proposed, rounded, previousWeightGrams);
}

/// The shared hold-or-round decision every `apply*Rounding` function above
/// makes once it has its own [rounded] candidate.
///
/// When rounding erases the entire proposed change — the rounded weight
/// equals [previousWeightGrams], but [proposed] didn't — the weight is held
/// and a rep is added instead (§3), rather than silently proposing the same
/// weight as last time with no way to tell that apart from a plain repeat.
TargetSet _applyRounding(
  TargetSet target,
  int proposed,
  int? rounded,
  int? previousWeightGrams,
) {
  if (rounded == null || rounded == proposed) return target;

  if (previousWeightGrams != null &&
      rounded == previousWeightGrams &&
      proposed != previousWeightGrams) {
    return TargetSet(
      weightGrams: previousWeightGrams,
      reps: (target.reps ?? 0) + 1,
      sets: target.sets,
      rationale: ProgressionRationale(
        outcome: ProgressionOutcome.plateRoundingHeld,
        previousWeightGrams: target.rationale.previousWeightGrams,
        previousReps: target.rationale.previousReps,
        targetReps: target.reps,
        consecutiveFailures: target.rationale.consecutiveFailures,
        rawWeightGrams: proposed,
      ),
    );
  }

  return TargetSet(
    weightGrams: rounded,
    reps: target.reps,
    sets: target.sets,
    rationale: ProgressionRationale(
      outcome: target.rationale.outcome,
      previousWeightGrams: target.rationale.previousWeightGrams,
      previousReps: target.rationale.previousReps,
      targetReps: target.rationale.targetReps,
      deltaGrams: target.rationale.deltaGrams,
      consecutiveFailures: target.rationale.consecutiveFailures,
      rawWeightGrams: proposed,
    ),
  );
}
