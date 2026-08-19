# F-THM-008 — Unify large-title header across Home, Routines, History, Insights

Status: done | Priority: P2 | Phase: 6
Reads: 24-DESIGN-SYSTEM

## Spec

1. `F-THM-007` gave Home a large-title header (34/700, -1.02 tracking, a date
   caption above it, a round Settings icon top-right) and removed its
   `AppBar`. Routines, History, and the main Insights tab were left on a
   plain `AppBar(title: Text(...))` — much smaller, unbolded — because they
   were outside that handoff's four redesigned screens. The project owner
   flagged the mismatch directly; this closes it by extending the same
   large-title treatment to all four tab-root screens rather than leaving
   Home as the one outlier.
2. New shared widget `lib/features/shell/widgets/tab_header.dart`
   (`TabHeader`): title (34/700/-1.02), optional caption line above it,
   optional trailing actions row — a generalisation of Home's former private
   `_Header`. Callers own their own outer padding; the widget only lays out
   the row.
3. `dashboard_screen.dart`: `_Header` replaced by a direct `TabHeader` call
   (same caption/title/action as before — no visible change on Home).
4. `routine_list_screen.dart`, `history_screen.dart`,
   `analytics/insights_screen.dart`: `Scaffold.appBar` removed; each screen's
   body is now `SafeArea(child: Column([Padding(TabHeader(...)), Expanded(rest
   of the screen)]))`. Routines keeps its toggle/starter-programs/new-folder/
   new-routine icon row as `TabHeader.actions`; History and Insights pass no
   actions (they had none). History's title switches between "History" and
   nothing else it already didn't have; Routines keeps its
   "Routines"/"Archived Routines" title switch unchanged.

## Acceptance

- [x] Home, Routines, History, and Insights render the same 34/700 title
      style; no screen is left on the smaller/lighter `AppBar` title.
- [x] Routines' existing app-bar actions (archive toggle, starter programs,
      new folder, new routine) and History's search field/FAB are unaffected
      — same behaviour, different chrome above them.
- [x] `tools/verify.sh` passes clean (format, analyze, full test suite,
      layers, network, strings, docs).
- [x] All four tabs, plus every other 200%-text-scale route in
      `accessibility_test.dart` (`F-A11Y-002`), still render without
      overflow with the header change.

## Edge cases

- Routines' "Archived Routines" title is longer than "Routines" — same
  `TabHeader`, no fixed width, wraps the same way Home's title already would
  at a long locale string.
- History and Insights pass `actions: const []`, so `TabHeader` renders just
  the title row with no trailing gap — verified visually, not just by
  omission, since `TabHeader` conditionally adds spacing only when the list
  is non-empty.

## Open questions

None — a direct visual-consistency fix, not a new interaction.

---

## Why

The four bottom-tab roots are meant to read as one family, not one polished
screen (Home) and three left on the generic Material default from before
`F-THM-007`'s redesign pass reached them. The project owner asked directly
whether to unify or keep them different; unifying was the chosen direction,
consistent with the "large titles" convention `F-THM-007` already uses
elsewhere (onboarding, Session Summary).
