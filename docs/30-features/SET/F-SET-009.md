# F-SET-009 — About

Status: in-progress | Priority: P1 | Phase: 1
Reads: 22-UNITS

## Spec

Version and build number, open-source licences, link to the repository, and a
plain statement of the privacy position: no account, no telemetry, no network
calls. Required for a store listing, and it's the page that demonstrates the
project's claims.

## Implementation

Started in batch 0.4: `about_screen.dart` shows the version and the privacy
position. The version is checked against `VERSION` by `tools/check-docs.sh`,
because with no telemetry or crash reporting it is the only diagnostic context
a bug report can carry.

Remaining for Phase 1: open-source licences, repository link, and reading the
build number from the package rather than a constant (`F-REL-005`).
