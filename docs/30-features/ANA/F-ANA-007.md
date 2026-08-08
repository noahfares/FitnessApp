# F-ANA-007 — PR timeline

Status: done | Priority: P1 | Phase: 3
Depends on: F-LOG-013
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets
Screens: PR Timeline

## Spec

Chronological list of every personal record, filterable by exercise and kind,
with the set that achieved it. The app's highlight reel.

## Status notes (batch 3.4)

`PersonalRecordRepository.watchTimeline` — a straight join of
`personal_records`/`exercises`, newest first, no domain layer needed since
this is a display list, not a computed metric. `PrTimelineScreen` filters by
exercise and kind via two dropdowns (client-side, over the already-streamed
list — the same "fetch once, filter in the UI" pattern
`ExerciseDetailScreen`'s date range uses) and describes each entry with the
same four-kind wording `SessionSummaryScreen._describe` already uses for
the in-session celebration, so a record reads identically whether found in
the moment or later here. Reached from a new button row on `InsightsScreen`.
