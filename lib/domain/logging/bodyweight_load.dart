/// Effective load for bodyweight-loaded exercises (`F-LOG-019`).
///
/// Pure Dart. Counting a weighted pull-up as just its added plate
/// understates the load by a factor of five — most of it is the lifter.
library;

/// `bodyweight × coefficient + added weight` (§1, §3).
///
/// [bodyweightGrams] is the session's captured bodyweight (`F-BOD-001`) —
/// null when nothing has ever been logged, in which case the added weight
/// is all there is to go on. [coefficient] defaults to `1.0` (full
/// bodyweight) when the exercise has no override configured — a push-up's
/// ~0.64 is an example override, not a universal default.
int effectiveLoadGrams({
  required int? bodyweightGrams,
  required double? coefficient,
  required int addedGrams,
}) {
  if (bodyweightGrams == null) return addedGrams;
  final loaded = (bodyweightGrams * (coefficient ?? 1.0)).round();
  return loaded + addedGrams;
}
