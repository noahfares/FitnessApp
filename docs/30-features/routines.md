# Routines & programs — `ROU`

Templates you train from. A **routine** is a container; a **routine day** is what
you actually start a workout from. Phase 2 territory, so specified in full.

Critical invariant, from [`../21-DATA-MODEL.md`](../21-DATA-MODEL.md): workouts
**snapshot** their routine day. Editing a routine must never alter history.

---

### F-ROU-001 — Routine CRUD
Status: planned | Priority: P0 | Phase: 2
Blocks: F-ROU-002, F-ROU-010
Screens: Routine List, Routine Editor
Data: `routines`

**Behaviour**
1. Create, rename, duplicate, archive, and delete routines.
2. A routine has a name, optional notes, an optional folder, and one or more days.
3. Create from scratch, from a built-in template (`F-ROU-015`), or from a past
   workout (`F-LOG-012`).
4. Deleting a routine never affects workouts performed from it —
   `source_routine_day_id` is nulled.

**Acceptance criteria**
- [ ] Deleting a routine leaves all historical workouts intact and correctly rendered.
- [ ] Duplicating produces a fully independent copy, including days and targets.

---

### F-ROU-002 — Routine days
Status: planned | Priority: P0 | Phase: 2
Depends on: F-ROU-001
Data: `routine_days`

**Intent** — Programs are multi-day. PPL has three days, upper/lower has two,
5/3/1 has four. Modelling the routine as a flat exercise list would force one
routine per day and lose the grouping that makes a program a program.

**Behaviour**
1. A routine contains ordered, named days ("Push", "Pull", "Legs").
2. Days are added, renamed, reordered, and deleted independently.
3. A workout is started from a *day*, never from a routine.
4. A single-day routine is legitimate and shouldn't feel bureaucratic — the UI
   collapses the day layer when there's only one.

**Acceptance criteria**
- [ ] A three-day PPL routine is creatable and each day independently startable.
- [ ] Single-day routines don't force the user through an extra navigation level.

---

### F-ROU-003 — Exercise targets
Status: planned | Priority: P0 | Phase: 2
Depends on: F-ROU-002
Blocks: F-PRG-001
Data: `routine_exercises`

**Intent** — What distinguishes a plan from a list. Note that reps are a
**range**, not a number: real programming says 8–12, and collapsing that to a
single value is the mistake that makes most template features useless.

**Behaviour**
1. Per exercise: target sets, target rep range (min/max), optional target weight,
   optional target RPE, rest duration.
2. Rep range may be a single value (min == max) when that's genuinely intended.
3. Targets are optional throughout — an exercise with no targets is valid.
4. Targets pre-fill set rows when a workout starts (`F-ROU-010`).
5. Later, the progression engine overwrites targets per session (`F-PRG-001`).

**Acceptance criteria**
- [ ] Starting a workout from a day creates the right number of set rows with
      targets pre-filled.
- [ ] Rep ranges display as "8–12" and single values as "8".

---

### F-ROU-004 — Reordering
Status: planned | Priority: P1 | Phase: 2

Drag to reorder exercises within a day and days within a routine. Order is
explicit (`order_index`), never implied by insertion or ID.

---

### F-ROU-005 — Supersets and circuits
Status: planned | Priority: P1 | Phase: 2
Blocks: F-LOG-015
Data: `routine_exercises.superset_group`

**Behaviour**
1. Two or more adjacent exercises can be grouped into a superset.
2. Grouping is visually explicit in both editor and logger.
3. Rest configuration: within-group rest (often zero) and after-group rest.
4. Ungrouping is a single action and never loses logged data.

**Open questions** — Are circuits (3+ exercises, multiple rounds) the same
concept as a superset, or a distinct one with its own round counter? Treating
them as the same is simpler; decide before implementing.

---

### F-ROU-006 — Rest defaults
Status: planned | Priority: P1 | Phase: 2
Depends on: F-TIM-005

Rest duration resolves in order: routine exercise → exercise default → global
default. Each level is explicitly overridable and shows which level it inherited
from.

---

### F-ROU-007 — Folders
Status: planned | Priority: P2 | Phase: 2
Data: `routine_folders`

Group routines into folders — "Current block", "Archive", "Deload". Flat, one
level deep; nested folders are complexity without payoff at this scale.

---

### F-ROU-008 — Duplicate and version
Status: planned | Priority: P1 | Phase: 2
Depends on: F-ROU-001

**Intent** — Programs evolve. You want "PPL v2" with a swapped accessory without
losing what v1 was, and without rewriting history.

**Behaviour**
1. Duplicate produces an independent copy with a distinguishing name.
2. Because workouts snapshot their day, editing a routine in place is already
   safe for history — versioning is for the user's own clarity, not data safety.
3. Archived routines stay startable but are hidden from the main list.

---

### F-ROU-009 — Archive routines
Status: planned | Priority: P2 | Phase: 2

Soft-hide completed training blocks without deleting them. Archived routines
remain in history references and can be restored.

---

### F-ROU-010 — Start a workout from a routine day
Status: planned | Priority: P0 | Phase: 2
Depends on: F-ROU-003, F-LOG-001
Blocks: F-PRG-001

**Intent** — The join between planning and logging, and the point at which the
snapshot invariant is enforced.

**Behaviour**
1. Starting from a day copies its exercises, order, superset groups, and targets
   into `workout_exercises` and empty `sets` rows.
2. The copy is complete — the workout never reads the routine again for display.
3. `source_routine_day_id` records provenance only.
4. `target_snapshot` records the targets as they were, for auditing what
   progression proposed (`F-PRG-008`).
5. Set rows are pre-created for the target set count, uncompleted, with targets
   and ghost values (`F-LOG-004`) both visible.

**Acceptance criteria**
- [ ] Editing the routine after starting a workout does not alter that workout.
- [ ] Deleting the routine mid-workout doesn't break the session.
- [ ] Starting from a day with no targets behaves like an empty workout with the
      right exercises.

---

### F-ROU-011 — Routine preview
Status: planned | Priority: P2 | Phase: 3
Depends on: F-ANA-005

Before starting: estimated duration, planned volume, and sets per muscle group.
Turns the routine editor from a list builder into a programming tool — you can
see that your PPL has 22 chest sets and 6 rear-delt sets before you run it for
eight weeks.

---

### F-ROU-012 — Scheduling
Status: planned | Priority: P2 | Phase: 3
Data: `routine_days.scheduled_weekdays`

Assign days to weekdays so the dashboard can show "today: Push" and consistency
analytics can measure adherence against a plan rather than just counting
sessions. Optional — plenty of people train on a rolling rotation.

**Open questions** — Fixed weekdays or a rolling rotation ("day 3 of 6")? Both
are common. Probably needs to support both, which makes the model non-trivial.

---

### F-ROU-013 — Cycles, blocks and deload weeks
Status: idea | Priority: P2 | Phase: —

Multi-week programs with progression across weeks and scheduled deloads —
5/3/1's four-week wave, for instance. Depends on `F-PRG-004` and needs a real
design pass; the data model would gain a cycle/week dimension.

---

### F-ROU-014 — Share and import routines
Status: idea | Priority: P2 | Phase: —
Depends on: F-DAT-001

Export a routine as a small JSON file, share it, import it. No server involved —
just a file. The cheapest possible form of program sharing, and it fits the
local-first stance ([ADR-0002](../70-decisions/ADR-0002-local-first.md)).

---

### F-ROU-015 — Built-in starter programs
Status: planned | Priority: P2 | Phase: 3

Ship well-known programs as templates: PPL, Upper/Lower, Starting Strength,
GZCLP, 5/3/1, nSuns. Turns an empty app into a usable one for a beginner and
exercises the progression engine against real-world programming.

**Open questions** — Several named programs are published works with named
authors. Reimplementing the *structure* is fine; copying their written
programming text is not. Ship structure with attribution and a link, never
transcribed content.
