# F-CAT-006 — Favourites and recency ordering

Status: planned | Priority: P1 | Phase: 2
Depends on: F-CAT-004
Reads: 21-DATA-MODEL#exercises
Data: `exercises.is_favorite`, derived from `sets`

## Spec
1. Star to favourite; favourites pin to the top.
2. Below favourites, order by most recently performed.
3. Empty search shows favourites and recents rather than an alphabetical wall.

## Acceptance
- [ ] Opening the picker with no query surfaces the last-used exercises first.

---

## Why

Almost every session reuses the same 15–25 movements. Making the
picker default to what you actually do turns a search into a single tap.
