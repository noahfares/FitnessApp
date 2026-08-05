# Settings — `SET`

Preferences. Small individually, but `F-SET-001` and `F-SET-004` are referenced
by half the app, and getting units wrong corrupts data rather than merely
annoying people.

---

### F-SET-001 — Units
Status: planned | Priority: P0 | Phase: 0
Blocks: F-LOG-003, F-BOD-001, F-PLT-002
Screens: Settings › Units

**Intent** — Explicitly required, and structurally load-bearing. See
[`../22-UNITS.md`](../22-UNITS.md) for the full rules.

**Behaviour**
1. Four independent settings: `loadUnit` (kg/lb), `bodyUnit` (kg/lb),
   `lengthUnit` (cm/in), `distanceUnit` (km/mi).
2. Independent because real users mix them — lifting in kilograms while weighing
   in pounds is entirely normal.
3. **Display-only.** Changing one never migrates or rewrites data, and is
   instantly reversible.
4. Defaults inferred from device locale on first run, then never touched again.

**Acceptance criteria**
- [ ] Switching load unit updates every displayed weight, immediately, everywhere.
- [ ] No database write occurs when a unit setting changes.
- [ ] Increments follow the display unit — 2.5 kg or 5 lb (`F-SET-007`).

---

### F-SET-002 — Theme mode
Status: planned | Priority: P0 | Phase: 0
Screens: Settings › Appearance

Light, dark, or follow system. Explicitly required. Applies instantly with no
restart. Both schemes are designed as equals — see
[`../24-DESIGN-SYSTEM.md`](../24-DESIGN-SYSTEM.md).

**Open questions** — A separate pure-black AMOLED variant? Popular on OLED
phones, and cheap. Probably worth it, but it's a third scheme to check in every
review.

---

### F-SET-003 — Rest-timer defaults
Status: planned | Priority: P1 | Phase: 1
Depends on: F-TIM-005

Global default rest duration, auto-start toggle, alert style, and pre-warning.
Per-exercise and per-routine overrides live with those entities.

---

### F-SET-004 — Bar and plate inventory
Status: planned | Priority: P1 | Phase: 4
Depends on: F-PLT-002

Configure available bars and plates. Reached from settings and directly from the
plate calculator, since that's where you notice it's wrong.

---

### F-SET-005 — Week start
Status: planned | Priority: P1 | Phase: 3
Blocks: F-ANA-004, F-ANA-006

**Intent** — Every weekly aggregate in the app depends on where the week starts.
Getting this wrong shifts every bar in every weekly chart by a day and makes
consistency streaks subtly wrong.

**Behaviour**
1. Configurable first day of week; default from locale.
2. Applies uniformly to weekly volume, sets-per-muscle, streaks, and the calendar.
3. Changing it recomputes all weekly aggregates.

---

### F-SET-006 — e1RM formula
Status: planned | Priority: P2 | Phase: 3
Depends on: F-ANA-003

Choose between Epley (default), Brzycki, and Lombardi. They disagree meaningfully
at high rep counts, so the choice is exposed rather than hidden, and every chart
using it states which is active. Formulas: [`../40-ANALYTICS-SPEC.md`](../40-ANALYTICS-SPEC.md).

---

### F-SET-007 — Increment steps
Status: planned | Priority: P1 | Phase: 2
Depends on: F-SET-001

Default weight increments per equipment type, overridable per exercise. Defined
in the display unit — 2.5 kg or 5 lb — converted once to canonical. Drives the
steppers (`F-LOG-006`) and linear progression (`F-PRG-002`).

---

### F-SET-008 — Notification preferences
Status: planned | Priority: P2 | Phase: 2
Depends on: F-TIM-003

Rest-timer alerts, optional workout reminders, and measurement reminders. All
default off except the rest timer; permission requested in context, never at
first launch.

---

### F-SET-009 — About
Status: planned | Priority: P1 | Phase: 1

Version and build number, open-source licences, link to the repository, and a
plain statement of the privacy position: no account, no telemetry, no network
calls. Required for a store listing, and it's the page that demonstrates the
project's claims.

---

### F-SET-010 — App lock
Status: planned | Priority: P3 | Phase: 5
Depends on: F-BOD-004

Optional biometric or PIN lock. Matters mainly because of progress photos and
body measurements, which are the most sensitive data the app holds.

---

### F-SET-011 — Onboarding
Status: planned | Priority: P2 | Phase: 6

**Intent** — Only becomes important when strangers install it. For now the app
should simply be obvious.

**Behaviour**
1. First-run: units, theme, and optionally a starter routine (`F-ROU-015`).
2. Skippable in full, with every choice changeable later.
3. No account creation, no email capture, no permission requests up front —
   which is itself the strongest first impression the app can make.
