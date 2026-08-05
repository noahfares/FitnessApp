# F-SET-005 — Week start

Status: planned | Priority: P1 | Phase: 3
Blocks: F-ANA-004, F-ANA-006
Reads: 22-UNITS

## Spec
1. Configurable first day of week; default from locale.
2. Applies uniformly to weekly volume, sets-per-muscle, streaks, and the calendar.
3. Changing it recomputes all weekly aggregates.

---

## Why

Every weekly aggregate in the app depends on where the week starts.
Getting this wrong shifts every bar in every weekly chart by a day and makes
consistency streaks subtly wrong.
