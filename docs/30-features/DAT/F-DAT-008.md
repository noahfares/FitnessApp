# F-DAT-008 — Automatic local backups

Status: done | Priority: P2 | Phase: 5
Depends on: F-DAT-003
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

## Spec

Periodic automatic backup to app storage with a rotating retention window. Cheap
insurance against user error — deleting the wrong workout, a bad import, a
migration bug.

---

## Status note (batch 5.2)

`BackupService.maybeCreateAutomaticBackup()`, called fire-and-forget from
`main()` on every launch: writes a new `fitnessapp-autobackup-*` file only
if the newest one is older than 24 hours, then prunes to the 7 most recent —
the rotating retention window. Kept in its own filename namespace, separate
from `createBackup()`'s manual/pre-restore output, so rotation never deletes
either. Not built: a true OS-level scheduled background job — this runs on
app launch only, the same scope this codebase already drew for `F-TIM-003`'s
background timer and for the same reason (no Android SDK in this session's
toolchain to build or verify platform-channel work against). An app opened
regularly gets backups regularly; one left untouched for a week does not
get backed up until it's next opened.
