# F-LOG-003 — Set row entry

Status: done | Priority: P0 | Phase: 1
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
- [x] Completing a set is one tap when values are unchanged from last time —
      the toggle adopts the ghost values in the same write.
- [x] Row remains legible and operable at 200% text scale (`F-A11Y-002`): past
      a scaled 16 dp of 22 the row becomes two, rather than shrinking the type
      that the setting exists to enlarge.
- [x] All tracking types render correct inputs — six, not five: the enum grew a
      `weightTime` after this file was written, and it is covered too.
- [ ] No frame drops scrolling a 12-exercise session on a low-end device. *Not
      verifiable here — needs a profile build on real hardware, which arrives
      with `F-REL-002`. What is in place for it: the ghost query runs once per
      exercise rather than per row, its result is de-duplicated so a completion
      does not rebuild every other exercise's ghost, and set numbering is
      computed once per data change.*
- [x] Screen reader announces the row meaningfully (`F-A11Y-001`) — "Set 1, kg
      100, Reps 8, completed". A describing node above the controls, not a
      merge, so the toggle and the note button keep their own.

## Edge cases

Zero-weight sets (bodyweight — valid, not an error). Very large
numbers (a 1000 kg leg press is real). Deleting a set that's mid-edit. Reps
without weight on a `weightReps` exercise — allowed, flagged only in analytics.

## Implementation

- `lib/features/logging/presentation/set_row.dart` — the row. Holds no state:
  every tap writes through and the row re-renders from the database
  (`F-LOG-007`).
- Which columns exist comes from the exercise's tracking type via
  `setFieldsFor` (pure domain), resolved once per exercise rather than per row.
- Deleting is a tombstone with an undo snack bar, so undo is a field update
  rather than a resurrection (ADR-0008).
- Positions are left with gaps after a delete: they are an ordering, not a
  numbering. What the user sees is derived on read by `labelSets`
  (`F-LOG-005`).
- **Not** here: reordering sets, and the rest timer that a completion starts
  (`F-TIM-002`, batch 1.5).

---

## Why

The most-used widget in the app by an enormous margin. Everything
about it is a performance and ergonomics decision.
