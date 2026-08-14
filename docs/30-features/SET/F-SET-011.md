# F-SET-011 — Onboarding

Status: done | Priority: P2 | Phase: 6
Reads: 22-UNITS

## Spec
1. First-run: units, theme, and optionally a starter routine (`F-ROU-015`).
2. Skippable in full, with every choice changeable later.
3. No account creation, no email capture, no permission requests up front —
   which is itself the strongest first impression the app can make.

## Status note

`OnboardingScreen` (`lib/features/onboarding/presentation/`), a three-page
`PageView` reached at `/onboarding` — welcome, then units/theme, then an
optional starter-program import — with a `Skip` visible on every page, not
just the first. `onboardingCompletedProvider`
(`lib/features/onboarding/application/onboarding_provider.dart`) is a
`SharedPreferences`-backed flag in the same shape as `themeModeProvider`;
`startupLocationFor` (`active_workout_providers.dart`) now takes it as a
required param and returns `AppRoutes.onboarding` whenever it's unset,
ahead of even the kill-recovery check — a first-run device is never
mid-workout, so onboarding always wins when both could apply. §2 holds by
construction rather than by copying values afterward: the units/theme page
reads and writes `unitPreferencesProvider`/`themeModeProvider` directly, the
exact providers Settings uses, so there is no separate onboarding-only
value to keep in sync. The starter-routine page reuses
`RoutineRepository.importStarterProgram` (`F-ROU-015`) exactly as the full
gallery screen does, landing on the new routine on success. §3 needed no
code — nothing in this screen asks for an account, an email, or a platform
permission, so the criterion is met by omission, not by a check.

---

## Why

Only becomes important when strangers install it. For now the app
should simply be obvious.
