# F-CAT-013 — Muscle taxonomy and body map data

Status: done | Priority: P1 | Phase: 3
Blocks: F-ANA-005, F-ANA-008, F-ANA-014
Reads: 21-DATA-MODEL#exercises, 40-ANALYTICS-SPEC#3-hard-sets-per-muscle-group-per-week

## Spec
1. Fixed enum, as listed in [`../21-DATA-MODEL.md`](../../21-DATA-MODEL.md).
2. Each muscle maps to a region on the body-map SVG (`F-ANA-014`).
3. Each maps to a push/pull/legs/core category for balance ratios (`F-ANA-008`).
4. Secondary-muscle involvement counts as 0.5 of a set (`F-ANA-005`).

## Status notes (batch 3.3)

Items 1 and 4 already existed — the `Muscle` enum since Phase 0/1's schema,
the 0.5 secondary weighting written into `F-ANA-005`'s own domain function
(`setsPerMuscleByWeek`), not here, since it's a counting rule for that metric
rather than a property of the taxonomy itself. Item 3 is new:
`domain/catalog/muscle_taxonomy.dart`'s `categoryOf` maps all 21 muscles to
`push`/`pull`/`legs`/`core` except `neck` and `fullBody`, which resolve to
`null` — deliberately, per this feature's own "decide explicitly" note,
rather than forced into a category that would misattribute them. Verified
against `docs/40-ANALYTICS-SPEC.md` §9's push/pull ratio fixture muscles.
## Status notes (Phase 4 closing pass)

Item 2 closed alongside `F-ANA-014`: `bodyMapViewOf` maps every muscle with a
category to a `BodyMapView.front`/`.back` region — same "decide explicitly"
treatment as `categoryOf`'s own `neck`/`fullBody` exclusion.

## Open questions
- Granularity: is splitting front/side/rear delts right while lumping all quad
  heads together? Defensible, but decide explicitly.
- Is a fixed 0.5 weighting for secondary muscles good enough, or should it vary
  per exercise? Fixed for v1; revisit with real data.

---

## Why

Sets-per-muscle-per-week and muscle-balance analytics are only as
good as the taxonomy underneath. A fixed enum with defined granularity, decided
once, because changing it later invalidates historical aggregates.
