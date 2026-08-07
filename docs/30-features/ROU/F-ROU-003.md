# F-ROU-003 — Exercise targets

Status: done | Priority: P0 | Phase: 2
Depends on: F-ROU-002 | Blocks: F-PRG-001
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot
Data: `routine_exercises`

## Spec
1. Per exercise: target sets, target rep range (min/max), optional target weight,
   optional target RPE, rest duration.
2. Rep range may be a single value (min == max) when that's genuinely intended.
3. Targets are optional throughout — an exercise with no targets is valid.
4. Targets pre-fill set rows when a workout starts (`F-ROU-010`).
5. Later, the progression engine overwrites targets per session (`F-PRG-001`).

## Acceptance
- [x] Starting a workout from a day creates the right number of set rows with
      targets pre-filled.
- [x] Rep ranges display as "8–12" and single values as "8".

---

## Why

What distinguishes a plan from a list. Note that reps are a
**range**, not a number: real programming says 8–12, and collapsing that to a
single value is the mistake that makes most template features useless.
