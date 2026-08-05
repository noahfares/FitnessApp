# F-REL-003 — GitHub Release automation

Status: planned | Priority: P1 | Phase: 1
Depends on: F-REL-002
Reads: 62-RELEASE, 61-CI-CD

## Spec

Attach the signed APK to a GitHub Release with generated release notes and the
APK's SHA-256 checksum. The checksum matters: sideloaded APKs have no store to
vouch for them, so a published hash is the only integrity signal a user gets.
