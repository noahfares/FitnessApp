# F-ANA-016 — Chart interaction

Status: done | Priority: P2 | Phase: 3
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec

Tap for a tooltip with exact values and the source session, pinch to zoom the
time axis, tap through to the workout that produced a point. Charts that are
read-only pictures waste the data behind them.

## Status notes (batch 3.6)

`TrendChart` (the e1RM trend on `ExerciseDetailScreen`) already had a
tap-tooltip from batch 3.2; this batch adds tap-through to the point's source
workout (`onPointTap`, carrying `TrendChartPoint.workoutId` from
`E1rmTrendPoint`/`ExerciseHistorySession.workoutId`) and pinch-to-zoom on the
time axis via fl_chart 1.2's `FlTransformationConfig` (`zoomEnabled`, on by
default). `WeeklyBarChart` gets per-bar tap-through instead of pinch-zoom — a
week aggregates many workouts, so there is no single session to navigate to;
tapping a bar on Insights' "hard sets per muscle" chart scopes the existing
"contributing exercises" drill-down (`F-ANA-005` §3) to that one week, closing
the exact deferral `sets_per_muscle.dart`'s own doc comment named. Zoom is
**not** added to `WeeklyBarChart` — the routine day editor's Preview card
embeds one inside an `ExpansionTile` inside a scrolling column, and a pan/scale
gesture there would fight the parent scroll (the same card that broke a
widget test in batch 3.5 for a related reason); tap-through was judged safe
there instead since a single tap doesn't compete with a drag-to-scroll the
way a sustained pinch/pan would, and the preview card passes no `onBarTap`
regardless (it has no per-week drill-down to scope). Not built: reduce-motion
gating (`F-A11Y-005`) — the codebase has no `MediaQuery.disableAnimations`
read anywhere yet, in any chart, from any prior batch; adding it here for
these two widgets alone without an app-wide convention was judged out of
scope for this feature.
