# F-CAT-007 — Per-exercise sticky notes

Status: planned | Priority: P1 | Phase: 2
Reads: 21-DATA-MODEL#exercises
Screens: Exercise Detail, Active Workout | Data: `exercises.notes`

## Spec
1. A free-text note attached to the exercise, distinct from per-session notes
   (`F-LOG-008`).
2. Shown inline in the active workout, collapsed to one line, expandable.
3. Editable from the session without leaving it.
4. Persists across all sessions and routines.

## Acceptance
- [ ] Note is visible on the active-workout screen without navigation.
- [ ] Editing mid-session doesn't disturb logged sets or the rest timer.

---

## Why

Seat height 4, pin position 7, grip at the second ring. This
information is forgotten between sessions, is a genuine source of inconsistent
training, and no competitor handles it well. It is nearly free to build and
disproportionately useful.
