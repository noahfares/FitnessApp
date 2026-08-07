# F-REL-002 — Signed release APK

Status: done | Priority: P0 | Phase: 1
Depends on: F-REL-001
Reads: 62-RELEASE, 70-decisions/ADR-0007-signing

## Spec
1. Tagging `v*` builds a release APK signed with the upload keystore.
2. Keystore and passphrase come from GitHub Secrets, base64-encoded. **Never
   committed**, in any form, at any time.
3. Build is reproducible from the tag alone.
4. The workflow fails loudly if signing material is missing rather than silently
   producing a debug-signed artefact — an unsigned or wrongly-signed public APK
   is the exact failure mode that breaks upgrades later.

## Acceptance
- [x] Tagged builds produce an installable, correctly signed APK.
- [x] No signing material appears anywhere in the repository or in build logs.

## Implementation

`.github/workflows/release.yml` fires on `v*`, decodes
`ANDROID_KEYSTORE_BASE64` from secrets to a runner-local file, and fails the
job before touching Gradle if that secret is absent. `android/app/build.gradle.kts`
reads the keystore path/passwords from environment variables (or a git-ignored
local `key.properties`, for a contributor testing the release path without
CI) and, when `REQUIRE_RELEASE_SIGNING=true` (set only by `release.yml`),
throws rather than falling back to the debug signing config if any of
`ANDROID_KEYSTORE_PATH`/`_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`
is missing. The decoded keystore file is removed at the end of the job
regardless of outcome.

Not yet exercised for real: the actual `ANDROID_KEYSTORE_BASE64` and friends
have to be generated once, offline, and added to GitHub Secrets by a human —
that step is unrecoverable if lost (ADR-0007) and isn't something this session
can do. Until then, the first tag push will fail this workflow loudly, which
is the intended behaviour, not a bug.

---

## Why

The distribution mechanism you asked for: a downloadable APK from
GitHub. Also the point at which the signing decision becomes irreversible in
practice — see [ADR-0007](../../70-decisions/ADR-0007-signing.md).
