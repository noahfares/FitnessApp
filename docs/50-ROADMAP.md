# Roadmap

Phases are **lists of feature IDs**, not restated prose. The features themselves
are defined in [`30-features/`](30-features/); this document only decides
sequence and when a phase is finished.

Progress is tracked in the `Status:` field of each feature entry, never here.

---

## This roadmap is binding

It is followed **strictly and in order**. It exists so the project cannot drift,
cannot lose track of where it is, and cannot quietly skip a feature that turns
out to matter.

**Allowed without asking:**

- Adding a **sub-feature** inside the current phase's scope. Give it a new ID,
  write the entry, mention it in the commit. This is how the plan improves.
- Fixing, clarifying, or expanding any entry's specification.
- Reordering work *within* a phase.

**Requires asking first:**

- Moving a feature between phases.
- Reordering or merging phases.
- Starting phase *N+1* before phase *N*'s exit criteria are all met.
- Declaring a phase complete with unmet exit criteria.
- Dropping a feature entirely.

If the roadmap looks wrong, **say so and stop**. Do not route around it, and do
not silently reinterpret an exit criterion to make it pass. A roadmap that gets
quietly bent is the same as no roadmap.

Every change to this file is itself a versioned commit
([`63-VERSIONING.md`](63-VERSIONING.md)), so the sequence has an audit trail.

## Sequencing principles

1. **Every phase ends with something usable.** No phase produces only
   infrastructure.
2. **Data-shape decisions come first.** Anything that would require migrating
   real training history — units, set types, template snapshotting — lands in
   Phase 0–1.
3. **Log before plan, plan before analyse, analyse before automate.** You cannot
   build analytics without data, and you cannot build progression without
   analytics.
4. **Distribution is proved early.** A signed APK on a real phone in Phase 1, not
   at the end, because signing and CI failures discovered late are the expensive
   kind.
5. **Unrecoverable data is captured before it is used.** A missing column can be
   added later; a year of missing observations cannot. Bodyweight (`F-BOD-001`)
   and per-set notes (`F-LOG-023`) are therefore in Phase 1, well before the
   analytics that consume them, and the schema carries nullable columns that
   Phase 1 never populates. See
   [ADR-0008](70-decisions/ADR-0008-sync-ready-foundations.md).

---

## ⚠ Standing instruction

**Stop after Phase 1 and train with the app for at least two weeks before
starting Phase 2.**

The catalogue is roughly 160 features — several years of solo work. Real use is
the only reliable way to learn which 20% matters, and it will reorder everything
below. Building Phases 2–6 straight through without using Phase 1 is the most
likely way this project fails.

---

## Batches

Features are grouped into **batches** — sets that share the same background
reading and are naturally built together. Building a batch in one session means
the foundational documents get read once instead of once per feature, which is
the single biggest lever on how much work fits in a session.

Prefer batches over individual features. Each batch below lists its shared
`Reads:` set; the per-feature files add anything extra.

Phases 0–1 are batched in detail. Later phases get batched when they are
scheduled — batching work that is years out would only be re-done.

---

## Phase 0 — Foundation

Project skeleton with no features. Everything here is load-bearing for
everything after it.

`F-NAV-001` `F-NAV-002` `F-THM-001` `F-THM-002` `F-THM-005` `F-I18N-002`
`F-SET-001` `F-SET-002` `F-REL-001` `F-REL-012`

| Batch | Features | Shared reads |
|---|---|---|
| **0.1** Project & CI | `F-REL-001` `F-REL-012` | `20-ARCHITECTURE` `61-CI-CD` `63-VERSIONING` |
| **0.2** Units foundation | `F-SET-001` `F-I18N-002` | `22-UNITS` `ADR-0003` |
| **0.3** Theme | `F-THM-001` `F-THM-002` `F-THM-005` `F-SET-002` | `24-DESIGN-SYSTEM` |
| **0.4** Shell & routing | `F-NAV-001` `F-NAV-002` | `23-NAVIGATION` |
| **0.5** Database schema | — (no feature ID; see below) | `21-DATA-MODEL` `ADR-0003` `ADR-0008` |

Batch **0.5** carries no feature ID because the schema is infrastructure every
feature rests on rather than a feature itself. It was missing from the original
0.1–0.4 breakdown — the roadmap listed the Drift schema under Phase 0 but
outside the batches, so it fell through. It is the last item before Phase 1.

Also, though not features: the Drift schema from
[`21-DATA-MODEL.md`](21-DATA-MODEL.md), the `Mass`/`Length`/`Distance` value
objects from [`22-UNITS.md`](22-UNITS.md), and the layer-rule lint.

**Exit criteria — all met at v0.8.0. Phase 0 complete.**
- [x] App builds and runs on a physical Android device.
- [x] Bottom navigation with placeholder screens; light and dark both correct.
- [x] Units and theme settings work and persist.
- [x] Database created at v1 with a passing migration test.
- [x] `Mass` value object fully unit-tested, including the no-drift test.
- [x] `flutter analyze` and `flutter test` green in CI; debug APK downloadable
      from a build artefact.
- [x] CI fails when a `domain/` file imports Flutter.
- [x] Pushing a `VERSION` bump creates the matching tag with no manual step
      (`F-REL-012`).

---

## Phase 1 — MVP

The point of this phase is a real training session logged on a real phone.

**Catalogue** `F-CAT-001` `F-CAT-002` `F-CAT-003` `F-CAT-004` `F-CAT-005`

**Logging** `F-LOG-001` `F-LOG-002` `F-LOG-003` `F-LOG-004` `F-LOG-005`
`F-LOG-006` `F-LOG-007` `F-LOG-008` `F-LOG-009` `F-LOG-011` `F-LOG-012`
`F-LOG-018` `F-LOG-023`

**Timers** `F-TIM-001` `F-TIM-002` `F-TIM-003` `F-TIM-005` `F-TIM-006`

**Shell** `F-NAV-003` `F-NAV-004` `F-NAV-005` `F-NAV-006` `F-A11Y-004`

**Settings** `F-SET-003` `F-SET-009`

**Unrecoverable capture** `F-BOD-001` `F-DAT-011`

**Release** `F-REL-002` `F-REL-003` `F-REL-005`

| Batch | Features | Shared reads |
|---|---|---|
| **1.1** Catalogue data | `F-CAT-001` `F-CAT-002` `F-CAT-003` | `21-DATA-MODEL#exercises` `21-DATA-MODEL#seed-data` |
| **1.2** Catalogue UI | `F-CAT-004` `F-CAT-005` | `23-NAVIGATION` `24-DESIGN-SYSTEM#component-inventory` |
| **1.3** Session lifecycle | `F-LOG-001` `F-LOG-002` `F-LOG-007` | `21-DATA-MODEL#workouts` `21-DATA-MODEL#persistence-behaviour` |
| **1.4** The set row | `F-LOG-003` `F-LOG-004` `F-LOG-005` `F-LOG-006` `F-LOG-023` | `21-DATA-MODEL#sets` `24-DESIGN-SYSTEM#component-inventory` `22-UNITS` |
| **1.5** Rest timer | `F-TIM-001` `F-TIM-002` `F-TIM-003` `F-TIM-005` `F-TIM-006` `F-SET-003` | `20-ARCHITECTURE#cross-platform-discipline` |
| **1.6** History | `F-LOG-008` `F-LOG-009` `F-LOG-011` `F-LOG-012` `F-LOG-018` | `21-DATA-MODEL` `23-NAVIGATION` |
| **1.7** Shell & empty states | `F-NAV-003` `F-NAV-004` `F-NAV-005` `F-NAV-006` `F-A11Y-004` | `23-NAVIGATION` `24-DESIGN-SYSTEM` |
| **1.8** Unrecoverable capture | `F-BOD-001` `F-DAT-011` | `21-DATA-MODEL#body_measurements` `22-UNITS` |
| **1.9** Ship it | `F-REL-002` `F-REL-003` `F-REL-005` `F-SET-009` | `62-RELEASE` `ADR-0007` `63-VERSIONING` |

Batch **1.4** is the heart of the app and the one to take most care over —
everything else in Phase 1 exists to support it.

**Exit criteria — verified on-device from the v0.17.3 release APK. Phase 1
complete, with one criterion explicitly waived by the project owner (see
below).**
- [x] A complete training session can be logged start to finish without touching
      any other app or a notebook.
- [x] Ghost values (`F-LOG-004`) appear correctly on the second session of an
      exercise.
- [x] Force-killing the app mid-session loses nothing.
- [x] The rest timer fires reliably with the phone in a pocket, screen off, on a
      device with aggressive battery management. Verified on-device by the
      project owner; note that `F-TIM-003`'s notification/foreground-service
      layer is still not built (only the in-app timer), so this is worth
      re-checking if a longer rest period or a different device ever fires
      late or not at all.
- [x] Bodyweight can be logged in under three taps from the dashboard.
- [x] `F-DAT-011` dumps every table to JSON, verified against a database with
      real sessions in it.
- [x] A signed APK is installed on your own phone from a GitHub Release.
- [ ] ~~Two weeks of real training logged before Phase 2 begins.~~ **Waived.**
      The app isn't yet in a state the project owner would use over their
      current tracker, so there's no real-use data to accumulate before moving
      on — accumulating it would just delay Phase 2 without changing what it
      finds. Revisit daily-driver adoption once Phase 2/3 make the app worth
      switching to.

---

## Phase 2 — Planning

Turns the logger into something you run a program on.

**Routines** `F-ROU-001` `F-ROU-002` `F-ROU-003` `F-ROU-004` `F-ROU-005`
`F-ROU-006` `F-ROU-007` `F-ROU-008` `F-ROU-009` `F-ROU-010`

**Logging** `F-LOG-010` `F-LOG-013` `F-LOG-014` `F-LOG-015` `F-LOG-016`
`F-LOG-017` `F-LOG-022`

**Catalogue** `F-CAT-006` `F-CAT-007` `F-CAT-008` `F-CAT-009`

**Timers** `F-TIM-004` `F-TIM-007`

**Settings & theme** `F-SET-007` `F-SET-008` `F-THM-003`

| Batch | Features | Shared reads |
|---|---|---|
| **2.1** Routine core | `F-ROU-001` `F-ROU-002` `F-ROU-003` `F-ROU-010` | `21-DATA-MODEL#routine_days` `70-decisions/ADR-0004-template-snapshot` |
| **2.2** Routine polish | `F-ROU-004` `F-ROU-007` `F-ROU-008` `F-ROU-009` | `21-DATA-MODEL#routine_days` `70-decisions/ADR-0004-template-snapshot` |
| **2.3** Supersets | `F-ROU-005` `F-LOG-015` | `21-DATA-MODEL#routine_days` `21-DATA-MODEL#sets` `70-decisions/ADR-0004-template-snapshot` `24-DESIGN-SYSTEM#component-inventory` |
| **2.4** Session editing & safety | `F-LOG-010` `F-LOG-016` `F-LOG-022` | `21-DATA-MODEL#sets` `24-DESIGN-SYSTEM#component-inventory` |
| **2.5** Set richness | `F-LOG-014` `F-LOG-017` | `21-DATA-MODEL#sets` `22-UNITS` `24-DESIGN-SYSTEM#component-inventory` |
| **2.6** PR detection | `F-LOG-013` | `40-ANALYTICS-SPEC#4-personal-records` `21-DATA-MODEL#personal_records` |
| **2.7** Catalogue polish | `F-CAT-006` `F-CAT-007` `F-CAT-008` `F-CAT-009` | `21-DATA-MODEL#exercises` |
| **2.8** Timer & settings polish | `F-TIM-004` `F-TIM-007` `F-SET-007` `F-SET-008` `F-THM-003` | `20-ARCHITECTURE#cross-platform-discipline` `22-UNITS` `24-DESIGN-SYSTEM` |

Batches 2.2–2.8 are ordered so each builds directly on what the previous one
left in place: polish on the routine core before supersets touch both routine
and logger, session-editing safety before the set-row fields that make more
of a session worth protecting, PR detection last among the logging batches
because it depends on `F-LOG-003`'s sets already existing in volume. Catalogue
and timer/settings polish are independent of the rest and could run in
either order — they're last because nothing else in the phase depends on
them.

Batch **2.1** started at the user's explicit request, before Phase 1's
on-device exit criteria above had been independently verified and the
two-week training criterion formally waived — done by overriding this
document's standing instruction rather than by silently routing around it.
Both have since been confirmed (see Phase 1's exit criteria above); recorded
here so the deviation still has an audit trail.

**Exit criteria**
- [ ] A full training week runs from routine days, with targets pre-filled.
- [ ] Editing a routine provably leaves historical workouts unchanged.
- [ ] PRs are detected and celebrated in-session, and correctly demoted when the
      set that set them is deleted.
- [ ] Supersets work end to end, editor through logger.

---

## Phase 3 — Insights

Where the app stops being a notebook.

**Engine & charts** `F-ANA-001` `F-ANA-002` `F-ANA-003` `F-ANA-004` `F-ANA-005`
`F-ANA-006` `F-ANA-007` `F-ANA-008` `F-ANA-015` `F-ANA-016`

**Supporting** `F-CAT-013` `F-ROU-011` `F-ROU-012` `F-ROU-015` `F-SET-005`
`F-SET-006` `F-THM-004`

**Exit criteria**
- [ ] Every metric in [`40-ANALYTICS-SPEC.md`](40-ANALYTICS-SPEC.md) scheduled
      for this phase has a passing fixture test.
- [ ] All charts render correctly in both themes and degrade gracefully with
      sparse data.
- [ ] Figures are cross-checked by hand against the raw log for one real
      training block. **Nothing else in this phase counts if the numbers are
      wrong.**
- [ ] Full recomputation over all existing history stays under 100 ms.

---

## Phase 4 — Automation

The differentiator phase.

**Progression** `F-PRG-001` `F-PRG-002` `F-PRG-003` `F-PRG-004` `F-PRG-005`
`F-PRG-006` `F-PRG-007` `F-PRG-008` `F-PRG-009` `F-PRG-010` `F-PRG-011`
`F-PRG-012`

**Plate maths** `F-PLT-001` `F-PLT-002` `F-PLT-003` `F-PLT-004` `F-PLT-005`
`F-SET-004`

**Body** `F-BOD-002` `F-BOD-003` — capture (`F-BOD-001`) already landed in Phase 1

**Advanced analytics** `F-ANA-009` `F-ANA-010` `F-ANA-011` `F-ANA-012`
`F-ANA-013` `F-ANA-014`

**Logging** `F-LOG-019` `F-LOG-020` `F-TIM-009`

**Exit criteria**
- [ ] Starting a routine day pre-fills targets that are correct, explained, and
      always assemblable from the configured plates.
- [ ] Every progression rule has fixture tests for success, partial, failure,
      and first-run paths.
- [ ] The plate calculator never proposes plates the user doesn't own.
- [ ] Insight cards say nothing at all when data is insufficient.

---

## Phase 5 — Data

Makes the ownership claim real, and de-risks the signing migration before any
public release.

`F-DAT-001` `F-DAT-002` `F-DAT-003` `F-DAT-004` `F-DAT-005` `F-DAT-006`
`F-DAT-007` `F-DAT-008` `F-DAT-010` `F-BOD-004` `F-SET-010`

The minimal dump (`F-DAT-011`) already exists from Phase 1 as a schema-mistake
escape hatch; this phase builds the real, versioned, round-trip-guaranteed
format on top of it.

**Exit criteria**
- [ ] Export → wipe → import reproduces the database exactly, verified table by
      table.
- [ ] A real Strong export imports with correct dates, weights, and set types,
      and refuses to guess when units are ambiguous.
- [ ] A restore that fails partway leaves the existing database untouched.
- [ ] Progress photos are excluded from backups unless explicitly opted in.

---

## Phase 6 — Publish

Everything required to hand the app to strangers.

**Accessibility** `F-A11Y-001` `F-A11Y-002` `F-A11Y-003` `F-A11Y-005`

**Localisation & branding** `F-I18N-001` `F-THM-006`

**Onboarding** `F-SET-011`

**Release** `F-REL-004` `F-REL-006` `F-REL-007`

**Health** `F-HLT-001` `F-HLT-002`

**Exit criteria**
- [ ] Full app usable with a screen reader and at 200% text scale.
- [ ] Privacy policy and data-safety declarations match actual behaviour, with
      "no network calls" verified rather than asserted.
- [ ] Play internal testing track live, then production.
- [ ] The upgrade path from a sideloaded APK to the Play build is documented and
      tested — see [ADR-0007](70-decisions/ADR-0007-signing.md).

---

## Unscheduled

Everything not listed above lives in [`51-BACKLOG.md`](51-BACKLOG.md) with its
ID intact. Notably this includes the entire iOS port (`F-REL-009`) and the
wearable companions (`F-HLT-004`, `F-HLT-005`).

## Phase summary

| Phase | Features | Batches | Theme |
|---|---|---|---|
| 0 | 10 | 4 | Foundation |
| 1 | 35 | 9 | MVP — a usable logger |
| 2 | 26 | TBD | Programs and templates |
| 3 | 17 | TBD | Analytics |
| 4 | 29 | TBD | Progression and automation |
| 5 | 11 | TBD | Data portability |
| 6 | 12 | TBD | Store release |
| — | 23 | — | Backlog |
| | **140 scheduled, 23 unscheduled, 163 defined** | | |

Live counts are in [`features.tsv`](features.tsv); `tools/check-docs.sh`
verifies this table still reconciles.
