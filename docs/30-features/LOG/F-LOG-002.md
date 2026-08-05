# F-LOG-002 — Add exercises to a session

Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-001, F-CAT-001
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory
Screens: Active Workout, Exercise Picker | Data: `workout_exercises`

## Spec
1. Exercise picker opens as a bottom sheet (thumb reach, preserves context).
2. Multi-select: add several exercises in one pass.
3. Added exercises append in selection order, each with one empty set row ready.
4. Search, filter, and recency ordering as per `F-CAT-004`–`F-CAT-006`.

## Acceptance
- [ ] Adding an exercise takes at most three taps from the active workout.
- [ ] The same exercise can appear twice in one session (legitimate — e.g. a
      movement done again at the end).
