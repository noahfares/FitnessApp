# F-PRG-002 — Linear progression

Status: done | Priority: P1 | Phase: 4
Depends on: F-PRG-001
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec
1. All target reps achieved at target weight → add a configured increment.
2. N consecutive failures → deload by a configured percentage.
3. Increment and failure threshold are per-exercise, with sensible defaults
   (smaller jumps for upper-body lifts than lower-body).
4. Partial success — some sets made, some missed — repeats the same weight.

## Acceptance
- [x] Success, partial, and failure paths each produce the right next target
      (`applyLinearProgression`, `lib/domain/progression/linear_progression.dart`;
      the `linearProgression` fixture, `docs/40-ANALYTICS-SPEC.md` §12).
- [x] Deload triggers only after the configured consecutive-failure count
      (default 3; `test/domain/progression/progression_engine_test.dart`'s
      three-consecutive-failures case, and the "alone does not deload" case
      proving a shorter run doesn't).

## Status note

Increment defaults from the exercise's primary muscle's push/pull/legs/core
category (`F-CAT-013`'s `MuscleCategory`, batch 3.3): 5 kg for `legs`,
2.5 kg otherwise (`defaultIncrementGrams`). Failure threshold and deload
fraction default to 3 and 10% and are not yet independently configurable in
the rule-assignment UI (`F-PRG-007`) — only the increment is exposed there
this batch.
