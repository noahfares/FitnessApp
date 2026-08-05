# ADR-0007 — Signing and distribution strategy

**Status:** Accepted · 2026-08

## Context

The intended path is: signed APKs on GitHub Releases now, Google Play later, App
Store eventually.

Android identifies an installed app by `applicationId` **plus signing key**. An
APK signed with key A cannot be upgraded in place by a build signed with key B —
installation fails with a signature mismatch, and the only remedy is
uninstalling, which deletes all app data.

Google Play uses **Play App Signing**: Google holds the final app signing key,
and the developer holds an *upload* key. At enrolment, you can either let Google
generate a fresh app signing key or adopt your existing key.

If the GitHub-released APKs are signed with a different key from the one Play
ultimately uses, every existing sideloaded user is stranded on the GitHub version
permanently, and loses their entire training history if they move to the Play
build. Given [ADR-0002](ADR-0002-local-first.md) — no cloud backup — that history
exists nowhere else.

**This decision becomes irreversible the moment the first public APK ships.**

## Options

**Sign GitHub builds with a throwaway key, generate a fresh Play key later.**
Simplest now. Cost: guarantees the stranding scenario above.

**Generate one upload keystore now; use it for everything; adopt it as the Play
app signing key at enrolment.** Requires getting it right up front and guarding
the keystore permanently. Cost: losing the keystore is unrecoverable.

**Use different `applicationId`s for the GitHub and Play builds.** Sidesteps the
conflict by making them different apps — they'd install side by side. Cost:
migration becomes a manual export/import for every user, and two listings to
maintain forever.

## Decision

**One upload keystore, generated before the first public APK, used for every
public artefact on both channels.** At Play enrolment, adopt the existing key as
the app signing key rather than letting Google generate a new one.

Supporting commitments:

1. `applicationId` is fixed from the first commit and never changes.
2. The keystore is backed up offline in at least two locations, with passwords
   stored separately.
3. It is never committed — not in a private repository, not encrypted, not
   temporarily. CI reads it from GitHub Secrets, base64-encoded.
4. The release workflow **fails loudly** when signing material is missing, rather
   than silently producing a debug-signed artefact (`F-REL-002`).
5. **Export/import (`F-DAT-001`, `F-DAT-004`) ships before any public release**
   as the safety net. If the migration goes wrong despite everything, users can
   export, reinstall, and import instead of losing years of data.
6. The exact Play App Signing behaviour is **verified at enrolment time**, not
   assumed from this document — it is the highest-consequence step in the whole
   distribution story, and platform policies change.

## Consequences

- Keystore custody becomes a permanent operational responsibility. Losing it
  means no further updates to the published app, ever.
- The GitHub APK and the Play build stay upgrade-compatible, which is the
  point.
- `F-DAT-001`/`F-DAT-004` are effectively safety-critical rather than
  convenience features, which is why Phase 5 precedes Phase 6.
- iOS has no equivalent hazard — App Store distribution is the only channel
  there, so `F-REL-009` inherits none of this.
- Sideloaded users still get no automatic updates. `F-REL-008` would address
  that but conflicts with the no-network stance in `F-REL-007`, so it stays
  unscheduled and opt-in.

## Reversal cost

**Irreversible after the first public APK.** Before that, free.

Nothing else in this project has that property, which is why it is decided in
writing now, well before Phase 1 ships anything to anyone.
