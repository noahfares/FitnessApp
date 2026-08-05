# F-PRG-009 — Failure and deload handling

Status: planned | Priority: P1 | Phase: 4
Depends on: F-PRG-002
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec

Detect repeated failure and apply the rule's deload. Explicitly surfaced rather
than silent — the user must know a deload happened and why, or the app looks
broken.
