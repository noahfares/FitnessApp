# F-DAT-006 — Hevy CSV import

Status: done | Priority: P2 | Phase: 5
Depends on: F-DAT-005
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

## Spec

Same machinery as `F-DAT-005` with a different column mapping. Build the importer
as a shared pipeline with pluggable format adapters, so a third format is a
mapping file rather than a new feature.

---

## Status note (batch 5.3)

Exactly the spec's own ask: `hevyColumnMapping` is a second `ColumnMapping`
value (`domain/import/csv_import_adapter.dart`) — no new parsing code, no
new service. `CsvImportAdapter`'s single engine reads Hevy's `snake_case`,
unit-suffixed headers (`weight_kg`, `exercise_title`, `set_type`) the same
way it reads Strong's, since column matching is header-name-driven rather
than format-specific. `ImportScreen` tries Strong's mapping before Hevy's on
an unrecognised file — matching `F-DAT-005`'s own P1-before-P2 priority, not
a meaningful detection order otherwise.
