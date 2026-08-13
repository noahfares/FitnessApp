# F-TIM-009 — Stopwatch for timed exercises

Status: done | Priority: P2 | Phase: 4
Depends on: F-CAT-002
Reads: 20-ARCHITECTURE#cross-platform-discipline

## Spec

Count-up timer feeding the duration field for `time` and `weightTime` tracking
types — planks, carries, dead hangs. Without it those types require an external
timer, which defeats the point of tracking them.

## Status note (batch 4.6)

`domain/logging/stopwatch.dart`'s `LogStopwatch` is the same "value, not a
ticking object" shape `RestTimer` already used (`F-TIM-001`): elapsed time
is derived from a stored start timestamp against "now", never accumulated,
so it can't drift if the app is backgrounded mid-set. `NumericKeypadSheet`
gained a start/stop toggle shown only for the duration field, writing the
live elapsed seconds through the same `_write(digitsFromSeconds(...))` path
manual entry already used, with a `Timer.periodic` redrawing the display
once a second while running — the sheet's own state, not a new provider,
since the stopwatch's life is exactly one keypad session.
