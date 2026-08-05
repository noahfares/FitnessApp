# Health platform integration — `HLT`

Integration with Health Connect (Android), HealthKit (iOS), and wearables.

Deliberately late. It's optional value, it carries the heaviest store-policy
burden in the project, and it's the one area where a mistake means handling
health data badly rather than merely having a bug. Read the current platform
policy **before** implementing, not after.

---

### F-HLT-001 — Health Connect write
Status: planned | Priority: P2 | Phase: 6

**Intent** — Workouts logged here should appear alongside everything else the
user's phone knows about their activity, without them re-entering anything.

**Behaviour**
1. Write completed workouts to Health Connect as strength-training sessions with
   start time, duration, and optionally energy expenditure.
2. Explicitly opt-in, off by default, revocable, with a clear statement of what
   is written.
3. Write failures never block finishing a workout — the local record is
   authoritative.

**Acceptance criteria**
- [ ] Nothing is written before explicit consent.
- [ ] Revoking permission degrades gracefully with no data loss.
- [ ] Deleting a workout locally offers to remove the corresponding record.

**Open questions** — Energy expenditure for resistance training is a guess at
best. Writing a fabricated calorie figure into a user's health record is worse
than writing nothing. Default to omitting it.

---

### F-HLT-002 — Health Connect read
Status: planned | Priority: P3 | Phase: 6
Depends on: F-BOD-001

Read bodyweight from Health Connect so a smart scale populates `F-BOD-001`
automatically. Read-only, opt-in, and with a clear conflict rule when both
sources have an entry for the same day.

---

### F-HLT-003 — HealthKit parity
Status: idea | Priority: P2 | Phase: —
Depends on: F-HLT-001

The iOS equivalent, behind the same `data/platform/` interface. Scheduled with
the iOS port, which has no date. HealthKit's permission model and review
requirements differ meaningfully from Health Connect's, so this is not a
trivial re-implementation.

---

### F-HLT-004 — Wear OS companion
Status: idea | Priority: P3 | Phase: —

Log sets and control the rest timer from the wrist. Genuinely useful — it's the
one place a wearable beats a phone for this app, since your phone is in your bag
and your watch is on you. Also a substantial second application with its own
data-sync problem, so it stays an idea until the phone app is finished.

---

### F-HLT-005 — watchOS companion
Status: idea | Priority: P3 | Phase: —
Depends on: F-HLT-004

The Apple equivalent. Further out still, and gated on both the iOS port and
`F-HLT-004` proving the concept.
