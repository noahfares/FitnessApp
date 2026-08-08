# F-ROU-015 — Built-in starter programs

Status: done | Priority: P2 | Phase: 3
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot

Ship well-known programs as templates: PPL, Upper/Lower, Starting Strength,
GZCLP, 5/3/1, nSuns. Turns an empty app into a usable one for a beginner and
exercises the progression engine against real-world programming.

## Open questions

Several named programs are published works with named
authors. Reimplementing the *structure* is fine; copying their written
programming text is not. Ship structure with attribution and a link, never
transcribed content.

## Status notes (batch 3.6)

Resolved: every program ships as structure only —
`domain/routines/starter_programs.dart` (`StarterProgram`/`StarterProgramDay`/
`StarterProgramExercise`, pure Dart, no Flutter, no `lib/data/` import) holds
exercise references, absolute set/rep targets and superset group keys; each
program's own `attribution` string and `attributionUrl` point at the source
rather than reproducing its written programming, and 5/3/1's and nSuns'
percentage/wave loading — which the schema's absolute `target_weight_grams`
can't express — lands in each day's `loadingNotes`, written in this codebase's
own words, not transcribed. Exercises are referenced by the catalogue's
stable `external_id` (`ExerciseSeeder`'s own matching key), never a database
row id, since this file has no database to hold one.
`RoutineRepository.importStarterProgram` resolves each reference against the
live catalogue at import time, skips and reports (`StarterProgramImportResult
.skippedExternalIds`) whatever it can't find rather than inserting a dangling
id or failing the whole import, and — same "snapshot, never link" reasoning
as `duplicate()`/`createFromWorkout()` (`ADR-0004` generalised one level up)
— keeps no back-reference to the template, so a future catalogue or program
change can never rewrite a routine already imported and edited.
`StarterProgramGalleryScreen` (`/routines/starter-programs`) is a browsable
list, never auto-seeded into the routine list the way `ExerciseSeeder` seeds
the catalogue; reached from the routine list's empty state (`EmptyState`'s
action, `F-NAV-005`) and from a permanent app-bar icon once routines exist,
per the spec's own "turns an empty app into a usable one" framing. The pure
domain test (`test/domain/routines/starter_programs_test.dart`) asserts every
program's exercise references resolve against the seeded catalogue in
`assets/seed/exercises.json`, group keys are shared by at least two
exercises, and every program carries an attribution and an `https://` URL —
the guard against the exact failure mode of a program silently rotting as the
seed list changes.
