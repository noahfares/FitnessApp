/// Structured explanation for a proposed target (`F-PRG-008`).
///
/// Deliberately not an English sentence: canonical units only, display units
/// are a presentation concern (`CLAUDE.md` invariants) — the feature layer
/// turns this into "You hit 3×5 at 100 kg last time, so this is +2.5 kg."
/// using the same `QuantityFormatter` every other screen already reads
/// weight through.
library;

enum ProgressionOutcome {
  /// No prior session exists for this exercise — the routine's own static
  /// target is used unchanged (`F-PRG-001` §5).
  firstRun,

  /// The rule has no opinion — carries the last session's own values
  /// forward verbatim (`F-PRG-006`).
  manualCarryForward,

  /// Every counted set met the target last time.
  success,

  /// Some but not all counted sets met the target last time.
  partial,

  /// No counted set met the target last time, and the failure streak has
  /// not yet reached the deload threshold.
  failure,

  /// The failure streak just reached the deload threshold.
  deload,

  /// Every counted set reached the top of the rep range last time
  /// (`F-PRG-003` §2) — weight goes up, reps reset to the bottom.
  repRangeTopMet,

  /// The raw proposal rounded to an assemblable load lands back on the
  /// weight already being lifted — the smallest achievable plate jump
  /// exceeds the rule's increment (`F-PRG-012` §3). Weight is held; a rep is
  /// added instead.
  plateRoundingHeld,
}

class ProgressionRationale {
  const ProgressionRationale({
    required this.outcome,
    this.previousWeightGrams,
    this.previousReps,
    this.targetReps,
    this.deltaGrams = 0,
    this.consecutiveFailures = 0,
    this.rawWeightGrams,
  });

  final ProgressionOutcome outcome;

  /// What was actually logged (or, for [ProgressionOutcome.firstRun], null)
  /// last time this exercise appeared.
  final int? previousWeightGrams;
  final int? previousReps;

  /// The rep target the proposal is for — constant across a linear rule's
  /// history (§12 rule; reps only change on [ProgressionOutcome.manualCarryForward]).
  final int? targetReps;

  /// Signed change from [previousWeightGrams] to the proposed weight: positive
  /// on a successful increment, negative on a deload cut, zero otherwise.
  final int deltaGrams;

  final int consecutiveFailures;

  /// The raw pre-rounding proposal, only set when plate-aware rounding
  /// (`F-PRG-012`) actually changed the weight — including the
  /// [ProgressionOutcome.plateRoundingHeld] case, where it's what the rule
  /// wanted before rounding erased it entirely.
  final int? rawWeightGrams;

  /// Persisted as a nested object inside `workout_exercises.target_snapshot`
  /// (`F-PRG-008` §3) — alongside the proposed numbers themselves rather
  /// than as a separate column, since it is only ever read back for the one
  /// workout it was proposed for.
  Map<String, Object?> toJson() => {
    'outcome': outcome.name,
    'previousWeightGrams': previousWeightGrams,
    'previousReps': previousReps,
    'targetReps': targetReps,
    'deltaGrams': deltaGrams,
    'consecutiveFailures': consecutiveFailures,
    'rawWeightGrams': rawWeightGrams,
  };

  static ProgressionRationale? fromJson(Object? json) {
    if (json == null) return null;
    final map = json as Map<String, dynamic>;
    final outcomeName = map['outcome'] as String?;
    ProgressionOutcome? outcome;
    for (final value in ProgressionOutcome.values) {
      if (value.name == outcomeName) {
        outcome = value;
        break;
      }
    }
    if (outcome == null) return null;
    return ProgressionRationale(
      outcome: outcome,
      previousWeightGrams: map['previousWeightGrams'] as int?,
      previousReps: map['previousReps'] as int?,
      targetReps: map['targetReps'] as int?,
      deltaGrams: map['deltaGrams'] as int? ?? 0,
      consecutiveFailures: map['consecutiveFailures'] as int? ?? 0,
      rawWeightGrams: map['rawWeightGrams'] as int?,
    );
  }
}
