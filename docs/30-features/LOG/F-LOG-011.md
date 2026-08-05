# F-LOG-011 — Workout history list

Status: planned | Priority: P0 | Phase: 1
Reads: 21-DATA-MODEL#sets, 24-DESIGN-SYSTEM#component-inventory
Screens: History

## Spec
1. Reverse-chronological list: date, name, duration, exercise count, total
   volume, PR badges.
2. Grouped by month with sticky headers.
3. Paginated or lazily loaded — must stay smooth at thousands of sessions.
4. Search by exercise name or workout name.
