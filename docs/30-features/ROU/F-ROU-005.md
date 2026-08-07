# F-ROU-005 — Supersets and circuits

Status: in-progress | Priority: P1 | Phase: 2
Blocks: F-LOG-015
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot
Data: `routine_exercises.group_id`

## Spec
1. Two or more adjacent exercises can be grouped into a superset.
2. Grouping is visually explicit in both editor and logger.
3. Rest configuration: within-group rest (often zero) and after-group rest.
4. Ungrouping is a single action and never loses logged data.

## Open questions — resolved

Circuits are treated as the same concept as supersets: any number of
exercises sharing one `group_id`, with no separate round counter. `group_id`
already existed on `routine_exercises` (and its snapshot counterpart
`workout_exercises`) from schema v3, so no migration was needed —
`RoutineRepository.groupExercises`/`ungroupExercises` write it directly.
Within-group rest has no dedicated column; it is fixed at zero rather than
independently configurable, and after-group rest reuses each exercise's
existing `rest_seconds` override (`F-TIM-005`). `duplicate()` and
`createFromWorkout` were fixed to mint a fresh `group_id` per copied group
rather than reusing the source's, which would otherwise have tied unrelated
days together. `reorderExercises` dissolves a group whose members a drag
has pulled apart, rather than leaving a non-contiguous `group_id` that would
render as two disconnected "Superset" blocks.

## Status notes

§1, §2 and §4 are done. §3 is partial: after-group rest works (each
exercise's own `rest_seconds`/defaults), but within-group rest is not an
independently configurable value — it is hardcoded to zero rather than
backed by a column. Revisit if a real within-group rest ever needs to be
non-zero.
