# F-CAT-008 — Aliases and synonyms

Status: done | Priority: P2 | Phase: 2
Depends on: F-CAT-004
Reads: 21-DATA-MODEL#exercises
Data: `exercises.aliases`

## Spec
1. Seeded exercises carry common aliases and abbreviations (RDL, OHP, BSS).
2. Aliases are searchable but not displayed as the primary name.
3. Users can add aliases to any exercise.

## Status notes

§1 and §2 predate this batch: `assets/seed/exercises.json` already carries
aliases for 29 of the 100 seeded exercises, including exactly `rdl`, `ohp`
and `bss`, and `domain/catalog/exercise_search.dart`'s matching already
folds and searches `aliases` while the catalogue list only ever renders
`name`. This batch is what closes §3 — the editor now has an alias field
(add via Enter or the `+` button, remove via chip delete, trimmed and
de-duplicated case-insensitively before being written through
`ExerciseRepository.update`/`.createCustom`).
