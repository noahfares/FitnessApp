# F-ROU-012 — Scheduling

Status: planned | Priority: P2 | Phase: 3
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot
Data: `routine_days.scheduled_weekdays`

Assign days to weekdays so the dashboard can show "today: Push" and consistency
analytics can measure adherence against a plan rather than just counting
sessions. Optional — plenty of people train on a rolling rotation.

## Open questions

Fixed weekdays or a rolling rotation ("day 3 of 6")? Both
are common. Probably needs to support both, which makes the model non-trivial.
