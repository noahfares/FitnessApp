# Feature catalogue

Every planned feature, with a permanent ID. This is the working surface of the
project — the roadmap schedules IDs from here, commits cite them, and a build
session should be able to work from a single entry plus the documents it links.

## Files

| File | Domains |
|---|---|
| [`catalog.md`](catalog.md) | `CAT` — exercise catalogue |
| [`routines.md`](routines.md) | `ROU` — routines and programs |
| [`logging.md`](logging.md) | `LOG` — workout logging |
| [`timers.md`](timers.md) | `TIM` — rest and interval timers |
| [`analytics.md`](analytics.md) | `ANA` — analytics and charts |
| [`progression.md`](progression.md) | `PRG` — progression engine |
| [`body.md`](body.md) | `BOD` — bodyweight and measurements |
| [`data-portability.md`](data-portability.md) | `DAT` — export, import, backup |
| [`settings.md`](settings.md) | `SET` — preferences |
| [`plate-math.md`](plate-math.md) | `PLT` — plate calculation |
| [`shell.md`](shell.md) | `NAV`, `THM`, `A11Y`, `I18N` — app shell, theming, accessibility, localisation |
| [`health.md`](health.md) | `HLT` — health platform integration, wearables |
| [`release.md`](release.md) | `REL` — build, signing, distribution |

## Entry format

```markdown
### F-XXX-NNN — Title
Status: planned | Priority: P1 | Phase: 2
Depends on: F-AAA-NNN, F-BBB-NNN
Blocks: F-CCC-NNN
Screens: Active Workout, Exercise Detail
Data: sets, workout_exercises

**Intent** — why this exists and what it's worth. One paragraph.

**Behaviour**
1. Numbered, testable statements.

**Acceptance criteria**
- [ ] Verifiable conditions.

**Edge cases** — what breaks it.

**Open questions** — unresolved decisions.
```

Fields may be omitted when genuinely not applicable, except `Status` and
`Priority`, which are always present.

## Field values

- **Status** — `idea` → `planned` → `in-progress` → `done`, or `deferred` /
  `dropped`. This is the only progress tracker in the project; update it in the
  same commit as the code.
- **Priority** — `P0` core, the app is pointless without it · `P1` important,
  expected of a serious tracker · `P2` valuable, not urgent · `P3` speculative.
- **Phase** — from [`../50-ROADMAP.md`](../50-ROADMAP.md), or `—` if unscheduled
  (those also appear in [`../51-BACKLOG.md`](../51-BACKLOG.md)).
- **Depends on / Blocks** — must reference real IDs. Broken references are
  caught in review; see the verification note in `../60-ENGINEERING.md`.

## Adding a feature

1. Pick the domain; take the next unused number.
2. Update the **Allocated** range in [`../00-INDEX.md`](../00-INDEX.md).
3. Write the entry. Unscheduled ideas can be brief — intent plus a sketch — and
   also get listed in `51-BACKLOG.md`.
4. If it changes the schema, an ADR, or an invariant, say so explicitly in the
   entry and update the relevant document in the same commit.

## Specification depth

Deliberately uneven. Phase 0–2 entries are specified in full and should be
implementable cold. Phase 3+ entries carry intent, a behaviour sketch, and open
questions, and get expanded when their phase is scheduled — expanding one is
itself a good planning task. Backlog entries may be a single paragraph.
