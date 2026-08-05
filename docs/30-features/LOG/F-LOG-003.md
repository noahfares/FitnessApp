# F-LOG-003 — Set row entry

Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-002, F-CAT-002 | Blocks: F-LOG-004, F-LOG-005, F-LOG-006
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory, 22-UNITS
Screens: Active Workout | Data: `sets`

## Spec
1. Columns: set number / type indicator · previous (ghost, `F-LOG-004`) ·
   weight · reps · completion toggle. Columns rendered depend on tracking type
   (`F-CAT-002`).
2. Tapping a value opens the numeric keypad sheet (`F-LOG-006`), not the system
   keyboard.
3. The completion toggle writes `is_completed` and `completed_at`, and starts
   the rest timer (`F-TIM-002`).
4. Completing a set with empty fields adopts the ghost values — the common case
   is "same as last time", and it should cost one tap.
5. Add-set appends a row pre-filled from the previous set in the same exercise.
6. Swipe left deletes with undo; long-press opens set-type selection
   (`F-LOG-005`).
7. Every change writes through to the database immediately (`F-LOG-007`).

## Acceptance
- [ ] Completing a set is one tap when values are unchanged from last time.
- [ ] Row remains legible and operable at 200% text scale (`F-A11Y-002`).
- [ ] All five tracking types render correct inputs.
- [ ] No frame drops scrolling a 12-exercise session on a low-end device.
- [ ] Screen reader announces the row meaningfully (`F-A11Y-001`).

## Edge cases

Zero-weight sets (bodyweight — valid, not an error). Very large
numbers (a 1000 kg leg press is real). Deleting a set that's mid-edit. Reps
without weight on a `weightReps` exercise — allowed, flagged only in analytics.

---

## Why

The most-used widget in the app by an enormous margin. Everything
about it is a performance and ergonomics decision.
