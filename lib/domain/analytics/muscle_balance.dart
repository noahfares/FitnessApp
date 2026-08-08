/// Muscle balance ratios (`F-ANA-008`, `docs/40-ANALYTICS-SPEC.md` §9).
///
/// Each ratio's numerator/denominator is the specific, narrower muscle list
/// §9's own table names — not `domain/catalog/muscle_taxonomy.dart`'s general
/// push/pull/legs/core category (which also includes `sideDelts`, `traps`,
/// `rearDelts` and `forearms`). The two serve different purposes: the
/// taxonomy is for a future relative-volume-by-muscle radar chart; this
/// ratio is the specific formula the spec defines and fixture-tests.
library;

class MuscleBalanceRatio {
  const MuscleBalanceRatio({
    required this.ratio,
    required this.numeratorSets,
    required this.denominatorSets,
  });

  /// `null` when the denominator is zero (§9 rule 2) — reported as "no
  /// pulling volume recorded", never as infinity.
  final double? ratio;

  final double numeratorSets;
  final double denominatorSets;
}

/// Push : pull — `chest + frontDelts + triceps` over `lats + upperBack + biceps`.
MuscleBalanceRatio pushPullRatio(Map<String, double> setsPerMuscle) {
  final push =
      (setsPerMuscle['chest'] ?? 0) +
      (setsPerMuscle['frontDelts'] ?? 0) +
      (setsPerMuscle['triceps'] ?? 0);
  final pull =
      (setsPerMuscle['lats'] ?? 0) +
      (setsPerMuscle['upperBack'] ?? 0) +
      (setsPerMuscle['biceps'] ?? 0);
  return MuscleBalanceRatio(
    ratio: pull == 0 ? null : push / pull,
    numeratorSets: push,
    denominatorSets: pull,
  );
}

/// Quad : hamstring — `quads` over `hamstrings + glutes`.
MuscleBalanceRatio quadHamstringRatio(Map<String, double> setsPerMuscle) {
  final quad = setsPerMuscle['quads'] ?? 0;
  final hamstring =
      (setsPerMuscle['hamstrings'] ?? 0) + (setsPerMuscle['glutes'] ?? 0);
  return MuscleBalanceRatio(
    ratio: hamstring == 0 ? null : quad / hamstring,
    numeratorSets: quad,
    denominatorSets: hamstring,
  );
}
