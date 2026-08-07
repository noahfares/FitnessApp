# F-CAT-007 — Per-exercise sticky notes

Status: done | Priority: P1 | Phase: 2
Reads: 21-DATA-MODEL#exercises
Screens: Exercise Detail, Active Workout | Data: `exercises.notes`

## Spec
1. A free-text note attached to the exercise, distinct from per-session notes
   (`F-LOG-008`).
2. Shown inline in the active workout, collapsed to one line, expandable.
3. Editable from the session without leaving it.
4. Persists across all sessions and routines.

## Acceptance
- [x] Note is visible on the active-workout screen without navigation.
- [x] Editing mid-session doesn't disturb logged sets or the rest timer.

## Status notes

There is no standalone "Exercise Detail" screen in this app — the closest
analog is the exercise editor (`F-CAT-003`), which now carries a Notes field
alongside the existing name/muscle/equipment fields. `WorkoutRepository
.watchExercises` now selects `exercises.notes` into a new
`SessionExercise.exerciseNotes` field (kept distinct from `.notes`, which is
the *session's* per-exercise note, `F-LOG-008`). The active workout screen
shows it collapsed to one line via `_StickyNoteText`, tap to expand; "Edit
note" on the exercise's overflow menu opens `ExerciseNoteSheet`, which
writes only through `ExerciseRepository.setNotes` — it cannot touch a set or
the rest timer by construction, since it never reads `SetRepository` or
`RestTimerService` at all.

---

## Why

Seat height 4, pin position 7, grip at the second ring. This
information is forgotten between sessions, is a genuine source of inconsistent
training, and no competitor handles it well. It is nearly free to build and
disproportionately useful.
