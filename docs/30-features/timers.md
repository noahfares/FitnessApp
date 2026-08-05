# Timers — `TIM`

Rest timing is the second-most-used interaction in the app after set entry, and
the one most exposed to platform differences. Background execution behaves very
differently on Android and iOS, and that divergence is the main cross-platform
risk in the whole project.

---

### F-TIM-001 — Rest timer core
Status: planned | Priority: P0 | Phase: 1
Blocks: F-TIM-002, F-TIM-003
Screens: Active Workout

**Behaviour**
1. Countdown from a configured duration, displayed persistently while running.
2. Start, pause, reset, skip; ±15 s adjustment while running.
3. Displayed in `displaySmall` tabular figures — readable at arm's length from a
   bench, which is the actual usage position.
4. Timer state derives from a target timestamp, not a decrementing counter, so
   it stays accurate across app backgrounding and doze.

**Acceptance criteria**
- [ ] Remains accurate to within a second after several minutes backgrounded.
- [ ] Surviving an app kill is not required — but the app must not crash or show
      a stale timer on relaunch.

---

### F-TIM-002 — Auto-start on set completion
Status: planned | Priority: P0 | Phase: 1
Depends on: F-TIM-001, F-LOG-003

**Behaviour**
1. Completing a set starts the rest timer automatically.
2. Duration resolves routine exercise → exercise default → global default
   (`F-ROU-006`, `F-TIM-005`).
3. Auto-start is globally disableable.
4. Completing another set restarts the timer rather than stacking timers.
5. Un-completing a set cancels a running timer that it started.

---

### F-TIM-003 — Background execution and notification
Status: planned | Priority: P0 | Phase: 1
Depends on: F-TIM-001

**Intent** — Phones go in pockets between sets. A timer that only runs with the
app in the foreground is useless.

**Behaviour**
1. The timer continues while the app is backgrounded or the screen is off.
2. A notification fires at zero, with sound and/or vibration per `F-TIM-006`.
3. A live notification shows remaining time while running.
4. Tapping the notification deep-links back to the active workout (`F-NAV-002`).

**Acceptance criteria**
- [ ] Fires reliably with the app backgrounded and the screen off.
- [ ] Fires reliably under Android battery optimisation, on at least one
      aggressive OEM (Samsung or Xiaomi) — this is where such timers usually fail.
- [ ] Notification permission is requested in context, not at first launch.

**Edge cases** — Notification permission denied (fall back to in-app-only, and
say so). Do Not Disturb active. Battery optimisation killing the process.

**Open questions** — Android needs a foreground service or exact-alarm handling
for reliability; iOS restricts background execution far more and will likely
need local notifications scheduled at start time rather than a live timer.
Document both approaches behind the `RestTimerService` interface before writing
either. **This is the largest known Android/iOS behavioural divergence in the
project.**

---

### F-TIM-004 — Notification and lock-screen controls
Status: planned | Priority: P2 | Phase: 2
Depends on: F-TIM-003

Skip and +15 s actions directly from the notification, so the phone need not be
unlocked between sets.

---

### F-TIM-005 — Default rest durations
Status: planned | Priority: P1 | Phase: 1
Data: `exercises.default_rest_seconds`, app settings

Global default, per-exercise override, per-routine-exercise override, resolved
in that order of specificity. Sensible built-in defaults by exercise type —
compound lifts want considerably more rest than isolation work.

---

### F-TIM-006 — Alert style
Status: planned | Priority: P1 | Phase: 1

Sound, vibration, both, or silent; volume independent of media volume where the
platform allows; optional 10-second warning before zero.

---

### F-TIM-007 — Rest-taken recording
Status: planned | Priority: P2 | Phase: 2
Data: `sets.rest_taken_seconds`

Record actual elapsed rest before each set, derived from the previous set's
`completed_at`. Feeds rest-compliance analytics (`F-ANA-012`) — useful because
rest duration materially affects performance, and drifting rest times explain a
lot of apparent plateaus.

---

### F-TIM-008 — Interval / EMOM timer
Status: idea | Priority: P3 | Phase: —

Repeating interval timer for EMOM and circuit work. Distinct enough from rest
timing to warrant its own mode.

---

### F-TIM-009 — Stopwatch for timed exercises
Status: planned | Priority: P2 | Phase: 4
Depends on: F-CAT-002

Count-up timer feeding the duration field for `time` and `weightTime` tracking
types — planks, carries, dead hangs. Without it those types require an external
timer, which defeats the point of tracking them.
