# Architecture decision records

Decisions that constrain future work, with the reasoning that produced them and
what it would cost to reverse them.

An ADR exists so that a future session — or a future you — can tell the
difference between a deliberate choice and an accident. If a decision seems
wrong, argue with the ADR; don't route around it silently.

| ADR | Decision | Status | Reversal cost |
|---|---|---|---|
| [0001](ADR-0001-flutter.md) | Flutter + Dart | Accepted | High after Phase 2 |
| [0002](ADR-0002-local-first.md) | Local-first, no backend | Accepted | Medium |
| [0003](ADR-0003-canonical-units.md) | Canonical integer-gram storage | Accepted | **Very high** once real history exists |
| [0004](ADR-0004-template-snapshot.md) | Workouts snapshot their template | Accepted | **Very high** — unrecoverable |
| [0005](ADR-0005-drift.md) | Drift for persistence | Accepted | Medium |
| [0006](ADR-0006-riverpod.md) | Riverpod for state and DI | Accepted | Low–medium |
| [0007](ADR-0007-signing.md) | Signing and distribution strategy | Accepted | **Irreversible** after first public APK |

## Format

Context → Options → Decision → Consequences → Reversal cost. Short. An ADR that
needs a page of prose is usually two decisions.

## Adding one

Any decision that constrains future work, that a future session might otherwise
undo by accident, or that was genuinely close between options. Number
sequentially; never renumber. Superseding an ADR means writing a new one that
says so, not editing the old one.
