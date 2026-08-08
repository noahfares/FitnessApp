/// Estimated one-rep max (`docs/40-ANALYTICS-SPEC.md` §1).
library;

import 'dart:math' as math;

/// Epley e1RM for a set of [weightGrams] × [reps], in the same unit as
/// [weightGrams] (canonical grams in practice).
///
/// Returns `null` for non-positive weight (§1 rule 5: no e1RM, not zero).
/// A genuine single (`reps == 1`) returns the weight exactly (§1 rule 1) —
/// Epley would otherwise scale it by 1.033, which is plainly wrong for a
/// weight the lifter has already proven they can lift once.
///
/// Used unconditionally by personal-record detection (`F-LOG-013`) and
/// per-exercise history (`F-ANA-002`) — record-keeping and "what did I lift"
/// are not user preferences the way a trend chart's formula is
/// (`estimate1Rm` below, `F-SET-006`).
int? epley1Rm({required int weightGrams, required int reps}) {
  if (weightGrams <= 0) return null;
  if (reps <= 1) return weightGrams;
  return (weightGrams * (1 + reps / 30)).round();
}

/// Selectable in settings (`F-SET-006`); Epley is the default.
enum E1rmFormula { epley, brzycki, lombardi }

/// [estimate1Rm]'s result: the value, and whether it's reliable (§1 rule 2).
class E1rmEstimate {
  const E1rmEstimate({required this.weightGrams, required this.reliable});

  final int weightGrams;

  /// False above 12 reps (§1 rule 2) or when Brzycki's undefined range forced
  /// a fallback to Epley (§1 rule 3) — either way, charts may choose to
  /// exclude it rather than plot a number nobody should trust.
  final bool reliable;
}

/// e1RM under a selectable [formula] (`F-SET-006`). `null` for non-positive
/// weight, same as [epley1Rm].
///
/// A genuine single always returns the weight exactly, for every formula
/// (§1 rule 1) — Brzycki and Lombardi would otherwise also distort a proven
/// single, the same reason `epley1Rm` special-cases it.
E1rmEstimate? estimate1Rm({
  required int weightGrams,
  required int reps,
  required E1rmFormula formula,
}) {
  if (weightGrams <= 0) return null;
  if (reps <= 1) {
    return E1rmEstimate(weightGrams: weightGrams, reliable: true);
  }

  final reliable = reps <= 12;
  switch (formula) {
    case E1rmFormula.epley:
      return E1rmEstimate(
        weightGrams: epley1Rm(weightGrams: weightGrams, reps: reps)!,
        reliable: reliable,
      );
    case E1rmFormula.brzycki:
      // Undefined (division by zero or negative) at r >= 37 (§1 rule 3):
      // clamp by falling back to Epley, and the fallback is never reliable
      // regardless of rep count — it is standing in for an undefined result.
      if (reps >= 37) {
        return E1rmEstimate(
          weightGrams: epley1Rm(weightGrams: weightGrams, reps: reps)!,
          reliable: false,
        );
      }
      return E1rmEstimate(
        weightGrams: (weightGrams * 36 / (37 - reps)).round(),
        reliable: reliable,
      );
    case E1rmFormula.lombardi:
      return E1rmEstimate(
        weightGrams: (weightGrams * math.pow(reps, 0.10)).round(),
        reliable: reliable,
      );
  }
}
