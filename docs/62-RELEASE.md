# Release & distribution

Operational runbook. Features: [`30-features/REL/`](30-features/REL/).
Workflows: [`61-CI-CD.md`](61-CI-CD.md). Decision:
[ADR-0007](70-decisions/ADR-0007-signing.md).

---

## ⚠ The signing hazard

**Read this before publishing a single APK to anyone else.**

Android identifies an app by `applicationId` **plus signing key**. An APK signed
with key A cannot be upgraded in place by a build signed with key B. The install
fails with a signature mismatch, and the only remedy is uninstalling — which
deletes all app data.

This matters because of the intended path: GitHub-released APKs now, Play Store
later. Google Play uses **Play App Signing**, where Google holds the final app
signing key and you hold an *upload* key. If the GitHub APKs were signed with a
different key from the one Play ends up using, **every existing user is stranded
on the sideloaded version forever** and loses their training history if they
switch.

### The rules

1. **Generate the upload keystore once, now, before any public APK.** Back it up
   in at least two places. Losing it is unrecoverable.
2. **Every public artefact is signed with that same key** — GitHub releases and
   Play submissions alike.
3. **When enrolling in Play App Signing, opt to let Google use the existing key
   as the app signing key** rather than generating a new one. This is the only
   configuration where sideloaded installs upgrade cleanly to Play installs.
   Verify the current Play behaviour at enrolment time — this is the highest-
   consequence step in the whole distribution story.
4. **Ship export/import (`F-DAT-001`, `F-DAT-004`) before any public release.**
   It is the safety net. If the migration goes wrong anyway, users can export,
   reinstall, and import instead of losing everything.
5. **Never change `applicationId`** once anything is public.

### Keystore handling

- Generated locally, never in CI.
- Stored in GitHub Secrets base64-encoded, per [`61-CI-CD.md`](61-CI-CD.md).
- **Never committed**, in any form, at any time. Not in a private repo, not
  encrypted, not "temporarily".
- Backed up offline, in two locations, with the passwords stored separately.
- The release workflow fails loudly when signing material is absent rather than
  silently producing a debug-signed build.

---

## Versioning (`F-REL-005`, `F-REL-012`)

**Canonical: [`63-VERSIONING.md`](63-VERSIONING.md).** Only what affects
releases is noted here:

- `VERSION` at the repo root is the source of truth; the tag is `v` + its
  contents; `pubspec.yaml` derives from it. CI fails if they disagree.
- Every commit bumps and tags. A release is simply a tag someone decided to
  build from — `release.yml` fires on `v*`.
- Build number is monotonically increasing and derived, never hand-edited. Play
  rejects a reused build number, and hand-management is how that happens.
- Version and build are shown in About (`F-SET-009`) so a bug report can name an
  exact build. With no crash reporting or telemetry
  ([ADR-0002](70-decisions/ADR-0002-local-first.md)), this is the only
  diagnostic context that exists.

Pre-1.0 while the schema is still moving. 1.0 means the data model is stable
enough that a migration path is guaranteed from then on — expected around the
end of Phase 5.

---

## Release checklist

Before tagging:

- [ ] `main` is green in CI.
- [ ] Every feature in the release has `Status: done` and passing acceptance
      criteria.
- [ ] Migration tests pass for every upgrade path from the previously released
      schema version.
- [ ] Installed over the previous release on a real device — **upgrade tested,
      not just fresh install**. This is where data-loss bugs are caught.
- [ ] Both themes checked on a real device.
- [ ] Release notes drafted.

After tagging:

- [ ] Release workflow succeeded; APKs **and the `.aab`** attached with
      checksums (`F-REL-004` — both come from the same tag, commit, version
      and upload key, which is what makes the GitHub build and the store build
      reconcilable).
- [ ] Downloaded and installed the published artefact on a real device.
- [ ] Verified an upgrade in place from the previous public version.

---

## Store readiness (`F-REL-006`, `F-REL-007`)

A live checklist, since public release is a confirmed goal. None of it is
scheduled before Phase 6, but nothing here may be *precluded* by earlier
decisions.

### Google Play

**minSdk is 26** as of `F-HLT-001`: Health Connect's client library requires
it. That drops Android 7.x — a 2016 release with a fraction of a percent of
active devices — which is a product decision recorded here rather than a build
detail buried in `build.gradle.kts`.


- [ ] Developer account (one-off fee).
- [ ] `applicationId` fixed and final.
- [ ] Play App Signing enrolment configured per the rules above.
- [x] App bundle (`F-REL-004`) — built by `release.yml` on every tag.
- [x] Store listing: title, short and full description, category — written and
      versioned in [`store/LISTING.md`](../store/LISTING.md).
- [x] Graphics: icon and feature graphic (`F-THM-006`), generated by
      `tools/gen-icons.sh` into `store/`.
- [ ] Phone screenshots. **Needs a device or emulator**: a golden render from
      `flutter test` uses the test font, so every label would come out as
      placeholder boxes. `store/LISTING.md` has the shot list and the
      demo-data step (`Settings › Data › Load sample data`).
- [ ] Content rating questionnaire.
- [ ] **Data Safety form.** Unusually easy here: no collection, no sharing, no
      account. It must match reality exactly, verified by confirming the app
      makes no network calls at all.
- [ ] Privacy policy, published and checked into the repository.
- [ ] Target API level meeting the current Play requirement.
- [ ] Health Connect declarations if `F-HLT-001` ships — these carry extra
      review requirements; read the current policy first.
- [ ] Internal testing track before production.

### Apple App Store (`F-REL-009`, unscheduled)

- [ ] Apple Developer Program membership (annual).
- [ ] Bundle identifier fixed.
- [ ] Certificates and provisioning profiles.
- [ ] macOS build capacity (CI runner or a physical machine).
- [ ] Privacy Nutrition Label, matching the Play declaration.
- [ ] Screenshots at every required device size.
- [ ] TestFlight before submission.
- [ ] HealthKit review requirements if `F-HLT-003` ships.

### F-Droid (`F-REL-010`, unscheduled)

- [ ] Reproducible build.
- [ ] No proprietary dependencies (already true).
- [ ] Inclusion request with build metadata.

---

## Distribution channels

| Channel | Status | Notes |
|---|---|---|
| GitHub Releases | Phase 1 | Signed APK plus SHA-256 checksums. The primary channel for now |
| Google Play | Phase 6 | Requires the full store checklist |
| App Store | Unscheduled | Gated on `F-REL-009` |
| F-Droid | Unscheduled | Natural fit; needs reproducible builds |

Sideloaded users get no automatic updates. `F-REL-008` would address that, but
it would be the app's only network call and contradicts the privacy claims in
`F-REL-007` — so it stays opt-in and unscheduled.

---

## Rollback

There is no server, so there is nothing to roll back centrally.

- **GitHub:** delete or mark the bad release as a pre-release, publish a fixed
  version. Users who already installed it must install the fix manually.
- **Play:** halt the staged rollout. A previous version cannot be re-published
  over a newer build number — you must ship a higher version containing the fix.
- **Data corruption is the real risk.** A migration bug can't be rolled back by
  reinstalling, which is exactly why `F-DAT-008` (automatic local backups) is
  scheduled before public release, and why every migration is tested against
  data rather than merely for absence of exceptions.
