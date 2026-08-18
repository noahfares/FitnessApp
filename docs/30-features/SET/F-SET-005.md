# F-SET-005 — Week start

Status: done | Priority: P1 | Phase: 3
Blocks: F-ANA-004, F-ANA-006
Reads: 22-UNITS

## Spec
1. Configurable first day of week; default from locale.
2. Applies uniformly to weekly volume, sets-per-muscle, streaks, and the calendar.
3. Changing it recomputes all weekly aggregates.

## Status notes (batch 3.3)

`core/units/week_start.dart` (`WeekStart`, `weekStartFor`) mirrors
`UnitPreferences`'s shape exactly — a country-code heuristic for the
first-run default (Sunday for the US/Canada/etc., Saturday for a short list
of Gulf states, Monday everywhere else), stored value wins afterwards.
`WeekStartNotifier` persists it via `SharedPreferences`; a three-way radio
row on Settings root, same "doesn't earn its own route" reasoning as RPE.
Item 2 holds for the two consumers that exist so far — `F-ANA-004`'s weekly
volume and `F-ANA-005`'s sets-per-muscle both take `WeekStart` as a
parameter, no metric computes its own week boundary. Still `in-progress`:
streaks (`F-ANA-006`) and the calendar aren't built yet, so "applies
uniformly" can't be verified end to end until they exist. Item 3
("recomputes") is automatic rather than a feature of its own — every
consumer is a pure function of the current `WeekStart` value, so changing
the Riverpod state naturally recomputes on next read; there is no cache to
invalidate.

---

## Why

Every weekly aggregate in the app depends on where the week starts.
Getting this wrong shifts every bar in every weekly chart by a day and makes
consistency streaks subtly wrong.

## Status notes (closed, v0.54.0)

Item 2's "applies uniformly" is now verifiable end to end: streaks
(`F-ANA-006`) and the calendar (`CalendarHeatmap`) exist and both take
`WeekStart` as a parameter, alongside weekly volume and sets-per-muscle. No
metric computes its own week boundary anywhere in the codebase. Item 3 needs no
mechanism — every consumer is a pure function of the current value, so changing
it recomputes on next read; there is no cache to invalidate.
