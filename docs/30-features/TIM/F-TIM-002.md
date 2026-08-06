# F-TIM-002 — Auto-start on set completion

Status: done | Priority: P0 | Phase: 1
Depends on: F-TIM-001, F-LOG-003
Reads: 20-ARCHITECTURE#cross-platform-discipline

## Spec
1. Completing a set starts the rest timer automatically.
2. Duration resolves routine exercise → exercise default → global default
   (`F-ROU-006`, `F-TIM-005`).
3. Auto-start is globally disableable.
4. Completing another set restarts the timer rather than stacking timers.
5. Un-completing a set cancels a running timer that it started.
