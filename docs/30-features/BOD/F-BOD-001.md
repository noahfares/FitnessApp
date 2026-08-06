# F-BOD-001 — Bodyweight log

Status: done | Priority: P0 | Phase: 1
Blocks: F-LOG-019, F-BOD-003
Reads: 21-DATA-MODEL#body_measurements, 22-UNITS
Screens: Body Metrics, Dashboard | Data: `body_measurements`

## Spec
1. Log bodyweight with a date and optional note; multiple entries per day
   allowed, though one is typical.
2. Displayed in the body unit (`F-SET-001`), which is independently configurable
   from the load unit — many people lift in kilograms and weigh in pounds.
3. The most recent value before a workout's date supplies its
   `workouts.bodyweight_grams`.
4. Quick entry from the dashboard, not just from a settings screen.

## Acceptance
- [ ] Stored canonically in grams; changing the display unit rewrites nothing.
- [ ] Backfilling an older entry updates the affected workouts' bodyweight
      association.

---

## Why

**Unrecoverable data, which is why this sits in Phase 1 rather than
with the rest of body metrics.** A missing column can be added later; a year of
missing bodyweight observations cannot. Without it, no strength trend can be
read as *relative* strength, bodyweight-loaded exercises (`F-LOG-019`) have no
basis for effective load, and a lifter who gained 8 kg while their squat went up
10 kg has no way to see what actually happened.

Only the capture is early. The rest of this domain — measurements, charts,
photos — stays in Phase 4. Logging a number is cheap; analysing it can wait.
