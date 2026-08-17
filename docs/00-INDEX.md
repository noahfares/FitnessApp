# Documentation index

This documentation is the source of truth for the project. Code is downstream of
it. It is designed to be read *narrowly* — load this file, then only the
documents relevant to your task.

## How the pieces connect

```
01-PLAIN-ENGLISH     what all the jargon means — start here if it's unfamiliar
10-VISION            why the project exists, what it will and won't be
11-EXTERNAL-INPUTS   outside handoffs: what was adopted, what was rejected
   │
   ├── 70-decisions/ the load-bearing choices, with reversal costs
   │        │
   │        ▼
   ├── 20-ARCHITECTURE ── 21-DATA-MODEL ── 22-UNITS
   │        │                  │
   │        ├── 23-NAVIGATION  │          screens & routes
   │        └── 24-DESIGN-SYSTEM          theme, components
   │                                │
   ▼                                ▼
30-features/<DOM>/<F-ID>.md  ← one file each; `Reads:` names its deps ─┐
features.tsv  ← all 163 in one small generated file                    │
   │                                                   │
   ├── 40-ANALYTICS-SPEC   formulas the ANA/PRG features implement
   │                                                   │
   ▼                                                   │
50-ROADMAP    phases, as lists of F-IDs — BINDING, followed in order ◄┘
51-BACKLOG    unscheduled ideas, already ID'd
   │
   ▼
60-ENGINEERING ── 61-CI-CD ── 62-RELEASE ── 63-VERSIONING ── 64-PRIVACY
                                   how work gets built, versioned, shipped
80-GLOSSARY   domain vocabulary
```

## Which document do I need?

| If you're… | Read |
|---|---|
| **New to the vocabulary** | **`01-PLAIN-ENGLISH.md` — start here** |
| Implementing a feature | `30-features/<DOM>/<F-ID>.md`, then only its `Reads:` line |
| Seeing project state | `features.tsv` — don't open specs for this |
| Adding a new feature idea | `tools/new-feature.sh`, then `51-BACKLOG.md` |
| Touching the database | `21-DATA-MODEL.md`, then `60-ENGINEERING.md` §migrations |
| Touching anything numeric | `22-UNITS.md` — non-negotiable |
| Writing analytics or progression | `40-ANALYTICS-SPEC.md` — has worked fixtures for tests |
| Building a screen | `23-NAVIGATION.md` + `24-DESIGN-SYSTEM.md` |
| Deciding what to build next | `50-ROADMAP.md` |
| Setting up CI or cutting a release | `61-CI-CD.md`, `62-RELEASE.md` |
| Filling in a store privacy questionnaire | `64-PRIVACY.md`, and `PRIVACY.md` at the root |
| **Committing anything at all** | `63-VERSIONING.md` — every commit bumps and tags |
| Wondering why something is the way it is | `70-decisions/` |
| Wondering whether an outside doc was already considered | `11-EXTERNAL-INPUTS.md` |
| Confused by a term | `80-GLOSSARY.md` |

## Document register

| File | Purpose |
|---|---|
| [`01-PLAIN-ENGLISH.md`](01-PLAIN-ENGLISH.md) | Every technical term explained, in plain language |
| [`10-VISION.md`](10-VISION.md) | Principles, audience, non-goals, competitor gap, risks |
| [`11-EXTERNAL-INPUTS.md`](11-EXTERNAL-INPUTS.md) | Handoff docs and prior art brought in from outside: what was adopted, what was rejected |
| [`20-ARCHITECTURE.md`](20-ARCHITECTURE.md) | Layering, folder structure, dependencies |
| [`21-DATA-MODEL.md`](21-DATA-MODEL.md) | Schema, relationships, migration policy |
| [`22-UNITS.md`](22-UNITS.md) | Canonical storage, value objects, formatting |
| [`23-NAVIGATION.md`](23-NAVIGATION.md) | Screen inventory, routes, state patterns |
| [`24-DESIGN-SYSTEM.md`](24-DESIGN-SYSTEM.md) | Colour, type, spacing, components, light/dark |
| [`30-features/`](30-features/) | The feature catalogue — one file per feature |
| [`features.tsv`](features.tsv) | Generated: whole project state in one file |
| [`40-ANALYTICS-SPEC.md`](40-ANALYTICS-SPEC.md) | Every metric: formula, edge cases, fixtures |
| [`50-ROADMAP.md`](50-ROADMAP.md) | Phases and exit criteria |
| [`51-BACKLOG.md`](51-BACKLOG.md) | Unscheduled features |
| [`60-ENGINEERING.md`](60-ENGINEERING.md) | Conventions, testing, definition of done |
| [`61-CI-CD.md`](61-CI-CD.md) | Workflow specifications |
| [`62-RELEASE.md`](62-RELEASE.md) | Signing, distribution, store checklists |
| [`63-VERSIONING.md`](63-VERSIONING.md) | **Version scheme and the mandatory bump-and-tag protocol** |
| [`64-PRIVACY.md`](64-PRIVACY.md) | Store data-safety answers, and how the no-network claim is verified |
| [`70-decisions/`](70-decisions/) | Architecture decision records |
| [`80-GLOSSARY.md`](80-GLOSSARY.md) | Domain vocabulary |

## Feature ID registry

Every feature has a permanent ID of the form `F-<DOMAIN>-<NNN>`, and lives in
its own file named after it: `F-LOG-004` → `30-features/LOG/F-LOG-004.md`. The
filename *is* the address, so nothing needs searching. IDs are never changed and
never reused.

**[`features.tsv`](features.tsv)** holds the whole project state — 163 rows with
phase, status, priority, dependencies and required reading. Read it to answer
"what's next" or "what's left"; don't open spec files for that.
**[`30-features/INDEX.md`](30-features/INDEX.md)** is the same data as a browsable
table. Both are generated by `tools/gen-index.sh` — never hand-edit them.

| Domain | Scope |
|---|---|
| [`CAT`](30-features/CAT/) | Exercise catalogue |
| [`ROU`](30-features/ROU/) | Routines & programs |
| [`LOG`](30-features/LOG/) | Workout logging |
| [`TIM`](30-features/TIM/) | Timers |
| [`ANA`](30-features/ANA/) | Analytics & charts |
| [`PRG`](30-features/PRG/) | Progression engine |
| [`BOD`](30-features/BOD/) | Body metrics |
| [`DAT`](30-features/DAT/) | Data portability |
| [`SET`](30-features/SET/) | Settings |
| [`PLT`](30-features/PLT/) | Plate mathematics |
| [`NAV`](30-features/NAV/) | App shell & navigation |
| [`THM`](30-features/THM/) | Theming |
| [`A11Y`](30-features/A11Y/) | Accessibility |
| [`I18N`](30-features/I18N/) | Localisation |
| [`HLT`](30-features/HLT/) | Health platform integration |
| [`REL`](30-features/REL/) | Release & distribution |

New IDs are allocated by `tools/new-feature.sh <DOMAIN> "<title>"`, which takes
the next free number and regenerates the index.

### The `Reads:` line

Every feature declares the documents needed to build it. A build session opens
those and nothing else — that is what keeps sessions cheap. Targets are verified
by `tools/check-docs.sh`.

## Specification depth

Entries are not all specified to the same depth, deliberately:

- **Phase 0–2 features** are specified in full — intent, behaviour, acceptance
  criteria, edge cases. They should be implementable cold from the entry alone.
- **Phase 3+ features** carry intent, a behaviour sketch, and known open
  questions. They get expanded to full depth when their phase is scheduled.
- **Backlog features** may be a single paragraph. That's fine; they're parked.

Expanding an entry from sketch to full spec is itself a planning task, and a
good use of a session.
