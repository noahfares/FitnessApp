# F-ANA-006 — Consistency

Status: done | Priority: P1 | Phase: 3
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

## Status notes (closed, v0.54.0)

Both remaining clauses are built:

- **The weekly target is a setting** (§5 rule 2), not a fixed 3 — chips on the
  consistency screen, persisted like `WeekStart`. A streak measured against a
  number nobody chose is a number nobody believes.
- **Adherence against schedule**, which waited on `F-ROU-012`.
  `domain/analytics/schedule_adherence.dart` measures the trailing four weeks —
  the same window the sessions-per-week average uses, so the two figures on the
  screen describe the same period. It is deliberately asymmetric: a session on
  an unscheduled day is reported and never subtracted, because "no shame"
  (§5 rule 4) is a maths decision here, not only a copy one. With nothing
  scheduled there is no ratio at all rather than 0%, which would be a lie about
  someone who never set a schedule.
