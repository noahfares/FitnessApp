# F-ANA-006 — Consistency

Status: in-progress | Priority: P1 | Phase: 3
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets
Screens: Consistency

## Spec

Calendar heatmap of training days, current and longest streak, rolling
sessions-per-week average, and adherence against schedule once `F-ROU-012`
exists. Streaks are motivating but must not shame — no loss animations, no
guilt copy.

## Status notes (batch 3.4)

`domain/analytics/consistency.dart` — `trainingDays`, `weeklySessionCounts`
(zero-filled between the earliest training day and the current week, so
streak maths never sees a gap it could misread as one continuous run), and
`consistencyStats`, matched exactly against the spec's own `streak` fixture
(current streak 3, longest 3, sessions/week 2.5) including its trickiest
rule: the in-progress current week is excluded from streak-breaking but
still counts in the trailing-4-weeks average. `CalendarHeatmap`
(`lib/features/shell/widgets/`) is the component inventory's named grid —
two states per cell only (trained / not), no colour ramp by volume and no
red for a miss, since §5 rule 4's "no shame" applies to colour as much as
to animation. `ConsistencyScreen` reached from a new button row on
`InsightsScreen`. Weekly target is a fixed `3`, not yet a setting (§5 rule 2
calls it "user-configurable") — no UI for it exists yet. Still
`in-progress`: adherence against a schedule waits on `F-ROU-012`
(scheduling), which doesn't exist.
