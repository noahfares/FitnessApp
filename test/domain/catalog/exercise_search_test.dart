import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/catalog/exercise_search.dart';

/// `F-CAT-004` and `F-CAT-005`. Search is used mid-session with a rest clock
/// running, so "quietly returns nothing" is the failure mode that matters —
/// which is why the matching rules are pinned here rather than in a widget.
void main() {
  ExerciseCandidate candidate(
    String id,
    String name, {
    List<String> aliases = const [],
    String muscle = 'chest',
    String equipment = 'barbell',
    bool favorite = false,
    int? lastUsedAt,
  }) => ExerciseCandidate(
    id: id,
    name: name,
    aliases: aliases,
    primaryMuscle: muscle,
    equipment: equipment,
    isFavorite: favorite,
    lastUsedAt: lastUsedAt,
  );

  List<String> namesOf(List<ExerciseCandidate> results) => [
    for (final c in results) c.name,
  ];

  List<String> search(List<ExerciseCandidate> all, String query) =>
      namesOf(searchExercises(all, ExerciseFilter(query: query)));

  group('foldForSearch', () {
    test('lower-cases and strips diacritics', () {
      expect(foldForSearch('Bíceps Cürl'), 'biceps curl');
      expect(foldForSearch('Ø'), 'o');
    });

    test('expands ligatures and eszett rather than dropping them', () {
      expect(foldForSearch('Straße'), 'strasse');
      expect(foldForSearch('Æon'), 'aeon');
    });

    test('trims and collapses whitespace', () {
      // A leading space from an autocorrect or a fat thumb must not zero the
      // results (`F-CAT-004` §4).
      expect(foldForSearch('  Bench   Press  '), 'bench press');
      expect(foldForSearch('   '), '');
    });
  });

  group('matching (F-CAT-004 §1, §4)', () {
    final catalogue = [
      candidate('a', 'Bench Press', aliases: ['flat bench', 'bp']),
      candidate('b', 'Incline Bench Press'),
      candidate('c', 'Romanian Deadlift', aliases: ['RDL']),
      candidate('d', 'Bíceps Curl'),
    ];

    test('is case-insensitive substring matching on the name', () {
      expect(search(catalogue, 'PRESS'), [
        'Bench Press',
        'Incline Bench Press',
      ]);
    });

    test('matches aliases', () {
      // The acceptance criterion in F-CAT-004.
      expect(search(catalogue, 'rdl'), ['Romanian Deadlift']);
      expect(search(catalogue, 'bp'), ['Bench Press']);
    });

    test('is diacritic-insensitive both ways', () {
      expect(search(catalogue, 'biceps'), ['Bíceps Curl']);
      expect(search(catalogue, 'bíceps'), ['Bíceps Curl']);
    });

    test('matches across word boundaries', () {
      expect(search(catalogue, 'inc bench'), ['Incline Bench Press']);
    });

    test('tolerates surrounding space and unordered tokens', () {
      expect(search(catalogue, '  inc bench '), ['Incline Bench Press']);
      expect(search(catalogue, 'bench inc'), ['Incline Bench Press']);
    });

    test('an empty query returns the whole catalogue', () {
      expect(search(catalogue, '   '), hasLength(catalogue.length));
    });

    test('a token that matches nothing returns nothing', () {
      expect(search(catalogue, 'bench zzz'), isEmpty);
    });
  });

  group('ordering (F-CAT-004 §3)', () {
    test('exact and prefix matches outrank mid-name hits', () {
      final results = search([
        candidate('a', 'Incline Bench Press'),
        candidate('b', 'Bench Press'),
        candidate('c', 'Close Grip Bench Press'),
      ], 'bench');

      // Starts-with first; the other two are word-prefix matches, so they fall
      // through to alphabetical.
      expect(results, [
        'Bench Press',
        'Close Grip Bench Press',
        'Incline Bench Press',
      ]);
    });

    test('an exact name match wins outright', () {
      final results = search([
        candidate('a', 'Bench Press Machine'),
        candidate('b', 'Bench Press'),
      ], 'bench press');

      expect(results.first, 'Bench Press');
    });

    test('name matches outrank alias-only matches', () {
      final results = search([
        candidate('a', 'Romanian Deadlift', aliases: ['rdl']),
        candidate('b', 'RDL Machine'),
      ], 'rdl');

      expect(results, ['RDL Machine', 'Romanian Deadlift']);
    });

    test('favourites come before non-favourites of the same rank', () {
      final results = search([
        candidate('a', 'Zercher Squat'),
        candidate('b', 'Back Squat', favorite: true),
      ], 'squat');

      expect(results, ['Back Squat', 'Zercher Squat']);

      // ...and the favourite wins even when alphabetically last, which is what
      // proves it is the favourite flag doing the work and not the name.
      final reversed = search([
        candidate('a', 'Zercher Squat', favorite: true),
        candidate('b', 'Back Squat'),
      ], 'squat');
      expect(reversed, ['Zercher Squat', 'Back Squat']);
    });

    test('recency breaks ties, and never-used rows sort last', () {
      final results = search([
        candidate('a', 'A Squat'),
        candidate('b', 'B Squat', lastUsedAt: 1000),
        candidate('c', 'C Squat', lastUsedAt: 9000),
      ], 'squat');

      expect(results, ['C Squat', 'B Squat', 'A Squat']);
    });

    test('alphabetical is the last tiebreak', () {
      final results = search([
        candidate('a', 'Cable Fly'),
        candidate('b', 'Bench Fly'),
      ], 'fly');

      expect(results, ['Bench Fly', 'Cable Fly']);
    });
  });

  group('filters (F-CAT-005)', () {
    final catalogue = [
      candidate('a', 'Bench Press', muscle: 'chest', equipment: 'barbell'),
      candidate('b', 'Chest Press', muscle: 'chest', equipment: 'machine'),
      candidate('c', 'Back Squat', muscle: 'quads', equipment: 'barbell'),
      candidate('d', 'Leg Press', muscle: 'quads', equipment: 'machine'),
    ];

    test('OR within a category', () {
      final results = searchExercises(
        catalogue,
        const ExerciseFilter(equipment: {'machine', 'barbell'}),
      );
      expect(results, hasLength(4));

      final machinesOnly = searchExercises(
        catalogue,
        const ExerciseFilter(equipment: {'machine'}),
      );
      expect(namesOf(machinesOnly), ['Chest Press', 'Leg Press']);
    });

    test('AND across categories', () {
      final results = searchExercises(
        catalogue,
        const ExerciseFilter(muscles: {'chest'}, equipment: {'machine'}),
      );
      expect(namesOf(results), ['Chest Press']);
    });

    test('composes with the search text', () {
      final results = searchExercises(
        catalogue,
        const ExerciseFilter(query: 'press', muscles: {'quads'}),
      );
      expect(namesOf(results), ['Leg Press']);
    });

    test('an empty filter is not a filter', () {
      const filter = ExerciseFilter();
      expect(filter.isActive, isFalse);
      expect(filter.hasFacets, isFalse);
      expect(searchExercises(catalogue, filter), hasLength(4));
    });

    test('whitespace alone does not count as an active query', () {
      // Otherwise the result count appears the moment the field is focused and
      // a space is typed by accident.
      expect(const ExerciseFilter(query: '  ').isActive, isFalse);
    });

    test('toggling adds then removes, leaving the query alone', () {
      const initial = ExerciseFilter(query: 'press');
      final withChest = initial.toggleMuscle('chest');
      expect(withChest.muscles, {'chest'});
      expect(withChest.query, 'press');
      expect(withChest.facetCount, 1);

      expect(withChest.toggleMuscle('chest').muscles, isEmpty);
    });

    test('clearing facets keeps what was typed', () {
      const filter = ExerciseFilter(query: 'press', muscles: {'chest'});
      expect(filter.withoutFacets.query, 'press');
      expect(filter.withoutFacets.hasFacets, isFalse);
    });

    test('is value-equal, so an identical rebuild is not a change', () {
      expect(
        const ExerciseFilter(query: 'a', muscles: {'chest', 'lats'}),
        const ExerciseFilter(query: 'a', muscles: {'lats', 'chest'}),
      );
      expect(
        const ExerciseFilter(query: 'a', muscles: {'chest', 'lats'}).hashCode,
        const ExerciseFilter(query: 'a', muscles: {'lats', 'chest'}).hashCode,
      );
      expect(
        const ExerciseFilter(query: 'a'),
        isNot(const ExerciseFilter(query: 'b')),
      );
    });
  });

  test('a 400-row catalogue searches well inside the budget', () {
    // F-CAT-004 acceptance: sub-100 ms on 400 rows. Measured cold — including
    // the folding of every name and alias — because that is the worst case,
    // the first keystroke after the catalogue changes.
    final catalogue = [
      for (var i = 0; i < 400; i++)
        candidate(
          'ex-$i',
          'Exercise Number $i Press',
          aliases: ['alias $i', 'e$i'],
          muscle: Muscle.values[i % Muscle.values.length],
        ),
    ];

    final stopwatch = Stopwatch()..start();
    final results = searchExercises(
      catalogue,
      const ExerciseFilter(query: 'exercise press'),
    );
    stopwatch.stop();

    expect(results, hasLength(400));
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
}

/// Muscle names as plain strings — the domain layer may not import the enum,
/// which lives in `lib/data/`.
abstract final class Muscle {
  static const List<String> values = ['chest', 'lats', 'quads', 'glutes'];
}
