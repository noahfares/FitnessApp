# F-TIM-003 — Background execution and notification

Status: in-progress | Priority: P0 | Phase: 1
Depends on: F-TIM-001
Reads: 20-ARCHITECTURE#cross-platform-discipline

## Spec
1. The timer continues while the app is backgrounded or the screen is off.
2. A notification fires at zero, with sound and/or vibration per `F-TIM-006`.
3. A live notification shows remaining time while running.
4. Tapping the notification deep-links back to the active workout (`F-NAV-002`).

## Status note — what has landed

`RestTimerService` exists (`lib/data/platform/rest_timer_service.dart`) with
both platform approaches documented on it, as the open question below demands,
and an in-app implementation behind it: a Dart timer, a system sound and a
haptic. That satisfies §1 only for as long as the process is alive, and nothing
of §2–§4.

Remaining: `flutter_local_notifications`, the Android manifest permissions and
channel, the ongoing live notification, and the deep link on tap. Deliberately
not attempted in batch 1.5 — the acceptance criteria below are on-device
criteria, and the session that would have written it had neither an Android SDK
nor a phone. Nothing in `features/` or `domain/` needs to change when it lands.

## Acceptance
- [ ] Fires reliably with the app backgrounded and the screen off.
- [ ] Fires reliably under Android battery optimisation, on at least one
      aggressive OEM (Samsung or Xiaomi) — this is where such timers usually fail.
- [ ] Notification permission is requested in context, not at first launch.

## Edge cases

Notification permission denied (fall back to in-app-only, and
say so). Do Not Disturb active. Battery optimisation killing the process.

## Open questions

Android needs a foreground service or exact-alarm handling
for reliability; iOS restricts background execution far more and will likely
need local notifications scheduled at start time rather than a live timer.
Document both approaches behind the `RestTimerService` interface before writing
either. **This is the largest known Android/iOS behavioural divergence in the
project.**

---

## Why

Phones go in pockets between sets. A timer that only runs with the
app in the foreground is useless.
