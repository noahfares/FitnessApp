# F-ANA-015 — Date range and filter controls

Status: done | Priority: P1 | Phase: 3
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec

Shared range selector across every chart — 4 weeks, 3 months, 6 months, 1 year,
all time, custom. Selection persists across screens within a session so
comparing charts doesn't mean re-selecting the range each time.

## Status notes (batch 3.2)

`domain/analytics/date_range.dart` (`RangePreset`, `resolveRange`) and
`features/analytics/application/date_range_provider.dart`
(`dateRangeSelectionProvider`, in-memory — the spec asks for it to persist
"within a session", not across app restarts the way a real setting would) are
built and wired into the one chart that exists so far
(`ExerciseDetailScreen`'s e1RM trend). `in-progress`, not `done`: "shared...
across every chart" can't be verified until the batches after 3.2 give it a
second and third chart to actually share with (`F-ANA-004`, batch 3.3
onward) — closing this out now would be asserting something only one
consumer has tested.

## Status notes (closed, v0.54.0)

"Shared across every chart" is now verifiable, because there are charts to
share it with: `DateRangeSelector` drives the e1RM trend and weekly volume on
`ExerciseDetailScreen` and every range-scoped section of `InsightsScreen`,
through one `dateRangeSelectionProvider`. Selection persists across screens
within a session, which is what the spec asks for — not across restarts, which
it deliberately does not.
