# F-LOG-014 — RPE and RIR

Status: done | Priority: P1 | Phase: 2
Blocks: F-PRG-005
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory
Data: `sets.rpe`

## Spec
1. Optional RPE per set, 6.0–10.0 in 0.5 steps.
2. A setting toggles between RPE and RIR display; stored canonically as RPE
   (`RIR = 10 − RPE`).
3. Hidden entirely when disabled — most users don't want it, and the set row has
   no room to spare.
4. Feeds autoregulated progression (`F-PRG-005`) and intensity analytics
   (`F-ANA-011`).

## Status

`sets.rpe` has existed since schema v1 — this batch is the first to read or
write it. `lib/domain/logging/rpe.dart` holds the pure conversion
(`rpeToRir`, `displayRpe`) and the nine fixed steps; `RpeSettingsNotifier`
persists `enabled`/`displayMode` the same way `RestTimerSettingsNotifier`
does, off by default (§3). The set row's RPE cell sits beside the note
button — a fixed-width badge, not one of the value columns, shown only when
the setting is on — and opens `RpeSheet`, a grid of the nine steps modelled
on `SetTypeSheet`. Options are always ordered easiest-to-hardest by
canonical RPE regardless of display mode, so a value near the top of the
sheet always means "went easier" whichever scale is showing; the sheet's own
subtitle text says which direction is harder for whichever mode is active,
since RIR's "lower is harder" reads backwards next to RPE's "higher is
harder" without it.

Deliberately no dedicated settings screen or route — two settings (a bool and
a two-value scale) fit inline on the settings root as a `SwitchListTile` plus
a conditional `RadioGroup`, and a separate screen for that little content
would be structure exceeding what it holds.

Not built: RPE does not appear anywhere outside the active-workout set row —
not on the history or edit-past-workout screens, and not yet feeding
`F-PRG-005` or `F-ANA-011`, both still `planned`. `sets.rpe` is there for them
to read whenever they land.
