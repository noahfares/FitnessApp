# Session contract for Claude Code

This repo is **planning-first**. `docs/` is the source of truth; the code is
downstream of it. Read this file, then `docs/00-INDEX.md`, before doing anything.

## Project in one line

An offline-first Flutter strength-training tracker that gives away free what
Strong / Hevy / JEFIT paywall: unlimited routines and custom exercises, real
analytics, progression automation, and full data export.

## Rules

1. **Every feature has an ID.** `F-<DOMAIN>-<NNN>`, defined in `docs/30-features/`.
   Never implement something that has no entry — write the entry first, get it
   approved, then build. IDs are permanent and never reused.
2. **Update `Status:` in the same commit as the code.** The feature files are the
   only progress tracker. `idea → planned → in-progress → done → deferred | dropped`.
3. **Read narrowly.** Load `00-INDEX.md` plus only the domain files your task
   touches. Do not read all of `docs/` by default.
4. **Don't silently expand scope.** If a task reveals a missing feature, add it
   to `docs/51-BACKLOG.md` with a new ID and mention it — don't build it.
5. **Ask before deviating from an ADR.** Decisions in `docs/70-decisions/` are
   load-bearing. If one seems wrong, say so; don't route around it.

## Invariants — violating any of these is a bug, not a style choice

- **Canonical units only.** Weight stored as integer grams, distance in metres,
  duration in seconds. Imperial/metric is a *display* concern. Never store a
  per-row unit flag. See `docs/22-UNITS.md`.
- **`lib/domain/` imports nothing from Flutter.** All math that can be silently
  wrong — e1RM, volume, progression targets, unit conversion — is pure Dart under
  unit test. See `docs/20-ARCHITECTURE.md`.
- **Warm-up sets are excluded** from volume, PR, and e1RM math, always.
  See `docs/40-ANALYTICS-SPEC.md`.
- **Workouts snapshot their template.** Editing a routine must never alter
  historical sessions. See `docs/21-DATA-MODEL.md`.
- **Write-through persistence.** Every set completion hits the DB immediately.
  An app kill mid-session must lose nothing.
- **No network calls in the core app.** Local-first, no account, no telemetry.
  See `ADR-0002`.

## Conventions

- Branch: `claude/<domain>-<short-desc>` — e.g. `claude/log-ghost-values`.
- Commit: `<type>(<domain>): <F-ID> <summary>` — e.g.
  `feat(log): F-LOG-004 last-time ghost values in set rows`.
- Every pure-domain function needs a unit test with a worked fixture. Analytics
  fixtures live alongside their spec in `docs/40-ANALYTICS-SPEC.md`.
- Definition of done is in `docs/60-ENGINEERING.md`. Check it before claiming
  a feature is complete.

## Current state

No application code exists yet. The next build step is **Phase 0** in
`docs/50-ROADMAP.md`. Do not scaffold until asked.
