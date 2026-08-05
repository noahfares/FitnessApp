# F-REL-001 — CI build and checks

Status: planned | Priority: P0 | Phase: 0
Blocks: F-REL-002
Reads: 62-RELEASE, 61-CI-CD

## Spec
1. On every push and pull request: `flutter analyze`, `flutter test`, and a debug
   APK build.
2. The layer rule from [`../20-ARCHITECTURE.md`](../../20-ARCHITECTURE.md) —
   `domain/` importing nothing from Flutter — is enforced here, not by good
   intentions.
3. Debug APK uploaded as a build artefact so any commit is installable.
4. Red CI blocks merge.

## Acceptance
- [ ] A `domain/` file importing Flutter fails CI.
- [ ] Build and test complete in a reasonable time on the free runner tier.
