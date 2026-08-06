# F-LOG-011 — Workout history list

Status: done | Priority: P0 | Phase: 1
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory
Screens: History

## Spec
1. Reverse-chronological list: date, name, duration, exercise count, total
   volume, PR badges.
2. Grouped by month with sticky headers.
3. Paginated or lazily loaded — must stay smooth at thousands of sessions.
4. Search by exercise name or workout name.

PR badges are not shown yet: `F-LOG-013` (PR detection, Phase 2) has not run,
so `personal_records` is always empty here. The row has room for a badge; it
arrives with that feature rather than a placeholder now.
