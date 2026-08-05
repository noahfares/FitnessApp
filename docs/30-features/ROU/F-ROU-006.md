# F-ROU-006 — Rest defaults

Status: planned | Priority: P1 | Phase: 2
Depends on: F-TIM-005
Reads: 21-DATA-MODEL#routine_days, 70-decisions/ADR-0004-template-snapshot

## Spec

Rest duration resolves in order: routine exercise → exercise default → global
default. Each level is explicitly overridable and shows which level it inherited
from.
