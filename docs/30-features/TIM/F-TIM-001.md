# F-TIM-001 — Rest timer core

Status: done | Priority: P0 | Phase: 1
Blocks: F-TIM-002, F-TIM-003
Reads: 20-ARCHITECTURE#cross-platform-discipline
Screens: Active Workout

## Spec
1. Countdown from a configured duration, displayed persistently while running.
2. Start, pause, reset, skip; ±15 s adjustment while running.
3. Displayed in `displaySmall` tabular figures — readable at arm's length from a
   bench, which is the actual usage position.
4. Timer state derives from a target timestamp, not a decrementing counter, so
   it stays accurate across app backgrounding and doze.

## Acceptance
- [x] Remains accurate to within a second after several minutes backgrounded —
      `RestTimer` is a target timestamp, so nothing about it changes while the
      app is asleep and there is no accumulated error to drift.
- [x] Surviving an app kill is not required — but the app must not crash or show
      a stale timer on relaunch. State is in memory only, so a relaunch starts
      idle; a fired timer is not rendered either (`isVisibleAt`).
