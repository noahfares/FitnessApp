# F-DAT-001 — JSON export

Status: planned | Priority: P0 | Phase: 5
Blocks: F-DAT-003, F-ROU-014
Reads: 22-UNITS#import-and-export, 21-DATA-MODEL

## Spec
1. Exports everything: exercises, routines, workouts, sets, measurements,
   settings, plate inventory.
2. **Canonical units only**, with an explicit `"units": "canonical-v1"` marker
   naming grams, metres and seconds. Never the display unit — a file whose
   meaning depends on a setting is a data-loss bug.
3. Carries a schema version, exported at a version the importer can check.
4. Stable UUIDs throughout, so a round-trip is genuinely idempotent.
5. Shared via the system share sheet or saved to a chosen location.

## Acceptance
- [ ] Export → wipe → import reproduces the database exactly, verified by
      comparing every table.
- [ ] Format is documented well enough for a third party to write a parser.
- [ ] A multi-year database exports without running out of memory — stream, don't
      build the whole string.

---

## Why

The full-fidelity, lossless representation. The format that proves
the data isn't hostage.
