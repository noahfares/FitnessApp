# F-LOG-007 — Crash and kill recovery

Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-001
Reads: 21-DATA-MODEL#persistence-behaviour

## Spec
1. Write-through persistence: every set change hits the database immediately.
   In-progress state is never only in memory.
2. On launch, any workout with a null `ended_at` is restored automatically.
3. Recovery restores exercises, sets, and elapsed time. The rest timer does not
   resume (it would be meaningless).
4. No "restore session?" prompt — it just resumes. Prompting invites the wrong
   answer under stress.

## Acceptance
- [ ] Force-killing the app mid-session loses nothing.
- [ ] Reopening lands directly in the active workout.
- [ ] Verified by an integration test that kills and restarts the app.

---

## Why

Losing a session in progress is the worst possible failure. Phones
get killed by aggressive battery managers constantly, and gym phones are usually
low on battery.
