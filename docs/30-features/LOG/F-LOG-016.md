# F-LOG-016 — Repeat a previous session

Status: done | Priority: P1 | Phase: 2
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory

## Spec

Start a new workout pre-populated from any past one, exercises and targets
carried across but sets empty. Covers people who train without formal routines,
and is the fastest path to a second session of the same thing.

## Status

`WorkoutRepository.startFromWorkout` mirrors `startFromRoutineDay`
(`F-ROU-010`) and `RoutineRepository.createFromWorkout` (`F-ROU-001` §3):
targets are derived from what was actually logged (non-warm-up completed set
count, rep range, heaviest weight), superset grouping carries across, and
every exercise gets fresh empty sets rather than copies of the old ones. A
"Repeat this workout" action on the workout detail screen calls it, with the
same `ActiveWorkoutExistsException` → "Resume it" handling
`StartDayButton` uses.
