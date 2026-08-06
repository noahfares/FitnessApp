/// Stepper increments (`F-LOG-006` §2–§3, `F-SET-007`).
///
/// Pure Dart over `lib/core/units`, which is itself pure (docs/22-UNITS.md).
library;

import '../../core/units/mass.dart';

/// The default jump for [equipment], **defined in the display [unit]** and
/// converted once to canonical grams.
///
/// Defined in the display unit because that is how plates come: a kilogram gym
/// steps in 2.5 kg and a pound gym in 5 lb, and converting one to the other
/// gives a number nobody can load (docs/22-UNITS.md §rounding). [equipment] is
/// the stored enum name; anything unrecognised gets the barbell default.
///
/// Per-exercise overrides land with `F-SET-007`; the caller passes
/// `exercises.increment_grams` when it is set and this is the fallback.
Mass defaultStep({required String equipment, required MassUnit unit}) {
  if (unit == MassUnit.lb) return Mass.lb(5);
  return switch (equipment) {
    'dumbbell' => Mass.kg(2),
    // Fixed-weight machines and bands do not step evenly at all, but a stepper
    // that does nothing is worse than one that guesses: 2.5 is the smallest
    // jump most stacks offer.
    _ => Mass.kg(2.5),
  };
}

/// [current] stepped by [times] × [step], floored at zero.
///
/// Integer grams throughout, so two hundred taps of `+2.5 kg` land on exactly
/// `+500 kg` — the acceptance criterion in `F-LOG-006`. Accumulating a double
/// and rounding at the end would not, and long-press repeat makes hundreds of
/// increments an ordinary occurrence rather than a pathological one.
///
/// Zero is a floor rather than an error: a zero-weight set is valid (an unloaded
/// bar, an assisted rep), but a negative one is not, and silently going negative
/// would be stored and then charted.
int steppedGrams(int current, Mass step, int times) {
  final result = current + step.grams * times;
  return result < 0 ? 0 : result;
}
