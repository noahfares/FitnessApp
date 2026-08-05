# F-ROU-001 — Routine CRUD

Status: planned | Priority: P0 | Phase: 2
Blocks: F-ROU-002, F-ROU-010
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot
Screens: Routine List, Routine Editor | Data: `routines`

## Spec
1. Create, rename, duplicate, archive, and delete routines.
2. A routine has a name, optional notes, an optional folder, and one or more days.
3. Create from scratch, from a built-in template (`F-ROU-015`), or from a past
   workout (`F-LOG-012`).
4. Deleting a routine never affects workouts performed from it —
   `source_routine_day_id` is nulled.

## Acceptance
- [ ] Deleting a routine leaves all historical workouts intact and correctly rendered.
- [ ] Duplicating produces a fully independent copy, including days and targets.
