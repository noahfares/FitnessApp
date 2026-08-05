# F-REL-005 — Versioning scheme

Status: planned | Priority: P1 | Phase: 1
Reads: 62-RELEASE, 61-CI-CD

## Spec

Semantic version plus a monotonically increasing build number, derived from the
tag and never hand-edited. Play rejects a reused build number, and hand-managed
numbers are how that happens. Version and build are shown in About (`F-SET-009`).
