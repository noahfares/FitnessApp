# F-CAT-003 — Custom exercises

Status: planned | Priority: P0 | Phase: 1
Depends on: F-CAT-002
Reads: 21-DATA-MODEL#exercises
Screens: Custom Exercise Editor | Data: `exercises`

## Spec
1. Create with name, primary muscle, optional secondary muscles, equipment,
   tracking type.
2. Edit and archive freely. Delete only when no sets reference it; otherwise
   archive.
3. Custom exercises are indistinguishable from seeded ones in use, marked only
   in the editor.
4. Duplicate-name warning, not a block — "Bench Press (Smith)" is legitimate.

## Acceptance
- [ ] Created exercise is immediately usable in the picker.
- [ ] Deleting one with history is prevented, with archive offered.
- [ ] Survives export/import round-trip with its UUID intact.

---

## Why

The single most commonly paywalled feature in competitors, and the
one that makes the app viable for anyone with an unusual machine or a coach's
bespoke movement. Unlimited, free.
