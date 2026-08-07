# F-LOG-009 — Edit and delete past workouts

Status: done | Priority: P0 | Phase: 1
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory
Screens: Workout Detail, Edit Past Workout

## Spec
1. Any past workout is fully editable: sets, values, types, exercises, date.
2. Deleting requires confirmation and cascades to its sets.
3. Any edit invalidates and recomputes the PR cache for affected exercises.
4. Workouts can be created retroactively with a chosen date and time.

§3 is a no-op until `F-LOG-013` (PR detection, Phase 2) exists — there is no
cache yet for an edit to invalidate. Nothing here blocks it: PR detection reads
`sets`, which this feature already edits correctly.

## Acceptance
- [ ] Editing a past workout correctly recomputes PRs and analytics.
- [ ] Deleting the workout that held a PR demotes it to the next best.

---

## Why

People forget to log a set, log the wrong weight, or need to enter
a session from memory afterwards. Without this the history can't be trusted, and
untrusted history poisons every analytic built on it.
