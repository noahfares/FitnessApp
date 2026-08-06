# F-LOG-007 — Crash and kill recovery

Status: done | Priority: P0 | Phase: 1
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
- [x] Force-killing the app mid-session loses nothing. There is nothing in
      memory to lose: the screen holds no session state, and rebuilding the app
      against the same database reproduces the session exactly.
- [x] Reopening lands directly in the active workout, with no prompt and no
      flash of the dashboard — `startupLocationFor` is resolved in `main()`
      before the first frame and feeds the router's `initialLocation`.
- [ ] Verified by an integration test that kills and restarts the app. *The
      widget test rebuilds the app against a surviving database, which covers
      the state loss but not the process death. A real kill needs
      `integration_test` on a device, which arrives with `F-REL-002`.*

## Implementation

- Elapsed time is **derived from `started_at`**, never counted up, so it is
  correct after a kill rather than restarting from zero. Tested by rendering a
  25-minute-old session in a process that was not running for any of it.
- `clockTickProvider` supplies the once-a-second tick, as a provider rather
  than a `Timer` in widget state: a periodic timer means `pumpAndSettle` never
  settles, so every widget test touching the logger would have to hand-roll its
  pumping. Overriding it in tests keeps the clock real in production.
- Recovery is a query — "the workout with a null `ended_at`" — which is only
  possible because at most one can exist (`F-LOG-001` §3, enforced by a partial
  unique index).

---

## Why

Losing a session in progress is the worst possible failure. Phones
get killed by aggressive battery managers constantly, and gym phones are usually
low on battery.
