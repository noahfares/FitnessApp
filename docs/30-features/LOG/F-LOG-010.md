# F-LOG-010 — Modify a session in progress

Status: done | Priority: P1 | Phase: 2
Depends on: F-LOG-002
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory

## Spec
1. Add, remove, and reorder exercises mid-session by drag.
2. Swap an exercise, preserving already-logged sets on the original.
3. Removing an exercise with logged sets requires confirmation.

---

## Why

Reality rarely matches the plan; the squat rack is taken.

## Status

`WorkoutRepository.reorderExercises` (§1), `.swapExercise` (§2) and
`.removeExerciseFromWorkout` (§3, already shipped by `F-LOG-009`) are the
building blocks; `ActiveWorkoutScreen` wires them up with a
`ReorderableListView`, a per-exercise "Swap"/"Remove" menu, and the exercise
picker for swap's target.

`swapExercise` never mutates `exercise_id` in place — every set ever
attached to a `workout_exercises` row is joined back to whatever
`exercise_id` that row carries, so rewriting it would silently reattribute
logged history (`ADR-0004`). Instead: with nothing completed yet, the row is
retired and a fresh one inserted for the new exercise; with a completed set,
the original is left standing (its sets keep the exercise actually done) and
the fresh row is inserted immediately after it, in the same superset group if
there was one. Either way the new row starts with one empty set — an
incomplete set's `weight_grams`/`reps` are not carried across, since a
different exercise can have a different `tracking_type` and the values would
be silently invalid for it.

Confirmation on removal (§3) is conditional, per the spec's own wording:
asked only when the exercise has completed sets, since there is nothing yet
to lose otherwise. Either way, removal now offers undo via the same
snackbar pattern set deletion already uses (`F-LOG-022` §3).
