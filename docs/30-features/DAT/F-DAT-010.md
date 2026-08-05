# F-DAT-010 — Wipe all data

Status: planned | Priority: P2 | Phase: 5
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

## Spec

Delete everything and return to first-run state. Required for a credible privacy
posture, and needed for testing. Requires typed confirmation and offers a backup
first.

Also the home for **tombstone purge**: soft deletes mean nothing is ever removed
([ADR-0008](../../70-decisions/ADR-0008-sync-ready-foundations.md)), so a
maintenance action to permanently drop rows tombstoned before a given date
belongs here. Not urgent — a multi-year history is tens of thousands of rows —
but it should exist before anyone accumulates a decade of data.
