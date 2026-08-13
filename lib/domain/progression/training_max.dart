/// Training max derivation (`F-PRG-010` §1).
///
/// Pure Dart. The training max itself is a plain, user-editable field
/// (`exercises.training_max_grams`) — this is only the "derive from e1RM"
/// shortcut, ~90% of the best estimated one-rep max, the conventional
/// starting point for 5/3/1-style programming.
library;

/// Rounds down deliberately: a training max is a conservative anchor that
/// percentage-based sets are built on top of, so erring light is the safer
/// direction than erring heavy.
int deriveTrainingMaxGrams(int bestE1rmGrams) => (bestE1rmGrams * 0.9).floor();
