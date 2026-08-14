import '../catalog/exercise_search.dart';

/// A catalogue exercise matched by name, or null when nothing in the
/// catalogue matches it and `F-DAT-007`'s mapping screen has to ask.
///
/// Exact-equality matching (folded, same as search's own normalisation for
/// accents/case), not the substring "contains" search
/// `domain/catalog/exercise_search.dart` does for live typeahead — an import
/// resolving "Bench" to every exercise with "bench" in its name would be a
/// worse outcome than asking.
String? matchImportedExerciseName(
  String importedName,
  List<ExerciseCandidate> catalogue,
) {
  final folded = foldForSearch(importedName);
  for (final candidate in catalogue) {
    if (candidate.foldedName == folded) return candidate.id;
  }
  for (final candidate in catalogue) {
    if (candidate.foldedAliases.contains(folded)) return candidate.id;
  }
  return null;
}

/// Every distinct imported exercise name that didn't match anything in the
/// catalogue — what `F-DAT-007`'s mapping screen presents, one row per name,
/// not one row per set (spec: *"remembers decisions... so a 400-row import
/// isn't 400 prompts"*).
List<String> unmatchedExerciseNames(
  Iterable<String> importedNames,
  List<ExerciseCandidate> catalogue,
) {
  final seen = <String>{};
  final unmatched = <String>[];
  for (final name in importedNames) {
    if (!seen.add(name)) continue;
    if (matchImportedExerciseName(name, catalogue) == null) {
      unmatched.add(name);
    }
  }
  return unmatched;
}
