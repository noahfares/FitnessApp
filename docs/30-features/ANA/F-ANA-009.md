# F-ANA-009 — Stall detection

Status: planned | Priority: P2 | Phase: 4
Depends on: F-ANA-003
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec
1. Linear regression on e1RM over the trailing N sessions of an exercise.
2. Flag when the slope is flat or negative across a meaningful window with
   enough data points to be significant.
3. Surface as plain English — "Bench press hasn't moved in 6 weeks" — not as a
   chart annotation.
4. Suggest concrete actions: deload (`F-PRG-011`), volume change, or exercise
   variation.

## Open questions

Thresholds. Too sensitive and it cries wolf every deload
week; too lax and it's useless. Needs tuning against real history, so ship it
after there is real history to tune against.

---

## Why

Charts require you to go looking. Stalling is exactly the thing you
don't notice from inside it, and the thing most worth being told.
