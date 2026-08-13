# F-BOD-003 — Trend charts with smoothing

Status: in-progress | Priority: P1 | Phase: 4
Depends on: F-BOD-001, F-ANA-001
Reads: 21-DATA-MODEL#body_measurements, 22-UNITS

## Spec
1. Chart raw points plus an exponential moving average.
2. The EMA is visually dominant; raw points are secondary.
3. Rate of change shown per week, computed on the smoothed series.
4. Optional goal line (`F-BOD-005`).

## Acceptance
- [x] EMA matches the fixture in [`../40-ANALYTICS-SPEC.md`](../../40-ANALYTICS-SPEC.md).
- [x] Gaps in logging don't corrupt the smoothing.

## Status note (batch 4.4)

§1–§3 done: `domain/analytics/bodyweight_trend.dart`'s `bodyweightTrendEma`
matches the spec's `ema` fixture exactly, and reuses `linear_regression.dart`
for `weeklyRateOfChangeGrams` — the same slope-of-a-series-against-elapsed-time
computation that module's own doc comment already earmarked for a second
consumer. `TrendChart` gained an optional `secondaryPoints` scatter (no
connecting line, muted colour) so the raw series can render behind the
dominant EMA line without a second chart widget. Shown above the bodyweight
history list on the body screen, alongside the weekly rate of change. Not
built: §4's optional goal line, which depends on `F-BOD-005` — not attempted
this batch, so this feature stays `in-progress` rather than `done`.

---

## Why

Daily bodyweight is dominated by water, food, and time of day; the
raw series swings by kilograms and reading it as progress is actively
misleading. The smoothed line is the only part that carries information.
