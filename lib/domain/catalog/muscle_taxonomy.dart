/// The muscle taxonomy's push/pull/legs/core categorisation
/// (`F-CAT-013` §3, used by `F-ANA-008`'s balance ratios).
///
/// Pure Dart. Muscles arrive as their stored **names**, not the `Muscle`
/// enum, which lives in `lib/data/db/tables/` and the domain layer may not
/// import (docs/20-ARCHITECTURE.md) — same convention as
/// `domain/timing/rest_defaults.dart`'s `compoundMuscles`.
library;

enum MuscleCategory { push, pull, legs, core }

/// `neck` and `fullBody` deliberately map to no category — neither is a
/// push, a pull, a leg exercise, or core work, and forcing one into the
/// other three would misattribute it rather than resolve an edge case
/// (`F-CAT-013`'s own "decide explicitly" note).
const Map<String, MuscleCategory> _categories = {
  'chest': MuscleCategory.push,
  'frontDelts': MuscleCategory.push,
  'sideDelts': MuscleCategory.push,
  'triceps': MuscleCategory.push,
  'lats': MuscleCategory.pull,
  'traps': MuscleCategory.pull,
  'upperBack': MuscleCategory.pull,
  'rearDelts': MuscleCategory.pull,
  'biceps': MuscleCategory.pull,
  'forearms': MuscleCategory.pull,
  'quads': MuscleCategory.legs,
  'hamstrings': MuscleCategory.legs,
  'glutes': MuscleCategory.legs,
  'calves': MuscleCategory.legs,
  'adductors': MuscleCategory.legs,
  'abductors': MuscleCategory.legs,
  'abs': MuscleCategory.core,
  'obliques': MuscleCategory.core,
  'lowerBack': MuscleCategory.core,
};

/// `null` for a muscle with no category (`neck`, `fullBody`) or a name this
/// build doesn't recognise.
MuscleCategory? categoryOf(String muscle) => _categories[muscle];
