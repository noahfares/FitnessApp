# F-LOG-019 — Bodyweight-loaded exercises

Status: planned | Priority: P2 | Phase: 4
Depends on: F-BOD-001
Reads: 40-ANALYTICS-SPEC#2-volume-load, 21-DATA-MODEL#exercises
Data: `workouts.bodyweight_grams`

## Spec
1. Exercises flagged as bodyweight-loaded compute effective load as
   bodyweight + added weight.
2. Bodyweight comes from the nearest measurement to the session date
   (`F-BOD-001`), falling back to the most recent.
3. A per-exercise bodyweight coefficient handles partial loading (a push-up is
   roughly 0.64 of bodyweight).
4. Analytics use effective load; the set row displays added weight.

## Open questions

Coefficients per exercise are approximations. Ship a default
table and let users override, or omit the concept and treat everything as full
bodyweight? Decide with real data.

---

## Why

Pull-ups and dips are load-bearing exercises whose load is mostly
you. Counting a weighted pull-up as "20 kg" understates it by a factor of five
and makes volume comparisons across a bodyweight change meaningless.
