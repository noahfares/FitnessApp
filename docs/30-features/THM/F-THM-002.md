# F-THM-002 — Light and dark schemes

Status: done | Priority: P0 | Phase: 0
Depends on: F-THM-001
Reads: 24-DESIGN-SYSTEM, 30-features/LOG/F-LOG-004

Explicitly required. Both schemes are designed as equals and checked in every
review, not one derived from the other by inversion. Dark mode uses M3 surface
tints for elevation and avoids pure black to prevent OLED smearing during scroll.

The `ghost` role (`F-LOG-004`) is the hardest single colour decision in the app:
too faint and it's invisible under gym lighting, too strong and users mistake it
for entered data. Needs testing on a real phone in a real gym, not in a simulator.

## Acceptance
- [ ] Every screen is checked in both schemes before its feature is done.
- [ ] 4.5:1 text contrast in both (`F-A11Y-003`).
