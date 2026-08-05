# Vision & scope

## The pitch

A strength-training tracker that gives away, free and offline, the features that
Strong, Hevy, JEFIT and Fitbod put behind subscriptions: unlimited routines and
custom exercises, real analytics, progression automation, and full data export.

## Principles

In priority order. When two conflict, the earlier wins.

1. **Logging a set must be effortless.** The app is used mid-set, one-handed,
   with sweaty hands, sometimes with no signal, often with a 90-second clock
   running. Every other consideration is secondary to that interaction. If a
   feature makes the set row slower to use, it loses.
2. **The data is yours.** Local-first, no account required, no telemetry,
   export to CSV/JSON at any time. This is an ethical position and also the
   clearest differentiator from every competitor.
3. **Insight over record-keeping.** Anything can store numbers. The value is
   telling you that your bench e1RM has been flat for five weeks while your
   weekly chest volume dropped 30%.
4. **Trustworthy numbers.** A tracker whose maths you doubt is worthless. All
   computation is pure, tested, and specified in writing before it is written.
5. **Boring technology.** One maintainer. No server to babysit, no exotic
   dependencies, no cleverness that has to be re-learned in six months.

## Audience

Designed first for the intermediate lifter running a structured program — PPL,
upper/lower, 5/3/1, GZCLP — who cares about progressive overload and wants trend
data. Beginners are served by the same interface plus starter templates
(`F-ROU-015`); advanced users are served by RPE/RIR (`F-LOG-014`) and
autoregulation (`F-PRG-005`).

The first user is the author. That is a feature: dogfooding on real training
decides what actually matters. See the Phase 1 stop-and-use instruction in
[`50-ROADMAP.md`](50-ROADMAP.md).

## Distribution intent

- **Now:** personal use, plus signed APKs on GitHub Releases for anyone who
  finds the repo.
- **Eventually:** public releases on Google Play and the App Store.

The second point constrains the first. Publishing formalities — a stable
`applicationId`, a coherent signing strategy, licence-clean seed content, a
privacy policy, a data-safety declaration — must all remain achievable from day
one, even though none of that work is scheduled yet. The two decisions that
would be genuinely expensive to get wrong are **exercise-catalogue licensing**
and **signing**; both are covered under Risks below.

## Non-goals

These are settled. They exist here so they stop being re-litigated. Reopening
one requires an ADR.

| Non-goal | Why |
|---|---|
| **Social feed, friends, leaderboards** | Requires a backend, moderation, and abuse handling. Contradicts principles 2 and 5. |
| **Nutrition / macro tracking** | A different app with a different data model and a much harder content problem — food databases are licensed and expensive. |
| **GPS route tracking for running/cycling** | Cardio gets a simple loggable entry. Route mapping is a separate product with its own battery, permission, and privacy story. |
| **A backend server** | Accounts, auth, GDPR obligations, hosting cost, and a permanent operational liability attached to a free app. See [ADR-0002](70-decisions/ADR-0002-local-first.md). |
| **AI workout generation** | Fitbod's niche. Fine to reconsider later, but the progression engine (`F-PRG-001`) delivers most of the value deterministically, explainably, and offline. |
| **Ads, or any monetisation** | The premise of the project is that this stuff shouldn't cost money. |

### Sync, specifically

Multi-device sync is *not* a non-goal, but it is deliberately deferred and
deliberately not server-based. The sequence is:

1. Manual export/import (`F-DAT-001`, `F-DAT-002`) — Phase 5.
2. Full backup/restore file (`F-DAT-003`, `F-DAT-004`) — Phase 5.
3. File-based sync via the OS provider — Google Drive, iCloud Drive, Nextcloud —
   with the database as a single encrypted blob (`F-DAT-009`) — unscheduled.

Real multi-device merge (CRDT or per-row last-write-wins) is a large project on
its own and gets built only if steps 1–3 prove insufficient in practice.

## Competitive gap

What is paywalled elsewhere and free here. Tiering shifts over time; treat this
as directional, not a specification.

| Capability | Strong | Hevy | JEFIT | Here |
|---|---|---|---|---|
| More than a handful of routines | Pro | Pro | Elite | Free |
| Custom exercises | Pro | Free | Elite | Free |
| Advanced charts & analytics | Pro | Pro | Elite | Free |
| Body measurements | Pro | Pro | Elite | Free |
| Plate calculator | Pro | Free | Elite | Free |
| RPE / RIR tracking | Pro | Pro | — | Free |
| Full data export | Pro | Pro | Elite | Free |
| Programmed progression | — | partial | Elite | Free |
| Rest-timer customisation | Free | Free | Elite | Free |
| Works fully offline, no account | partial | no | no | Yes |

The last row is the one no competitor can match without changing their business
model.

## Risks

| Risk | Severity | Mitigation |
|---|---|---|
| **Exercise-catalogue licensing.** Scraping a competitor's database is a legal and ethical non-starter, and would be fatal to a store release. | High | Use a source with an explicit permissive licence — reading the actual licence text, never a README summary — or hand-author the seed set. Seed data lives in versioned JSON with per-record provenance in `assets/seed/SOURCES.md`. See `F-CAT-001`. |
| **APK → Play signing migration.** An APK signed with a local key cannot be upgraded in place by a Play-signed build; users would have to uninstall and lose their data. | High | Settle signing before the first *public* APK. See [ADR-0007](70-decisions/ADR-0007-signing.md) and [`62-RELEASE.md`](62-RELEASE.md). Working export/import is the safety net, which is why it is scheduled before public release. |
| **Scope creep.** The feature catalogue is several years of solo work. | High | Phases with hard exit criteria; a standing instruction to stop after Phase 1 and train with it for two weeks before continuing. Real use decides which 20% matters. |
| **Silent numerical bugs.** Wrong e1RM or volume figures are worse than none — they'd be trusted. | Medium | Pure-domain computation, specified before implementation, with worked fixtures in [`40-ANALYTICS-SPEC.md`](40-ANALYTICS-SPEC.md). |
| **Play health-data policy.** Health Connect integration carries extra declaration requirements. | Medium | Keep health integration optional and late (`F-HLT-001`+). Read the current policy before implementing, not after. |
| **iOS cost and effort.** Apple Developer Program fee plus macOS build capacity. | Medium | No iOS work scheduled. Cross-platform correctness maintained continuously so the port stays cheap: platform services behind interfaces, no Android-only plugins without an abstraction. |
| **Solo-maintainer burnout.** | Medium | Boring stack, no server, high test coverage on the maths so regressions are loud rather than insidious. Every phase ends with something usable. |
| **Unit-handling bugs.** Mixed kg/lb data is corrupting and often invisible until far too late. | Medium | Canonical integer-gram storage, enforced by the type system via value objects. See [`22-UNITS.md`](22-UNITS.md) and [ADR-0003](70-decisions/ADR-0003-canonical-units.md). |

## Success criteria

Not downloads. In order:

1. The author uses it for every training session and stops opening any other app.
2. Its numbers are trusted enough to make programming decisions from.
3. Someone else adopts it and their data imports cleanly from what they were
   using before.
4. It reaches a store listing without any of the above regressing.
