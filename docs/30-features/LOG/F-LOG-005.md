# F-LOG-005 — Set types

Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-003
Reads: 21-DATA-MODEL#sets, 40-ANALYTICS-SPEC#universal-preconditions
Data: `sets.set_type`

## Spec
1. Types: `warmup`, `working`, `drop`, `failure`, `amrap`, `backoff`. Default
   `working`. The full enum exists in schema v1 even though Phase 1 only
   surfaces `warmup` and `working` in the UI — adding an enum value later is a
   migration, and mislabelled historical sets cannot be recovered.
2. Set by long-press on the set-number cell; indicated by letter and colour.
3. Warm-up sets are numbered separately (W1, W2) from working sets (1, 2, 3).
4. **Warm-ups are excluded from all analytics** — volume, PRs, e1RM, set counts.
5. Drop, failure, AMRAP, and back-off sets all count toward volume and PRs.

## Acceptance
- [ ] Changing a set's type updates all derived figures immediately.
- [ ] Warm-ups never appear in any volume or PR calculation.

---

## Why

Warm-ups must be excluded from analytics or every metric is wrong
(see [`../21-DATA-MODEL.md`](../../21-DATA-MODEL.md)). Drop sets and AMRAPs need to
be distinguishable for the same reason. This has to exist in v1 because the
information can't be recovered later.
