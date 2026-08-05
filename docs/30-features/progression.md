# Progression engine — `PRG`

The headline differentiator. Most free trackers record what you did; this
decides what you should do next, and explains why.

Everything here is a **pure function** `(rule, history, context) -> targets` in
`lib/domain/progression/`. No I/O, no UI, no database. Wrong numbers here would
directly cause bad training decisions, so the correctness bar is the highest in
the project.

---

### F-PRG-001 — Progression engine core
Status: planned | Priority: P1 | Phase: 4
Depends on: F-ROU-003, F-ROU-010, F-LOG-004
Blocks: F-PRG-002 … F-PRG-006

**Intent** — Turns a routine from a static list into a program. The app already
knows what you did last time and what the rule is; making you do the arithmetic
on a whiteboard is a failure of the tool.

**Behaviour**
1. Signature: `computeTargets(rule, exerciseHistory, context) -> TargetSet`,
   pure, deterministic, with no clock or randomness (dates arrive via `context`).
2. Runs when a workout is started from a routine day (`F-ROU-010`), producing
   target weight and reps per set.
3. Every result carries a human-readable rationale (`F-PRG-008`).
4. Targets are always overridable — the engine proposes, the user disposes.
5. Insufficient history falls back to the routine's static targets.
6. Proposed weights are rounded to achievable loads (`F-PRG-012`).

**Acceptance criteria**
- [ ] Pure and deterministic — same inputs, same outputs, always.
- [ ] Every rule type has fixture tests covering success, failure, and first-run.
- [ ] Overriding a target never corrupts subsequent progression.
- [ ] No rule can ever propose a load that cannot be assembled from the user's
      plates.

**Edge cases** — First time doing an exercise. A months-long gap. History logged
in a different unit (irrelevant — storage is canonical). A user who overrode
targets last session. Missing RPE where the rule needs it.

---

### F-PRG-002 — Linear progression
Status: planned | Priority: P1 | Phase: 4
Depends on: F-PRG-001

**Behaviour**
1. All target reps achieved at target weight → add a configured increment.
2. N consecutive failures → deload by a configured percentage.
3. Increment and failure threshold are per-exercise, with sensible defaults
   (smaller jumps for upper-body lifts than lower-body).
4. Partial success — some sets made, some missed — repeats the same weight.

**Acceptance criteria**
- [ ] Success, partial, and failure paths each produce the right next target.
- [ ] Deload triggers only after the configured consecutive-failure count.

---

### F-PRG-003 — Double progression
Status: planned | Priority: P1 | Phase: 4
Depends on: F-PRG-001

**Intent** — The most broadly useful hypertrophy scheme, and the one that makes
rep *ranges* (`F-ROU-003`) pay off.

**Behaviour**
1. At a fixed weight, work up the rep range across sessions.
2. When all sets hit the top of the range, add weight and drop to the bottom.
3. Below the bottom of the range on all sets for N sessions, deload.

---

### F-PRG-004 — Percentage / training-max based
Status: planned | Priority: P2 | Phase: 4
Depends on: F-PRG-010

Targets computed as percentages of a training max, as used by 5/3/1 and GZCLP.
Requires training-max management (`F-PRG-010`) and, for full fidelity, week/cycle
structure (`F-ROU-013`).

---

### F-PRG-005 — RPE-autoregulated
Status: planned | Priority: P2 | Phase: 4
Depends on: F-LOG-014

Adjust load from the gap between last session's recorded RPE and the target RPE —
came in under target, go up more; over, go up less or back off. Handles good and
bad days better than any fixed scheme, which is the entire argument for RPE.
Requires RPE data, so it degrades to `F-PRG-002` when RPE is absent.

---

### F-PRG-006 — Manual carry-forward
Status: planned | Priority: P1 | Phase: 4

The default and the null rule: carry last session's values forward as targets, no
automation. Explicitly a first-class option — plenty of people want the log
without the opinion.

---

### F-PRG-007 — Rule assignment
Status: planned | Priority: P1 | Phase: 4
Screens: Routine Editor

Assign a rule and its parameters per routine exercise, with a routine-level
default. Presented in plain language ("Add 2.5 kg when I hit 3×5") rather than
as a configuration form, because the concepts are simple but the vocabulary
isn't.

---

### F-PRG-008 — Target explanation
Status: planned | Priority: P1 | Phase: 4
Depends on: F-PRG-001

**Intent** — An unexplained number is either ignored or blindly obeyed, and both
are bad. Showing the reasoning also makes the engine debuggable by its user,
which matters when the correctness stakes are this high.

**Behaviour**
1. Every proposed target carries one sentence: "You hit 3×5 at 100 kg last time,
   so this is +2.5 kg."
2. Shown inline, collapsed, expandable.
3. When a target is overridden, record that so the next computation knows the
   proposal wasn't what happened.

---

### F-PRG-009 — Failure and deload handling
Status: planned | Priority: P1 | Phase: 4
Depends on: F-PRG-002

Detect repeated failure and apply the rule's deload. Explicitly surfaced rather
than silent — the user must know a deload happened and why, or the app looks
broken.

---

### F-PRG-010 — Training max management
Status: planned | Priority: P2 | Phase: 4
Blocks: F-PRG-004

Per-exercise training max, set manually or derived from e1RM (typically ~90%),
with prompts to increase it at cycle boundaries. The anchor for all
percentage-based programming.

---

### F-PRG-011 — Deload suggestion
Status: planned | Priority: P2 | Phase: 4
Depends on: F-ANA-009, F-ANA-010

Suggest a deload week when stall detection and workload ratio both indicate it.
A suggestion with reasoning, never an automatic change to the program.

---

### F-PRG-012 — Plate-aware rounding
Status: planned | Priority: P1 | Phase: 4
Depends on: F-PLT-001

**Intent** — A target of 102.3 kg is worse than useless — it's noise the user has
to mentally correct every session, and it destroys trust in the engine.

**Behaviour**
1. Every proposed load is rounded to the nearest weight assemblable from the
   user's actual bar and plate inventory (`F-PLT-002`).
2. Rounding direction is configurable — the default rounds down, since
   overshooting a target causes missed reps.
3. When the smallest achievable jump exceeds the rule's increment, the engine
   says so and offers to hold weight and add reps instead.

**Acceptance criteria**
- [ ] No proposed target is ever unassemblable from the configured inventory.
- [ ] Micro-plate owners get micro-plate-sized jumps.
