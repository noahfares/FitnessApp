# F-LOG-006 — Numeric keypad and steppers

Status: done | Priority: P0 | Phase: 1
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
- [x] Entering weight and reps for a set requires no system keyboard — the
      sheet contains no text field at all, asserted rather than assumed.
- [x] Steppers produce exact values with no floating-point drift over hundreds
      of increments: 200 × 2.5 kg lands on exactly 500 kg, because stepping
      happens on canonical integer grams.

## Implementation

- `numeric_keypad_sheet.dart`. Not full height, so the set list stays visible
  above it (§6) — the number being typed only means anything next to the ones
  above it.
- **Writes through on every keystroke** (`F-LOG-003` §7). The buffer holds text
  rather than a parsed number, so a half-typed `102.` survives the next key;
  unparseable input leaves the stored value alone rather than clearing it.
- Durations are typed as a gym timer reads them — `130` is 1:30 — rather than
  as a raw number of seconds, which would ask for mental division mid-set.
- Steppers: 2.5 kg / 2 kg by equipment, 5 lb in pound mode, overridden by
  `exercises.increment_grams` when set (`F-SET-007`). Defined in the display
  unit and converted once, because that is how plates come.
- §5, the plate calculator, waits for `F-PLT-001`.

---

## Why

The system keyboard is the wrong tool: small targets, a layout that
shifts, and it covers the set list. A purpose-built keypad is faster and works
with imprecise thumbs.
