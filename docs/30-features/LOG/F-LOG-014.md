# F-LOG-014 — RPE and RIR

Status: planned | Priority: P1 | Phase: 2
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
