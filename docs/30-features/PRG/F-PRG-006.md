# F-PRG-006 — Manual carry-forward

Status: done | Priority: P1 | Phase: 4
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec

The default and the null rule: carry last session's values forward as targets, no
automation. Explicitly a first-class option — plenty of people want the log
without the opinion.

## Status note

`ManualCarryForwardRule` (`lib/domain/progression/progression_rule.dart`) —
the decode target for both a `null` stored `progression_rule` and any
unrecognised stored value, so it is the default without every existing
routine exercise needing a migration to say so explicitly. Carries the last
session's **top set** (heaviest logged weight) forward verbatim; an
exercise logged with genuinely independent per-set weights (e.g. drop sets)
carries forward only that one set's values, same top-set-only simplification
`F-PRG-001`'s own doc comment names.
