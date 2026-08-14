# CI / CD

GitHub Actions. Features `F-REL-001` through `F-REL-005`.

Two workflows, deliberately: one that runs constantly and must stay fast, and one
that runs on tags and must be exactly right.

---

## `ci.yml` — every push

Runs on every push to any branch. Deliberately **not** also on `pull_request`:
for a same-repo PR (the only kind this solo project has), the PR's head is a
branch push, so a `pull_request` trigger alongside `push` would just run CI
twice for the same commit. GitHub attaches a push-triggered run to a PR's
checks by commit SHA regardless of which event triggered it, so push-only
loses nothing here. Reconsider if the project ever takes fork contributions
(`F-REL-010`), since a fork's push doesn't reach this repo — only its PR does.

Also carries `workflow_dispatch`, so a push that GitHub never turns into a run
(seen in practice when the account's Actions spending limit is exhausted —
the run object is never created at all, not even queued) can be fired
manually for the current head of any branch without an empty commit.

**Steps**

1. Checkout.
2. Set up Flutter (pinned stable version, cached).
3. `flutter pub get` (pub cache keyed on `pubspec.lock`).
4. `dart run build_runner build --delete-conflicting-outputs`.
5. `dart format --set-exit-if-changed .`
6. `flutter analyze --fatal-infos`
7. **Layer rule check** — fail if anything in `lib/domain/` imports Flutter or
   `lib/data/`. This is the enforcement point for the central architectural
   invariant, so it is a required check, not advisory:
   ```bash
   ! grep -rE "^import 'package:flutter/|^import 'package:.*/data/" lib/domain/
   ```
   (Replaced by a proper `import_lint` rule once one is configured.)
8. **Version consistency check** — `VERSION`, `pubspec.yaml`'s `version:` field,
   and (on a tag build) the tag itself must all agree. Required check, because
   a mismatch silently produces a build that misreports itself in About
   (`F-SET-009`) — the only diagnostic context this app has.
   ```bash
   V=$(cat VERSION)
   grep -q "^version: ${V}" pubspec.yaml || { echo "VERSION=$V != pubspec.yaml"; exit 1; }
   ```
9. `flutter test --coverage`
10. `flutter build apk --debug`
11. Upload the debug APK as a build artefact, so any commit is installable
    without a local toolchain.

**Requirements**

- Total runtime under ~10 minutes on the free tier. If it creeps past that,
  split the APK build onto pushes to the default branch only.
- Red CI blocks merge.
- No secrets are used by this workflow at all. It must run correctly on a fork.

---

## `release.yml` — on tag `v*`

Runs only on tags matching `v*`. Produces the artefacts users actually install.

**Steps**

1. Everything from `ci.yml` steps 1–9, including the version consistency check,
   which additionally asserts the tag equals `v$(cat VERSION)`. A tag that
   doesn't pass tests, or that disagrees with `VERSION`, never produces a
   release.
2. Decode the keystore from secrets:
   ```
   ANDROID_KEYSTORE_BASE64   base64 of the upload keystore
   ANDROID_KEYSTORE_PASSWORD
   ANDROID_KEY_ALIAS
   ANDROID_KEY_PASSWORD
   ```
3. **Fail loudly if any signing secret is missing.** Never fall back to a
   debug-signed artefact — a wrongly signed public APK is the exact failure that
   breaks upgrades forever ([ADR-0007](70-decisions/ADR-0007-signing.md)).
4. Derive version and build number from the tag (`F-REL-005`). Never hand-edited.
5. `flutter build apk --release --split-per-abi` and `flutter build appbundle
   --release` (`F-REL-004`) — same tag, same version, same signing config for
   both: Gradle ties signing to the `release` build *variant*, not the
   packaging task, so the bundle needs no signing setup of its own.
6. Compute SHA-256 checksums for every artefact.
7. Create a GitHub Release with generated notes, attaching the APKs, the bundle,
   and a `checksums.txt`.
8. Delete the decoded keystore from the runner.

**Requirements**

- The keystore is **never** committed, in any form, at any time.
- Signing material must not appear in logs. Mask the secrets and never `set -x`
  around them.
- Builds are reproducible from the tag alone.
- Publishing the SHA-256 matters: sideloaded APKs have no store vouching for
  them, so a published hash is the only integrity signal a user gets.

---

## Branch protection

On the default branch, once the project has code:

- `ci.yml` must pass.
- No force pushes.
- Linear history.

## Caching

- Pub cache keyed on `pubspec.lock`.
- Gradle cache keyed on the Gradle files.
- Build-runner output is **not** cached — stale generated code produces failures
  that are far more confusing than the time it saves.

## Deliberately not automated

| Thing | Why |
|---|---|
| Play Store upload | Manual until the release process is boring. Store rejections are much easier to debug when the submission was deliberate |
| Version bumping | Derived from the tag; tagging is the deliberate act |
| Dependency updates | Reviewed by hand. Automated bumps on a project with this correctness bar are a liability |
| Coverage gates | Coverage is a signal, not a target. A percentage threshold produces tests written to satisfy the threshold |

## Future

- `F-REL-009` (iOS) needs a macOS runner, signing certificates, provisioning
  profiles, and a TestFlight upload step. Unscheduled, but the workflow split
  above anticipates it: `ci.yml` stays platform-neutral.
- `F-REL-010` (F-Droid) requires a reproducible build, which constrains how much
  the release workflow may inject at build time.
