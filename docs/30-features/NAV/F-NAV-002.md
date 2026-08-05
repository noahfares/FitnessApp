# F-NAV-002 — Routing and deep links

Status: planned | Priority: P0 | Phase: 0
Depends on: F-NAV-001
Reads: 23-NAVIGATION

## Spec

Declarative routes per [`../23-NAVIGATION.md`](../../23-NAVIGATION.md). Deep links
are not cosmetic — home-screen widgets (`F-NAV-007`), app shortcuts
(`F-NAV-008`), and rest-timer notification taps (`F-TIM-003`) all route by URI.
`/workout/active` resolves the singleton in-progress session or redirects.
