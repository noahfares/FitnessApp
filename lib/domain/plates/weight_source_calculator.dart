/// Closest-achievable weight for the two non-barbell weight sources
/// (`F-PLT-005`), `docs/40-ANALYTICS-SPEC.md` §13.
///
/// Pure Dart, canonical grams throughout, same `RoundingDirection` semantics
/// [closestAchievableGrams] already established for the plate-loaded case
/// (down/up/nearest, ties favouring down).
library;

import 'plate_calculator.dart';

/// The closest weight in [availableGrams] — a dumbbell rack's actual stock,
/// not assumed to be evenly spaced (`F-PLT-005`'s "available-increment
/// list").
int? closestAchievableFixedIncrement({
  required int targetGrams,
  required List<int> availableGrams,
  RoundingDirection direction = RoundingDirection.down,
}) {
  if (availableGrams.isEmpty) return null;

  int? below;
  int? above;
  for (final g in availableGrams) {
    if (g <= targetGrams && (below == null || g > below)) below = g;
    if (g >= targetGrams && (above == null || g < above)) above = g;
  }

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

/// The closest weight a [baseGrams]-and-[stepGrams] stack can reach, with an
/// optional [halfStepGrams] add-on magnet stackable on any pin position.
///
/// Achievable loads are `base + n*step` and, when a half step is configured,
/// `base + n*step + halfStep` for every `n >= 0`.
int? closestAchievableStack({
  required int targetGrams,
  required int baseGrams,
  required int stepGrams,
  int? halfStepGrams,
  RoundingDirection direction = RoundingDirection.down,
}) {
  if (stepGrams <= 0) return null;
  if (targetGrams < baseGrams) {
    return direction == RoundingDirection.down ? null : baseGrams;
  }

  final halfSteps = (halfStepGrams != null && halfStepGrams > 0)
      ? [0, halfStepGrams]
      : const [0];
  final maxSteps = (targetGrams - baseGrams) ~/ stepGrams + 1;

  int? below;
  int? above;
  for (var n = 0; n <= maxSteps; n++) {
    for (final half in halfSteps) {
      final candidate = baseGrams + n * stepGrams + half;
      if (candidate <= targetGrams && (below == null || candidate > below)) {
        below = candidate;
      }
      if (candidate >= targetGrams && (above == null || candidate < above)) {
        above = candidate;
      }
    }
  }

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
