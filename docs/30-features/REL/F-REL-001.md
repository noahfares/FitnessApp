# F-REL-001 — CI build and checks

Status: in-progress | Priority: P0 | Phase: 0
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
- [ ] A `domain/` file importing Flutter fails CI. *`tools/check-layers.sh`
      verified locally against a deliberate violation — exits 1 on both a Flutter
      import and a `lib/data/` import. Not yet observed failing a real CI run.*
- [ ] Build and test complete in a reasonable time on the free runner tier.
- [ ] `flutter build apk --debug` succeeds. *Unverified locally — no Android SDK
      in the development sandbox. CI is the first real check.*

## Implementation

- `.github/workflows/ci.yml` — two jobs. `check` runs the cheap toolchain-free
  checks first (docs integrity, layer rule, version consistency) so a docs
  mistake fails in seconds rather than after Flutter setup, then format,
  analyse, test. `apk` builds the debug APK and uploads it as an artefact.
- `tools/check-layers.sh` — the layer rule, greppable and exit-coded.
- Uses no secrets, so it runs correctly on a fork.
