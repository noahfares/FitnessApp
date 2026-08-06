# F-LOG-001 — Start, finish, and discard a workout

Status: done | Priority: P0 | Phase: 1
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
5. Discarding requires explicit confirmation naming what will be lost, and
   **tombstones** the workout and its sets.
6. A workout with zero completed sets prompts "discard instead?" on finish.

> §5 originally said *hard deletes*. [ADR-0008](../../70-decisions/ADR-0008-sync-ready-foundations.md)
> §4 explicitly overrides that — "this **overrides** the mixed deletion policy
> previously written, which hard-deleted workouts and sets" — and names this
> exact case as its motivation: destroying data the moment someone taps
> something sweaty-handed mid-set. Corrected here rather than routed around.
> Nothing user-visible changes; a discarded session is gone from every read.

## Acceptance
- [x] Only one in-progress workout can exist, verified at the database level —
      `idx_workouts_single_in_progress`, a partial unique index over
      `(user_id) WHERE ended_at IS NULL AND deleted_at IS NULL`. The migration
      test asserts the *database* rejects a second one, not just the repository.
- [x] Discard requires confirmation and removes all associated rows from every
      read, tombstoning workout, `workout_exercises` and `sets` in one
      transaction.
- [x] Finishing an empty workout doesn't create a junk history entry — it asks,
      offering Discard, Finish anyway, or Keep training.

## Implementation

- `lib/data/repositories/workout_repository.dart` — start, finish, rename,
  discard, tally. Every method writes immediately; nothing about a session is
  held in memory (`F-LOG-007`).
- Schema **v3** adds the partial unique index. The migration closes out all but
  the most recently started open session first: a unique index cannot be created
  over duplicates, and an app that will not open its own database is a far worse
  outcome than one auto-closed session.
- `start()` throws `ActiveWorkoutExistsException` rather than resolving the
  conflict itself. Which session was meant to survive is not a decision the data
  layer can make.
- A session needs a name before it has any content to name it after, so it gets
  a time-of-day one. Routine days overwrite it wholesale (`F-ROU-010`).
- The centre tab opens the start sheet as a modal (docs/23-NAVIGATION.md); the
  `/start` route remains for deep links and app shortcuts (`F-NAV-008`).
- Finishing `go`es rather than popping, so back cannot walk into a finished
  session. It lands on Home until the summary exists (`F-LOG-018`, batch 1.6);
  PR evaluation (`F-LOG-013`) hangs off the same call in Phase 2.

## Edge cases

Starting a workout just before midnight and finishing after
(the session belongs to its `started_at` date for grouping). An in-progress
workout left open for days — prompt to finish or discard on next launch if
`started_at` is more than ~12 hours old.

**Resolved:** the launch prompt would contradict `F-LOG-007` §4, which is
explicit that there is no "restore session?" prompt because prompting invites
the wrong answer under stress. So the session resumes either way, and a
session older than 12 hours carries a notice on the active-workout screen where
finishing and discarding are each one tap and neither is the default.

---

## Why

The session container. Everything else hangs off it.
