# F-ANA-004 — Volume charts

Status: done | Priority: P1 | Phase: 3
Depends on: F-ANA-001
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec

Weekly volume load (Σ weight × reps over working sets) as a bar chart, per
exercise, per muscle group, and overall. Zero-based Y axis, since bar length
encodes magnitude. Week boundaries follow the user's first-day-of-week setting
(`F-SET-005`).

## Status notes (batch 3.3)

Two domain functions rather than one, because "per exercise" and
"per muscle group/overall" start from different data: `weeklyVolumeFromSessions`
sums `ExerciseHistorySession.volumeGrams` (`F-ANA-002`) by week for the
per-exercise chart on `ExerciseDetailScreen`; `weeklyVolume` works from the
new cross-catalogue `AnalyticsSetRecord` stream
(`SetRepository.watchAllAnalyticsSets`) for the "overall" and per-muscle
charts on the new `InsightsScreen`, attributing a set's full volume to its
*primary* muscle only — §2 has no fractional-secondary rule the way §3's set
counting does. `WeeklyBarChart` (`lib/features/shell/widgets/`) is the
shared zero-based bar component the design system names, built on
`fl_chart`'s `BarChart`. The Insights tab's placeholder is gone — this batch
is what finally gives it real content.
