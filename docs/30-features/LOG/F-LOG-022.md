# F-LOG-022 — Undo and mis-tap protection

Status: done | Priority: P1 | Phase: 2
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory

## Spec
1. Set deletion offers undo via a snackbar for several seconds.
2. Discarding a workout requires typed or held confirmation, not a single tap.
3. Undo covers the last destructive action within the session.
4. Undo is a `deleted_at` field update, not a re-insert — nothing is ever hard
   deleted ([ADR-0008](../../70-decisions/ADR-0008-sync-ready-foundations.md)), so
   restoring is trivially correct and preserves the original ID and timestamps.

---

## Why

Fat-fingering a completion toggle or deleting the wrong set
mid-session is common with imprecise, sweaty taps.

## Status

§1 (`SetRepository.deleteSet`/`.restoreSet`, wired to `SetRow`'s swipe-to-delete
snackbar) predates this batch — it shipped with `F-LOG-003`. This batch adds
the same pattern one level up: removing an exercise
(`WorkoutRepository.removeExerciseFromWorkout`/`.restoreExercise`, `F-LOG-010`
§3) now offers undo too, discriminated by the exact tombstone timestamp the
removal wrote so undo cannot resurrect a set that was already deleted before
the exercise was removed.

§2 is a held press (`HoldToConfirmButton`), not typed text — this app is used
one-handed and sweaty, and a hold is enough friction to refuse a mis-tap
without asking for a keyboard mid-set. It gates only the active-session
discard (`ActiveWorkoutScreen._discard`); the empty-session "discard instead
of finish" prompt (`F-LOG-001` §6) and deleting a past workout from history
(`F-LOG-009` §2, already shipped) are both left on their existing
single-tap confirms — the former protects nothing not logged yet, the latter
is a different, already-shipped feature this batch did not touch.

§3 is deliberately narrow: one snackbar-with-undo per destructive action,
following the pattern §1 already established, not a general undo stack. A
group `removeExerciseFromWorkout` dissolves when membership drops below two
is not re-formed by `restoreExercise` — that dissolution was a side effect,
not something the tombstone recorded, so undo is not perfectly symmetric in
that one edge case.
