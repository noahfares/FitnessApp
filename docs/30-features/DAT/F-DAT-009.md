# F-DAT-009 — File-based cloud sync

Status: idea | Priority: P2 | Phase: —
Depends on: F-DAT-003
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

Sync the backup blob through the OS-provided cloud storage — Google Drive,
iCloud Drive, Nextcloud — with no server of our own
([ADR-0002](../../70-decisions/ADR-0002-local-first.md)).

## Open questions

This is last-write-wins on a whole-database blob, so
concurrent edits on two devices lose data. Acceptable for
one-device-plus-a-backup, not for genuine multi-device use. True merge (CRDT or
per-row LWW) is a large project and should only be started if steps 1–3 of the
sync sequence in `10-VISION.md` prove insufficient in practice.
