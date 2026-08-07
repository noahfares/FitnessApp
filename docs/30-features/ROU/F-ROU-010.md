# F-ROU-010 — Start a workout from a routine day

Status: done | Priority: P0 | Phase: 2
Depends on: F-ROU-003, F-LOG-001 | Blocks: F-PRG-001
Reads: 70-decisions/ADR-0004-template-snapshot, 21-DATA-MODEL#workout_exercises

## Spec
1. Starting from a day copies its exercises, order, superset groups, and targets
   into `workout_exercises` and empty `sets` rows.
2. The copy is complete — the workout never reads the routine again for display.
3. `source_routine_day_id` records provenance only.
4. `target_snapshot` records the targets as they were, for auditing what
   progression proposed (`F-PRG-008`).
5. Set rows are pre-created for the target set count, uncompleted, with targets
   and ghost values (`F-LOG-004`) both visible.

## Acceptance
- [x] Editing the routine after starting a workout does not alter that workout.
- [x] Deleting the routine mid-workout doesn't break the session.
- [x] Starting from a day with no targets behaves like an empty workout with the
      right exercises.

---

## Why

The join between planning and logging, and the point at which the
snapshot invariant is enforced.
