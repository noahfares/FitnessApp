# F-PLT-004 — Closest achievable weight

Status: planned | Priority: P1 | Phase: 4
Depends on: F-PLT-001, F-PLT-002 | Blocks: F-PRG-012
Reads: 22-UNITS, 21-DATA-MODEL#bars-and-plates

## Spec

Given an arbitrary target, return the nearest assemblable load, with a
configurable rounding direction (default down). Exposed as a pure domain
function so the progression engine can call it directly without touching UI.
