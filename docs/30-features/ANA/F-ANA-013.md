# F-ANA-013 — Weekly insight cards

Status: done | Priority: P2 | Phase: 4
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

## Status note (Phase 4 closing pass)

`domain/analytics/weekly_insights.dart`'s `generateWeeklyInsights` composes
three already-built signals — per-muscle weekly volume (`F-ANA-004`),
per-exercise e1RM (via `epley1Rm`, `F-ANA-002`), and hard sets per muscle
per week (`F-ANA-005`) — into a ranked, capped list. Never fabricated: a
global gate requires at least 3 distinct weeks of counted-set history
before a single card is generated (§14 rule 1, closing the acceptance
criterion directly — two sessions almost always land inside 1–2 calendar
weeks), each signal has its own "genuinely notable" threshold (20% for
volume, 3% for a fresh e1RM high), and a plain "sets last week" fact's
ranking is scaled well under any real comparison so a busy muscle's raw
count can never crowd out a genuine change. Reached on the dashboard
(`WeeklyInsightsSection`, per this feature's own spec — "on the dashboard,"
not Insights) via `weeklyInsightsProvider`, rendering nothing at all
(`SizedBox.shrink()`) while loading, on error, or with too little history —
never a placeholder. Each card links to the chart behind it (§1 rule 3): the
e1RM card opens the specific exercise's detail screen precisely; the two
muscle-scoped kinds open the Insights tab generally rather than preselected
to that muscle, since `InsightsScreen`'s muscle picker is local widget
state, not yet a route parameter — a documented simplification, not a
missing link.

---

## Why

The payoff for the whole analytics layer. Most users will never open
a chart; they will read a sentence. This turns the metrics into the thing the app
is actually for.
