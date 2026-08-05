# Release & distribution — `REL`

Features covering build, signing, and getting the app onto devices. The
operational detail — keystore handling, store checklists, the migration hazard —
lives in [`../62-RELEASE.md`](../62-RELEASE.md); workflow specifications are in
[`../61-CI-CD.md`](../61-CI-CD.md).

---

### F-REL-001 — CI build and checks
Status: planned | Priority: P0 | Phase: 0
Blocks: F-REL-002

**Behaviour**
1. On every push and pull request: `flutter analyze`, `flutter test`, and a debug
   APK build.
2. The layer rule from [`../20-ARCHITECTURE.md`](../20-ARCHITECTURE.md) —
   `domain/` importing nothing from Flutter — is enforced here, not by good
   intentions.
3. Debug APK uploaded as a build artefact so any commit is installable.
4. Red CI blocks merge.

**Acceptance criteria**
- [ ] A `domain/` file importing Flutter fails CI.
- [ ] Build and test complete in a reasonable time on the free runner tier.

---

### F-REL-002 — Signed release APK
Status: planned | Priority: P0 | Phase: 1
Depends on: F-REL-001

**Intent** — The distribution mechanism you asked for: a downloadable APK from
GitHub. Also the point at which the signing decision becomes irreversible in
practice — see [ADR-0007](../70-decisions/ADR-0007-signing.md).

**Behaviour**
1. Tagging `v*` builds a release APK signed with the upload keystore.
2. Keystore and passphrase come from GitHub Secrets, base64-encoded. **Never
   committed**, in any form, at any time.
3. Build is reproducible from the tag alone.
4. The workflow fails loudly if signing material is missing rather than silently
   producing a debug-signed artefact — an unsigned or wrongly-signed public APK
   is the exact failure mode that breaks upgrades later.

**Acceptance criteria**
- [ ] Tagged builds produce an installable, correctly signed APK.
- [ ] No signing material appears anywhere in the repository or in build logs.

---

### F-REL-003 — GitHub Release automation
Status: planned | Priority: P1 | Phase: 1
Depends on: F-REL-002

Attach the signed APK to a GitHub Release with generated release notes and the
APK's SHA-256 checksum. The checksum matters: sideloaded APKs have no store to
vouch for them, so a published hash is the only integrity signal a user gets.

---

### F-REL-004 — App bundle for Play
Status: planned | Priority: P1 | Phase: 6
Depends on: F-REL-002

Build an AAB alongside the APK for Play submission. Both come from the same tag
and the same version, so the GitHub build and the store build are never a
mystery apart.

---

### F-REL-005 — Versioning scheme
Status: planned | Priority: P1 | Phase: 1

Semantic version plus a monotonically increasing build number, derived from the
tag and never hand-edited. Play rejects a reused build number, and hand-managed
numbers are how that happens. Version and build are shown in About (`F-SET-009`).

---

### F-REL-006 — Store listing assets
Status: planned | Priority: P2 | Phase: 6
Depends on: F-THM-006

Screenshots, feature graphic, short and full descriptions, category, content
rating. Required for both stores. The screenshots need real-looking training
data, which means a seeded demo database — worth building as a test fixture
anyway.

---

### F-REL-007 — Privacy policy and data safety
Status: planned | Priority: P0 | Phase: 6

**Intent** — Mandatory for both stores, and unusually easy here: the honest
answer to almost every question is "none" and "no".

**Behaviour**
1. A published privacy policy stating: no account, no telemetry, no network
   calls, no data collection, no third-party sharing. All data local; export and
   deletion available at any time (`F-DAT-001`, `F-DAT-010`).
2. Play Data Safety and App Store Privacy Nutrition Label completed to match.
3. If health integration (`F-HLT-001`) ships, the additional health-data
   declarations are completed accurately.
4. The policy is checked into the repository, not just hosted somewhere.

**Acceptance criteria**
- [ ] Declarations match actual app behaviour exactly — verified by confirming
      the app makes no network calls at all.

---

### F-REL-008 — Update check for sideloaded installs
Status: idea | Priority: P2 | Phase: —

APK users get no automatic updates. An optional check against the GitHub
releases API would notify them of a new version.

**Open questions** — This would be the app's only network call, contradicting the
"no network" claim in `F-REL-007`. If built, it must be strictly opt-in, clearly
disclosed, and disabled in store builds where the store handles updates.

---

### F-REL-009 — iOS build and TestFlight
Status: idea | Priority: P2 | Phase: —

macOS CI runner, signing certificates and provisioning profiles, TestFlight
distribution, App Store submission. Gated on the Apple Developer Program fee and
on the Android app being genuinely good. No date — but the cross-platform
constraints in [`../20-ARCHITECTURE.md`](../20-ARCHITECTURE.md) are maintained
continuously so this stays cheap when it happens.

---

### F-REL-010 — F-Droid
Status: idea | Priority: P3 | Phase: —

A natural fit — the app is open source, has no proprietary dependencies, and no
tracking, which is most of F-Droid's inclusion criteria already. Requires a
reproducible build and an inclusion request.

---

### F-REL-011 — Crash reporting
Status: idea | Priority: P2 | Phase: —

**Open questions** — Directly contradicts the no-telemetry stance in
`F-REL-007`, which is a genuine tension: shipping to strangers without crash
visibility means never learning about crashes. If it happens at all, it must be
opt-in, off by default, self-hosted or privacy-respecting, and disclosed
prominently. Not before there are real users to justify it.
