# F-LOG-002 — Add exercises to a session

Status: done | Priority: P0 | Phase: 1
Depends on: F-LOG-001, F-CAT-001
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory
Screens: Active Workout, Exercise Picker | Data: `workout_exercises`

## Spec
1. Exercise picker opens as a bottom sheet (thumb reach, preserves context).
2. Multi-select: add several exercises in one pass.
3. Added exercises append in selection order, each with one empty set row ready.
4. Search, filter, and recency ordering as per `F-CAT-004`–`F-CAT-006`.

## Acceptance
- [x] Adding an exercise takes at most three taps from the active workout —
      open the picker, tick it, confirm. Asserted as three taps in the widget
      test, not counted by hand.
- [x] The same exercise can appear twice in one session. `addExercises` is
      deliberately not de-duplicated.

## Implementation

- `lib/features/logging/presentation/exercise_picker_sheet.dart` — the sheet.
  Returns ids in **tick order**, which is the order they are appended in.
- Search and filtering are the same domain code as the catalogue
  (`F-CAT-004`, `F-CAT-005`); only the chrome differs. The filter *controls* are
  shared (`CatalogFilterBar`), the filter *state* is not — a filter left on
  while browsing the catalogue must not silently narrow what the picker offers
  mid-session.
- The picker clears its selection and filter every time it opens, for the same
  reason.
- Each added exercise gets one empty `sets` row, so it is ready to log against
  rather than needing an "add set" tap first. Rendering and editing that row is
  `F-LOG-003` (batch 1.4).
- Recency ordering is `F-CAT-006` (Phase 2) — the comparator already takes it,
  but there is no history to feed it yet.

Removing and reordering exercises mid-session is **not** here: that is
`F-LOG-010` (Phase 2).
