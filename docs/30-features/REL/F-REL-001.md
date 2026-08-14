# F-REL-001 — CI build and checks

Status: done | Priority: P0 | Phase: 0
Blocks: F-REL-002
Reads: 62-RELEASE, 61-CI-CD

## Spec
1. Triggered manually via `workflow_dispatch` — not automatically on every
   push (changed in v0.48.5; ran on every push through v0.48.4, which burned
   Actions minutes and artifact storage on every commit). Runs
   `flutter analyze`, `flutter test`, and a debug APK build on demand: end of
   a phase, before on-device manual testing, or whenever explicitly asked
   for. `tools/verify.sh` covers the everyday per-commit case locally.
2. The layer rule from [`../20-ARCHITECTURE.md`](../../20-ARCHITECTURE.md) —
   `domain/` importing nothing from Flutter — is enforced here, not by good
   intentions.
3. Debug APK uploaded as a build artefact so any on-demand run is installable.

## Acceptance
- [x] A `domain/` file importing Flutter fails CI. `tools/check-layers.sh` exits
      1 on a Flutter import, a `lib/data/` import, and — since v0.5.0 — on a
      *transitive* one reached through `lib/core/`. CI runs it as a required
      step, so a non-zero exit fails the build.
- [x] Build and test complete in a reasonable time on the free runner tier.
      **Observed: 7m26s total** — 2m05s analyse & test, 5m14s APK. The three
      toolchain-free checks finish in 3s, before Flutter setup begins.
- [x] `flutter build apk --debug` succeeds. **Verified in CI**, artefact
      uploaded. Still unverifiable locally — no Android SDK in the dev sandbox.

## Implementation

- `.github/workflows/ci.yml` — two jobs. `check` runs the cheap toolchain-free
  checks first (docs integrity, layer rule, version consistency) so a docs
  mistake fails in seconds rather than after Flutter setup, then format,
  analyse, test. `apk` builds the debug APK and uploads it as an artefact.
- `tools/check-layers.sh` — the layer rule, greppable and exit-coded.
- Uses no secrets, so it runs correctly on a fork.
