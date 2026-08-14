# F-LOG-019 — Bodyweight-loaded exercises

Status: done | Priority: P2 | Phase: 4
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

## Status note (batch 4.6)

§1's open question is resolved the simpler way: no default table, a
per-exercise override (`exercises.bodyweight_coefficient`, already existed
since schema v3) that defaults to `null` — full bodyweight — and is only
ever set by hand on the exercise editor, shown as a percentage field when
`trackingType == bodyweightReps`. `domain/logging/bodyweight_load.dart`'s
`effectiveLoadGrams` is the pure §1 formula (bodyweight × coefficient +
added), and `set_fields.dart`'s `bodyweightReps` case gained
`SetField.weight` — the set row logs *added* weight, never total, so a
push-up leaves it blank and a weighted pull-up doesn't. §2's "nearest
measurement, falling back to most recent" was already satisfied before this
batch: `WorkoutRepository._backfillBodyweight` (`F-BOD-001`) already
resolves `workouts.bodyweight_grams` that way at session start, so this
batch only had to read the column, not derive it again. §4 (analytics use
effective load) reaches `weekly_volume.dart`'s `weeklyVolume`/`dailyVolume`
via a new `_setVolumeGrams` helper, fixture-tested for both the
"bodyweight captured" and "no bodyweight on record" cases;
`AnalyticsSetRecord` carries `workoutBodyweightGrams` and
`bodyweightCoefficient` for this, sourced from `SetRepository`'s
whole-catalogue analytics query. Not built: `personal_records.dart` and
`exercise_history.dart` still key off raw `weightGrams` rather than
effective load — retrofitting every other analytics consumer beyond §4's
own volume chart was out of scope for this batch, same reasoning batch 3.1
gave for leaving PR detection's filter alone.

---

## Why

Pull-ups and dips are load-bearing exercises whose load is mostly
you. Counting a weighted pull-up as "20 kg" understates it by a factor of five
and makes volume comparisons across a bodyweight change meaningless.
