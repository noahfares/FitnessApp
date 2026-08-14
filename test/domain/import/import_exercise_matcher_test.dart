import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/catalog/exercise_search.dart';
import 'package:fitness_app/domain/import/import_exercise_matcher.dart';

/// Batch 5.3 — `F-DAT-005` §2, `F-DAT-007`.
void main() {
  final catalogue = [
    ExerciseCandidate(id: 'bench', name: 'Bench Press'),
    ExerciseCandidate(id: 'rdl', name: 'Romanian Deadlift', aliases: ['rdl']),
  ];

  test('matches an exact name, case-insensitively', () {
    expect(matchImportedExerciseName('bench press', catalogue), 'bench');
  });

  test('matches an alias', () {
    expect(matchImportedExerciseName('RDL', catalogue), 'rdl');
  });

  test('does not fuzzy-match a substring', () {
    expect(matchImportedExerciseName('Bench', catalogue), isNull);
  });

  test('returns each unmatched name once, in first-seen order', () {
    final unmatched = unmatchedExerciseNames([
      'Bench Press',
      'Skullcrusher',
      'Skullcrusher',
      'Leg Press',
    ], catalogue);

    expect(unmatched, ['Skullcrusher', 'Leg Press']);
  });
}
