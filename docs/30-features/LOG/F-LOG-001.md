# F-LOG-001 — Start, finish, and discard a workout

Status: planned | Priority: P0 | Phase: 1
Blocks: F-LOG-002, F-LOG-003, F-LOG-007
Reads: 21-DATA-MODEL#workouts, 23-NAVIGATION
Screens: Start sheet, Active Workout | Data: `workouts`

## Spec
1. Start an empty workout, or start from a routine day (`F-ROU-010`, Phase 2).
2. Starting inserts a `workouts` row with `started_at` set and `ended_at` null.
3. **At most one workout may be in progress**, enforced in the database and in
   navigation (`F-NAV-002`). Starting another prompts to finish or discard first.
4. Finishing sets `ended_at`, triggers PR evaluation (`F-LOG-013`), and routes
   to the summary (`F-LOG-018`).
5. Discarding requires explicit confirmation naming what will be lost, and hard
   deletes the workout and its sets.
6. A workout with zero completed sets prompts "discard instead?" on finish.

## Acceptance
- [ ] Only one in-progress workout can exist, verified at the database level.
- [ ] Discard requires confirmation and removes all associated rows.
- [ ] Finishing an empty workout doesn't create a junk history entry.

## Edge cases

Starting a workout just before midnight and finishing after
(the session belongs to its `started_at` date for grouping). An in-progress
workout left open for days — prompt to finish or discard on next launch if
`started_at` is more than ~12 hours old.

---

## Why

The session container. Everything else hangs off it.
