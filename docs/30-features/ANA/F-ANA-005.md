# F-ANA-005 — Sets per muscle group per week

Status: done | Priority: P1 | Phase: 3
Depends on: F-CAT-013 | Blocks: F-ROU-011
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec
1. Count working sets per muscle per week. Primary muscle counts 1.0, each
   secondary counts 0.5.
2. Bar chart per muscle with optional reference bands for common volume targets.
3. Drill into a muscle to see which exercises contributed.

## Status notes (batch 3.3)

`domain/analytics/sets_per_muscle.dart`'s `setsPerMuscleByWeek` implements
items 1 and 4's rules exactly against the spec's own `setsPerMuscle` fixture
(4 primary chest sets + 3 primary front-delt sets → chest 4.0, frontDelts
5.0, triceps 3.5). Rendered on the new `InsightsScreen` via `WeeklyBarChart`,
muscle-selectable through a dropdown shared with the volume chart beside it.
Item 3's drill-down is `contributingExercises` — ranks exercises by their
contribution to the selected muscle (primary 1.0, secondary 0.5, same
weighting) — but scoped to the whole selected date range rather than one
tapped bar/week, since per-bar tap-through is `F-ANA-016` (batch 3.6, not
built yet). `in-progress` rather than `done` for that reason, and because
item 2's reference bands are explicitly out of scope for this batch (the
feature's own "off by default" open-question answer still needs its own
pass once a real chart exists to attach them to).

## Open questions

Should reference bands ship at all? They imply a
prescriptive stance the app otherwise avoids, and the research ranges are wide.
Probably yes, clearly labelled as a rough guide, off by default.

---

## Why

The metric that actually drives hypertrophy programming, and the one
most consumer apps omit entirely. Training literature talks in hard sets per
muscle per week; nothing else in the app answers "am I doing enough for rear
delts?"

## Status notes (closed, v0.54.0)

§2's reference bands are built: `WeeklyBarChart` takes an optional
`referenceBand`, drawn as an `fl_chart` range annotation behind the bars, and
the hard-sets chart passes 10–20 sets a week. A **range, not a line** — the
evidence is a range, and one number would turn a rough guide into a
prescription, the same framing ACWR and muscle balance already use. The band is
shaded, and shading is colour, so it is also named in words beside the chart
(`F-A11Y-003`) and folded into the spoken summary (`F-A11Y-001`).
