# F-CAT-013 — Muscle taxonomy and body map data

Status: planned | Priority: P1 | Phase: 3
Blocks: F-ANA-005, F-ANA-008, F-ANA-014
Reads: 21-DATA-MODEL#exercises, 40-ANALYTICS-SPEC#3-hard-sets-per-muscle-group-per-week

## Spec
1. Fixed enum, as listed in [`../21-DATA-MODEL.md`](../../21-DATA-MODEL.md).
2. Each muscle maps to a region on the body-map SVG (`F-ANA-014`).
3. Each maps to a push/pull/legs/core category for balance ratios (`F-ANA-008`).
4. Secondary-muscle involvement counts as 0.5 of a set (`F-ANA-005`).

## Open questions
- Granularity: is splitting front/side/rear delts right while lumping all quad
  heads together? Defensible, but decide explicitly.
- Is a fixed 0.5 weighting for secondary muscles good enough, or should it vary
  per exercise? Fixed for v1; revisit with real data.

---

## Why

Sets-per-muscle-per-week and muscle-balance analytics are only as
good as the taxonomy underneath. A fixed enum with defined granularity, decided
once, because changing it later invalidates historical aggregates.
