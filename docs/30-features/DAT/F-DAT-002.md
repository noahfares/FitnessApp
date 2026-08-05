# F-DAT-002 — CSV export

Status: planned | Priority: P1 | Phase: 5
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

## Spec
1. One row per set, denormalised with workout date, exercise name, set type,
   weight, reps, RPE.
2. Uses the **display** unit, with the unit named in the column header
   (`weight_kg`), because a spreadsheet has no other place to carry that context.
3. Clearly labelled as lossy and not the backup format — that's `F-DAT-001`.
4. Separate CSVs for measurements and for routines.

---

## Why

For humans and spreadsheets, not for backup. People want to do their
own analysis, and CSV is where that happens.
