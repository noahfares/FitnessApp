# Session contract for Claude Code

This repo is **planning-first**. `docs/` is the source of truth; code is
downstream of it.

New to the terminology? [`docs/01-PLAIN-ENGLISH.md`](docs/01-PLAIN-ENGLISH.md).

## Project in one line

An offline-first Flutter strength-training tracker that gives away free what
Strong / Hevy / JEFIT paywall: unlimited routines and custom exercises, real
analytics, progression automation, and full data export.

---

## Session recipes — follow these exactly

These exist to keep sessions cheap. **Read only what the recipe names.** Do not
explore the docs to build context; the context you need is declared for you.

### Implement a feature

1. Read `docs/30-features/<DOM>/<F-ID>.md`. The filename is the ID — no search
   needed.
2. Read **only** the documents listed in its `Reads:` line.
3. **Skip the `## Why` section** — it's rationale for the human, not the build.
4. Build it. Update `Status:` in the same commit.

### Implement a batch

`docs/50-ROADMAP.md` groups features into batches that share a `Reads:` set.
Read the shared documents **once**, then all the batch's feature files. This is
the cheapest way to work — prefer it over one feature at a time.

### Read one section of a document

`tools/read.sh <DOC>#<anchor>` prints just that section — `Reads:` lines name
sections, not files, and `21-DATA-MODEL` is 324 lines of which `#sets` is 30.
`tools/read.sh F-LOG-003` prints a feature file without its `## Why`, which the
recipe above says to skip anyway.

### Verify before committing

`tools/verify.sh` — format, analyze, test, layers, **network**, **strings**,
docs, in **CI's order**. CI's
first gate is `dart format --set-exit-if-changed`, which fails the job before a
single test runs, so a green local suite is not evidence of a green build.
`tools/verify.sh --fix` formats in place first.

**Run the full `tools/verify.sh` exactly once per session, right before the
commit.** It re-runs the entire suite and full analyzer every time — cheap
once, wasteful as a mid-development sanity check. While iterating, use the
targeted commands below instead and save the full run for the actual gate.

### Trigger a full CI run

`ci.yml` is manual (`workflow_dispatch`) only — it does **not** run on push.
`tools/verify.sh` is the everyday per-commit gate; CI is the occasional real
signal on top of it (a clean Flutter toolchain, no local drift, a fresh debug
APK). Trigger it explicitly:

```bash
gh workflow run ci.yml --ref main
```

Do this when closing out a phase, before a round of on-device manual testing,
or whenever asked for — not after every commit. `tag.yml` is unaffected: it
still tags every push to `main` regardless of whether CI has been run.

### Run the tests, and analyze, cheaply while iterating

`tools/test.sh` — failures only, one line when the suite is green (254 lines of
"passed" is 254 lines of nothing). `tools/test.sh -v` when debugging, and it
takes paths: `tools/test.sh test/domain`. **Scope it to the file or directory
you're touching** (`tools/test.sh test/domain/routines`), not the whole suite —
that's what the one-shot `verify.sh` at the end is for.

Same for the analyzer: `flutter analyze <path>` on the files just changed, not
`flutter analyze lib/`. After the first `flutter` call in a session, pass
`--no-pub` on subsequent ones — pub re-resolves and reprints its "Resolving
dependencies" preamble on every invocation otherwise, which is pure noise once
packages are already fetched.

Widget tests build on `test/support/harness.dart`; read it before writing a new
one rather than re-deriving the provider overrides. **Widget tests are for new
interaction or layout logic** — a screen that reveals a real bug if built
wrong (state toggles, reorder/drag, a layout that can starve a sibling of
space, as `_RoutinePreviewCard`'s `ExpansionTile` once did). **They are not
required for a widget that only renders data it's given** — a card, a tile, a
label — where a domain-level test on the data it renders plus a quick read of
the code is the cheaper and sufficient check. When in doubt, prefer a
pure-domain unit test (fast, no widget pump, no provider harness) over a
widget test that exercises the same logic through a screen.

### Check project state

Read `docs/features.tsv`. 163 rows, everything: phase, status, priority,
dependencies. Do **not** open spec files to answer "what's left" or "what's next".

### Add a feature

`tools/new-feature.sh <DOMAIN> "<title>"` — allocates the next ID, writes the
template, regenerates the index. Then fill it in.

### Verify the docs

`tools/check-docs.sh` — orphan IDs, `Reads:` targets, index freshness, roadmap
consistency, version agreement. One command; don't hand-roll grep pipelines.

### Regenerate the index

`tools/gen-index.sh` after adding or editing any feature header.
`docs/features.tsv` and `docs/30-features/INDEX.md` are **generated** — never
hand-edit them.

---

## Rules

1. **Every feature has an ID.** `F-<DOMAIN>-<NNN>`, one file each under
   `docs/30-features/`. Never build something with no entry — write the entry
   first. IDs are permanent and never reused.
2. **Update `Status:` in the same commit as the code.** The feature files are
   the only progress tracker. `idea → planned → in-progress → done →
   deferred | dropped`.
3. **Don't silently expand scope.** If a task reveals a missing feature, add it
   with `tools/new-feature.sh`, park it in `docs/51-BACKLOG.md`, and mention it.
   Don't build it.
4. **Ask before deviating from an ADR.** `docs/70-decisions/` is load-bearing.
   If one seems wrong, say so; don't route around it.

## Invariants — violating any of these is a bug, not a style choice

Canonical statement. Other documents link here rather than restating.

- **Canonical units only.** Weight in integer grams, distance in metres,
  duration in seconds. Imperial/metric is a *display* concern. Never a per-row
  unit flag. → `docs/22-UNITS.md`
- **`lib/domain/` imports nothing from Flutter and nothing from `lib/data/`.**
  All maths that can be silently wrong is pure Dart under test.
  → `docs/20-ARCHITECTURE.md`
- **Warm-up sets are excluded** from volume, PR, and e1RM maths, always.
  → `docs/40-ANALYTICS-SPEC.md`
- **Nothing is ever hard-deleted.** Every delete sets `deleted_at`; every read
  filters `deleted_at IS NULL`; every write sets `updated_at`. → `ADR-0008`
- **Every user-meaningful timestamp stores its local UTC offset.** Local dates
  derive from the pair, never from UTC alone. → `ADR-0008`
- **Workouts snapshot their template.** Editing a routine must never alter
  historical sessions. → `ADR-0004`
- **Write-through persistence.** Every set completion hits the DB immediately.
  An app kill mid-session must lose nothing.
- **No network calls in the core app.** Local-first, no account, no telemetry.
  Enforced by `tools/check-network.sh` in CI, not just asserted. → `ADR-0002`
- **User-facing text lives in `lib/l10n/app_en.arb`**, read through
  `context.l10n`. Enforced by `tools/check-strings.sh`. → `F-I18N-001`

---

## Versioning — MANDATORY, NEVER SKIP, NEVER ASK

**Every commit bumps the version.** Do it automatically as part of committing.
Do not ask permission, do not batch several commits under one version.

```bash
echo "0.4.0" > VERSION          # 1. bump
git add -A && git commit -m "<type>(<domain>): <F-ID> <summary>"
git push origin main            # 2. push — CI tags it (F-REL-012)
```

**Tagging is automatic.** `.github/workflows/tag.yml` reads `VERSION` on every
push and creates `v$VERSION`. Don't create tags locally — this session's
credentials can't push them anyway, and CI is authoritative.

**Bump rules while pre-1.0** (`MAJOR` stays `0` until the schema is stable):

| Change | Bump |
|---|---|
| New feature, phase work, schema change, new planning doc | **MINOR** — `0.3.0 → 0.4.0` |
| Fix, clarification, refactor, doc edit, test-only change | **PATCH** — `0.3.0 → 0.3.1` |

`VERSION` at the repo root is the single source of truth. Full scheme:
`docs/63-VERSIONING.md`.

## The roadmap is binding

`docs/50-ROADMAP.md` is followed **strictly and in order**. Don't skip ahead,
don't reorder, don't start Phase N+1 while Phase N has unmet exit criteria.

- **Allowed without asking:** adding a sub-feature inside the current phase's
  scope, and improving any spec.
- **Ask first:** moving a feature between phases, reordering phases, starting a
  phase early, declaring a phase complete with unmet exit criteria, dropping a
  feature.

If the roadmap looks wrong, say so and stop. Don't route around it.

## Conventions

- **Work directly on `main`. Commit and push there.** No feature branches, no
  pull requests — solo project, and a self-approved PR is ceremony. Revisit once
  CI has a real test suite to gate on (`F-REL-001`); until then a PR gates
  nothing.
- Commit: `<type>(<domain>): <F-ID> <summary>` — e.g.
  `feat(log): F-LOG-004 last-time ghost values in set rows`.
- Commits are the unit of review. Keep them coherent and their messages honest —
  with no PR descriptions, the commit message *is* the record.
- Every pure-domain function needs a unit test using its worked fixture from
  `docs/40-ANALYTICS-SPEC.md` (machine-readable copies in `docs/fixtures/`).
- Definition of done: `docs/60-ENGINEERING.md`.

## Current state

Version **0.56.3**. **Phases 0–5 complete and audited.** **Phase 6 built** —
every scheduled feature across all six phases is `done` except two, and both
are blocked on hardware rather than on work:

- `F-TIM-003` — the OS rest notification is built (see below); its first two
  acceptance criteria are "fires with the screen off" and "fires under an
  aggressive OEM battery manager", which need a phone.
- `F-REL-006` — store copy and graphics are written and generated; screenshots
  need a device, because a golden render from `flutter test` uses the test font
  and every label would come out as placeholder boxes.

Phase 6's own exit criteria are two met, two open: the accessibility and
privacy criteria are met and CI-enforced; "Play internal testing track live"
and "the sideload→Play upgrade path tested" need a Play account and a device.
**Declaring Phase 6 complete is the project owner's call** — the roadmap
records exactly what is unmet.

### What Phase 6 added

- **`F-REL-007` (P0) — privacy.** `PRIVACY.md` at the repository root is the
  canonical policy; `docs/64-PRIVACY.md` answers Play's data-safety
  questionnaire line by line. The "no network calls" claim is *verified*, not
  asserted: `tools/check-network.sh` fails the build on a networking import,
  API, direct dependency, or an `INTERNET` permission in the manifest.
- **`F-A11Y-001`–`005` — accessibility.** Charts are replaced (not annotated)
  for a screen reader by `lib/core/a11y/chart_summary.dart`; all eleven
  top-level destinations are pumped at 200% text scale; the `ColorScheme`'s own
  text pairs are pinned at 4.5:1; `lib/core/a11y/motion.dart` is the single
  reduce-motion seam, wired into both charts, the PR badge and route
  transitions.
- **`F-I18N-001` — string externalisation.** ~600 ARB keys, `context.l10n`,
  ICU plurals instead of Dart ternaries, enum display names moved into the ARB
  (`RestAlertStyle`'s label left `lib/domain/` entirely — the domain layer
  imports nothing from Flutter). `tools/check-strings.sh` runs in CI so the
  retrofit never has to happen twice.
- **`F-SET-011` — onboarding.** Three pages, Skip on each, and the flag set on
  skip too. The test asserts an *absence*: no "Sign up", "Email" or "Allow
  notifications" anywhere in the flow.
- **`F-THM-006` — branding.** `tools/gen-icons.sh` generates twelve assets from
  one script (hand-rolled PNG encoder, no Pillow): launcher densities, adaptive
  foregrounds with a monochrome layer, the 512 store icon and the feature
  graphic.
- **`F-REL-004` — the `.aab`**, built by `release.yml` from the same tag,
  commit, version and upload key as the APKs.
- **`F-HLT-001`/`F-HLT-002` — Health Connect**, opt-in and off by default, two
  independent switches, no calorie estimate (a fabricated figure in a health
  record is worse than none), local bodyweight entries always winning over an
  imported one. `PRIVACY.md` was rewritten *before* the code, because version 1
  promised exactly that. **minSdk is now 26**, which the client library
  requires.
- **`F-TIM-003`/`F-TIM-004`/`F-SET-008` — the notification stack.**
  `NotificationRestTimerService` wraps the in-app timer rather than replacing
  it: the Dart timer is the floor, correct while the process lives and needing
  no permission, and the notification is what survives the process being
  killed. Live countdown as an ongoing silent notification; skip and +15 s as
  actions; tap deep-links to the session, including when the tap *is* the
  launch. Permission is requested at a switch or the first rest, never at
  launch.

### Carried-over items, now closed

`F-ROU-005`/`F-LOG-015` (schema v8 adds within-group rest; completing a set
scrolls the next group member up), `F-ROU-006` (`resolveRestSource` — the
resolution order was right, showing which level won was missing), `F-ANA-005`
(reference bands), `F-ANA-006` (configurable weekly target, schedule
adherence), `F-ANA-008` (the radar chart, drawn with `CustomPaint`),
`F-ANA-015`, `F-SET-005`, `F-SET-004`, `F-ROU-012` (rolling rotation, derived
from `workouts.source_routine_day_id` rather than a stored cursor),
`F-BOD-003` (goal line), `F-ANA-001` and `F-DAT-005` (both closed with one
criterion each explicitly **waived**, not met — the performance number and a
real Strong export).

### Outstanding, on hardware

One list, so it is not rediscovered: the rest alert firing with the screen off
and under a Samsung/Xiaomi battery manager (`F-TIM-003`); Health Connect's
permission handshake and its delete-on-delete (`F-HLT-001`); store screenshots
(`F-REL-006`); the analytics performance number (`F-ANA-001`); a real Strong
export (`F-DAT-005`); and the sideload→Play upgrade (`ADR-0007`).

Local toolchain: Flutter at `/opt/flutter` on the Linux sandbox, or
`C:\flutter` on the Windows machine (`git clone https://github.com/flutter/flutter.git -b stable --depth 1 C:\flutter`,
then add `C:\flutter\bin` to `PATH` — done once, persisted to the user `PATH`
via `setx`/`[Environment]::SetEnvironmentVariable`). No Android SDK on
either, so `flutter build apk` is CI-only. Flutter web is not a target
platform. `tools/verify.sh` passes clean on both as of this note — if a
future session finds neither toolchain present, set one up the same way
before trusting an unverified diff.
