/// Built-in starter programs (`F-ROU-015`) — well-known training structures
/// shipped as importable templates, so an empty install has something
/// usable before the user has written a single routine of their own.
///
/// Pure Dart, like every other file in `lib/domain/`. Exercises are
/// referenced by the catalogue's stable `external_id`
/// (`data/seed/exercise_seeder.dart`), never a database row id — this file
/// has no database to hold one. `RoutineRepository.importStarterProgram`
/// resolves each reference against the live catalogue at import time and
/// skips whatever it can't find, rather than failing the whole import.
///
/// These are *structures*, not the named authors' own written programming.
/// Several of the named programs are published works — reimplementing sets,
/// reps and exercise order is fine; the [attribution] string and
/// [attributionUrl] point at the source rather than reproducing its text
/// (`F-ROU-015`'s own open question).
library;

/// One exercise inside a starter program day.
class StarterProgramExercise {
  const StarterProgramExercise({
    required this.exerciseExternalId,
    this.targetSets,
    this.targetRepsMin,
    this.targetRepsMax,
    this.groupKey,
  });

  /// Matches `SeedExercise.externalId` in `assets/seed/exercises.json`.
  final String exerciseExternalId;

  final int? targetSets;
  final int? targetRepsMin;
  final int? targetRepsMax;

  /// Exercises sharing the same [groupKey] within a day become one superset
  /// group on import — a local key, remapped to a real `group_id` at
  /// import time, the same way `RoutineRepository.duplicate` mints fresh
  /// group ids per copy.
  final String? groupKey;
}

/// One day within a program.
class StarterProgramDay {
  const StarterProgramDay({
    required this.name,
    required this.exercises,
    this.loadingNotes,
  });

  final String name;
  final List<StarterProgramExercise> exercises;

  /// Free text carrying whatever the schema's absolute set/rep/weight
  /// targets can't express — percentage or wave loading, AMRAP-set rules,
  /// alternating-day instructions. In the importer's own wording, never
  /// transcribed from the source.
  final String? loadingNotes;
}

/// One built-in program.
class StarterProgram {
  const StarterProgram({
    required this.id,
    required this.name,
    required this.summary,
    required this.attribution,
    required this.attributionUrl,
    required this.days,
  });

  /// Stable slug, e.g. `'ppl'` — identifies the program in the gallery UI;
  /// never written anywhere a routine could be traced back to it
  /// (`ADR-0004`'s "snapshot, never link" reasoning applied one level up).
  final String id;

  final String name;
  final String summary;

  /// e.g. `'Structure by Jim Wendler, 5/3/1'` — shown next to
  /// [attributionUrl] rather than the source's own written programming.
  final String attribution;
  final String attributionUrl;

  final List<StarterProgramDay> days;
}

/// The six programs named in `F-ROU-015`'s spec.
const List<StarterProgram> starterPrograms = [
  _ppl,
  _upperLower,
  _startingStrength,
  _gzclp,
  _fiveThreeOne,
  _nSuns,
];

const StarterProgram _ppl = StarterProgram(
  id: 'ppl',
  name: 'Push/Pull/Legs',
  summary:
      'A classic 3-day split repeated twice a week: push, pull, legs, '
      'each hitting every major muscle once with a mix of compound and '
      'isolation work.',
  attribution: 'Structure widely attributed to the PPL bodybuilding split',
  attributionUrl:
      'https://en.wikipedia.org/wiki/Push%E2%80%93pull%E2%80%93legs_workout',
  days: [
    StarterProgramDay(
      name: 'Push',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'barbell-bench-press',
          targetSets: 4,
          targetRepsMin: 6,
          targetRepsMax: 8,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'overhead-press',
          targetSets: 3,
          targetRepsMin: 8,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'incline-dumbbell-press',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'lateral-raise',
          targetSets: 3,
          targetRepsMin: 12,
          targetRepsMax: 15,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'triceps-pushdown',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Pull',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'conventional-deadlift',
          targetSets: 3,
          targetRepsMin: 5,
          targetRepsMax: 5,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'barbell-row',
          targetSets: 4,
          targetRepsMin: 8,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'lat-pulldown',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'face-pull',
          targetSets: 3,
          targetRepsMin: 15,
          targetRepsMax: 15,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'barbell-curl',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Legs',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'back-squat',
          targetSets: 4,
          targetRepsMin: 6,
          targetRepsMax: 8,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'romanian-deadlift',
          targetSets: 3,
          targetRepsMin: 8,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'leg-press',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'leg-extension',
          targetSets: 3,
          targetRepsMin: 12,
          targetRepsMax: 15,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'standing-calf-raise',
          targetSets: 4,
          targetRepsMin: 12,
          targetRepsMax: 15,
        ),
      ],
    ),
  ],
);

const StarterProgram _upperLower = StarterProgram(
  id: 'upper-lower',
  name: 'Upper/Lower',
  summary:
      'A 4-day split alternating upper and lower body, each trained twice '
      'a week — a middle ground between full-body frequency and PPL '
      'specialisation.',
  attribution: 'Structure widely attributed to the Upper/Lower split',
  attributionUrl: 'https://en.wikipedia.org/wiki/Upper%E2%80%93lower_split',
  days: [
    StarterProgramDay(
      name: 'Upper A',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'barbell-bench-press',
          targetSets: 4,
          targetRepsMin: 6,
          targetRepsMax: 8,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'barbell-row',
          targetSets: 4,
          targetRepsMin: 6,
          targetRepsMax: 8,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'overhead-press',
          targetSets: 3,
          targetRepsMin: 8,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'lat-pulldown',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'barbell-curl',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'triceps-pushdown',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Lower A',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'back-squat',
          targetSets: 4,
          targetRepsMin: 6,
          targetRepsMax: 8,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'romanian-deadlift',
          targetSets: 3,
          targetRepsMin: 8,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'leg-press',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'standing-calf-raise',
          targetSets: 4,
          targetRepsMin: 12,
          targetRepsMax: 15,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'hanging-leg-raise',
          targetSets: 3,
          targetRepsMin: 12,
          targetRepsMax: 15,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Upper B',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'incline-barbell-bench-press',
          targetSets: 4,
          targetRepsMin: 6,
          targetRepsMax: 8,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'seated-cable-row',
          targetSets: 4,
          targetRepsMin: 8,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'lateral-raise',
          targetSets: 3,
          targetRepsMin: 12,
          targetRepsMax: 15,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'chin-up',
          targetSets: 3,
          targetRepsMin: 8,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'close-grip-bench-press',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Lower B',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'conventional-deadlift',
          targetSets: 3,
          targetRepsMin: 5,
          targetRepsMax: 5,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'front-squat',
          targetSets: 3,
          targetRepsMin: 8,
          targetRepsMax: 8,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'walking-lunge',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'lying-leg-curl',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 12,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'standing-calf-raise',
          targetSets: 4,
          targetRepsMin: 12,
          targetRepsMax: 15,
        ),
      ],
    ),
  ],
);

const StarterProgram _startingStrength = StarterProgram(
  id: 'starting-strength',
  name: 'Starting Strength',
  summary:
      'A novice linear-progression program: two alternating workouts, '
      'three times a week, adding weight every session on a small set of '
      'compound barbell lifts.',
  attribution: 'Structure by Mark Rippetoe, Starting Strength',
  attributionUrl: 'https://startingstrength.com/',
  days: [
    StarterProgramDay(
      name: 'Workout A',
      loadingNotes:
          'Add weight every session while it keeps working, per the '
          "program's own novice linear-progression rules.",
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'back-squat',
          targetSets: 3,
          targetRepsMin: 5,
          targetRepsMax: 5,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'barbell-bench-press',
          targetSets: 3,
          targetRepsMin: 5,
          targetRepsMax: 5,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'conventional-deadlift',
          targetSets: 1,
          targetRepsMin: 5,
          targetRepsMax: 5,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Workout B',
      loadingNotes:
          'Add weight every session while it keeps working, per the '
          "program's own novice linear-progression rules.",
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'back-squat',
          targetSets: 3,
          targetRepsMin: 5,
          targetRepsMax: 5,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'overhead-press',
          targetSets: 3,
          targetRepsMin: 5,
          targetRepsMax: 5,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'power-clean',
          targetSets: 5,
          targetRepsMin: 3,
          targetRepsMax: 3,
        ),
      ],
    ),
  ],
);

const StarterProgram _gzclp = StarterProgram(
  id: 'gzclp',
  name: 'GZCLP',
  summary:
      'A 4-day linear progression built on three tiers per session — a '
      'heavy T1 main lift, a moderate T2 secondary lift, and light T3 '
      'volume work.',
  attribution: 'Structure by Cody LeFever, GZCLP',
  attributionUrl: 'https://swoleateveryheight.blogspot.com/2016/05/gzclp.html',
  days: [
    StarterProgramDay(
      name: 'Day 1 — Squat',
      loadingNotes:
          'T1 5x3+: last set AMRAP. T2 3x10. T3 3x15+. Progress and '
          'stage-down each tier independently, per the program’s own rules.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'back-squat',
          targetSets: 5,
          targetRepsMin: 3,
          targetRepsMax: 3,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'barbell-bench-press',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'lat-pulldown',
          targetSets: 3,
          targetRepsMin: 15,
          targetRepsMax: 15,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Day 2 — OHP',
      loadingNotes:
          'T1 5x3+: last set AMRAP. T2 3x10. T3 3x15+. Progress and '
          'stage-down each tier independently, per the program’s own rules.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'overhead-press',
          targetSets: 5,
          targetRepsMin: 3,
          targetRepsMax: 3,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'conventional-deadlift',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'barbell-curl',
          targetSets: 3,
          targetRepsMin: 15,
          targetRepsMax: 15,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Day 3 — Bench',
      loadingNotes:
          'T1 5x3+: last set AMRAP. T2 3x10. T3 3x15+. Progress and '
          'stage-down each tier independently, per the program’s own rules.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'barbell-bench-press',
          targetSets: 5,
          targetRepsMin: 3,
          targetRepsMax: 3,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'back-squat',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'lat-pulldown',
          targetSets: 3,
          targetRepsMin: 15,
          targetRepsMax: 15,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Day 4 — Deadlift',
      loadingNotes:
          'T1 5x3+: last set AMRAP. T2 3x10. T3 3x15+. Progress and '
          'stage-down each tier independently, per the program’s own rules.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'conventional-deadlift',
          targetSets: 5,
          targetRepsMin: 3,
          targetRepsMax: 3,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'overhead-press',
          targetSets: 3,
          targetRepsMin: 10,
          targetRepsMax: 10,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'barbell-curl',
          targetSets: 3,
          targetRepsMin: 15,
          targetRepsMax: 15,
        ),
      ],
    ),
  ],
);

const StarterProgram _fiveThreeOne = StarterProgram(
  id: '531',
  name: '5/3/1',
  summary:
      'A 4-day percentage-based wave program built around one main lift '
      'per day, cycling through 5s, 3s and 5/3/1 rep waves off a training '
      'max.',
  attribution: 'Structure by Jim Wendler, 5/3/1',
  attributionUrl:
      'https://www.jimwendler.com/blogs/jimwendler-com/101433287-5-3-1-for-a-beginner',
  days: [
    StarterProgramDay(
      name: 'Overhead Press',
      loadingNotes:
          "Percentages of a training max, waved 5/5/5+, 3/3/3+, 5/3/1+ "
          'across the cycle — see the program’s own tables, not tracked '
          'as an absolute weight target here.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'overhead-press',
          targetSets: 3,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Deadlift',
      loadingNotes:
          "Percentages of a training max, waved 5/5/5+, 3/3/3+, 5/3/1+ "
          'across the cycle — see the program’s own tables, not tracked '
          'as an absolute weight target here.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'conventional-deadlift',
          targetSets: 3,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Bench Press',
      loadingNotes:
          "Percentages of a training max, waved 5/5/5+, 3/3/3+, 5/3/1+ "
          'across the cycle — see the program’s own tables, not tracked '
          'as an absolute weight target here.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'barbell-bench-press',
          targetSets: 3,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Squat',
      loadingNotes:
          "Percentages of a training max, waved 5/5/5+, 3/3/3+, 5/3/1+ "
          'across the cycle — see the program’s own tables, not tracked '
          'as an absolute weight target here.',
      exercises: [
        StarterProgramExercise(exerciseExternalId: 'back-squat', targetSets: 3),
      ],
    ),
  ],
);

const StarterProgram _nSuns = StarterProgram(
  id: 'nsuns',
  name: 'nSuns',
  summary:
      'A high-frequency percentage-based program built on 5/3/1 training '
      'maxes, hitting the bench and squat/deadlift patterns multiple '
      'times a week across many top-set-plus-backdown-set waves.',
  attribution: 'Structure by u/nSuns, nSuns 5/3/1 LP',
  attributionUrl: 'https://www.reddit.com/r/nSuns/wiki/index/programs/',
  days: [
    StarterProgramDay(
      name: 'Bench / OHP',
      loadingNotes:
          'Percentage-based top set plus backdown waves off a training '
          'max — see the program’s own spreadsheet, not tracked as an '
          'absolute weight target here.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'barbell-bench-press',
          targetSets: 9,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'overhead-press',
          targetSets: 3,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Squat',
      loadingNotes:
          'Percentage-based top set plus backdown waves off a training '
          'max — see the program’s own spreadsheet, not tracked as an '
          'absolute weight target here.',
      exercises: [
        StarterProgramExercise(exerciseExternalId: 'back-squat', targetSets: 9),
        StarterProgramExercise(
          exerciseExternalId: 'front-squat',
          targetSets: 3,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Deadlift / OHP',
      loadingNotes:
          'Percentage-based top set plus backdown waves off a training '
          'max — see the program’s own spreadsheet, not tracked as an '
          'absolute weight target here.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'conventional-deadlift',
          targetSets: 6,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'overhead-press',
          targetSets: 3,
        ),
      ],
    ),
    StarterProgramDay(
      name: 'Bench / Triceps',
      loadingNotes:
          'Percentage-based top set plus backdown waves off a training '
          'max — see the program’s own spreadsheet, not tracked as an '
          'absolute weight target here.',
      exercises: [
        StarterProgramExercise(
          exerciseExternalId: 'barbell-bench-press',
          targetSets: 8,
        ),
        StarterProgramExercise(
          exerciseExternalId: 'close-grip-bench-press',
          targetSets: 3,
        ),
      ],
    ),
  ],
);
