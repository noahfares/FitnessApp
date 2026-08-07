# F-CAT-009 — Archive and hide

Status: done | Priority: P1 | Phase: 2
Reads: 21-DATA-MODEL#exercises
Data: `exercises.archived_at`

## Spec
1. Archive hides an exercise from pickers and search by default.
2. History remains fully intact and viewable.
3. An "archived" filter reveals and restores them.
4. Bulk-archive by equipment type, for people without access to a cable machine.

## Status notes

§1 and §2 predate this batch: `ExerciseRepository.setArchived`,
`watchAll(includeArchived: ...)`, and the editor's per-exercise
Archive/Unarchive button already existed, and `findById` never filters
`archived_at` so history keeps rendering an archived exercise's name. This
batch closes §3 and §4, mirroring `F-ROU-009`'s routine-archive pattern
exactly: a "show archived" toggle on the catalogue screen's app bar
(`exerciseListShowArchivedProvider`) swaps in a flat, unfiltered
`_ArchivedExerciseList` with a "Restore" action per row
(`archivedExercisesProvider`). Bulk archive
(`ExerciseRepository.bulkArchiveByEquipment`) only ever widens the archived
set — already-archived rows for other reasons are left alone — reached from
an app-bar action that picks an equipment type, confirms via the shared
`ConfirmSheet` (non-destructive: everything it does is restorable one row at
a time), and reports how many were archived.

---

## Why

400 exercises is a lot of noise when you use 20. Archiving prunes
the picker without destroying history.
