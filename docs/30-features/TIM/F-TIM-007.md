# F-TIM-007 — Rest-taken recording

Status: planned | Priority: P2 | Phase: 2
Reads: 20-ARCHITECTURE#cross-platform-discipline
Data: `sets.rest_taken_seconds`

## Spec

Record actual elapsed rest before each set, derived from the previous set's
`completed_at`. Feeds rest-compliance analytics (`F-ANA-012`) — useful because
rest duration materially affects performance, and drifting rest times explain a
lot of apparent plateaus.
