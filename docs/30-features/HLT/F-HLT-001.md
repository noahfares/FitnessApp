# F-HLT-001 — Health Connect write

Status: planned | Priority: P2 | Phase: 6
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
