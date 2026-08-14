# F-DAT-007 — Import mapping UI

Status: done | Priority: P1 | Phase: 5
Depends on: F-DAT-005
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

## Spec

Resolve unmatched exercise names: map to an existing exercise, create a custom
one, or skip. Remembers decisions across a session so a 400-row import isn't 400
prompts. This screen is most of what makes an import feel trustworthy.

---

## Status note (batch 5.3)

`domain/import/import_mapping_state.dart`'s `ImportMappingState` is the
"remembers decisions" rule as a pure, unit-tested reducer — one resolution
per distinct exercise **name**, not per row, so a 400-row file with the same
unresolved exercise on 40 rows is one decision, applied everywhere that name
appears. `ImportScreen` (`features/settings/presentation/import_screen.dart`)
is the thin list over it: each unresolved name gets "Use existing" (reusing
the same `showExercisePicker` sheet `F-LOG-002`'s exercise picker already
built, rather than a second one), "Create new" (`ExerciseRepository
.createCustom`, defaulting to `Muscle.fullBody`/`Equipment.other` since a
CSV carries neither), or "Skip" (every set logged against that name is
dropped, not imported under a wrong exercise). The "Import" action stays
disabled until every unmatched name has a decision.
