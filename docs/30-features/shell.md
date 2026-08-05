# App shell, theming, accessibility, localisation

Four domains that cut across every screen: `NAV`, `THM`, `A11Y`, `I18N`.

Design specifications: [`../24-DESIGN-SYSTEM.md`](../24-DESIGN-SYSTEM.md).
Route map and state patterns: [`../23-NAVIGATION.md`](../23-NAVIGATION.md).

---

## Navigation & shell — `NAV`

### F-NAV-001 — App shell and bottom navigation
Status: planned | Priority: P0 | Phase: 0
Blocks: F-NAV-002, F-NAV-003

Five-tab bottom navigation with a stateful nested navigator per tab, so
switching tabs never loses scroll position or a half-completed form. The centre
tab is the emphasised Start action. Primary actions live in the bottom half of
the screen — the app is used one-handed, standing, mid-set.

**Acceptance criteria**
- [ ] Tab state persists across switches.
- [ ] Every primary action is reachable with a thumb without shifting grip.

---

### F-NAV-002 — Routing and deep links
Status: planned | Priority: P0 | Phase: 0
Depends on: F-NAV-001

Declarative routes per [`../23-NAVIGATION.md`](../23-NAVIGATION.md). Deep links
are not cosmetic — home-screen widgets (`F-NAV-007`), app shortcuts
(`F-NAV-008`), and rest-timer notification taps (`F-TIM-003`) all route by URI.
`/workout/active` resolves the singleton in-progress session or redirects.

---

### F-NAV-003 — Active-workout banner
Status: planned | Priority: P0 | Phase: 1
Depends on: F-LOG-001

Persistent banner above the bottom navigation on every screen while a workout is
in progress: exercise count, elapsed time, tap to return. Non-dismissible. It's
trivially easy to navigate away mid-session to check history, and unacceptable to
then have to hunt for the session you're in.

---

### F-NAV-004 — Dashboard
Status: planned | Priority: P1 | Phase: 1

The home screen. In priority order: resume or start a workout, today's scheduled
day (`F-ROU-012`), current streak, recent PRs, insight cards (`F-ANA-013`), quick
bodyweight entry. Everything is a shortcut to doing something, not a wall of
statistics.

---

### F-NAV-005 — Empty states
Status: planned | Priority: P1 | Phase: 1

Every list has a designed empty state: icon, one line of explanation, one action.
A new install is *all* empty states, so this is the entire first impression.

---

### F-NAV-006 — Error and loading states
Status: planned | Priority: P1 | Phase: 1

Consistent loading and error presentation, plus the shared destructive-
confirmation sheet that names exactly what will be lost. Errors say what happened
and what to do, never a raw exception.

---

### F-NAV-007 — Home-screen widget
Status: idea | Priority: P3 | Phase: —

Next scheduled workout, streak, or a one-tap start. Platform-specific work on
both Android and iOS, so genuinely two implementations.

---

### F-NAV-008 — App shortcuts
Status: idea | Priority: P3 | Phase: —

Long-press launcher shortcuts: start empty workout, resume, log bodyweight. Cheap
on Android, and pure convenience.

---

## Theming — `THM`

### F-THM-001 — Material 3 foundation
Status: planned | Priority: P0 | Phase: 0
Blocks: F-THM-002, F-THM-003, F-THM-004

`ColorScheme.fromSeed` from a single seed colour, with semantic role extensions
for `success`, `pr`, `warning`, `danger`, `ghost`, and the categorical chart
palette. Colour is never a literal in a widget.

---

### F-THM-002 — Light and dark schemes
Status: planned | Priority: P0 | Phase: 0
Depends on: F-THM-001

Explicitly required. Both schemes are designed as equals and checked in every
review, not one derived from the other by inversion. Dark mode uses M3 surface
tints for elevation and avoids pure black to prevent OLED smearing during scroll.

The `ghost` role (`F-LOG-004`) is the hardest single colour decision in the app:
too faint and it's invisible under gym lighting, too strong and users mistake it
for entered data. Needs testing on a real phone in a real gym, not in a simulator.

**Acceptance criteria**
- [ ] Every screen is checked in both schemes before its feature is done.
- [ ] 4.5:1 text contrast in both (`F-A11Y-003`).

---

### F-THM-003 — Dynamic colour
Status: planned | Priority: P2 | Phase: 2

Android 12+ wallpaper-derived colour, user-toggleable, **off by default** so the
app has a consistent identity out of the box. Must not break the semantic roles —
`pr` and `danger` keep their meaning regardless of the wallpaper.

---

### F-THM-004 — Chart theming
Status: planned | Priority: P1 | Phase: 3
Depends on: F-THM-001, F-ANA-001

Chart colours, gridlines, and axis labels as theme tokens. The categorical
series palette must be distinguishable in both schemes and without colour vision
(`F-A11Y-003`) — series are also differentiated by marker shape or dash pattern.

---

### F-THM-005 — Typography
Status: planned | Priority: P1 | Phase: 0
Depends on: F-THM-001

M3 type scale with one significant override: **all numeric display uses tabular
figures**. Set weights, reps, volumes, timers, axis labels. Proportional digits
in a set list read slowly and look wrong when columns should align vertically.

---

### F-THM-006 — App icon and branding
Status: planned | Priority: P2 | Phase: 6

Icon, adaptive icon, splash, and store assets. Deferred until there's something
worth putting an icon on, but required before any public listing (`F-REL-006`).

---

## Accessibility — `A11Y`

Built in continuously, not retrofitted in Phase 6. Each item below is part of the
definition of done for every feature ([`../60-ENGINEERING.md`](../60-ENGINEERING.md)),
with a dedicated audit pass in Phase 6.

### F-A11Y-001 — Screen reader support
Status: planned | Priority: P1 | Phase: 6

Semantic labels on every interactive element. Set rows announce meaningfully —
"set 3, working, 100 kilograms, 8 reps, completed" — rather than reading out raw
cell contents. Charts carry a text summary alternative, since a line chart is
otherwise entirely inaccessible.

---

### F-A11Y-002 — Dynamic type
Status: planned | Priority: P1 | Phase: 6

Full functionality at 200% system text scale. This constrains how many columns
the set row can carry, which is why it's a design constraint from the start
rather than a later fix.

---

### F-A11Y-003 — Contrast and colour independence
Status: planned | Priority: P1 | Phase: 6

4.5:1 for text and 3:1 for interactive boundaries, in both schemes. No
information conveyed by colour alone — set types carry letters, chart series
carry shapes, PRs carry an icon.

---

### F-A11Y-004 — Touch targets and reach
Status: planned | Priority: P1 | Phase: 1

48 dp minimum, 56 dp for set-row controls, which are hit mid-set with imprecise
aim. Primary actions in the bottom half of the screen.

---

### F-A11Y-005 — Reduce motion
Status: planned | Priority: P2 | Phase: 6

Honour the system reduce-motion setting: no chart animations, no PR celebration
animation, instant transitions.

---

## Localisation — `I18N`

### F-I18N-001 — String externalisation
Status: planned | Priority: P1 | Phase: 6

All user-facing strings in ARB files from the start, even while English-only.
Retrofitting extraction across a finished app is miserable and never quite
complete; doing it continuously costs almost nothing.

---

### F-I18N-002 — Locale-aware formatting
Status: planned | Priority: P1 | Phase: 0
Depends on: F-SET-001

Numbers and dates formatted via `intl`. Decimal separators follow the device
locale — a German user typing `102,5` must work — which is a correctness issue
in the input parser, not a cosmetic one. Belongs in Phase 0 with the unit system,
not with the rest of localisation.

---

### F-I18N-003 — Additional locales
Status: idea | Priority: P3 | Phase: —

Actual translations. Only worth doing once there are users who need them; the
scaffolding above is what keeps the option open.
