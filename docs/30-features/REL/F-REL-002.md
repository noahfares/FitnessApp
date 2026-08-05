# F-REL-002 — Signed release APK

Status: planned | Priority: P0 | Phase: 1
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
- [ ] Tagged builds produce an installable, correctly signed APK.
- [ ] No signing material appears anywhere in the repository or in build logs.

---

## Why

The distribution mechanism you asked for: a downloadable APK from
GitHub. Also the point at which the signing decision becomes irreversible in
practice — see [ADR-0007](../../70-decisions/ADR-0007-signing.md).
