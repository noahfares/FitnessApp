# F-BOD-004 — Progress photos

Status: done | Priority: P2 | Phase: 5
Reads: 21-DATA-MODEL#body_measurements, 22-UNITS

## Spec
1. Photos stored in app-private storage. **Never uploaded, never leave the
   device**, and excluded from any future cloud sync unless explicitly opted in.
2. Date-tagged, side-by-side comparison view.
3. Included in local backups (`F-DAT-003`) only with explicit consent, since it
   changes the backup's sensitivity profile entirely.
4. Optional biometric lock (`F-SET-010`).

## Open questions

Backup handling is genuinely tricky: silently including
photos in a backup file the user then emails to themselves would be a serious
privacy failure. Default to excluding them, with a clear opt-in.

---

## Why

The most useful body-composition record there is, and the most
sensitive data the app would ever hold.

---

## Status note (batch 5.4)

Schema v7 adds `progress_photos` (`id`/`taken_at`/`taken_at_tz_offset_minutes`/
`file_path`/`notes`, plus the universal `SyncColumns`). `ProgressPhotoRepository`
copies a picked file into an app-private `photos/` subdirectory
(`getApplicationSupportDirectory`); the database row only ever holds a
relative path (§1). §3's default (exclude photos from backup) is met **by
construction**, not by a filter that could be forgotten: `JsonExportService`/
`JsonDumpService` dump DB tables only, and a photo's bytes never enter either
one. The opt-in half of §3 — bundling photos into a backup on request — is
**not built**: today's backup is a single JSON file, and base64-encoding
photo bytes into it would defeat `F-DAT-001`'s own streaming acceptance
criterion; a real archive format is the honest way to do this and is
deferred, not silently dropped. One consequence of restoring a backup onto a
fresh device: photo rows survive (they're ordinary DB rows) but their files
don't, leaving dangling paths — `ProgressPhotosScreen` renders a blank tile
rather than crashing, but this is a real, documented gap, not a bug to
"discover" later. Deleting a photo tombstones the row *and* deletes the file
— the second deliberate exception to "nothing is ever hard-deleted"
(ADR-0008) this codebase has made, alongside `F-DAT-010`'s wipe, because a
"deleted" photo still sitting on disk is wrong for the most sensitive data
the app holds. §4 (lock) is `F-SET-010`, PIN only — see its own status note.
