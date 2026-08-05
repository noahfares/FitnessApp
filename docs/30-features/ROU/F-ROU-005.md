# F-ROU-005 — Supersets and circuits

Status: planned | Priority: P1 | Phase: 2
Blocks: F-LOG-015
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot
Data: `routine_exercises.superset_group`

## Spec
1. Two or more adjacent exercises can be grouped into a superset.
2. Grouping is visually explicit in both editor and logger.
3. Rest configuration: within-group rest (often zero) and after-group rest.
4. Ungrouping is a single action and never loses logged data.

## Open questions

Are circuits (3+ exercises, multiple rounds) the same
concept as a superset, or a distinct one with its own round counter? Treating
them as the same is simpler; decide before implementing.
