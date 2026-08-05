# F-SET-001 — Units

Status: planned | Priority: P0 | Phase: 0
Blocks: F-LOG-003, F-BOD-001, F-PLT-002
Reads: 22-UNITS, 70-decisions/ADR-0003-canonical-units
Screens: Settings › Units

## Spec
1. Four independent settings: `loadUnit` (kg/lb), `bodyUnit` (kg/lb),
   `lengthUnit` (cm/in), `distanceUnit` (km/mi).
2. Independent because real users mix them — lifting in kilograms while weighing
   in pounds is entirely normal.
3. **Display-only.** Changing one never migrates or rewrites data, and is
   instantly reversible.
4. Defaults inferred from device locale on first run, then never touched again.

## Acceptance
- [ ] Switching load unit updates every displayed weight, immediately, everywhere.
- [ ] No database write occurs when a unit setting changes.
- [ ] Increments follow the display unit — 2.5 kg or 5 lb (`F-SET-007`).

---

## Why

Explicitly required, and structurally load-bearing. See
[`../22-UNITS.md`](../../22-UNITS.md) for the full rules.
