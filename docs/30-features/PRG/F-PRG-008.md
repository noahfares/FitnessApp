# F-PRG-008 — Target explanation

Status: done | Priority: P1 | Phase: 4
Depends on: F-PRG-001
Reads: 40-ANALYTICS-SPEC, 22-UNITS

## Spec
1. Every proposed target carries one sentence: "You hit 3×5 at 100 kg last time,
   so this is +2.5 kg."
2. Shown inline, collapsed, expandable.
3. When a target is overridden, record that so the next computation knows the
   proposal wasn't what happened.

## Status note

`ProgressionRationale` (`lib/domain/progression/progression_rationale.dart`)
is structured data, not a sentence — canonical-units-only means the domain
layer cannot format a weight string in the user's chosen unit
(`CLAUDE.md`'s invariants). `progressionRationaleText` (new,
`lib/features/logging/presentation/progression_rationale_text.dart`) turns
it into the actual English sentence at render time via the same
`QuantityFormatter` every other screen already reads weight through, shown
via `ProgressionRationaleText` — collapsed to one line, expandable on tap,
same interaction `_StickyNoteText` already used on this screen for the
exercise note (§2). §3 needed no extra work: the engine only ever reads
*actual completed sets*, never the previous proposal, so an override is
just what happened rather than a case requiring detection — see
`F-PRG-001`'s own acceptance note.

---

## Why

An unexplained number is either ignored or blindly obeyed, and both
are bad. Showing the reasoning also makes the engine debuggable by its user,
which matters when the correctness stakes are this high.
