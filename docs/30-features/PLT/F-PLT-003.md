# F-PLT-003 — Loading visualisation

Status: done | Priority: P2 | Phase: 4
Depends on: F-PLT-001
Reads: 22-UNITS, 21-DATA-MODEL#bars-and-plates

## Spec

Draw the loaded bar to scale with colour-coded plates matching real IPF plate
colours. Far faster to read mid-set than a list of numbers, and it's how lifters
already think about a loaded bar.

## Status note (batch 4.3)

`features/shell/widgets/plate_stack_visualization.dart`'s
`PlateStackVisualization` — one side, heaviest plate nearest the bar sleeve
(how a bar is actually loaded), height scaling with plate size within a
fixed, legible band so a 1.25 kg change plate never draws taller than a
25 kg one. Colours are bucketed by canonical kilograms regardless of the
display unit — the IPF convention itself is defined in kg, and a
pound-configured inventory is still made of these same physical plate
sizes. Shown above the existing per-side plate list in
`PlateCalculatorSheet` for both the exact and closest-achievable cases.
