# F-TIM-007 — Rest-taken recording

Status: done | Priority: P2 | Phase: 2
Reads: 20-ARCHITECTURE#cross-platform-discipline
Data: `sets.rest_taken_seconds`

## Spec

Record actual elapsed rest before each set, derived from the previous set's
`completed_at`. Feeds rest-compliance analytics (`F-ANA-012`) — useful because
rest duration materially affects performance, and drifting rest times explain a
lot of apparent plateaus.

## Status notes

No schema change — `sets.rest_taken_seconds` has existed since schema v3.
`SetRepository.complete()` now looks up the most recent *other* completed
set in the same **session** (not the same exercise — rest is scoped to the
session the same way the rest timer itself already is, `F-TIM-002`, so a
superset partner's set correctly counts as "the previous one") and stores
the gap in seconds; a session's first completion has nothing to have rested
from, so it stores null rather than zero. `uncomplete()` clears it alongside
`completed_at`, for the same reason that field is cleared: a rest duration
with no completion to anchor it to is orphaned data. This value is
deliberately the *actual* elapsed time, not the timer's target — `F-ANA-012`
(Phase 4) is what reads it, and nothing displays it yet.
