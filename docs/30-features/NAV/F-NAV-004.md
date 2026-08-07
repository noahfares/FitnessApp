# F-NAV-004 — Dashboard

Status: done | Priority: P1 | Phase: 1
Reads: 23-NAVIGATION

## Spec

The home screen. In priority order: resume or start a workout, today's scheduled
day (`F-ROU-012`), current streak, recent PRs, insight cards (`F-ANA-013`), quick
bodyweight entry. Everything is a shortcut to doing something, not a wall of
statistics.

Only the first item and a recent-workouts list ship now. Today's scheduled day
needs routines (`F-ROU-012`, Phase 2); streak and insight cards need the Phase 3
analytics providers; recent PRs need `F-LOG-013` (Phase 2); quick bodyweight
entry is `F-BOD-001`, the next batch. Each arrives on the dashboard when its
own feature does, rather than as a placeholder card here.
