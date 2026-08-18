# F-REL-004 — App bundle for Play

Status: done | Priority: P1 | Phase: 6
Depends on: F-REL-002
Reads: 62-RELEASE, 61-CI-CD

## Spec

Build an AAB alongside the APK for Play submission. Both come from the same tag
and the same version, so the GitHub build and the store build are never a
mystery apart.

## Implementation

`release.yml` builds `flutter build appbundle --release` alongside the
`--split-per-abi` APKs, from the same tag, the same commit, the same
`--build-name`/`--build-number` and the same upload keystore, and attaches the
`.aab` to the GitHub Release with its SHA-256 beside the APKs'. That sameness
is the whole requirement: a store build produced by a separate process is one
nobody can reconcile with the GitHub build when the two behave differently.

Not verified by a real run — this session had no Android SDK, and the workflow
only fires on a tag. The first tagged release after this commit is the check.
