# F-PLT-004 — Closest achievable weight

Status: done | Priority: P1 | Phase: 4
Depends on: F-PLT-001, F-PLT-002 | Blocks: F-PRG-012
Reads: 22-UNITS, 21-DATA-MODEL#bars-and-plates

## Spec

Given an arbitrary target, return the nearest assemblable load, with a
configurable rounding direction (default down). Exposed as a pure domain
function so the progression engine can call it directly without touching UI.

---

## Status note (batch 4.3)

`closestAchievableGrams` in `domain/plates/plate_calculator.dart`, wrapping
`solvePlateLoad` (`F-PLT-001`). `RoundingDirection.down`/`.up`/`.nearest`,
default `down`. Consumed directly by `F-PRG-012`'s `applyPlateRounding` —
no UI of its own beyond what `F-PLT-001`'s calculator sheet already shows.
