# F-SET-009 — About

Status: done | Priority: P1 | Phase: 1
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

Batch 1.9 completed it: the version line now reads `<version> (build <build>)`
from `package_info_plus` (via `AppInfoService`, faked in widget tests) instead
of a constant; "Open-source licences" opens Flutter's built-in `LicensePage`;
"Source code" links to the repository via `url_launcher` — not a network call
from the app itself, just handing a URL to the user's own browser
(ADR-0002).
