# F-ANA-003 — Estimated 1RM trend

Status: done | Priority: P1 | Phase: 3
Depends on: F-ANA-001
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets
Screens: Exercise Detail, Per-Exercise Analytics

## Spec
1. One point per session: the best working set's e1RM.
2. Line chart over a selectable range, with an optional linear-regression overlay.
3. Sets above 12 reps are marked unreliable and optionally excluded.
4. Formula selectable in settings (`F-SET-006`); the chart states which is in use.
5. Y axis does not start at zero (`../24-DESIGN-SYSTEM.md`).

## Acceptance
- [x] Matches hand-computed fixtures exactly — `e1rm_trend_test.dart` against
      the `sessionE1rm` fixture, and `e1rm_test.dart`/`linear_regression_test.dart`
      against `docs/40-ANALYTICS-SPEC.md` §1 and §7's fixtures underneath it.
- [x] Fewer than three points renders "not enough data yet", not a misleading
      line — `TrendChart`'s own widget test, and reproduced through the real
      screen in `exercise_detail_screen_test.dart`.

## Status notes (batch 3.2)

`domain/analytics/e1rm_trend.dart` (`e1rmTrend`) picks each session's best
counted set by e1RM under the selected `E1rmFormula` and date `DateRange`,
built on `domain/analytics/e1rm.dart`'s new `estimate1Rm` (item 4) and
`domain/analytics/linear_regression.dart` (item 2's overlay — shared with
`F-ANA-009`'s stall detection, Phase 4, rather than a one-off). `TrendChart`
(`lib/features/shell/widgets/`) is the reusable line-chart component the
design system names, built on `fl_chart` (now a real dependency, previously
only reserved in `pubspec.yaml`); it renders below-zero-safe Y bounds (item
5), an empty state under three points, and unreliable points as hollow dots
rather than hiding them outright — exclusion (item 3) is a toggle on the
screen, not something the chart decides for itself. Found and fixed along
the way: the spec's own `e1rm` fixture had an arithmetic error in the
Lombardi/60kg/12-rep cell (documented 76.049; `60 × 12^0.10` is 76.925 —
verified numerically, and the other four rows in the same table all match
their formula exactly). Corrected in both `docs/40-ANALYTICS-SPEC.md` and
`docs/fixtures/analytics.json`.

---

## Why

The single best answer to "am I getting stronger?" Raw top-set
weight is confounded by rep changes; e1RM normalises across rep ranges so a
5×5 block and an 8–12 block are comparable.
