# F-LOG-012 — Workout detail

Status: done | Priority: P0 | Phase: 1
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory
Screens: Workout Detail

## Spec
1. Full session: every exercise, every set, notes, duration, total volume.
2. PRs achieved are marked inline.
3. Actions: edit (`F-LOG-009`), delete, repeat as a new workout (`F-LOG-016`),
   save as a routine (`F-ROU-001`).

§2 arrives with `F-LOG-013`, and §3's last two actions with `F-LOG-016` and
`F-ROU-001` — all three are Phase 2. Building them now would start Phase 2
before Phase 1's exit criteria are met (`docs/50-ROADMAP.md`); edit and delete
are the Phase 1 actions and are what ships here.
