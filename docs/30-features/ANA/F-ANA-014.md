# F-ANA-014 — Body map heat overlay

Status: done | Priority: P3 | Phase: 4
Depends on: F-CAT-013
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec

Anatomical silhouette shaded by recent training volume per muscle. Instantly
legible, and it's what people actually want from `F-ANA-005`. Needs a licence-
clean SVG — same sourcing discipline as `F-CAT-001`.

## Status note (Phase 4 closing pass)

The "licence-clean SVG" this feature's own doc named as the blocker
(batch 4.5's status note: "needs a licence-clean SVG asset this session
couldn't responsibly source") is resolved by not needing an SVG at all:
`BodyMapHeatOverlay` (`lib/features/shell/widgets/`) draws an original,
non-anatomical silhouette directly with `CustomPaint` — simple rounded
rectangles per muscle region in a fixed coordinate space, nothing traced or
sourced from anywhere, which is what "licence-clean" actually requires.
`domain/analytics/muscle_heat.dart`'s `muscleHeatIntensity` is relative, not
absolute (`volume(muscle) / max(volume(m) for m in all trained muscles)`,
§16) — the hardest-trained muscle is always the hottest colour, everything
else scaled against it, so the map stays legible at any training volume.
`domain/catalog/muscle_taxonomy.dart`'s new `bodyMapViewOf` closes
`F-CAT-013` §2 (front/back region mapping) as a side effect — the same 19
muscles that have a push/pull/legs/core category map to exactly one view,
`neck`/`fullBody` to neither, same "decide explicitly" reasoning. Reached
from `InsightsScreen`'s new "Muscle heat map" section (collapsed by
default, `F-ROU-011`'s starvation fix again — its own widget test caught
the identical bug this feature introduced on first pass, an unbounded
100:220 portrait shape stretched to full list width).
