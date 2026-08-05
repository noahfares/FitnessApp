# F-DAT-011 — Minimal JSON dump

Status: planned | Priority: P0 | Phase: 1
Blocks: F-DAT-001
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

## Spec
1. Serialise every table, every column, including tombstoned rows, to a single
   JSON file.
2. Canonical units, raw column names, no transformation. Fidelity to the
   database beats readability — this is a rescue artefact.
3. Includes the schema version and the app version (`VERSION`).
4. Saved or shared via the system share sheet.
5. No import counterpart. Reading it back in Phase 1 is a manual, one-off
   operation; `F-DAT-004` is the real restore.

## Acceptance
- [ ] Exists and works from the first commit that creates the database.
- [ ] Output round-trips through `jq` without error, and every table appears
      even when empty.
- [ ] Dumping a multi-year database does not exhaust memory — stream, don't
      build the whole string.

## Edge cases

Dump taken mid-workout (include the in-progress session, it's
just rows). Dump on a schema version the reader doesn't recognise — the embedded
version is what makes that diagnosable.

---

## Why

Insurance, not a feature. The schema will change weekly through
Phases 0–2, and a migration bug discovered after real training data exists is
the worst failure mode available. A one-button "dump every table to a file"
utility means any schema mistake is survivable: dump, fix, reimport by hand if
necessary.

This is deliberately **not** the full export (`F-DAT-001`, Phase 5). That one is
a designed, versioned, round-trip-guaranteed format. This one is a debug tool
that has to exist from the moment the database does.
