# F-THM-004 — Chart theming

Status: done | Priority: P1 | Phase: 3
Depends on: F-THM-001, F-ANA-001
Reads: 24-DESIGN-SYSTEM

## Spec

Chart colours, gridlines, and axis labels as theme tokens. The categorical
series palette must be distinguishable in both schemes and without colour vision
(`F-A11Y-003`) — series are also differentiated by marker shape or dash pattern.

## Status notes (batch 3.2)

`chartSeries[]` (`core/theme/app_colors.dart`) already existed since batch
2.8's dynamic-colour work, pinned by its own test. This batch is the first to
actually consume it: `TrendChart` reads `context.appColors.chartSeries.first`
for its line, and gridlines/axis text come from `Theme.of(context)`
(`dividerColor`, `textTheme.bodySmall`) rather than literals. "Differentiated
by marker shape or dash pattern" doesn't yet apply in practice —
`TrendChart` only ever draws one data series plus its own dashed regression
overlay (a fixed, non-palette style, not a second categorical series) — it
will apply once a chart here plots two or more `chartSeries[]` lines at
once, none of which exist yet.
