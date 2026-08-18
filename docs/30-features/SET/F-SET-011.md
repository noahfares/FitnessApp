# F-SET-011 — Onboarding

Status: done | Priority: P2 | Phase: 6
Reads: 22-UNITS

## Spec
1. First-run: units, theme, and optionally a starter routine (`F-ROU-015`).
2. Skippable in full, with every choice changeable later.
3. No account creation, no email capture, no permission requests up front —
   which is itself the strongest first impression the app can make.

---

## Why

Only becomes important when strangers install it. For now the app
should simply be obvious.

## Implementation

- Three pages, a Skip on every one, and `onboarding.seen` set when the flow
  ends **or is skipped** — skipping is a complete answer, not a postponement
  (§2). Everything asked has a working default already, so someone who skips
  lands exactly where they would have without this screen.
- `startupLocationFor(active, onboardingSeen:)` sends a first run to
  `/onboarding` ahead of everything else; `main()` reads the flag from the
  `SharedPreferences` instance it already opens before the first frame, so
  there is no flash of the dashboard first.
- Units set here also set bodyweight and distance, rather than asking a fourth
  question — anyone wanting them to differ has Settings › Units, where that
  choice already lives. The page says the thing that actually matters: changing
  it later rewrites nothing (ADR-0003).
- The starter-program page offers the first three programs, not all six: a wall
  of choices is exactly the decision this screen exists to avoid making feel
  necessary. The gallery (`F-ROU-015`) is one tap away for anyone who knows
  what they want.
- §3 is the feature's actual point, so the test asserts an absence: no
  "Sign up", "Email", "Create account" or "Allow notifications" text exists
  anywhere in the flow. Asserting a negative is the only way it stays true.
