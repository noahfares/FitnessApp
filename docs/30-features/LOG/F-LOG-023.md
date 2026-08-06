# F-LOG-023 — Per-set notes

Status: done | Priority: P1 | Phase: 1
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
- [x] Adding a note never displaces or shrinks the weight, reps, or completion
      controls — the marker is a fixed 32 dp icon, and the value cells stay
      flexible whether a note exists or not.
- [ ] Notes survive an export/import round-trip. *There is no export yet
      (`F-DAT-001`, `F-DAT-002`, Phase 4). The column is populated from the
      first session, which is the part that cannot be backfilled.*
- [x] A set with a note is visually distinguishable without opening it — the
      icon fills and takes the primary colour.

## Edge cases

A very long note (truncate in list views, never in storage).
Notes on a set that is later deleted — tombstoned with the set, restored by undo.

## Implementation

- `set_note_sheet.dart`, opened from the row's icon. This is the one place the
  system keyboard is right: free text, typed between sets rather than during
  one.
- An empty or whitespace-only note is stored as null, so "has a note" stays a
  single null check everywhere it is asked.
- §4 — visibility in workout detail and per-exercise history — arrives with
  `F-LOG-012` and `F-ANA-002`.

---

## Why

The catch-all for everything the schema didn't anticipate. "Left
shoulder twinged", "belt too loose", "spotter took some of it", "bar slipped".
This is unrecoverable data: the observation exists for about ten seconds after
the set and then it's gone. A nullable text column costs nothing and captures
what no structured field ever will.
