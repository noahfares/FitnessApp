# Data portability — `DAT`

Principle 2 in [`../10-VISION.md`](../10-VISION.md): the data is yours. This is
where that stops being a slogan. It's also the safety net for the signing-
migration risk ([ADR-0007](../70-decisions/ADR-0007-signing.md)) — if a user ever
has to uninstall and reinstall, working export/import is the difference between
an inconvenience and losing years of training history.

Unit handling in export and import is specified in
[`../22-UNITS.md`](../22-UNITS.md) and is the easiest thing in this domain to get
catastrophically wrong.

---

### F-DAT-001 — JSON export
Status: planned | Priority: P0 | Phase: 5
Blocks: F-DAT-003, F-ROU-014

**Intent** — The full-fidelity, lossless representation. The format that proves
the data isn't hostage.

**Behaviour**
1. Exports everything: exercises, routines, workouts, sets, measurements,
   settings, plate inventory.
2. **Canonical units only**, with an explicit `"units": "canonical-v1"` marker
   naming grams, metres and seconds. Never the display unit — a file whose
   meaning depends on a setting is a data-loss bug.
3. Carries a schema version, exported at a version the importer can check.
4. Stable UUIDs throughout, so a round-trip is genuinely idempotent.
5. Shared via the system share sheet or saved to a chosen location.

**Acceptance criteria**
- [ ] Export → wipe → import reproduces the database exactly, verified by
      comparing every table.
- [ ] Format is documented well enough for a third party to write a parser.
- [ ] A multi-year database exports without running out of memory — stream, don't
      build the whole string.

---

### F-DAT-002 — CSV export
Status: planned | Priority: P1 | Phase: 5

**Intent** — For humans and spreadsheets, not for backup. People want to do their
own analysis, and CSV is where that happens.

**Behaviour**
1. One row per set, denormalised with workout date, exercise name, set type,
   weight, reps, RPE.
2. Uses the **display** unit, with the unit named in the column header
   (`weight_kg`), because a spreadsheet has no other place to carry that context.
3. Clearly labelled as lossy and not the backup format — that's `F-DAT-001`.
4. Separate CSVs for measurements and for routines.

---

### F-DAT-003 — Backup file
Status: planned | Priority: P0 | Phase: 5
Depends on: F-DAT-001

Single-file backup of the entire database, with optional passphrase encryption.
Includes progress photos only with explicit consent (`F-BOD-004`). Timestamped
filename. This is the artefact a user keeps.

---

### F-DAT-004 — Restore
Status: planned | Priority: P0 | Phase: 5
Depends on: F-DAT-003

**Behaviour**
1. Restore from a backup file, replacing all current data after explicit
   confirmation naming what will be lost.
2. Version-checked; a newer backup on an older app version is refused clearly
   rather than partially applied.
3. Restore is transactional — it either fully succeeds or leaves the existing
   database untouched.
4. An automatic pre-restore backup is taken first.

**Acceptance criteria**
- [ ] A failed or interrupted restore never leaves a half-populated database.
- [ ] Restoring onto a device with existing data is unambiguous about the outcome.

---

### F-DAT-005 — Strong CSV import
Status: planned | Priority: P1 | Phase: 5
Blocks: F-CAT-010

**Intent** — Removes the switching cost. Anyone with years of Strong history can
move without abandoning it, which is the difference between "interesting project"
and "app I can actually use".

**Behaviour**
1. Parse Strong's CSV export into workouts, exercises and sets.
2. Map source exercise names onto catalogue entries; unmatched names create
   custom exercises or prompt for mapping (`F-DAT-007`).
3. **Determine the source unit explicitly.** If it cannot be established with
   certainty from the file, ask. Never guess — a silently mis-imported history
   is worse than a failed import.
4. Preview before committing: counts of workouts, sets, and unmatched exercises.
5. Idempotent — re-importing the same file doesn't duplicate.

**Acceptance criteria**
- [ ] A real export imports with correct dates, weights and set types.
- [ ] Ambiguous units halt and ask rather than assuming.
- [ ] Warm-up set information is preserved where the source records it.

**Open questions** — Strong's export format has varied across versions. Support
detection of multiple layouts, and fail loudly on an unrecognised one.

---

### F-DAT-006 — Hevy CSV import
Status: planned | Priority: P2 | Phase: 5
Depends on: F-DAT-005

Same machinery as `F-DAT-005` with a different column mapping. Build the importer
as a shared pipeline with pluggable format adapters, so a third format is a
mapping file rather than a new feature.

---

### F-DAT-007 — Import mapping UI
Status: planned | Priority: P1 | Phase: 5
Depends on: F-DAT-005

Resolve unmatched exercise names: map to an existing exercise, create a custom
one, or skip. Remembers decisions across a session so a 400-row import isn't 400
prompts. This screen is most of what makes an import feel trustworthy.

---

### F-DAT-008 — Automatic local backups
Status: planned | Priority: P2 | Phase: 5
Depends on: F-DAT-003

Periodic automatic backup to app storage with a rotating retention window. Cheap
insurance against user error — deleting the wrong workout, a bad import, a
migration bug.

---

### F-DAT-009 — File-based cloud sync
Status: idea | Priority: P2 | Phase: —
Depends on: F-DAT-003

Sync the backup blob through the OS-provided cloud storage — Google Drive,
iCloud Drive, Nextcloud — with no server of our own
([ADR-0002](../70-decisions/ADR-0002-local-first.md)).

**Open questions** — This is last-write-wins on a whole-database blob, so
concurrent edits on two devices lose data. Acceptable for
one-device-plus-a-backup, not for genuine multi-device use. True merge (CRDT or
per-row LWW) is a large project and should only be started if steps 1–3 of the
sync sequence in `10-VISION.md` prove insufficient in practice.

---

### F-DAT-010 — Wipe all data
Status: planned | Priority: P2 | Phase: 5

Delete everything and return to first-run state. Required for a credible privacy
posture, and needed for testing. Requires typed confirmation and offers a backup
first.

Also the home for **tombstone purge**: soft deletes mean nothing is ever removed
([ADR-0008](../70-decisions/ADR-0008-sync-ready-foundations.md)), so a
maintenance action to permanently drop rows tombstoned before a given date
belongs here. Not urgent — a multi-year history is tens of thousands of rows —
but it should exist before anyone accumulates a decade of data.

---

### F-DAT-011 — Minimal JSON dump
Status: planned | Priority: P0 | Phase: 1
Blocks: F-DAT-001

**Intent** — Insurance, not a feature. The schema will change weekly through
Phases 0–2, and a migration bug discovered after real training data exists is
the worst failure mode available. A one-button "dump every table to a file"
utility means any schema mistake is survivable: dump, fix, reimport by hand if
necessary.

This is deliberately **not** the full export (`F-DAT-001`, Phase 5). That one is
a designed, versioned, round-trip-guaranteed format. This one is a debug tool
that has to exist from the moment the database does.

**Behaviour**
1. Serialise every table, every column, including tombstoned rows, to a single
   JSON file.
2. Canonical units, raw column names, no transformation. Fidelity to the
   database beats readability — this is a rescue artefact.
3. Includes the schema version and the app version (`VERSION`).
4. Saved or shared via the system share sheet.
5. No import counterpart. Reading it back in Phase 1 is a manual, one-off
   operation; `F-DAT-004` is the real restore.

**Acceptance criteria**
- [ ] Exists and works from the first commit that creates the database.
- [ ] Output round-trips through `jq` without error, and every table appears
      even when empty.
- [ ] Dumping a multi-year database does not exhaust memory — stream, don't
      build the whole string.

**Edge cases** — Dump taken mid-workout (include the in-progress session, it's
just rows). Dump on a schema version the reader doesn't recognise — the embedded
version is what makes that diagnosable.
