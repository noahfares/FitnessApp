# F-DAT-002 — CSV export

Status: done | Priority: P1 | Phase: 5
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

---

## Status note (batch 5.2)

`lib/data/io/csv_export_service.dart`, on top of new one-shot export queries
(`SetRepository.getSetsForExport`, `RoutineRepository.getAllForExport`,
`BodyMeasurementRepository.getAllForExport`) and a dependency-free
`csv_writer.dart` RFC 4180 encoder. Three separate CSVs (§4), each header
naming its column's unit (§2) via `UnitPreferences`. Settings › Data's
"Export data (.csv)" shares all three in one action
(`ExportSharer.shareAll`, new alongside the existing single-file `share`).
Measurements are one CSV across every `MeasurementType` rather than one file
per type — §4 only requires separation *from* sets and routines, not from
each other, and a dozen near-empty files would be worse for the exact
spreadsheet use case this exists for.
