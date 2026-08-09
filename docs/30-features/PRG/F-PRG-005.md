# F-PRG-005 — RPE-autoregulated

Status: done | Priority: P2 | Phase: 4
Depends on: F-LOG-014
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec

Adjust load from the gap between last session's recorded RPE and the target RPE —
came in under target, go up more; over, go up less or back off. Handles good and
bad days better than any fixed scheme, which is the entire argument for RPE.
Requires RPE data, so it degrades to `F-PRG-002` when RPE is absent.
