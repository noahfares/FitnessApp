# F-CAT-002 — Exercise model & tracking types

Status: planned | Priority: P0 | Phase: 1
Depends on: F-CAT-001 | Blocks: F-LOG-003
Reads: 21-DATA-MODEL#exercises, 40-ANALYTICS-SPEC#universal-preconditions
Data: `exercises`

## Spec
1. `tracking_type` ∈ `weightReps`, `bodyweightReps`, `reps`, `time`,
   `distanceTime`, `weightTime`.
2. All four measurement columns on `sets` — weight, reps, duration, distance —
   are nullable from schema v1. The tracking type decides which are rendered and
   required. **Phase 1 implements `weightReps` only**; the rest of the enum
   exists in the schema from day one so no migration is needed to add them.
3. The logger renders only the relevant inputs for the type.
4. Analytics respect the type — volume load is meaningless for `time`, and those
   exercises are excluded from volume rather than counted as zero.
5. Type is editable on custom exercises, and on seeded ones with a warning that
   existing history may become inconsistent.

## Acceptance
- [ ] Each of the six types renders correct inputs.
- [ ] Analytics exclude, rather than zero out, inapplicable metrics.

## Edge cases

Changing type on an exercise with history. Weighted pull-ups
(`weightReps` with bodyweight added — see `F-LOG-019`).

---

## Why

Not everything is weight × reps. Planks are time, running is
distance + time, pull-ups are reps (optionally weighted). The tracking type
decides which input fields the logger renders, so it has to exist before the
set row is built rather than being bolted on.
