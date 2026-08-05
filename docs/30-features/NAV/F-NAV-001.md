# F-NAV-001 — App shell and bottom navigation

Status: done | Priority: P0 | Phase: 0
Blocks: F-NAV-002, F-NAV-003
Reads: 23-NAVIGATION

Five-tab bottom navigation with a stateful nested navigator per tab, so
switching tabs never loses scroll position or a half-completed form. The centre
tab is the emphasised Start action. Primary actions live in the bottom half of
the screen — the app is used one-handed, standing, mid-set.

## Acceptance
- [x] Tab state persists across switches. `StatefulShellRoute.indexedStack`
      keeps every branch mounted, so a departed tab is offstage rather than
      rebuilt — asserted with `skipOffstage: false`.
- [x] Every primary action is reachable with a thumb without shifting grip.
      Navigation is a bottom bar; Settings is the one top-bar action and is
      deliberately low-frequency.

## Implementation

- `lib/features/shell/presentation/app_shell.dart` — five destinations, centre
  slot emphasised as the Start action.
- Re-tapping the current tab pops it to its root, which is the cheapest way out
  of a deep stack with a rest timer running.
- Settings pushes over the shell rather than owning a tab; five slots are
  scarce and it is low-frequency.
