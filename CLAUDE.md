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
  → `ADR-0002`

---

## Versioning — MANDATORY, NEVER SKIP, NEVER ASK

**Every commit bumps the version.** Do it automatically as part of committing.
Do not ask permission, do not batch several commits under one version.

```bash
echo "0.4.0" > VERSION          # 1. bump
git add -A && git commit -m "<type>(<domain>): <F-ID> <summary>"
git push -u origin <branch>     # 2. push — CI tags it (F-REL-012)
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

- Branch: `claude/<domain>-<short-desc>` — e.g. `claude/log-ghost-values`.
- Commit: `<type>(<domain>): <F-ID> <summary>` — e.g.
  `feat(log): F-LOG-004 last-time ghost values in set rows`.
- Every pure-domain function needs a unit test using its worked fixture from
  `docs/40-ANALYTICS-SPEC.md` (machine-readable copies in `docs/fixtures/`).
- Definition of done: `docs/60-ENGINEERING.md`.

## Current state

Version **0.3.0**. No application code yet. Next build step is **Phase 0** in
`docs/50-ROADMAP.md`. Do not scaffold until asked.
