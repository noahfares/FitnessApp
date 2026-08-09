/// RPE-autoregulated progression (`F-PRG-005`,
/// `docs/40-ANALYTICS-SPEC.md` §12).
library;

import 'progression_rationale.dart';
import 'progression_rule.dart';

/// One session's outcome applied to [weightGrams], given [gap] — target RPE
/// minus the RPE actually logged on last session's top set. A positive gap
/// means the set came in *easier* than aimed for (room to add more); a
/// negative gap means it came in *harder* (go up less, or back off).
/// Reuses [ProgressionOutcome.success]/`.partial`/`.deload` — the same three
/// directions ("go up", "repeat", "cut weight") linear progression already
/// names, just reached by a different signal.
({int weightGrams, ProgressionRationale rationale}) applyRpeAutoregulation({
  required int weightGrams,
  required double gap,
  required RpeAutoregulationConfig config,
  required int previousReps,
}) {
  if (gap >= 1.0) {
    final delta = config.incrementGrams * 2;
    return (
      weightGrams: weightGrams + delta,
      rationale: ProgressionRationale(
        outcome: ProgressionOutcome.success,
        previousWeightGrams: weightGrams,
        previousReps: previousReps,
        deltaGrams: delta,
      ),
    );
  }
  if (gap >= 0) {
    return (
      weightGrams: weightGrams + config.incrementGrams,
      rationale: ProgressionRationale(
        outcome: ProgressionOutcome.success,
        previousWeightGrams: weightGrams,
        previousReps: previousReps,
        deltaGrams: config.incrementGrams,
      ),
    );
  }
  if (gap > -1.0) {
    return (
      weightGrams: weightGrams,
      rationale: ProgressionRationale(
        outcome: ProgressionOutcome.partial,
        previousWeightGrams: weightGrams,
        previousReps: previousReps,
      ),
    );
  }
  final backedOff = (weightGrams * (1 - config.backoffFraction)).round();
  return (
    weightGrams: backedOff,
    rationale: ProgressionRationale(
      outcome: ProgressionOutcome.deload,
      previousWeightGrams: weightGrams,
      previousReps: previousReps,
      deltaGrams: backedOff - weightGrams,
    ),
  );
}
