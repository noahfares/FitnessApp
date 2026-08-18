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

**Accessibility** `F-A11Y-001` `F-A11Y-002` `F-A11Y-003` `F-A11Y-005`

**Localisation & branding** `F-I18N-001` `F-THM-006` `F-THM-007`

**Onboarding** `F-SET-011`

**Release** `F-REL-004` `F-REL-006` `F-REL-007`

**Health** `F-HLT-001` `F-HLT-002`

**Exit criteria**
- [x] Full app usable with a screen reader and at 200% text scale.
      `test/features/a11y/accessibility_test.dart` pumps all eleven top-level
      destinations at `TextScaler.linear(2)` and asserts a spoken alternative
      for every chart; `F-A11Y-001`–`005` are done.
- [x] Privacy policy and data-safety declarations match actual behaviour, with
      "no network calls" verified rather than asserted —
      `tools/check-network.sh` is a required CI check, and the manifest still
      declares no `INTERNET` permission (`PRIVACY.md`, `64-PRIVACY.md`).
- [ ] **Play internal testing track live, then production.** Needs a Play
      developer account and a human at the console; nothing in the repository
      blocks it. `store/LISTING.md` holds the copy, `release.yml` builds the
      `.aab` (`F-REL-004`), and the only missing artefact is screenshots,
      which need a device (`F-REL-006`).
- [ ] **The upgrade path from a sideloaded APK to the Play build is documented
      and tested.** Documented — [ADR-0007](70-decisions/ADR-0007-signing.md)
      and [`62-RELEASE.md`](62-RELEASE.md) §the-signing-hazard. **Not tested**,
      and untestable without both artefacts on a real device.

**Status: every scheduled feature is `done` except two, both blocked on
hardware rather than on work**: `F-TIM-003`'s "fires with the screen off /
under an aggressive battery manager" and `F-REL-006`'s screenshots. Declaring
the phase complete is the project owner's call, per `CLAUDE.md` — the two
criteria above are unmet, and both need a person with a phone and a Play
account rather than another session.

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
