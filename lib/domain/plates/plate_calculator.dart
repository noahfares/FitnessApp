/// Plate maths (`F-PLT-001`, `F-PLT-004`), `docs/40-ANALYTICS-SPEC.md` §13.
///
/// Pure Dart, canonical grams throughout — no display unit ever appears
/// here (`CLAUDE.md` invariants).
library;

/// One plate size and how many *pairs* of it are available (`F-PLT-002`).
class PlateSpec {
  const PlateSpec({required this.weightGrams, required this.pairsAvailable});

  final int weightGrams;
  final int pairsAvailable;
}

/// How many pairs of one plate size a solved load uses.
class PlateUsage {
  const PlateUsage({required this.weightGrams, required this.pairs});

  final int weightGrams;
  final int pairs;
}

enum PlateSolveStatus {
  /// The target is assembled exactly.
  exact,

  /// The target is below the bar's own weight — no plates can make it
  /// lighter.
  belowBar,

  /// `target − bar` is an odd number of grams and cannot be split into two
  /// equal integer-gram sides.
  oddLoad,

  /// The target sits strictly between the best achievable load below it and
  /// the best achievable load above it.
  closest,
}

/// `solvePlateLoad`'s result (`F-PLT-001` §1–3).
class PlateSolveResult {
  const PlateSolveResult({
    required this.targetGrams,
    required this.barWeightGrams,
    required this.status,
    this.plates = const [],
    this.achievedGrams,
    this.closestBelowGrams,
    this.closestAboveGrams,
  });

  final int targetGrams;
  final int barWeightGrams;
  final PlateSolveStatus status;

  /// The per-side plates for [achievedGrams] (empty for [belowBar] and
  /// [oddLoad]).
  final List<PlateUsage> plates;

  /// The load this solve actually reaches — equals [targetGrams] when
  /// [status] is [PlateSolveStatus.exact], equals [closestBelowGrams]
  /// otherwise.
  final int? achievedGrams;

  final int? closestBelowGrams;
  final int? closestAboveGrams;

  bool get isExact => status == PlateSolveStatus.exact;
}

/// Greedy heaviest-first solve, constrained by the pairs actually available
/// (`F-PLT-001` §2).
PlateSolveResult solvePlateLoad({
  required int targetGrams,
  required int barWeightGrams,
  required List<PlateSpec> inventory,
}) {
  if (targetGrams < barWeightGrams) {
    return PlateSolveResult(
      targetGrams: targetGrams,
      barWeightGrams: barWeightGrams,
      status: PlateSolveStatus.belowBar,
      closestAboveGrams: barWeightGrams,
    );
  }

  final perSideTarget = targetGrams - barWeightGrams;
  if (perSideTarget.isOdd) {
    return PlateSolveResult(
      targetGrams: targetGrams,
      barWeightGrams: barWeightGrams,
      status: PlateSolveStatus.oddLoad,
    );
  }

  final halfTarget = perSideTarget ~/ 2;
  final sorted = [...inventory]
    ..removeWhere((p) => p.weightGrams <= 0 || p.pairsAvailable <= 0)
    ..sort((a, b) => b.weightGrams.compareTo(a.weightGrams));

  var remaining = halfTarget;
  final used = <PlateUsage>[];
  for (final plate in sorted) {
    final maxByRemaining = remaining ~/ plate.weightGrams;
    final count = maxByRemaining < plate.pairsAvailable
        ? maxByRemaining
        : plate.pairsAvailable;
    if (count > 0) {
      used.add(PlateUsage(weightGrams: plate.weightGrams, pairs: count));
      remaining -= count * plate.weightGrams;
    }
  }

  final achievedHalf = halfTarget - remaining;
  final achievedGrams = barWeightGrams + achievedHalf * 2;

  if (remaining == 0) {
    return PlateSolveResult(
      targetGrams: targetGrams,
      barWeightGrams: barWeightGrams,
      status: PlateSolveStatus.exact,
      plates: used,
      achievedGrams: achievedGrams,
    );
  }

  final usedPairs = {for (final u in used) u.weightGrams: u.pairs};
  int? closestAboveGrams;
  // Smallest plate size first — the smallest available step up from what was
  // already assembled.
  for (final plate in sorted.reversed) {
    if ((usedPairs[plate.weightGrams] ?? 0) < plate.pairsAvailable) {
      closestAboveGrams = achievedGrams + plate.weightGrams * 2;
      break;
    }
  }

  return PlateSolveResult(
    targetGrams: targetGrams,
    barWeightGrams: barWeightGrams,
    status: PlateSolveStatus.closest,
    plates: used,
    achievedGrams: achievedGrams,
    closestBelowGrams: achievedGrams,
    closestAboveGrams: closestAboveGrams,
  );
}

enum RoundingDirection { down, up, nearest }

/// The nearest assemblable load, direction-configurable (`F-PLT-004`).
///
/// Exposed as a pure domain function so the progression engine can call it
/// directly without touching UI.
int? closestAchievableGrams({
  required int targetGrams,
  required int barWeightGrams,
  required List<PlateSpec> inventory,
  RoundingDirection direction = RoundingDirection.down,
}) {
  final result = solvePlateLoad(
    targetGrams: targetGrams,
    barWeightGrams: barWeightGrams,
    inventory: inventory,
  );

  switch (result.status) {
    case PlateSolveStatus.exact:
      return result.achievedGrams;
    case PlateSolveStatus.belowBar:
      return direction == RoundingDirection.down ? null : barWeightGrams;
    case PlateSolveStatus.oddLoad:
      return null;
    case PlateSolveStatus.closest:
      final below = result.closestBelowGrams;
      final above = result.closestAboveGrams;
      switch (direction) {
        case RoundingDirection.down:
          return below;
        case RoundingDirection.up:
          return above ?? below;
        case RoundingDirection.nearest:
          if (above == null) return below;
          if (below == null) return above;
          final belowGap = targetGrams - below;
          final aboveGap = above - targetGrams;
          return aboveGap < belowGap ? above : below;
      }
  }
}
