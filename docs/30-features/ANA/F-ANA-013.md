# F-ANA-013 — Weekly insight cards

Status: planned | Priority: P2 | Phase: 4
Depends on: F-ANA-003, F-ANA-004, F-ANA-005, F-ANA-009
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec
1. A small set of generated cards on the dashboard, e.g. "Chest volume is down
   31% versus your 4-week average", "Squat e1RM up 7.5 kg this month",
   "Rear delts: 4 sets last week".
2. Ranked by significance; only genuinely notable changes shown.
3. Each card links to the chart behind it.
4. Never fabricates significance — with insufficient data, it says nothing
   rather than inventing an observation.

## Acceptance
- [ ] A new user with two sessions sees no spurious insights.
- [ ] Every card's claim is verifiable from the underlying chart.

---

## Why

The payoff for the whole analytics layer. Most users will never open
a chart; they will read a sentence. This turns the metrics into the thing the app
is actually for.
