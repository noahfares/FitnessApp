# F-PRG-001 — Progression engine core

Status: planned | Priority: P1 | Phase: 4
Depends on: F-ROU-003, F-ROU-010, F-LOG-004 | Blocks: F-PRG-002 … F-PRG-006
Reads: 40-ANALYTICS-SPEC, 20-ARCHITECTURE#the-one-hard-rule, 22-UNITS

## Spec
1. Signature: `computeTargets(rule, exerciseHistory, context) -> TargetSet`,
   pure, deterministic, with no clock or randomness (dates arrive via `context`).
2. Runs when a workout is started from a routine day (`F-ROU-010`), producing
   target weight and reps per set.
3. Every result carries a human-readable rationale (`F-PRG-008`).
4. Targets are always overridable — the engine proposes, the user disposes.
5. Insufficient history falls back to the routine's static targets.
6. Proposed weights are rounded to achievable loads (`F-PRG-012`).

## Acceptance
- [ ] Pure and deterministic — same inputs, same outputs, always.
- [ ] Every rule type has fixture tests covering success, failure, and first-run.
- [ ] Overriding a target never corrupts subsequent progression.
- [ ] No rule can ever propose a load that cannot be assembled from the user's
      plates.

## Edge cases

First time doing an exercise. A months-long gap. History logged
in a different unit (irrelevant — storage is canonical). A user who overrode
targets last session. Missing RPE where the rule needs it.

---

## Why

Turns a routine from a static list into a program. The app already
knows what you did last time and what the rule is; making you do the arithmetic
on a whiteboard is a failure of the tool.
