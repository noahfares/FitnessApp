# F-ANA-012 — Duration and rest compliance

Status: done | Priority: P3 | Phase: 4
Depends on: F-TIM-007
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec

Session duration trend and actual-versus-prescribed rest. Drifting rest times
explain a lot of apparent plateaus.

## Status note (Phase 4 closing pass)

`domain/analytics/duration_compliance.dart`'s `sessionDurationTrend` is
`endedAt - startedAt` per finished session, oldest to newest; shown via
`TrendChart` on `InsightsScreen`'s new "Duration & rest" section (collapsed
by default, same `ExpansionTile` fix `F-ROU-011`'s own preview card needed
to avoid starving whatever the list renders below it).
`averageRestComplianceRatio` averages `actual / prescribed` across every
completed, non-warm-up set with a recorded `rest_taken_seconds`
(`F-TIM-007`); `SetRepository.watchRestCompliance` resolves "prescribed"
through `resolveRestSeconds` using the exercise's *currently* configured
default and the global rest-timer setting. This is a documented
approximation, not a historical snapshot — no per-set prescribed rest is
stored, so a default changed after a set was logged makes that set's
compliance figure reflect the new default, not the one that actually
applied. Acceptable for a trend-level reading; a precise per-set figure
would need a schema change this batch didn't make.
