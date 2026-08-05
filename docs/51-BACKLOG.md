# Backlog

Features that are defined and ID'd but not scheduled into any phase. They live
in the same [`30-features/`](30-features/) files as everything else — this
document is an index, not a separate store, so an entry never has to move when
it gets scheduled.

**Promoting an item** = adding its ID to a phase in
[`50-ROADMAP.md`](50-ROADMAP.md), setting `Phase:` in its entry, and expanding
the entry to full specification depth. Removing it from the list below is the
last step, not the first.

## Unscheduled features

| ID | Feature | Why it's parked |
|---|---|---|
| `F-CAT-010` | Merge duplicate exercises | Only matters after a messy import; irreversible without a backup, so it needs `F-DAT-003` first |
| `F-CAT-011` | Exercise images / animations | App size, and an image-licensing problem harder than the catalogue's own |
| `F-CAT-012` | Substitution suggestions | Needs an equipment-availability model to be useful rather than noisy |
| `F-CAT-014` | Exercise variants and modifiers | Powerful and genuinely complicated; needs its own design pass |
| `F-ROU-013` | Cycles, blocks and deload weeks | Adds a week/cycle dimension to the data model; wait until `F-PRG-004` is real |
| `F-ROU-014` | Share and import routines as files | Cheap once `F-DAT-001` exists; no urgency before other people use the app |
| `F-LOG-021` | Live session metrics in the header | Nice, not necessary; must not cost a frame |
| `F-TIM-008` | Interval / EMOM timer | Distinct mode, distinct audience, low overlap with strength training |
| `F-ANA-017` | Year in review | Pure delight; needs a year of data to be worth anything |
| `F-ANA-018` | Exercise comparison charts | Narrow appeal until there's a lot of history |
| `F-BOD-005` | Goals | Risks drifting into prescriptive territory the app deliberately avoids |
| `F-BOD-006` | Measurement reminders | Nagging is a fast route to uninstallation; needs careful design |
| `F-DAT-009` | File-based cloud sync | Last-write-wins on a whole-database blob loses data on genuine multi-device use — see the open question in its entry |
| `F-NAV-007` | Home-screen widget | Two platform-specific implementations for modest value |
| `F-NAV-008` | App shortcuts | Cheap, but pure convenience |
| `F-I18N-003` | Additional locales | Only worth doing when there are users who need them |
| `F-HLT-003` | HealthKit parity | Gated on the iOS port |
| `F-HLT-004` | Wear OS companion | A substantial second app with its own sync problem |
| `F-HLT-005` | watchOS companion | Gated on both the iOS port and `F-HLT-004` |
| `F-REL-008` | Update check for sideloaded installs | Would be the app's only network call, contradicting `F-REL-007` |
| `F-REL-009` | iOS build and TestFlight | Confirmed goal, no timeline. Gated on the Apple Developer fee and on Android being genuinely good |
| `F-REL-010` | F-Droid distribution | Natural fit; needs a reproducible build |
| `F-REL-011` | Crash reporting | Directly tensions with the no-telemetry stance; opt-in only, and not before real users |

23 unscheduled of 160 defined.

---

## Ideas without an ID

Not yet worth an entry. Promote to a real feature — with an ID — before anyone
builds anything, per the rules in [`../CLAUDE.md`](../CLAUDE.md).

- **Exercise-specific 1RM testing protocol.** Guided work-up to a true single,
  with the result feeding `F-PRG-010`.
- **Session templates by time available.** "I have 40 minutes" → trim the day's
  accessories automatically.
- **Gym profiles.** Different plate and machine inventories per location, since
  travelling and home gyms have entirely different equipment (`F-PLT-002`
  currently assumes one inventory).
- **Warm-up quality tracking.** Whether the prescribed ramp was actually done,
  as a possible confounder in stall analysis.
- **Training partner mode.** Alternating sets between two people on one bar
  without two separate sessions.
- **Bar speed / velocity entry.** Manual VBT numbers from an external device.
  Small audience, but the data model would support it cheaply.
- **Plate-loading photo check.** Camera-based verification of what's on the bar.
  Almost certainly not worth it; recorded so it stops being re-suggested.
- **Rest-day recovery notes.** Sleep, soreness, stress as context for stall
  detection. Drifts toward nutrition/wellness tracking, which is a documented
  non-goal — would need a clear boundary first.
- **Auto-detect deload weeks** from a volume drop, rather than requiring
  `F-ROU-013` to declare them.
- **Export to a spreadsheet template** with pivot tables and charts already set
  up, for people who want to do their own analysis.

---

## Rejected

Considered and declined. Recorded so they don't come back around without new
information. Reopening one needs an ADR.

| Idea | Why not |
|---|---|
| Social feed, friends, leaderboards | Requires a backend, moderation, abuse handling. Non-goal in [`10-VISION.md`](10-VISION.md) |
| Nutrition and macro tracking | Different app, different data model, licensed food databases |
| GPS route tracking | Separate product with its own battery, permission and privacy story |
| AI-generated workouts | The progression engine delivers most of the value deterministically, explainably, and offline |
| Ads or subscriptions | The entire premise is that this shouldn't cost money |
| Cloud account with server-side sync | Accounts, auth, GDPR, hosting cost, permanent liability. See [ADR-0002](70-decisions/ADR-0002-local-first.md) |
