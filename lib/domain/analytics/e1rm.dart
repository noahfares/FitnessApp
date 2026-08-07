/// Estimated one-rep max (`docs/40-ANALYTICS-SPEC.md` §1).
///
/// Epley only — formula selection (`F-SET-006`) is Phase 3. Whether a value
/// is "unreliable" at high reps (§1 rule 2) is a chart concern (`F-ANA-003`),
/// not decided here.
library;

/// Epley e1RM for a set of [weightGrams] × [reps], in the same unit as
/// [weightGrams] (canonical grams in practice).
///
/// Returns `null` for non-positive weight (§1 rule 5: no e1RM, not zero).
/// A genuine single (`reps == 1`) returns the weight exactly (§1 rule 1) —
/// Epley would otherwise scale it by 1.033, which is plainly wrong for a
/// weight the lifter has already proven they can lift once.
int? epley1Rm({required int weightGrams, required int reps}) {
  if (weightGrams <= 0) return null;
  if (reps <= 1) return weightGrams;
  return (weightGrams * (1 + reps / 30)).round();
}
