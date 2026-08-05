# F-BOD-003 — Trend charts with smoothing

Status: planned | Priority: P1 | Phase: 4
Depends on: F-BOD-001, F-ANA-001
Reads: 21-DATA-MODEL#body_measurements, 22-UNITS

## Spec
1. Chart raw points plus an exponential moving average.
2. The EMA is visually dominant; raw points are secondary.
3. Rate of change shown per week, computed on the smoothed series.
4. Optional goal line (`F-BOD-005`).

## Acceptance
- [ ] EMA matches the fixture in [`../40-ANALYTICS-SPEC.md`](../../40-ANALYTICS-SPEC.md).
- [ ] Gaps in logging don't corrupt the smoothing.

---

## Why

Daily bodyweight is dominated by water, food, and time of day; the
raw series swings by kilograms and reading it as progress is actively
misleading. The smoothed line is the only part that carries information.
