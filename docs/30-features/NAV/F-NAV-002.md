# F-NAV-002 — Routing and deep links

Status: done | Priority: P0 | Phase: 0
Depends on: F-NAV-001
Reads: 23-NAVIGATION

## Spec

Declarative routes per [`../23-NAVIGATION.md`](../../23-NAVIGATION.md). Deep links
are not cosmetic — home-screen widgets (`F-NAV-007`), app shortcuts
(`F-NAV-008`), and rest-timer notification taps (`F-TIM-003`) all route by URI.
`/workout/active` resolves the singleton in-progress session or redirects.

## Acceptance

- [x] Routes are declared centrally, with paths as constants rather than string
      literals — a typo in a deep link is a dead entry point, not a compile
      error.
- [x] An unknown URI lands on a real "not found" screen with a way home, not a
      crash. Stale deep links from widgets, shortcuts and notifications are a
      realistic input.
- [x] Settings routes resolve and are reachable.
- [ ] `/workout/active` singleton resolution — arrives with `F-LOG-001`.

## Implementation

`lib/core/routing/` — `app_routes.dart` (paths) and `app_router.dart` (config).
Only the Phase 0 routes exist; the rest arrive with the features that own them,
so the router never references a screen that does not exist.
