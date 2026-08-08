# F-SET-006 — e1RM formula

Status: done | Priority: P2 | Phase: 3
Depends on: F-ANA-003
Reads: 22-UNITS

## Spec

Choose between Epley (default), Brzycki, and Lombardi. They disagree meaningfully
at high rep counts, so the choice is exposed rather than hidden, and every chart
using it states which is active. Formulas: [`../40-ANALYTICS-SPEC.md`](../../40-ANALYTICS-SPEC.md).

## Status notes (batch 3.2)

`domain/analytics/e1rm.dart`'s `estimate1Rm`/`E1rmFormula`, fixture-tested
against all three formulas including Brzycki's undefined-range fallback
(§1 rule 3). `E1rmFormulaNotifier` persists the choice via
`SharedPreferences`, same pattern as `RpeSettingsNotifier`; picked from
`E1rmFormulaSheet`, opened from the trend chart's own app bar rather than a
general settings screen — Epley-only `epley1Rm` (used by PR detection and
per-exercise history) is deliberately untouched, since neither of those is
a user preference.
