# F-ROU-002 — Routine days

Status: done | Priority: P0 | Phase: 2
Depends on: F-ROU-001
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot
Data: `routine_days`

## Spec
1. A routine contains ordered, named days ("Push", "Pull", "Legs").
2. Days are added, renamed, reordered, and deleted independently.
3. A workout is started from a *day*, never from a routine.
4. A single-day routine is legitimate and shouldn't feel bureaucratic — the UI
   collapses the day layer when there's only one.

## Acceptance
- [x] A three-day PPL routine is creatable and each day independently startable.
- [x] Single-day routines don't force the user through an extra navigation level.

---

## Why

Programs are multi-day. PPL has three days, upper/lower has two,
5/3/1 has four. Modelling the routine as a flat exercise list would force one
routine per day and lose the grouping that makes a program a program.
