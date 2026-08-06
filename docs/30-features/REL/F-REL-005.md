# F-REL-005 — Versioning scheme

Status: done | Priority: P1 | Phase: 1
Reads: 62-RELEASE, 61-CI-CD

## Spec

Semantic version plus a monotonically increasing build number, derived from the
tag and never hand-edited. Play rejects a reused build number, and hand-managed
numbers are how that happens. Version and build are shown in About (`F-SET-009`).

## Implementation

`release.yml` passes `--build-name=$(cat VERSION)` and
`--build-number=$(git rev-list --count HEAD)` to `flutter build apk`. Commit
count only grows, so it satisfies "monotonic" and is derived rather than
hand-picked; the version name is the same `VERSION` file every other check
already agrees against. Android bakes both into the installed package
(`versionName`/`versionCode` in `android/app/build.gradle.kts`, unchanged —
they already read `flutter.versionName`/`flutter.versionCode`). `AboutScreen`
reads them back via `package_info_plus` (`lib/data/platform/app_info_service.dart`)
rather than restating a constant, which is what makes them trustworthy as the
one diagnostic a bug report can carry (ADR-0002).
