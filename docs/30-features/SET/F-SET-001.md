# F-SET-001 — Units

Status: done | Priority: P0 | Phase: 0
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
- [x] Switching load unit updates every displayed weight, immediately,
      everywhere. Every number renders through `quantityFormatterProvider`,
      which watches the preference, so one change rebuilds all of them.
- [x] No database write occurs when a unit setting changes. One
      `SharedPreferences` key; no stored quantity is touched.
- [ ] Increments follow the display unit — 2.5 kg or 5 lb (`F-SET-007`).
      *Deferred with `F-SET-007` in Phase 2; nothing here precludes it, and the
      steppers it applies to do not exist until `F-LOG-006`.*

## Implementation

Foundation complete (batch 0.2), **screen outstanding**:

- `lib/core/units/` — `Mass` (grams), `Length` (mm), `Distance` (m),
  `UnitPreferences`. Pure Dart, integer-backed, enforced by
  `tools/check-layers.sh`.
- `lib/core/formatting/` — `QuantityFormatter`, `QuantityParser` (`F-I18N-002`).
- `lib/features/settings/application/unit_preferences_provider.dart` —
  persistence and the reactive binding.
- `lib/features/settings/presentation/units_screen.dart` — the screen, landed
  in batch 0.4 once the shell existed. Carries a live preview so the
  display-only claim is visible rather than taken on trust.

---

## Why

Explicitly required, and structurally load-bearing. See
[`../22-UNITS.md`](../../22-UNITS.md) for the full rules.
