# F-ANA-011 — Rep range and intensity distribution

Status: done | Priority: P2 | Phase: 4
Depends on: F-LOG-014
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec

Histograms of sets by rep range and by intensity zone (% of e1RM, or RPE where
recorded). Reveals that a program claiming to be "strength focused" is actually
running everything at 8–12 — a genuinely common blind spot.

## Status note (batch 4.5)

`domain/analytics/intensity_distribution.dart` — `repRangeDistribution`
buckets sets by §10's five rep ranges; `intensityZoneDistribution` buckets
by percentage of each set's own exercise's best e1RM *as of the session
before it* (§10 rule 1) — an exercise's first-ever session has no baseline
yet and is excluded, never bucketed as zero (§10 rule 2); `rpeDistribution`
is the RPE-based reading shown alongside wherever RPE was logged (§10
rule 3). `AnalyticsSetRecord` (`F-ANA-004`/`F-ANA-005`'s shared
whole-catalogue stream) gained `exerciseId` and `rpe` columns — grouping by
exercise *name* alone was never safe (`F-CAT-003` §4 allows duplicate
names), and nothing before this batch needed a set's RPE outside the
per-exercise history screen. All three histograms render on the Insights
tab, scoped to the shared date range selector, reusing `WeeklyBarChart`
for a non-weekly categorical axis — the widget only ever needed
`(value, label)` pairs.
