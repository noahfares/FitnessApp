# F-CAT-010 — Merge duplicate exercises

Status: idea | Priority: P2 | Phase: —
Reads: 21-DATA-MODEL#exercises

## Open questions

Irreversible without a backup; requires a confirmation and
probably an automatic pre-merge backup.

---

## Why

After an import (`F-DAT-005`) or careless custom creation, the same
movement can exist twice with split history. Merging reassigns all sets from one
to the other and archives the loser.
