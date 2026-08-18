/// Muscle balance ratios (`F-ANA-008`, `docs/40-ANALYTICS-SPEC.md` §9).
///
/// Each ratio's numerator/denominator is the specific, narrower muscle list
/// §9's own table names — not `domain/catalog/muscle_taxonomy.dart`'s general
/// push/pull/legs/core category (which also includes `sideDelts`, `traps`,
/// `rearDelts` and `forearms`). The two serve different purposes: the
/// taxonomy is for a future relative-volume-by-muscle radar chart; this
/// ratio is the specific formula the spec defines and fixture-tests — and
/// `volumeShareByCategory` below is that radar, using the taxonomy.
library;

import '../catalog/muscle_taxonomy.dart';
import 'analytics_boundary.dart';
import 'analytics_set_record.dart';

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

/// Volume share by push/pull/legs/core, for the radar (`F-ANA-008`).
///
/// Shares rather than absolute grams: the question a radar answers is "is one
/// side of my training dwarfing another", and a chart whose scale depends on
/// how strong someone is answers a different, less useful one. Every category
/// is always present, including at zero — a missing axis would change the
/// shape of the polygon and read as though the category did not exist.
Map<MuscleCategory, double> volumeShareByCategory(
  List<AnalyticsSetRecord> records,
) {
  final totals = <MuscleCategory, int>{
    for (final category in MuscleCategory.values) category: 0,
  };
  for (final record in records) {
    if (!isCountedSet(
      setType: record.setType,
      isCompleted: record.isCompleted,
    )) {
      continue;
    }
    final category = categoryOf(record.primaryMuscle);
    if (category == null) continue;
    final weight = record.weightGrams;
    final reps = record.reps;
    if (weight == null || reps == null) continue;
    totals[category] = totals[category]! + weight * reps;
  }

  final sum = totals.values.fold<int>(0, (a, b) => a + b);
  if (sum == 0) {
    return {for (final category in MuscleCategory.values) category: 0.0};
  }
  return {for (final entry in totals.entries) entry.key: entry.value / sum};
}
