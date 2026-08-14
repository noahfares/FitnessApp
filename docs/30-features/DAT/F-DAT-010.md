# F-DAT-010 — Wipe all data

Status: done | Priority: P2 | Phase: 5
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

---

## Status note (batch 5.1)

`TableSnapshotIo.deleteAllRows()` and `.purgeTombstonesBefore(cutoff)`
(`lib/data/db/table_snapshot_io.dart`), shared with restore's delete step.
Wipe is a hard delete — the one deliberate exception to "nothing is ever
hard-deleted" (ADR-0008), a user-initiated full reset rather than a normal
delete path. Settings › Data gates it behind typing "DELETE" (stronger than
the shared `ConfirmSheet`, since this destroys strictly more than any other
destructive action in the app) and always takes a backup first. Tombstone
purge has the domain method but no settings UI yet — genuinely not urgent
per this feature's own spec, and no database in this codebase is old enough
for it to matter.
