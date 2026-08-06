# F-LOG-005 — Set types

Status: done | Priority: P0 | Phase: 1
Depends on: F-LOG-003
Reads: 21-DATA-MODEL#sets, 40-ANALYTICS-SPEC#universal-preconditions
Data: `sets.set_type`

## Spec
1. Types: `warmup`, `working`, `drop`, `failure`, `amrap`, `backoff`. Default
   `working`. The full enum exists in schema v1 even though Phase 1 only
   surfaces `warmup` and `working` in the UI — adding an enum value later is a
   migration, and mislabelled historical sets cannot be recovered.
2. Set by long-press on the set-number cell; indicated by letter and colour.
3. Warm-up sets are numbered separately (W1, W2) from working sets (1, 2, 3).
4. **Warm-ups are excluded from all analytics** — volume, PRs, e1RM, set counts.
5. Drop, failure, AMRAP, and back-off sets all count toward volume and PRs.

## Acceptance
- [x] Changing a set's type updates all derived figures immediately — today
      that means the numbering, which renumbers the moment the type is written.
- [ ] Warm-ups never appear in any volume or PR calculation. *There is no
      volume or PR calculation yet (`F-ANA-*`, `F-LOG-013`, Phase 2). What
      exists now is the thing that cannot be added later: the type is captured
      and stored from the first session, and `matchGhostIndices` already
      refuses to mix the two classes.*

## Implementation

- Long-press on the set-number cell opens the sheet
  (`set_type_sheet.dart`). Phase 1 offers **warm-up and working only** — all
  six exist in the schema from v1, but surfacing types whose distinction is not
  visible anywhere yet would be clutter on the most contested screen in the
  app. The rest arrive with the analytics that read them.
- `labelSets` (pure) numbers warm-ups `W1, W2` in their own sequence and gives
  the other counted types a letter — `D`, `F`, `A`, `B` — beside the number.
  Colour says the same thing a second time, deliberately: colour alone is not
  an indicator (`F-A11Y-003`).
- Adding a set copies the type of the one above it rather than promoting it to
  working. A wrong `set_type` is the one thing on the row that cannot be
  recovered later.

---

## Why

Warm-ups must be excluded from analytics or every metric is wrong
(see [`../21-DATA-MODEL.md`](../../21-DATA-MODEL.md)). Drop sets and AMRAPs need to
be distinguishable for the same reason. This has to exist in v1 because the
information can't be recovered later.
