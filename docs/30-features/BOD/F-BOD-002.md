# F-BOD-002 — Circumference measurements

Status: planned | Priority: P2 | Phase: 4
Reads: 21-DATA-MODEL#body_measurements, 22-UNITS
Data: `body_measurements`

## Spec

Waist, chest, hips, neck, arms, thighs, calves, shoulders, plus body-fat
percentage. Left and right tracked separately for limbs, since asymmetry is
worth seeing. Stored in millimetres, displayed in centimetres or inches
(`F-SET-001`). Users choose which measurements to track — showing all thirteen
by default is clutter.
