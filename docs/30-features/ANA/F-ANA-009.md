# F-ANA-009 — Stall detection

Status: done | Priority: P2 | Phase: 4
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

## Status note (batch 4.5)

`domain/analytics/stall_detection.dart`'s `detectStall` implements §7
exactly: silence (`null`) under 5 sessions, the trailing-8-session window,
and the slope-and-3-week-span condition together, matching the spec's
`slope` fixture. Surfaced on `ExerciseDetailScreen` as a plain-English
banner — never a chart annotation — naming concrete actions (§4) and,
when `F-PRG-011`'s workload signal agrees too, the deload suggestion. The
**open question above is still open**: thresholds (100 g/session, 3-week
span) are the spec's own defaults, not yet tuned against real training
history — same waiver Phase 1 and Phase 3 each gave their own
no-real-history criteria.

---

## Why

Charts require you to go looking. Stalling is exactly the thing you
don't notice from inside it, and the thing most worth being told.
