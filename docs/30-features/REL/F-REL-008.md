# F-REL-008 — Update check for sideloaded installs

Status: idea | Priority: P2 | Phase: —
Reads: 62-RELEASE, 61-CI-CD

APK users get no automatic updates. An optional check against the GitHub
releases API would notify them of a new version.

## Open questions

This would be the app's only network call, contradicting the
"no network" claim in `F-REL-007`. If built, it must be strictly opt-in, clearly
disclosed, and disabled in store builds where the store handles updates.
