# F-PRG-008 — Target explanation

Status: planned | Priority: P1 | Phase: 4
Depends on: F-PRG-001
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec
1. Every proposed target carries one sentence: "You hit 3×5 at 100 kg last time,
   so this is +2.5 kg."
2. Shown inline, collapsed, expandable.
3. When a target is overridden, record that so the next computation knows the
   proposal wasn't what happened.

---

## Why

An unexplained number is either ignored or blindly obeyed, and both
are bad. Showing the reasoning also makes the engine debuggable by its user,
which matters when the correctness stakes are this high.
