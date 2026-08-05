# ADR-0004 — Workouts snapshot their template

**Status:** Accepted · 2026-08

## Context

Workouts are usually performed from a routine day. The obvious modelling is a
foreign key from the workout to the routine day it came from, reading the
exercise list through that reference.

That model is wrong, and wrong in a way that destroys data.

Routines change constantly — swap an accessory, drop an exercise, reorder the
day. With a live reference, editing a routine silently rewrites every historical
workout performed from it. Swap dumbbell press for machine press today, and last
March's session claims you did machine press. Delete a routine and the history
performed from it either vanishes or dangles.

The training history is the entire value of the app. It must be immutable except
by deliberate editing (`F-LOG-009`).

## Options

**Live foreign key.** Normalised, no duplication, cheap to write. Cost: history
is corrupted by ordinary routine editing. Fatal.

**Immutable routine versions.** Each edit creates a new version; workouts point
at the version they used. Correct, and normalised. Cost: version proliferation,
a more complex editor, and awkward questions about what "editing" means.

**Snapshot on start.** The workout copies the exercise list, order, superset
groups, and targets at the moment it starts. Cost: duplicated data; the workout
can't automatically reflect later routine improvements — which is exactly the
point.

## Decision

**Snapshot on start** (`F-ROU-010`).

`workouts.source_routine_day_id` exists as weak provenance only —
`ON DELETE SET NULL`, and never read to render the session. `workout_exercises`
holds the real, copied list. `target_snapshot` additionally records the targets
as proposed, so it's possible to audit what the progression engine suggested
versus what was actually done (`F-PRG-008`).

## Consequences

- **Editing a routine never alters history.** The core guarantee.
- **Deleting a routine never affects past workouts.** They keep their exercises.
- Data is duplicated per session. Negligible — a session is a few dozen rows.
- The user cannot retroactively "fix" a whole history by editing the template.
  That is correct: retroactive changes to what you actually did are exactly the
  thing to prevent.
- Mid-session modifications (`F-LOG-010`) are naturally supported, because the
  session already owns its own list.
- The routine editor and the logger need separate models rather than sharing
  one, which is a small amount of extra code.

## Reversal cost

**Very high, and partly unrecoverable.** If the live-reference model shipped
first, the original exercise lists would be gone the moment anyone edited a
routine — there'd be nothing to migrate *from*.

This is why it's decided before Phase 2, and why it's listed as an invariant in
[`../CLAUDE.md`](../CLAUDE.md).
