# F-BOD-004 — Progress photos

Status: planned | Priority: P2 | Phase: 5
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
