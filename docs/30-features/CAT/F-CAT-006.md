# F-CAT-006 — Favourites and recency ordering

Status: done | Priority: P1 | Phase: 2
Depends on: F-CAT-004
Reads: 21-DATA-MODEL#exercises
Data: `exercises.is_favorite`, derived from `sets`

## Spec
1. Star to favourite; favourites pin to the top.
2. Below favourites, order by most recently performed.
3. Empty search shows favourites and recents rather than an alphabetical wall.

## Acceptance
- [x] Opening the picker with no query surfaces the last-used exercises first.

## Status notes

`domain/catalog/exercise_search.dart`'s ordering (favourite → recency →
alphabetical) predates this batch, built ahead of time in `F-CAT-004` with
`lastUsedAt` always null until this batch wired it. This batch is what
actually populates it:
`SetRepository.watchLastUsedAtByExercise()` (a `sets`/`workout_exercises`/
`workouts` join, counting warm-ups too — this is a browsing convenience, not
an analytics figure, so none of `docs/40-ANALYTICS-SPEC.md`'s exclusions
apply) feeds `CatalogIndex` via `lastUsedAtProvider`. The favourite star
(`ExerciseRepository.setFavorite`, itself already existing) is exposed on
the catalogue screen's list rows only, not in the picker — favouriting reads
as a browsing/organising action, not something you reach for mid-add.

---

## Why

Almost every session reuses the same 15–25 movements. Making the
picker default to what you actually do turns a search into a single tap.
