# F-ANA-003 — Estimated 1RM trend

Status: planned | Priority: P1 | Phase: 3
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
- [ ] Matches hand-computed fixtures exactly.
- [ ] Fewer than three points renders "not enough data yet", not a misleading line.

---

## Why

The single best answer to "am I getting stronger?" Raw top-set
weight is confounded by rep changes; e1RM normalises across rep ranges so a
5×5 block and an 8–12 block are comparable.
