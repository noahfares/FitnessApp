# F-HLT-001 — Health Connect write

Status: done | Priority: P2 | Phase: 6
Reads: 20-ARCHITECTURE#cross-platform-discipline

## Spec
1. Write completed workouts to Health Connect as strength-training sessions with
   start time, duration, and optionally energy expenditure.
2. Explicitly opt-in, off by default, revocable, with a clear statement of what
   is written.
3. Write failures never block finishing a workout — the local record is
   authoritative.

## Acceptance
- [ ] Nothing is written before explicit consent.
- [ ] Revoking permission degrades gracefully with no data loss.
- [ ] Deleting a workout locally offers to remove the corresponding record.

## Open questions

Energy expenditure for resistance training is a guess at
best. Writing a fabricated calorie figure into a user's health record is worse
than writing nothing. Default to omitting it.

---

## Why

Workouts logged here should appear alongside everything else the
user's phone knows about their activity, without them re-entering anything.

## Implementation

- `HealthService` (`data/platform/`) is the seam, the same shape
  `RestTimerService` uses and for the same reason: Health Connect and HealthKit
  differ enough that neither may leak into `features/` or `domain/`.
  `PlatformHealthService` wraps the `health` plugin; `NoopHealthService` is the
  honest implementation for a platform with no health store, and the default in
  tests.
- **Every method swallows its failures and reports a value.** That is what
  makes §3 a property of one file rather than a promise each call site keeps:
  the write on finishing is `unawaited`, after the summary navigation is
  already decided, so a slow or refused platform call cannot stand between
  finishing a session and seeing it.
- Off by default, two independent switches (write workouts, read bodyweight) —
  they are separate decisions, and plenty of people want the first without the
  second. Permission is requested when a switch is flipped, never at launch;
  the test asserts zero permission requests on the way into the screen.
- No energy figure, settling the open question the way it leaned: a fabricated
  calorie number in someone's health record is worse than no number.
- Deleting a workout locally deletes the Health Connect copy too, and the
  confirmation sheet says so — but only when the switch is on, since offering
  to remove a record that was never written is noise.
- **minSdk moves to 26**, which Health Connect's client library requires. That
  drops Android 7.x; recorded in `docs/62-RELEASE.md` as the product decision
  it is rather than left in `build.gradle.kts`.
- `PRIVACY.md` §health-data was rewritten *first* — version 1 promised any such
  integration would be disclosed there before it shipped — and
  `docs/64-PRIVACY.md` gained the Play Health-apps declaration.

## Status

Built and unit-tested against a fake; **not verified on a device**. This
session had no Android SDK, so the manifest declarations, the permission flow
and the Health Connect handshake itself are unexercised. That is the same
caveat `F-TIM-003` carries, and the first on-device pass should check: the
permission rationale intent resolves, a finished session appears in Health
Connect, revoking permission there degrades quietly, and deleting locally
removes the remote copy.
