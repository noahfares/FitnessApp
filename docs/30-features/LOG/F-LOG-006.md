# F-LOG-006 — Numeric keypad and steppers

Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-003 | Blocks: F-PLT-001
Reads: 22-UNITS, 24-DESIGN-SYSTEM#component-inventory

## Spec
1. Bottom-sheet keypad with large digits, decimal point, and clear.
2. Plus/minus steppers increment by the exercise's configured step
   (`F-SET-007`), defaulting to 2.5 kg / 5 lb for barbells and 2 kg / 5 lb for
   dumbbells. Long-press repeats.
3. Increments are defined in the *display* unit (`../22-UNITS.md`).
4. Next/previous field navigation without closing the sheet.
5. Plate calculator accessible from the keypad once `F-PLT-001` exists.
6. The set list stays visible above the sheet.

## Acceptance
- [ ] Entering weight and reps for a set requires no system keyboard.
- [ ] Steppers produce exact values with no floating-point drift over hundreds
      of increments.

---

## Why

The system keyboard is the wrong tool: small targets, a layout that
shifts, and it covers the set list. A purpose-built keypad is faster and works
with imprecise thumbs.
