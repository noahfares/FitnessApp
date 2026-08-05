# F-DAT-006 — Hevy CSV import

Status: planned | Priority: P2 | Phase: 5
Depends on: F-DAT-005
Reads: 21-DATA-MODEL, 22-UNITS#import-and-export

## Spec

Same machinery as `F-DAT-005` with a different column mapping. Build the importer
as a shared pipeline with pluggable format adapters, so a third format is a
mapping file rather than a new feature.
