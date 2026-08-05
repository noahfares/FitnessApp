# Feature catalogue

One file per feature, named after its ID. The filename **is** the address:
`F-LOG-004` lives at `LOG/F-LOG-004.md`. No searching, no index lookup.

- **[`INDEX.md`](INDEX.md)** — all features, grouped by domain. Generated.
- **[`../features.tsv`](../features.tsv)** — the whole project state in one
  small file: phase, status, priority, dependencies. Generated. Read this to
  answer "what's next" rather than opening specs.

Both are produced by `tools/gen-index.sh`. **Never hand-edit them.**

## Domains

`CAT` catalogue · `ROU` routines · `LOG` logging · `TIM` timers ·
`ANA` analytics · `PRG` progression · `BOD` body metrics · `DAT` data
portability · `SET` settings · `PLT` plate maths · `NAV` shell/navigation ·
`THM` theming · `A11Y` accessibility · `I18N` localisation · `HLT` health
integration · `REL` release

## Entry format

```markdown
# F-LOG-004 — "Last time" ghost values

Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-003 | Blocks: F-PRG-001
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#colour, 22-UNITS
Screens: Active Workout | Data: `sets`

## Spec
1. Numbered, testable statements.

## Acceptance
- [ ] Verifiable conditions.

## Edge cases
What breaks it.

## Open questions
Unresolved decisions.

---

## Why
Rationale, trade-offs, what it's worth.
```

### The header fields

| Field | Meaning |
|---|---|
| `Status` | `idea` → `planned` → `in-progress` → `done`, or `deferred`/`dropped`. The only progress tracker in the project — update it in the same commit as the code |
| `Priority` | `P0` core · `P1` important · `P2` valuable · `P3` speculative |
| `Phase` | From [`../50-ROADMAP.md`](../50-ROADMAP.md), or `—` if unscheduled |
| `Depends on` / `Blocks` | Real IDs only. `tools/check-docs.sh` catches broken references |
| **`Reads`** | **The documents needed to build this, and nothing more.** See below |
| `Screens` / `Data` | Which screens and tables it touches |

### `Reads:` — the important one

This is what keeps sessions cheap. It declares the complete background reading
for the feature, so a build session opens three documents instead of twelve and
never has to explore to find context.

Paths are relative to `docs/`, with an optional `#anchor` naming a section:
`21-DATA-MODEL#sets`. Every target is verified by `tools/check-docs.sh`.

Keep it **minimal and honest**. Listing everything defeats the purpose; omitting
something needed means the next session guesses. If you build a feature and
needed a document that wasn't listed, add it — that's a real fix.

### Spec vs `## Why`

Everything above the `---` is what to build. The `## Why` below it is the
reasoning — why the feature exists, what it's worth, what was traded off.

Build sessions **skip `## Why`**. It isn't decoration: it's what stops decisions
being silently re-litigated months later. Keep it, just keep it out of the way.

## Specification depth

Deliberately uneven. Phase 0–2 entries are specified in full and should be
implementable cold. Phase 3+ entries carry intent, a behaviour sketch, and open
questions, and get expanded when their phase is scheduled — expanding one is
itself a good planning task. Backlog entries may be a single paragraph.

## Adding a feature

```bash
tools/new-feature.sh LOG "Undo across sessions"
```

Allocates the next free ID, writes the template, regenerates the index. Then
fill it in, add it to a phase in the roadmap **or** to
[`../51-BACKLOG.md`](../51-BACKLOG.md), run `tools/check-docs.sh`, and commit
with a version bump.

If a change touches the schema, an ADR, or an invariant, say so explicitly in
the entry and update that document in the same commit.
