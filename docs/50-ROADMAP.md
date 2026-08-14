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

**Exit criteria — all four provable by automated test as of batch 2.8
(v0.26.1). Phase 2 complete, declared by the project owner with the two
caveats below explicitly accepted rather than silently carried forward.**
- [x] A full training week runs from routine days, with targets pre-filled.
      `test/features/routines/routine_flow_test.dart` proves one day
      end-to-end through the UI (create → day → exercise → targets → start,
      targets visibly pre-filled); `test/data/repositories
      /workout_repository_test.dart`'s "a full training week from routine
      days" runs three days (Push/Pull/Legs) sequentially — start, verify
      pre-filled targets, log, finish, repeat — proving finishing one day
      actually frees the next rather than just that a single day works in
      isolation.
- [x] Editing a routine provably leaves historical workouts unchanged.
      `workout_repository_test.dart`'s "starting from a routine day" group
      has one case for an in-progress workout (re-targeting the routine
      afterwards) and one for a **finished** one — deleting the exercise,
      the day, and the routine itself after finishing, then re-reading the
      historical workout and confirming every copied field is untouched
      (`ADR-0004`).
- [x] PRs are detected and celebrated in-session, and correctly demoted when
      the set that set them is deleted. Detection:
      `test/domain/analytics/personal_records_test.dart` (the spec's own
      `prDetection` fixture) and `personal_record_repository_test.dart`.
      Demotion on delete: the same file's "deleting a PR set and rebuilding
      demotes to the next best". Celebration wiring:
      `test/features/logging/personal_record_ui_test.dart` completes a
      record-setting set through the real `ActiveWorkoutScreen` and asserts
      `PrBadge` actually appears — not just that the cache updates.
- [x] Supersets work end to end, editor through logger.
      `routine_superset_test.dart` (grouping in the day editor) →
      `workout_repository_test.dart`'s "carries the routine day's superset
      grouping into the session" (the `ADR-0004` snapshot preserves
      `group_id`) → `active_workout_test.dart`'s superset group (grouping
      and ungrouping mid-session) → `rest_defaults_test.dart`'s
      `restSecondsForGroupMember` plus a `rest_timer_test.dart` widget case
      (completing a non-last member does not start the full rest). Editor
      through logger, not just each layer in isolation.

Two caveats worth reading before treating this as "done, no further work":
`F-ROU-005` §3 and `F-LOG-015` §2 are still `in-progress` — within-group
rest is fixed at zero rather than independently configurable, and
completing a set does not auto-advance focus to the next group member (see
each feature's own status notes). Neither blocks the mechanic from working
end to end, which is what this exit criterion asks. Separately, `F-LOG-013`'s
first-ever-set edge case (§4 rule 3, "record it silently") is only
half-honoured: the cache write is silent as specified, but the inline
`PrBadge` itself has no separate suppression for a first-ever set, so it
can appear immediately rather than only on a later, genuine PR — a minor
gap against the letter of that one edge case, not against the exit
criterion's own wording.

---

## Phase 3 — Insights

Where the app stops being a notebook.

**Engine & charts** `F-ANA-001` `F-ANA-002` `F-ANA-003` `F-ANA-004` `F-ANA-005`
`F-ANA-006` `F-ANA-007` `F-ANA-008` `F-ANA-015` `F-ANA-016`

**Supporting** `F-CAT-013` `F-ROU-011` `F-ROU-012` `F-ROU-015` `F-SET-005`
`F-SET-006` `F-THM-004`

| Batch | Features | Shared reads |
|---|---|---|
| **3.1** Engine & per-exercise history | `F-ANA-001` `F-ANA-002` | `40-ANALYTICS-SPEC` `20-ARCHITECTURE#the-one-hard-rule` `21-DATA-MODEL#sets` |
| **3.2** e1RM trend & date range | `F-ANA-003` `F-SET-006` `F-ANA-015` `F-THM-004` | `40-ANALYTICS-SPEC#1-estimated-one-rep-max-e1rm` `21-DATA-MODEL#sets` `22-UNITS` `24-DESIGN-SYSTEM#charts` |
| **3.3** Volume & muscle taxonomy | `F-CAT-013` `F-SET-005` `F-ANA-004` `F-ANA-005` | `40-ANALYTICS-SPEC#2-volume-load` `40-ANALYTICS-SPEC#3-hard-sets-per-muscle-group-per-week` `21-DATA-MODEL#exercises` `21-DATA-MODEL#sets` |
| **3.4** Consistency, PR timeline & balance | `F-ANA-006` `F-ANA-007` `F-ANA-008` | `40-ANALYTICS-SPEC#5-consistency` `40-ANALYTICS-SPEC#9-muscle-balance-ratios` `21-DATA-MODEL#sets` `21-DATA-MODEL#personal_records` |
| **3.5** Routine programming view | `F-ROU-011` `F-ROU-012` | `40-ANALYTICS-SPEC#11-estimated-session-duration` `21-DATA-MODEL#routine_days` `70-decisions/ADR-0004-template-snapshot` |
| **3.6** Chart interaction & starter programs | `F-ANA-016` `F-ROU-015` | `24-DESIGN-SYSTEM#charts` `21-DATA-MODEL#routine_days` `70-decisions/ADR-0004-template-snapshot` |

Ordering rationale: `F-ANA-001` is the shared engine and boundary-filtering
seam every other `F-ANA-*` needs, so it lands first, paired with `F-ANA-002`
(the plain reverse-chronological list, no chart) rather than alone — a
foundation batch that ships nothing visible would break the pattern every
other phase has followed. `fl_chart` is added in **3.2**, the first batch
that actually renders one (pre-declared in `pubspec.yaml`'s deferred-deps
comment). `F-ANA-003`/`F-SET-006` resolve their mutual reference by building
the trend chart on the existing Epley default first, then adding the
formula picker in the same batch. `F-CAT-013` (muscle taxonomy) must precede
both `F-ANA-005` and `F-ANA-008` since they read its enum; **3.3** bundles
it with the one consumer (`F-ANA-005`) that also needs `F-SET-005` (week
start), leaving muscle balance (`F-ANA-008`, no `F-SET-005` dependency) for
**3.4** alongside the two other metrics needing no new shared reading.
`F-ROU-011` depends on `F-ANA-005`, so routine programming view comes after
**3.3**; `F-ROU-012` (scheduling) has no hard dependency but shares its
`Reads:` set and only *optionally* enriches `F-ANA-006`, so it rides along
rather than forcing a batch of its own. `F-ANA-016` (tap/pinch interaction)
and `F-ROU-015` (starter programs) are last because the former is polish
across every chart already built and the latter is independent content,
same reasoning Phase 2 gave for its own trailing polish batches.

**Exit criteria — audited at v0.34.0, mirroring Phase 2's audit batch: a test
per criterion that proves the criterion's own wording, not just its
component features' specs. Phase 3 complete, declared by the project owner
with one criterion explicitly waived below rather than silently carried
forward.**
- [x] Every metric in [`40-ANALYTICS-SPEC.md`](40-ANALYTICS-SPEC.md) scheduled
      for this phase has a passing fixture test. §1 e1RM (`e1rm_test.dart`),
      §2 volume load (`weekly_volume_test.dart`, `workout_volume_test.dart`),
      §3 sets per muscle (`sets_per_muscle_test.dart`), §4 personal records
      (`personal_records_test.dart`), §5 consistency (`consistency_test.dart`),
      §9 muscle balance (`muscle_balance_test.dart`) and §11 session duration
      (`routine_preview_test.dart`) each have their spec's own fixture as a
      test. §6 (bodyweight EMA, `F-BOD-003`) and §7 (stall detection,
      `F-ANA-009`) are Phase 4 features and were never scheduled for this
      phase — `linear_regression.dart`'s shared slope utility that §7 will
      reuse already has its own fixture test, built ahead of time in batch
      3.2.
- [x] All charts render correctly in both themes and degrade gracefully with
      sparse data. Sparse data (empty, single-point, single-zero-value,
      fewer-than-three-points, unreliable-point) was already covered for all
      three chart widgets; dark-theme rendering was not — added one
      `AppTheme.dark()` case per widget (`trend_chart_test.dart`,
      `weekly_bar_chart_test.dart`, `calendar_heatmap_test.dart`), plus a
      `dark` parameter on `pumpScreen` for future screen-level theme tests.
- [ ] ~~Figures are cross-checked by hand against the raw log for one real
      training block.~~ **Waived**, same reasoning as Phase 1's "two weeks of
      real training logged" criterion: there is still no real training block
      to check figures against, and this app is not yet anyone's
      daily-driver tracker. Revisit once one exists — an unchecked figure is
      a real gap, not a formality, and this waiver does not make the numbers
      trusted, only acknowledges they haven't been checked yet.
- [ ] ~~Full recomputation over all existing history stays under 100 ms~~ —
      **verified as "linear, not quadratic" only**, not as a literal 100ms
      wall-clock number, left unchecked rather than ticked for the part that
      isn't. `recompute_performance_test.dart` found the real
      obstacle: `flutter test` runs pure Dart on the VM's JIT tier, not the
      AOT-compiled release build the 100ms budget was written for, and
      measured roughly a 3x-over-budget result on a desktop CPU for reasons
      entirely explained by that gap (confirmed by comparing 1-year vs.
      5-year synthetic history — time scales with data size, not with a
      hidden quadratic term). The literal on-device number needs the same
      real-APK-and-device verification Phase 1's on-device criteria used and
      this session's toolchain doesn't have; it is not asserted here as met.

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

Batched into 4.1–4.6, the same way Phases 2–3 were, since later batches only
get scheduled once the phase actually starts:

| Batch | Features | Shared reads |
|---|---|---|
| **4.1** Progression engine & first rule | `F-PRG-001` `F-PRG-002` `F-PRG-006` `F-PRG-007` `F-PRG-008` `F-PRG-009` | `40-ANALYTICS-SPEC#12-progression-rules` `20-ARCHITECTURE#the-one-hard-rule` `22-UNITS` `21-DATA-MODEL#routine_exercises` |
| **4.2** Remaining progression rules | `F-PRG-003` `F-PRG-004` `F-PRG-010` `F-PRG-005` | `40-ANALYTICS-SPEC#12-progression-rules` `22-UNITS` |
| **4.3** Plate maths | `F-PLT-002` `F-PLT-001` `F-PLT-004` `F-PLT-003` `F-PLT-005` `F-PRG-012` | `21-DATA-MODEL#bars-and-plates` `22-UNITS` |
| **4.4** Body tracking | `F-BOD-002` `F-BOD-003` | `21-DATA-MODEL#body_measurements` `22-UNITS` `40-ANALYTICS-SPEC#6-bodyweight-trend-ema` |
| **4.5** Advanced analytics & deload | `F-ANA-009` `F-ANA-010` `F-ANA-011` `F-ANA-012` `F-ANA-013` `F-ANA-014` `F-PRG-011` | `40-ANALYTICS-SPEC#7-stall-detection` `40-ANALYTICS-SPEC#8-acute-to-chronic-workload-ratio` `40-ANALYTICS-SPEC#10-intensity-and-rep-distribution` |
| **4.6** Logging extras | `F-LOG-019` `F-LOG-020` `F-TIM-009` | `21-DATA-MODEL#exercises` `21-DATA-MODEL#sets` `24-DESIGN-SYSTEM#component-inventory` |

Ordering rationale: the engine (`F-PRG-001`) leads, same reasoning as
`F-ANA-001` in Phase 3 — paired with its simplest real rule (`F-PRG-002`,
linear) and the always-available null rule (`F-PRG-006`) rather than shipped
alone, plus the assignment UI and explanation that make either rule
reachable and legible at all (`F-PRG-007`, `F-PRG-008`) and the
failure/deload handling `F-PRG-002` itself needs to be a complete rule
(`F-PRG-009`). `40-ANALYTICS-SPEC.md` has no progression section yet — one is
added in this batch (§12) with worked fixtures, since Phase 4's own exit
criterion demands fixture tests per rule and none of Phase 1–3 needed one.
**4.2** completes the remaining P1/P2 rule types once the engine shape is
proven: double progression (`F-PRG-003`) needs nothing new, then training-max
management (`F-PRG-010`) before percentage-based (`F-PRG-004`, which depends
on it), then RPE-autoregulation (`F-PRG-005`, depends only on `F-LOG-014`,
already done). **4.3** is plate maths as its own batch — `F-PLT-002`
(inventory) before `F-PLT-001` (the calculator that reads it) before
`F-PLT-004` (closest achievable weight, needs both), then the two P2
extras (`F-PLT-003`, `F-PLT-005`); `F-PRG-012` (plate-aware rounding) closes
the batch since it depends on `F-PLT-001` and is what finally satisfies
`F-PRG-001` §6 and the Phase 4 exit criterion about never proposing
unassemblable plates — `F-PRG-001` itself ships in 4.1 without that
guarantee met yet, the same kind of documented partial-acceptance Phase 3's
batches repeatedly used. **4.4** (body tracking) has no dependency on
anything progression- or plate-related and could run anywhere; grouped here
because `F-BOD-003`'s EMA smoothing is the one still-unbuilt §6 metric from
`40-ANALYTICS-SPEC.md`, closing that gap from the Phase 3 audit above.
**4.5** groups every remaining `F-ANA-*` metric with `F-PRG-011` (deload
suggestion), since it depends on two of them (`F-ANA-009` stall detection,
`F-ANA-010` ACWR) and both need real history to tune thresholds against —
this is also the batch that finally makes "insight cards say nothing when
data is insufficient" a testable exit criterion rather than an aspiration.
**4.6** is trailing odds and ends with no dependents of their own, same
reasoning Phases 2–3 gave their own trailing batches.

**Exit criteria — all four met at v0.43.0. Phase 4 complete.**
- [x] Starting a routine day pre-fills targets that are correct, explained, and
      always assemblable from the configured plates.
      `test/data/repositories/workout_repository_test.dart`'s "plate-aware
      rounding on proposed targets" group calls `startFromRoutineDay` through
      a real plate inventory and asserts the `plateRoundingHeld` rationale
      end-to-end, not just the domain-level rounding function in isolation.
- [x] Every progression rule has fixture tests for success, partial, failure,
      and first-run paths. True for linear, double-progression and
      RPE-autoregulation. One deliberate exception: percentage-of-training-max
      has no success/partial/failure verdict *by design* (`F-PRG-004`'s own
      spec — the training max moves by hand, not by session performance), so
      its fixture covers the percentage computation and the no-training-max
      fallback instead — the shape that actually applies to it.
- [x] The plate calculator never proposes plates the user doesn't own.
      `test/domain/plates/plate_calculator_test.dart`'s `plateMaths` fixture,
      reinforced by the same end-to-end repository test above.
- [x] Insight cards say nothing at all when data is insufficient.
      `test/domain/analytics/weekly_insights_test.dart` at the domain level;
      `test/features/shell/weekly_insights_section_test.dart` through the
      real `DashboardScreen` — no section renders with fewer than 3 distinct
      weeks of history, the widget-level proof Phases 2–3's own audits made
      the standard.

---

## Phase 5 — Data

Makes the ownership claim real, and de-risks the signing migration before any
public release.

The minimal dump (`F-DAT-011`) already exists from Phase 1 as a schema-mistake
escape hatch; this phase builds the real, versioned, round-trip-guaranteed
format on top of it.

| Batch | Features | Reads |
|---|---|---|
| **5.1** Round-trip spine | `F-DAT-001` `F-DAT-003` `F-DAT-004` `F-DAT-010` | `21-DATA-MODEL` `22-UNITS#import-and-export` |
| **5.2** CSV export & auto-backup | `F-DAT-002` `F-DAT-008` | `21-DATA-MODEL` `22-UNITS#import-and-export` |
| **5.3** Third-party import | `F-DAT-005` `F-DAT-006` `F-DAT-007` | `21-DATA-MODEL` `22-UNITS#import-and-export` |
| **5.4** Photos & app lock | `F-BOD-004` `F-SET-010` | `21-DATA-MODEL#body_measurements` `22-UNITS` |

Ordering rationale: the phase's own exit criterion is a round trip — export,
wipe, import, reproduced exactly — so the four P0/P2 features that criterion
actually names (`F-DAT-001` JSON export, `F-DAT-003` backup file, `F-DAT-004`
restore, `F-DAT-010` wipe) ship together in **5.1** rather than split across
batches the way their individual priorities alone would suggest; a JSON export
nothing can read back is not a shippable increment on its own. **5.2** is the
two remaining P1/P2 export-side features with no dependents of their own.
**5.3** groups the three third-party importer features together since
`F-DAT-006` and `F-DAT-007` both depend on `F-DAT-005`. **5.4** is unrelated
to the rest of the phase (progress photos and an app-lock PIN) and trails for
the same reason prior phases' odds-and-ends batches did.

**Batch 5.1 done.** `F-DAT-001`, `F-DAT-003`, `F-DAT-004`, `F-DAT-010` all
done. No schema change — every table already carries `SyncColumns`
(`id`/`created_at`/`updated_at`/`deleted_at`), so a generic, schema-agnostic
implementation covers all of them without per-table code.
`lib/data/io/json_export_service.dart` (`F-DAT-001`) is `JsonDumpService`'s
(`F-DAT-011`) same one-table-at-a-time streaming format with one addition, an
explicit `"units":"canonical-v1"` marker — the two rescue-vs-real exporters
stay deliberately separate files since `F-DAT-011`'s own spec says it "has no
import counterpart," but they are otherwise identical, and this is the format
`F-DAT-004` reads back. `lib/data/db/table_snapshot_io.dart`
(`TableSnapshotIo`) is the shared delete/reinsert engine both restore and
wipe need: `deleteAllRows()`, `restoreFrom(tables)`, and
`purgeTombstonesBefore(cutoff)` (`F-DAT-010`'s own spec names tombstone purge
as belonging here, alongside the wipe-to-first-run action). All three run
inside a Drift transaction with `PRAGMA defer_foreign_keys = TRUE`, so table
order never has to match the FK graph and any failure mid-restore rolls back
completely — the transactionality `F-DAT-004` §3 requires. `BackupService`
(`F-DAT-003`) wraps the export into a timestamped file kept in the app's own
documents directory (not just handed to the share sheet) specifically so
`RestoreService`'s automatic pre-restore safety copy (`F-DAT-004` §4) can be
taken without user interaction. Restore is version-checked by exact
`schemaVersion` match (`F-DAT-004` §2) — this app only ever migrates the
database it opens on launch, never a restore's raw rows, so a backup from any
other schema version is refused with a clear message rather than partially
applied, satisfying `F-DAT-004`'s "never leaves a half-populated database"
acceptance criterion by construction rather than by best-effort. Settings ›
Data gained backup/restore (file picker + a `ConfirmSheet` naming what will
be lost) and wipe (typed "DELETE" confirmation — stronger than
`ConfirmSheet` alone, since a wipe destroys strictly more than any other
destructive action in the app). Round-trip proven directly:
`test/data/db/table_snapshot_io_test.dart`'s "export, wipe, restore
reproduces every table exactly" deliberately includes a soft-deleted row —
the case that would silently vanish if the exporter were built on
repository reads (which filter `deleted_at`) instead of raw table selects.
Not built: passphrase encryption (`F-DAT-003`'s spec calls it "optional")
and bundling progress photos (`F-BOD-004` doesn't exist yet, batch 5.4) —
both explicit deferrals with nothing to gate consent on yet, not silent
drops. `F-DAT-005`–`F-DAT-008` remain `planned`, batches 5.2–5.3.

**Batch 5.2 done.** `F-DAT-002`, `F-DAT-008` both done. No schema change.
`lib/data/io/csv_export_service.dart` builds three CSVs (sets, measurements,
routines) via new one-shot export queries on the existing repositories and a
dependency-free `csv_writer.dart` RFC 4180 encoder — display units
throughout, named in each header, via the existing `UnitPreferences`.
`ExportSharer` gained `shareAll` so the three files go out in one share-sheet
action rather than three separate prompts. `BackupService
.maybeCreateAutomaticBackup()` runs fire-and-forget from `main()` on every
launch, writing a new `fitnessapp-autobackup-*` file only once 24 hours have
passed since the last one and pruning to the 7 most recent — kept in its own
filename namespace so rotation never touches a manual backup or a restore's
pre-restore safety copy. Not built: true OS-level scheduled execution while
the app is closed — this batch's automatic backup runs on launch only, the
same scope already drawn for `F-TIM-003`'s background timer and for the same
toolchain reason (no Android SDK this session, `flutter build apk` is
CI-only). `F-DAT-005`–`F-DAT-007` remain `planned`, batch 5.3.

**Batch 5.3 done.** `F-DAT-006`, `F-DAT-007` done; `F-DAT-005`
`in-progress` — its own acceptance note has the one unmet criterion (a real
Strong export's dates/weights/set-types, unverifiable this session with no
real export file to test against). No schema change. One shared engine,
`domain/import/csv_import_adapter.dart`'s `CsvImportAdapter`, driven by a
declarative `ColumnMapping` per format — Strong and Hevy are two data values,
not two importers, closing `F-DAT-006`'s own "third format is a mapping
file" ask before a third format even exists. Columns are matched by header
**name**, not position, against a per-field list of candidate spellings,
closing `F-DAT-005`'s "support detection of multiple layouts" open question
directly: an unrecognised layout throws naming exactly which required field
is missing, rather than guessing. The source unit (§3) is read from the
weight column's own header or a separate unit column; genuinely ambiguous
throws `AmbiguousUnitException` before a single row is parsed, and
`ImportScreen` asks rather than falling back to the app's own display
preference — a display setting is not evidence about a file's contents.
`domain/import/import_exercise_matcher.dart` reuses `exercise_search.dart`'s
`foldForSearch` for exact/alias matching, deliberately not that module's own
substring search. `data/io/import_service.dart`'s `ImportService.commit` is
idempotent at the workout level (a workout already at the source's exact
`started_at` is skipped, not duplicated) and runs the whole write in one
transaction with `PRAGMA defer_foreign_keys = TRUE`, the same shape
`TableSnapshotIo` proved out in batch 5.1; `PersonalRecordRepository
.rebuildAll` runs afterward, since the PR cache can't find a bulk-imported
history's best values incrementally. `domain/import/import_mapping_state.dart`'s
`ImportMappingState` is `F-DAT-007`'s "remembers decisions" rule as a pure,
tested reducer — one decision per distinct exercise name, applied to every
row with that name — with `ImportScreen` as the thin UI over it, reusing
`F-LOG-002`'s own exercise picker for "use existing" rather than building a
second one. Not built: distance import (exactly as unit-ambiguous as weight,
but no acceptance criterion needs cardio-distance correctness) and a CSV's
missing UTC offset is filled with the device's current offset at import
time, the same best-effort choice `app_database.dart`'s own `from < 3`
migration already made once — both documented in `F-DAT-005`'s own status
note.

**Batch 5.4 done — the last scheduled batch of Phase 5.** `F-BOD-004`,
`F-SET-010` both done. Schema v7 adds `progress_photos`
(`id`/`taken_at`/`taken_at_tz_offset_minutes`/`file_path`/`notes`, plus the
universal `SyncColumns`) — the first schema change since v6
(`F-PRG-010`). `ProgressPhotoRepository` copies a picked file into an
app-private `photos/` subdirectory; the row only ever holds a relative path,
which is what makes photos excluded from a JSON backup **by construction**
(`JsonExportService`/`JsonDumpService` dump DB tables only) rather than by a
filter that could be forgotten — satisfying spec §3's default directly. The
opt-in half of §3 (bundling photos into a backup on request) is not built:
today's backup is one JSON file, and base64-encoding photo bytes into it
would defeat `F-DAT-001`'s own streaming acceptance criterion — a real
archive format is the honest way to do this and is deferred, not silently
dropped, alongside the documented consequence that a restore onto a fresh
device leaves photo rows with dangling file paths. Deleting a photo
tombstones the row *and* deletes the file, the second deliberate exception
to "nothing is ever hard-deleted" this codebase has made (alongside
`F-DAT-010`'s wipe). `F-SET-010`'s app lock is PIN only, off by default:
`PinHasher` (`core/security/pin_hasher.dart`) stores a salted SHA-256 hash
via `SharedPreferences`, never the PIN itself; `AppLockGate` wraps
`MaterialApp.router`'s `builder` and is a genuine no-op with no PIN
configured — verified by re-running the full widget suite after adding it,
not assumed — and re-locks on every return from the background, not just
cold start. Biometric unlock is not built: `local_auth` needs platform
manifest/entitlement work this session's toolchain (no Android SDK, no
device) can't responsibly add without verifying it, the same class of
deferral as `F-TIM-003`'s background notification. Both features' own status
notes are explicit that neither is encryption at rest — a PIN and an
excluded-by-construction photo path gate casual access, nothing more.

**Exit criteria — Phase 5 complete, with one criterion explicitly waived by
the project owner (see below).**
- [x] Export → wipe → import reproduces the database exactly, verified table by
      table. `test/data/db/table_snapshot_io_test.dart`.
- [ ] ~~A real Strong export imports with correct dates, weights, and set
      types, and refuses to guess when units are ambiguous.~~ **Waived.** No
      real Strong export file was available in any session to test against;
      ambiguous-unit refusal itself is proven
      (`test/domain/import/csv_import_adapter_test.dart`), but not against
      real data. Checked on paper instead — `strongColumnMapping`'s column
      candidates and warm-up detection were compared against Strong's
      publicly documented export format and line up — and the project owner
      accepted that as sufficient rather than leaving the criterion open
      indefinitely. See `F-DAT-005`'s own status note; worth re-running
      against a real export if one ever turns up. `F-DAT-005` stays
      `in-progress` for this reason even though the phase is closed, the
      same shape `F-TIM-003` left open when Phase 1 closed.
- [x] A restore that fails partway leaves the existing database untouched.
      `test/data/io/restore_service_test.dart`.
- [x] Progress photos are excluded from backups unless explicitly opted in.
      By construction — `JsonExportService`/`JsonDumpService` dump DB tables
      only, so a photo's bytes have no path into either.

---

## Phase 6 — Publish

Everything required to hand the app to strangers.

| Batch | Features | Reads |
|---|---|---|
| **6.1** Accessibility | `F-A11Y-001` `F-A11Y-002` `F-A11Y-003` `F-A11Y-005` | `24-DESIGN-SYSTEM#accessibility-baseline` |
| **6.2** Localisation & branding | `F-I18N-001` `F-THM-006` | `22-UNITS` `24-DESIGN-SYSTEM` |
| **6.3** Onboarding | `F-SET-011` | `22-UNITS` |
| **6.4** Release | `F-REL-004` `F-REL-006` `F-REL-007` | `62-RELEASE` `61-CI-CD` `10-VISION#non-goals` |
| **6.5** Health | `F-HLT-001` `F-HLT-002` | `20-ARCHITECTURE#cross-platform-discipline` |

Ordering rationale: **6.1** first — every other Phase 6 batch adds new
screens or flows that would otherwise ship without the accessibility
baseline `24-DESIGN-SYSTEM` §128 already claims every feature carries, and
the phase's own first exit criterion names it directly. `24-DESIGN-SYSTEM`
itself groups I18N and branding, so **6.2** stays paired; `F-REL-006`
(store listing) depends on `F-THM-006` (app icon), which is why branding
sits ahead of release rather than trailing with the rest of `REL`.
**6.3** (onboarding) is small and self-contained. **6.4** groups every
store-facing release feature. **6.5** (Health Connect) is last: `F-HLT-002`
depends on `F-BOD-001` (done, Phase 1), needs nothing from the rest of the
phase, and is the one batch this session's toolchain — no Android SDK, no
device — cannot build or verify at all, so it is deliberately not attempted
here.

**Batch 6.1 — accessibility, partial.** `F-A11Y-001` and `F-A11Y-003` done;
`F-A11Y-002` and `F-A11Y-005` `in-progress` (each for its own documented
reason below). No schema change. `24-DESIGN-SYSTEM` §130 states accessibility
"is not a Phase 6 retrofit" — true in part: `SetRow` (`F-LOG-003`) already
carried a full semantic label, a >22sp text-scale stacking threshold, and
colour-plus-letter set-type encoding since it was built, and
`app_theme_test.dart` already held `AppColors`' semantic-role pairs to
4.5:1. What this batch found genuinely missing on auditing the rest of the
app: only 3 files used `Semantics` at all, 1 read `MediaQuery.textScal*`,
and none checked `disableAnimations` — the same gap `F-ANA-016`'s own status
note had already flagged for charts specifically. `F-A11Y-001`: `TrendChart`
and `WeeklyBarChart` are canvas-painted by `fl_chart`, not semantic, so a
screen reader got nothing from either — both now wrap their chart in
`Semantics(label: ...)` over an `ExcludeSemantics`-wrapped chart, the label
built from the same `points`/`valueLabel` the chart already renders (count,
range, first/last, trend direction for the line chart; count and the
highest bar for the bar chart) — a summary standing in for the chart, not a
transcription of every point. `F-A11Y-003`: the existing 4.5:1 test covers
every `AppColors` semantic pair; the spec's other named figure, 3:1 for
interactive boundaries, was untested — one line added asserting
`ColorScheme.outline` against `surface` in both themes, which passes by
construction from Material 3's own seeded scheme. "No colour alone" was
already true (set-type letters, chart-series-as-single-series, `PrBadge`'s
icon) and needed no new code. `F-A11Y-005`: `TrendChart` and
`WeeklyBarChart` now pass `duration: Duration.zero` to their underlying
`fl_chart` widgets when `MediaQuery.disableAnimations` is set, and
`PrBadge`'s 350 ms entrance `TweenAnimationBuilder` does the same;
`CalendarHeatmap` has no animation of its own and needed no change. Left
`in-progress`, not `done`: `F-A11Y-005`'s own "instant transitions" clause
also covers page-route transitions, which this batch did not touch —
gating `MaterialApp.router`'s `PageTransitionsTheme` is an app-wide change
this batch's chart-scoped fix deliberately did not expand into. `F-A11Y-002`
stays `in-progress` for the same reason `24-DESIGN-SYSTEM` §130's claim is
only partly true: `SetRow`'s own stacking behaviour is now proven at the
screen level, not just the widget level, by a new 200%-scale
`ActiveWorkoutScreen` render test and a new 200%-scale `ExerciseDetailScreen`
render test (the app's other genuinely dense, chart-bearing screen) — both
added `pumpApp`/`pumpScreen` `textScale` support (`pumpScreen` already had
it; `pumpApp` did not, and needed `tester.platformDispatcher
.textScaleFactorTestValue` rather than `pumpScreen`'s `MediaQuery`-wrapping
trick, since `MaterialApp.router` builds its own root `MediaQuery` from the
view rather than inheriting an ancestor one). Every other screen in the app
— catalogue, history, routines, insights, settings — remains unverified at
200%; auditing all of them was judged too large for one batch and is left
for a future accessibility pass, not silently claimed done.

**Batch 6.1, second pass — reduce-motion page transitions.** `F-A11Y-005`
now `done`. `ReducedMotionPageTransitionsBuilder`
(`lib/core/theme/app_theme.dart`) wraps each platform's default
`PageTransitionsBuilder` in `AppTheme`'s new `pageTransitionsTheme`,
returning the incoming child untouched — no fade, no slide, no scale —
whenever `MediaQuery.of(context).disableAnimations` is true, and delegating
to the normal platform transition otherwise. Closes the one clause the
first pass of this batch deliberately left open. `F-A11Y-002` (the
200%-scale screen audit) is untouched and stays `in-progress`.

**Batch 6.1, third pass — the rest of the 200%-scale audit.** `F-A11Y-002`
now `done`, closing batch 6.1 entirely. Every reachable screen left
unaudited after the first pass (`ActiveWorkoutScreen`,
`ExerciseDetailScreen`) now has its own 200%-scale render test —
`DashboardScreen`; the three history screens; the four routine screens;
both catalogue screens; the three remaining analytics screens; the two
body screens; the two remaining logging screens; `OnboardingScreen`; and
all nine Settings screens. `PlaceholderScreen` is the one screen file left
untested — dead code with no call site anywhere in `lib/`, not an
unaudited live one. The audit found two real overflow bugs and fixed both:
`AppearanceScreen`'s ghost-value preview `Row` overflows horizontally at
200% (now a `Wrap`, matching the swatch row directly above it that already
used one); `OnboardingScreen`'s welcome page — built in batch 6.3, days
before this audit — centred its content in a fixed `Column` that overflows
vertically at 200% (now a `SingleChildScrollView`, matching its other two
pages, both already `ListView`s).

**Batch 6.2 — localisation & branding, partial.** `F-I18N-001`
`in-progress`; `F-THM-006` not attempted, left `planned`. No schema change.
`F-THM-006` (icon, adaptive icon, splash): deliberately deferred rather than
generated. `flutter_launcher_icons`/`flutter_native_splash` write platform
mipmaps and mutate `AndroidManifest.xml`/`Info.plist` from a source image —
this session's toolchain has no Android SDK and no device to render or
verify the result against, the same class of deferral as `F-TIM-003`'s
notification layer and `F-ANA-014`'s SVG sourcing. A source image generated
programmatically and committed as a real brand icon without ever seeing it
on a launcher was judged worse than leaving the feature `planned` with the
reason on record; `F-REL-006` (store listing) depends on this and stays
untouched too. `F-I18N-001`: the ARB pipeline is real, not stubbed —
`flutter_localizations` (sdk), `flutter: generate: true`, `l10n.yaml` with
`synthetic-package` omitted (deprecated, and this repo's own convention is
committed generated code, same as drift's `.g.dart`, so `lib/l10n/generated/`
is tracked, not gitignored) and one seed `lib/l10n/app_en.arb`.
`AppLocalizations.delegate`/`supportedLocales` are wired into
`MaterialApp.router` in `app.dart`; both `pumpScreen` and `pumpApp` in
`test/support/harness.dart` carry them too — `pumpApp` needed no change
(`FitnessApp` already provides them), but `pumpScreen`'s bare `MaterialApp`
did, since any migrated widget calling `AppLocalizations.of(context)!`
would otherwise null-assert in every existing test that renders it.
`SettingsScreen` is migrated end to end (18 keys, the whole screen) as the
one complete, verified slice — chosen because it is self-contained (no
`pumpApp`-level navigation test asserts its exact strings) rather than for
being small. Deliberately not routed through ARB: unit symbols
(`docs/22-UNITS.md` owns `kg`/`lb`/etc. as canonical-unit display, not
translatable copy) and anything `QuantityFormatter`/`intl` already format
(numbers, dates, durations). Every other screen in the app is still
English-string literals — genuinely most of the app, not a rounding error —
left for future batches now that the pipeline itself is proven rather than
attempted as one all-at-once sweep.

**Batch 6.2, second pass — four more screens.** `F-I18N-001` still
`in-progress` — genuinely most of the app remains English literals, but
three of the five tab-root screens are now migrated:
`DashboardScreen`, `HistoryScreen`, `RoutineListScreen` (plus the shared
`promptRoutineName` dialog it defines, called from every other routines
screen), and `ConfirmSheet` — the one confirmation sheet every destructive
action in the app routes through, whose default button labels moved from a
literal parameter default (Dart requires those to be compile-time
constants) to a null default resolved from `AppLocalizations` in the
function body. ICU plurals cover exercise counts on both newly migrated
screens' workout tiles. Deliberately not touched: `AppShell`'s bottom-nav
labels are a `static const List<ShellDestination>` an existing test
asserts against directly — localizing it needs a real restructure, not a
mechanical pass, so it waits for a batch that can give it its own
attention. Found and preserved rather than silently fixed while moving
strings into ARB: the routine-delete confirmation carried a literal
internal doc citation, `` (`ADR-0004`) ``, real broken-looking copy for an
end user — kept verbatim in the ARB value, with a follow-up task filed to
fix the copy itself separately from this migration.

**Batch 6.2, third pass — the last two tab-root screens.** `F-I18N-001`
still `in-progress`. `ExerciseCatalogScreen` and `InsightsScreen` are now
migrated — the latter by far the largest single-screen migration yet, over
40 keys across every section heading, empty/insufficient-data state and
explanatory paragraph. All five tab-root screens are migrated at their top
level now, `ExerciseCatalogScreen` makes a sixth real screen. Deliberately
left as literals within `InsightsScreen`, same reasoning `22-UNITS.md`
already applies to unit symbols: rep-range/intensity-zone bucket labels and
every chart `valueLabel` formatter closure read as formatted numeric
ranges, not translatable prose. `date_range_selector.dart`'s own chip
labels are a separate widget this pass didn't touch, so the range-preset
prose now exists in ARB under two different names for the two different
places it's read from — a duplication to reconcile once that selector is
migrated, not a bug now. Still English literals: routine/exercise
sub-screens beyond the list, the rest of logging, the rest of history,
body, `ConsistencyScreen`/`PrTimelineScreen`, every Settings sub-screen
beyond the root, `AppShell`'s nav labels, and onboarding.

**Batch 6.2, fourth pass — the rest of logging.** `F-I18N-001` still
`in-progress`. `ActiveWorkoutScreen` — the app's densest screen — is now
fully migrated: every dialog, sheet, overflow-menu item, and a message
with two independent ICU plural clauses in one string (`"{exercises,
plural, ...} and {sets, plural, ...} will be removed..."`), alongside
`StartWorkoutScreen` and `SessionSummaryScreen`. Deliberately not followed
into the shared widgets this screen only *renders* — `SetRow`,
`AddSetButton`, `RestTimerBar`, and `fieldHeader()` (called from three
separate presentation files, none of which have a `BuildContext` where the
call happens) — each is its own unit with call sites across multiple
screens, the same "needs its own batch" reasoning already applied to
`AppShell`. Still English literals: routine/exercise sub-screens beyond
the list, the rest of history, body, `ConsistencyScreen`/
`PrTimelineScreen`, every Settings sub-screen beyond the root, `AppShell`'s
nav labels, the shared widgets named above, and onboarding.

**Batch 6.2, fifth pass — the routine editor.** `F-I18N-001` still
`in-progress`. `RoutineEditorScreen` (both the multi-day list and the
single-day-collapses-inline case) is migrated, reusing several keys
`RoutineListScreen`'s own pass already defined
(`routinesDeleteConfirmTitle`/`Message`, `routinesDuplicateAction`,
`routinesArchiveAction`, `routinesDeleteAction`, `routinesNoDaysYet`)
rather than duplicating near-identical text — the per-screen-prefix
convention is a default for independent copy, not a rule against reuse
when two screens describe the same action. `RoutineDayEditorScreen` —
1,000+ lines, several complex sub-widgets including the five-segment
progression target sheet and the weekday scheduler `RoutineEditorScreen`
itself already imports from it — is deliberately left for its own batch,
large enough by this file's own sizing precedent (`InsightsScreen`, the
previous largest single migration, was roughly 700 lines) to be a unit of
work on its own. Still English literals: `RoutineDayEditorScreen`, the
rest of history, body, `ConsistencyScreen`/`PrTimelineScreen`, every
Settings sub-screen beyond the root, `AppShell`'s nav labels, the shared
logging widgets, and onboarding.

**Batch 6.2, sixth pass — the routine day editor.** `F-I18N-001` still
`in-progress`. `RoutineDayEditorScreen` — the file the previous pass
deliberately deferred — is now fully migrated: the exercise list's empty
state and superset multi-select bar (including its ICU plural,
`"{count, plural, one{1 selected} other{{count} selected}}"`), the
target-editor sheet's every field across all five progression-rule
segments, the `_RoutinePreviewCard`'s duration/volume labels, and the
"already training" resume sheet reached from `StartDayButton`. The one
structural change: `formatScheduledWeekdays`'s weekday abbreviations were a
module-level `const List<String>`, which has no `AppLocalizations` to read
— unlike a widget's `build()`, a plain module constant is evaluated once at
load time with no `BuildContext` in reach. Rather than thread a
`BuildContext` through what should stay a pure formatting function, the
constant became `weekdayAbbreviations(AppLocalizations l10n)`, resolved
once by each of the two real call sites (the scheduler sheet's own chip
row, and `RoutineEditorScreen`'s `_DayTile`) and passed into
`formatScheduledWeekdays(weekdays, abbreviations)` alongside the data —
the function itself stays pure and independently testable, just no longer
hard-coded to English. Several keys are reused rather than duplicated,
the same judgment the fifth pass made for `RoutineEditorScreen`:
`routineEditorScheduleAction`/`routineEditorMenuRename`/
`routineEditorExercisesReadError`/`routineEditorRenameDayTitle`
(exact-text matches from the parent screen's own pass), `routineNameDialogSave`/
`routineNameDialogCancel` (this app's only existing generic Save/Cancel
pair), and `startWorkoutAlreadyTrainingTitle` for the already-training
sheet's title — its message needed its own key,
`routineDayEditorAlreadyTrainingMessage`, since this call site's
`ActiveWorkoutExistsException` catch block has no workout name to interpolate,
unlike `StartWorkoutScreen`'s version of the same sheet. Still English
literals: the rest of history, body, `ConsistencyScreen`/
`PrTimelineScreen`, every Settings sub-screen beyond the root, `AppShell`'s
nav labels, the shared logging widgets, and onboarding.

**Batch 6.2, seventh pass — the rest of history.** `F-I18N-001` still
`in-progress`. `WorkoutDetailScreen`, `EditPastWorkoutScreen`,
`HistorySetRow`, and `LogPastWorkoutSheet` are now fully migrated —
`HistorySetRow` needed its own pass regardless of the still-deferred shared
`SetRow`, since it is a deliberately trimmed-down, independent widget (no
ghost value, no rest timer), not a wrapper around it. Reuses several
exact-text keys already defined elsewhere rather than minting new ones:
`sessionSummaryDurationLabel`/`sessionSummaryExercisesLabel`,
`routinesDeleteAction`, `routineDayEditorAddExercisesAction` (three call
sites now), `activeWorkoutRemove`/`activeWorkoutRemoveExerciseConfirmTitle`/
`activeWorkoutUndo`, and the already-training title/resume/cancel trio the
sixth pass established — `WorkoutDetailScreen`'s "repeat this workout"
conflict sheet is the third call site for that exact message, after
`StartWorkoutScreen`'s differently-worded version and the routine day
editor's. The one screen-specific exception: the past-workout editor's
remove-exercise confirmation is unconditional prose ("Its sets in this
session will be removed too."), unlike the live logger's completed-set-count
plural — editing history has nothing analogous to count, so it kept its own
key rather than being forced into the active-workout message's shape. Still
English literals: body, `ConsistencyScreen`/`PrTimelineScreen`, every
Settings sub-screen beyond the root, `AppShell`'s nav labels, the shared
logging widgets, and onboarding.

**Batch 6.2, eighth pass — the body feature.** `F-I18N-001` still
`in-progress`. `BodyWeightScreen`, `LogBodyweightSheet`,
`LogMeasurementSheet`, `ProgressPhotosScreen`, and
`TrackedMeasurementsSheet` are now fully migrated; `measurement_labels.dart`
stays untouched, the same enum-label exclusion `exercise_labels.dart` has
had since the catalogue pass. `bodyPhotosTitle` and
`bodyMeasurementsToTrackAction` are each reused across two call sites
(an app-bar tooltip and the screen/sheet the tooltip opens, sharing exact
text); `bodyLogAction` ("Log {type}") covers the one real repeated
pattern — a per-measurement add tooltip and a log sheet's create-mode
title both saying "Log " plus the same label — while the edit-mode titles
stayed separate keys rather than being forced through the same
placeholder, since bodyweight's own phrasing ("Edit bodyweight") isn't
shaped like the generic "Edit {label}" the other measurements use. Still
English literals: `ConsistencyScreen`/`PrTimelineScreen`, every Settings
sub-screen beyond the root, `AppShell`'s nav labels, the shared logging
widgets, and onboarding.

**Batch 6.2, ninth pass — consistency and PR timeline.** `F-I18N-001`
still `in-progress`. `ConsistencyScreen` and `PrTimelineScreen` are now
fully migrated. `PrTimelineScreen._describe`'s own doc comment claims it
mirrors `SessionSummaryScreen._describe` with "same wording", but the two
actually differ in casing (session summary is lowercase inline text; the
timeline's own version is sentence-case, standing alone as a whole list-tile
subtitle) — three of the four PR-kind messages got their own sentence-case
keys rather than forcing one casing to fit both call sites, while the
fourth ("{reps} reps at {weight}") starts with a number and is genuinely
identical either way, so `sessionSummaryPrRepsAtWeight` is reused as-is.
`consistencyStreakWeeks` ("{weeks} wk") follows the non-pluralized-
abbreviation pattern the seventh pass's "min" key established — "wk"
doesn't inflect in English regardless of count. Still English literals:
every Settings sub-screen beyond the root, `AppShell`'s nav labels, the
shared logging widgets, and onboarding.

**Batch 6.2, tenth pass — six Settings sub-screens.** `F-I18N-001` still
`in-progress`. `AboutScreen`, `AppLockScreen`, `AppearanceScreen`,
`E1rmFormulaSheet`, `RestTimerScreen`, and `UnitsScreen` are now migrated —
the smaller six of Settings' nine sub-screens, taken together since each
averages under 170 lines; `DataScreen`/`ImportScreen`/`PlateSettingsScreen`
(462/350/389 lines) are left for their own pass. Left as literals on
purpose: `E1rmFormulaSheet`'s three formula subtitles ("w × (1 + reps /
30)" etc.) are mathematical notation, the same "formatted, not prose"
exclusion `InsightsScreen`'s bucket labels already established;
`AppearanceScreen`'s ghost-value demo localizes only the "last time:"
prose, leaving both illustrative weight values literal, matching
`UnitsScreen`'s own preview rows (already `QuantityFormatter` output, this
file's unit-symbol exclusion since the catalogue pass). `unitsBodyweightTitle`
is reused for both the unit-choice row and the identical-text preview row
label, the same real-reuse judgment the ninth pass applied elsewhere; the
fourth appearance swatch reuses `routinesDeleteAction` rather than minting
a near-duplicate, since its label is literally "Delete". Still English
literals: `DataScreen`, `ImportScreen`, `PlateSettingsScreen`, `AppShell`'s
nav labels, the shared logging widgets, and onboarding.

**Batch 6.2, eleventh pass — the last three Settings sub-screens.**
`F-I18N-001` still `in-progress`, but Settings itself is now fully
migrated: `DataScreen`, `ImportScreen`, and `PlateSettingsScreen` close out
all nine sub-screens. Found and fixed, not just translated: the wipe
confirmation dialog displayed "Type DELETE to confirm" but compared
`controller.text` against a hardcoded `'DELETE'` literal — once the prompt
read from `l10n.dataWipeConfirmKeyword`, keeping the comparison hardcoded
would have silently broken the flow the moment a translation changed the
displayed word, so the same `keyword` variable now drives both the display
and the equality check. `ImportScreen` gained two proper ICU plurals
(`importUnresolvedMessage`, `importSkippedSuffix`) replacing the source's
own `length == 1 ? '' : 's'` ternaries and `plateSettingsPairsAvailable`
replaces `_PlateRow`'s `"pair(s) available"` shorthand the same way — real
cleanup, not preservation, since a crude-but-legible plural marker isn't
the kind of broken copy earlier passes have deliberately kept verbatim
(the routine-delete `ADR-0004` citation). `importResultMessage`'s own
"workouts"/"sets" wording stays deliberately non-pluralized, since the
source never conditioned it on count either — the two ternaries were
fixed because they were already trying to pluralize and doing it crudely;
this one was never trying, so nothing needed fixing. Every screen in the
app is now migrated except `AppShell`'s nav labels, the shared logging
widgets, and `OnboardingScreen`.

**Batch 6.2, twelfth pass — AppShell's nav labels.** `F-I18N-001` still
`in-progress`. `AppShell.destinations`, a `static const` that couldn't
call `AppLocalizations` (const evaluation has no `BuildContext`), became
`static List<ShellDestination> destinationsFor(AppLocalizations l10n)`,
the same shape the sixth pass's `weekdayAbbreviations(l10n)` used for an
identical problem. Four of the five labels reuse another screen's exact
title (`routinesTitle`, `startWorkoutTitle`, `historyTitle`,
`insightsTitle`) rather than duplicate it — a tab and the screen it opens
are the same name; the fifth, "Home", is a new key (`shellHomeLabel`)
since the dashboard's own app bar shows the FitnessApp brand instead.
`navigation_test.dart`'s "shows five destinations" test — the reason this
was deferred — now resolves `AppLocalizations` from a pumped widget's
context and calls `destinationsFor` directly; every other assertion in
the test was already generic over `destination.label`. Only the shared
logging widgets and `OnboardingScreen` remain.

**Batch 6.3 — onboarding.** `F-SET-011` done — the last item Phase 6
scheduled ahead of release/health. No schema change.
`OnboardingScreen` (`lib/features/onboarding/presentation/`) is a
three-page `PageView` at `/onboarding` — welcome, then units/theme, then an
optional starter-program import — with `Skip` reachable from every page,
not just the first. `onboardingCompletedProvider` is a
`SharedPreferences`-backed flag, the same shape `themeModeProvider` already
used; `startupLocationFor` (`lib/features/logging/application/
active_workout_providers.dart`) now takes it as a required param and
returns onboarding whenever it's unset, checked ahead of even
`F-LOG-007`'s kill-recovery redirect — a first-run device is never
mid-workout, so the two checks can never actually conflict, but onboarding
is still the one that wins by construction. §2's "every choice changeable
later" holds without any explicit sync step: the units/theme page reads and
writes `unitPreferencesProvider`/`themeModeProvider` directly, the exact
providers Settings itself uses, so there is no separate onboarding-only
copy of either value. The starter-routine page is a compact reuse of
`RoutineRepository.importStarterProgram` (`F-ROU-015`), landing on the new
routine on success exactly like the full gallery screen does. §3 ("no
account, no email, no permission prompts") needed no code to satisfy —
nothing in the screen asks for any of the three, so it holds by omission.

**Batch 6.4 — release, partial.** `F-REL-004` done; `F-REL-007`
`in-progress`; `F-REL-006` untouched, still `planned` (depends on
`F-THM-006`, deferred in batch 6.2 for the same no-SDK/no-device reason).
Taken out of the roadmap's own batch order — ahead of 6.3 at first, since
`F-REL-007` is P0, needs no toolchain this session lacks, and was otherwise
the single highest-value thing to do before any store submission is even
possible; `F-REL-004` followed once 6.3 was done, for the same
no-toolchain-required reason. `PRIVACY.md` (repo root) is the checked-in
policy `F-REL-007` §4 asks for: no account, no telemetry, no network calls,
what's stored and where, that export/sharing is always user-initiated,
`F-DAT-010`'s wipe as the deletion story, and the Health Connect case for
if `F-HLT-001`/`F-HLT-002` ever ship. Its acceptance criterion's "verified
rather than asserted" is checked the strongest way available without a live
network capture: the release `AndroidManifest.xml` declares no `INTERNET`
permission at all (only the `debug`/`profile` manifests do — Flutter's own
template default for the DevTools connection, never present in a release
artefact), no HTTP/socket/analytics dependency exists in `pubspec.yaml`, and
no `dart:io` `HttpClient`/`Socket`/`InternetAddress` call exists anywhere in
`lib/`. Left `in-progress`: actually filling in and submitting the Play
Data Safety form and App Store Privacy Nutrition Label needs a live
developer console this session has no access to. `F-REL-004`:
`.github/workflows/release.yml` now runs `flutter build appbundle --release`
alongside the existing split-per-abi APK build, same tag, same version, same
signing env vars — no separate signing setup needed, since Gradle ties a
release signing config to the build variant, not the packaging task. The AAB
and its checksum join the APKs and theirs in the GitHub Release, combined
into one `checksums.txt` rather than two identically named files (GitHub
release assets need unique names). Not locally build-verified — no Android
SDK on this toolchain, the same constraint every CI-only release feature
since Phase 1 has carried — checked instead by reading the Gradle
signing-config scoping directly and a plain YAML syntax check.

**Exit criteria**
- [ ] Full app usable with a screen reader and at 200% text scale. Automated
      coverage is now complete for both halves — every screen carries
      semantic labels where `Semantics` matters (`F-A11Y-001`) and has its
      own 200%-scale render test with no overflow (`F-A11Y-002`) — but
      "usable" is an on-device claim a render test can't make on its own:
      real TalkBack/VoiceOver navigation order and announcement clarity
      still need a physical device this session doesn't have, the same
      class of gap Phase 1/3's own on-device-only criteria left open.
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
| 2 | 26 | 8 | Programs and templates |
| 3 | 17 | TBD | Analytics |
| 4 | 29 | TBD | Progression and automation |
| 5 | 11 | TBD | Data portability |
| 6 | 12 | TBD | Store release |
| — | 23 | — | Backlog |
| | **140 scheduled, 23 unscheduled, 163 defined** | | |

Live counts are in [`features.tsv`](features.tsv); `tools/check-docs.sh`
verifies this table still reconciles.
