# Documentation index

This documentation is the source of truth for the project. Code is downstream of
it. It is designed to be read *narrowly* — load this file, then only the
documents relevant to your task.

## How the pieces connect

```
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
30-features/  ← every feature, with a stable F-ID ─────┐
   │                                                   │
   ├── 40-ANALYTICS-SPEC   formulas the ANA/PRG features implement
   │                                                   │
   ▼                                                   │
50-ROADMAP    phases, as lists of F-IDs — BINDING, followed in order ◄┘
51-BACKLOG    unscheduled ideas, already ID'd
   │
   ▼
60-ENGINEERING ── 61-CI-CD ── 62-RELEASE ── 63-VERSIONING
                                   how work gets built, versioned, shipped
80-GLOSSARY   domain vocabulary
```

## Which document do I need?

| If you're… | Read |
|---|---|
| Implementing a feature | `30-features/<domain>.md` for the ID, plus whatever it links |
| Adding a new feature idea | `30-features/README.md` (entry format), then `51-BACKLOG.md` |
| Touching the database | `21-DATA-MODEL.md`, then `60-ENGINEERING.md` §migrations |
| Touching anything numeric | `22-UNITS.md` — non-negotiable |
| Writing analytics or progression | `40-ANALYTICS-SPEC.md` — has worked fixtures for tests |
| Building a screen | `23-NAVIGATION.md` + `24-DESIGN-SYSTEM.md` |
| Deciding what to build next | `50-ROADMAP.md` |
| Setting up CI or cutting a release | `61-CI-CD.md`, `62-RELEASE.md` |
| **Committing anything at all** | `63-VERSIONING.md` — every commit bumps and tags |
| Wondering why something is the way it is | `70-decisions/` |
| Wondering whether an outside doc was already considered | `11-EXTERNAL-INPUTS.md` |
| Confused by a term | `80-GLOSSARY.md` |

## Document register

| File | Purpose |
|---|---|
| [`10-VISION.md`](10-VISION.md) | Principles, audience, non-goals, competitor gap, risks |
| [`11-EXTERNAL-INPUTS.md`](11-EXTERNAL-INPUTS.md) | Handoff docs and prior art brought in from outside: what was adopted, what was rejected |
| [`20-ARCHITECTURE.md`](20-ARCHITECTURE.md) | Layering, folder structure, dependencies |
| [`21-DATA-MODEL.md`](21-DATA-MODEL.md) | Schema, relationships, migration policy |
| [`22-UNITS.md`](22-UNITS.md) | Canonical storage, value objects, formatting |
| [`23-NAVIGATION.md`](23-NAVIGATION.md) | Screen inventory, routes, state patterns |
| [`24-DESIGN-SYSTEM.md`](24-DESIGN-SYSTEM.md) | Colour, type, spacing, components, light/dark |
| [`30-features/`](30-features/) | The feature catalogue — see below |
| [`40-ANALYTICS-SPEC.md`](40-ANALYTICS-SPEC.md) | Every metric: formula, edge cases, fixtures |
| [`50-ROADMAP.md`](50-ROADMAP.md) | Phases and exit criteria |
| [`51-BACKLOG.md`](51-BACKLOG.md) | Unscheduled features |
| [`60-ENGINEERING.md`](60-ENGINEERING.md) | Conventions, testing, definition of done |
| [`61-CI-CD.md`](61-CI-CD.md) | Workflow specifications |
| [`62-RELEASE.md`](62-RELEASE.md) | Signing, distribution, store checklists |
| [`63-VERSIONING.md`](63-VERSIONING.md) | **Version scheme and the mandatory bump-and-tag protocol** |
| [`70-decisions/`](70-decisions/) | Architecture decision records |
| [`80-GLOSSARY.md`](80-GLOSSARY.md) | Domain vocabulary |

## Feature ID registry

Every feature has a permanent ID of the form `F-<DOMAIN>-<NNN>`. IDs are never
changed and never reused. The roadmap, ADRs, commits, and tests all reference
features by ID rather than restating them.

| Domain | Scope | File | Allocated |
|---|---|---|---|
| `CAT` | Exercise catalogue | [`30-features/catalog.md`](30-features/catalog.md) | 001–014 |
| `LOG` | Workout logging | [`30-features/logging.md`](30-features/logging.md) | 001–023 |
| `ROU` | Routines & programs | [`30-features/routines.md`](30-features/routines.md) | 001–015 |
| `TIM` | Timers | [`30-features/timers.md`](30-features/timers.md) | 001–009 |
| `ANA` | Analytics & charts | [`30-features/analytics.md`](30-features/analytics.md) | 001–018 |
| `PRG` | Progression engine | [`30-features/progression.md`](30-features/progression.md) | 001–012 |
| `BOD` | Body metrics | [`30-features/body.md`](30-features/body.md) | 001–006 |
| `DAT` | Data portability | [`30-features/data-portability.md`](30-features/data-portability.md) | 001–011 |
| `SET` | Settings | [`30-features/settings.md`](30-features/settings.md) | 001–011 |
| `PLT` | Plate mathematics | [`30-features/plate-math.md`](30-features/plate-math.md) | 001–005 |
| `NAV` | App shell & navigation | [`30-features/shell.md`](30-features/shell.md) | 001–008 |
| `THM` | Theming | [`30-features/shell.md`](30-features/shell.md) | 001–006 |
| `A11Y` | Accessibility | [`30-features/shell.md`](30-features/shell.md) | 001–005 |
| `I18N` | Localisation | [`30-features/shell.md`](30-features/shell.md) | 001–003 |
| `HLT` | Health platform integration | [`30-features/health.md`](30-features/health.md) | 001–005 |
| `REL` | Release & distribution | [`30-features/release.md`](30-features/release.md) | 001–011 |

When allocating a new ID, take the next unused number in the domain and update
the **Allocated** column above in the same commit.

## Specification depth

Entries are not all specified to the same depth, deliberately:

- **Phase 0–2 features** are specified in full — intent, behaviour, acceptance
  criteria, edge cases. They should be implementable cold from the entry alone.
- **Phase 3+ features** carry intent, a behaviour sketch, and known open
  questions. They get expanded to full depth when their phase is scheduled.
- **Backlog features** may be a single paragraph. That's fine; they're parked.

Expanding an entry from sketch to full spec is itself a planning task, and a
good use of a session.
