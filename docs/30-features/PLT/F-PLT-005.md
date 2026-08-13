# F-PLT-005 — Machine and stack increments

Status: done | Priority: P2 | Phase: 4
Reads: 22-UNITS, 21-DATA-MODEL#bars-and-plates

## Spec

Some exercises aren't plate-loaded at all. Per-exercise weight sources: plate
loaded, fixed dumbbells (with an available-increment list), or a weight stack
(base increment plus optional half-steps for add-on magnets). Determines both
what the calculator shows and what increments the steppers and progression
engine use.

## Status note (batch 4.3)

Schema v4 adds `exercises.weight_source` (`WeightSource`: `plateLoaded`,
`fixedIncrement`, `stack`) plus its per-source config columns
(`fixed_increments_grams`, `stack_base_grams`, `stack_step_grams`,
`stack_half_step_grams`), defaulting existing rows to `plateLoaded` —
exactly how every exercise behaved before this column existed, so no
backfill beyond the default was needed. `defaultWeightSourceFor` mirrors
`defaultWeightEntryModeFor`'s per-equipment guess (dumbbell/kettlebell →
fixed increment, machine/cable → stack, everything else → plate-loaded),
always overridable on the exercise editor's new "Weight source" field,
which swaps in the bar picker, an available-weights list, or base/step/
half-step fields depending on the choice. `domain/plates/
weight_source_calculator.dart` mirrors `closestAchievableGrams`'s
direction semantics for the other two sources: `closestAchievableFixedIncrement`
looks up the nearest value actually in the configured list (real racks are
not evenly spaced), `closestAchievableStack` enumerates `base + n·step`
and, when a half step is configured, `base + n·step + halfStep`.
`domain/progression/plate_aware_rounding.dart` gained
`applyFixedIncrementRounding`/`applyStackRounding` alongside the existing
`applyPlateRounding`, all three now sharing one hold-or-round decision;
`WorkoutRepository.startFromRoutineDay` dispatches on the exercise's own
`weight_source` rather than assuming plate-loaded, closing the gap
`F-PLT-001`'s status note left open. The plate calculator sheet
(`F-PLT-001` §4) does the same dispatch to decide what it shows.
