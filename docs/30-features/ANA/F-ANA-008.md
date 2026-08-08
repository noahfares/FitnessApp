# F-ANA-008 — Muscle balance

Status: in-progress | Priority: P2 | Phase: 3
Depends on: F-CAT-013
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec

Push-to-pull and quad-to-hamstring ratios plus a radar chart of relative volume
by muscle group. Catches the classic imbalances that cause injuries and stalls,
which are invisible in per-exercise views.

## Status notes (batch 3.4)

`domain/analytics/muscle_balance.dart`'s `pushPullRatio`/`quadHamstringRatio`
match §9's fixture (27:22, ≈1.23:1) exactly, over a trailing 4-week window
computed independently of `InsightsScreen`'s shared date range selector
(`F-ANA-015`) — §9 fixes its own window, deliberately not tied to whatever
range someone happens to have picked for the volume charts above it. Each
ratio's numerator/denominator is the specific muscle list §9's own table
names (push = chest+frontDelts+triceps, pull = lats+upperBack+biceps) —
narrower than `domain/catalog/muscle_taxonomy.dart`'s general push/pull
category (`F-CAT-013`), which also includes `sideDelts`, `traps`,
`rearDelts` and `forearms`; the two are for different purposes and neither
is wrong. A zero denominator reports "no data recorded" (`_RatioTile`'s `—`
plus the explanatory subtitle) rather than infinity (§9 rule 2). Not built:
the radar chart of relative volume by muscle group — the two ratios ship as
plain text tiles on `InsightsScreen`, clearly labelled "a rough guide, not a
prescription" (§9 rule 1). `in-progress` for that reason.
