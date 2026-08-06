# F-REL-003 — GitHub Release automation

Status: done | Priority: P1 | Phase: 1
Depends on: F-REL-002
Reads: 62-RELEASE, 61-CI-CD

## Spec

Attach the signed APK to a GitHub Release with generated release notes and the
APK's SHA-256 checksum. The checksum matters: sideloaded APKs have no store to
vouch for them, so a published hash is the only integrity signal a user gets.

## Implementation

Same `release.yml` job as `F-REL-002`. After the split-per-ABI APKs build,
`sha256sum *.apk > checksums.txt` runs alongside them, then
`softprops/action-gh-release` creates the release with
`generate_release_notes: true` and attaches every APK plus `checksums.txt`.
