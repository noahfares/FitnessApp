# F-LOG-023 — Per-set notes

Status: planned | Priority: P1 | Phase: 1
Depends on: F-LOG-003
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory
Data: `sets.notes`

## Spec
1. Optional free-text note per set, distinct from workout and per-exercise notes
   (`F-LOG-008`) and from the exercise's persistent sticky note (`F-CAT-007`).
2. Entry must be genuinely incidental — an icon on the set row that opens a
   small sheet, never a field competing for space in the row itself. The set row
   is the most contested space in the app (`F-LOG-003`).
3. A set carrying a note shows a subtle marker so it's findable later.
4. Notes are visible in workout detail (`F-LOG-012`) and in per-exercise history
   (`F-ANA-002`), and are searchable there.
5. Included in export (`F-DAT-001`, `F-DAT-002`).

## Acceptance
- [ ] Adding a note never displaces or shrinks the weight, reps, or completion
      controls.
- [ ] Notes survive an export/import round-trip.
- [ ] A set with a note is visually distinguishable without opening it.

## Edge cases

A very long note (truncate in list views, never in storage).
Notes on a set that is later deleted — tombstoned with the set, restored by undo.

---

## Why

The catch-all for everything the schema didn't anticipate. "Left
shoulder twinged", "belt too loose", "spotter took some of it", "bar slipped".
This is unrecoverable data: the observation exists for about ten seconds after
the set and then it's gone. A nullable text column costs nothing and captures
what no structured field ever will.
