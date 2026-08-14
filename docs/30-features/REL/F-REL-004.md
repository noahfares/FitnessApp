# F-REL-004 — App bundle for Play

Status: done | Priority: P1 | Phase: 6
Depends on: F-REL-002
Reads: 62-RELEASE, 61-CI-CD

## Spec

Build an AAB alongside the APK for Play submission. Both come from the same tag
and the same version, so the GitHub build and the store build are never a
mystery apart.

## Status note

`.github/workflows/release.yml` gains a `flutter build appbundle --release`
step alongside the existing `flutter build apk --release --split-per-abi`
one — same `--build-name`/`--build-number` derived from the same tag
(`F-REL-005`), same signing env vars, and no separate signing setup needed:
Gradle ties a release signing config to the build *variant*
(`android/app/build.gradle.kts`'s `release { }` block), not to which
packaging task runs, so `bundleRelease` picks up exactly the same keystore
`assembleRelease` does. The AAB (`build/app/outputs/bundle/release/*.aab`)
is attached to the GitHub Release alongside the APKs, with SHA-256 checksums
for both artefact types combined into one `checksums.txt` — GitHub release
assets need unique filenames, and one manifest matches the spec's own "never
a mystery apart" framing better than two identically named files would.
This workflow does **not** upload anything to Play — that needs a live
Console this session has no credentials for, so `F-REL-004` ends at
"produces the exact file Play submission needs," not at submission itself.
Not locally build-verified: this session's toolchain has no Android SDK, the
same constraint every other CI-only release feature (`F-REL-002`,
`F-REL-003`, `F-REL-005`) has carried since Phase 1 — verified instead by a
straight read of the Gradle signing-config scoping and a YAML syntax check.
