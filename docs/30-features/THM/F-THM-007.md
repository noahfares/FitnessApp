# F-THM-007 — Apple-style visual redesign — light and dark

Status: done | Priority: P2 | Phase: 6
Reads: 24-DESIGN-SYSTEM

A visual redesign of the five-tab shell, Home, Log a Set (the numeric keypad
and plate calculator), Insights (per-exercise), and Session Summary — rebuilt
on Apple's product-page and iOS vocabulary: SF-style system type with tight
negative tracking, tinted grouped surfaces, filled pill buttons, and a single
accent colour. Both light and dark appearances are fully specified from a
design handoff, following Apple's *elevated* dark palette rather than pure
black.

---

## Spec

1. `AppColors` gained the handoff's full token set (`background`, `surface`,
   `surfaceRaised`, `surfaceHover`, `surfaceRaisedHover`, `label`,
   `labelSecondary`, `labelTertiary`, `separator`, `tint`, `tintHover`,
   `prSurface`, `prBorder`, `prLabel`, `prBody`, `chartInactive`,
   `barShaftStart`, `barShaftEnd`) alongside the existing semantic roles.
   `pr` moved to Apple's `systemOrange` (`#FF9500` / `#FF9F0A`); `onPr`
   changed from white to black in light mode to clear WCAG AA against it.
2. `AppTheme.seed` moved from the old indigo (`#3E63DD`) to Apple's light
   `tint` (`#0071E3`) — `ColorScheme.fromSeed` still derives the rest of the
   Material roles from it, so every screen re-tints, not only the four
   redesigned ones. `AppRadius` is a new token set (`card`=20, `tile`=16,
   `control`=12, `plate`=4) alongside `AppSpacing`.
3. **Dynamic colour becomes the "off" state's alternative**, not a casualty:
   when the existing toggle (`F-THM-003`) is off (default), `AppTheme` uses
   the exact Apple hexes for background/surface/tint; when it's on, it falls
   back to the wallpaper-derived M3 scheme exactly as before. Resolves the
   handoff's "Material 3 vs. this" conflict without removing the feature.
4. Five-tab shell (`app_shell.dart`): `NavigationBar` restyled via
   `labelTextStyle`/icon colours (`tint` active, `labelSecondary` inactive);
   the centre Start slot is a floating 44×44 filled-circle icon with no
   visible label (an accessible `Semantics(label: 'Start')` stands in for
   assistive tech). `ActiveWorkoutBanner` restyled to `surface` with a top
   hairline instead of `primaryContainer`.
5. Home (`dashboard_screen.dart`): app bar removed in favour of an inline
   date caption + large "Home" title; grouped `surface` cards (radius 20) for
   the resume/start action, today's schedule, and bodyweight; a flush row
   list (hairline dividers, no cards) for recent workouts. The former
   `OutlinedButton` pair (Exercises/History) is replaced by flush rows for
   **Exercises** and **Settings** — Settings previously lived in the app
   bar's removed action; per the project owner's call, both moved to Home
   rather than a tab, since neither has a tab slot of its own.
6. Log a Set (`set_row.dart`, `numeric_keypad_sheet.dart`,
   `plate_calculator_sheet.dart`, `plate_stack_visualization.dart`): value
   cells and keypad keys restyled to `surfaceRaised`/`AppRadius.control`;
   the `+`/`−` steppers restyled to the tint/surfaceRaised pairing the
   handoff specifies; `PlateStackVisualization` gained a `fullBar` option
   that draws both sleeves and a gradient shaft with the plates mirrored on
   each side (previously one side only), used by the plate calculator.
7. Insights (`exercise_detail_screen.dart`): secondary text and the stall
   card moved to `labelSecondary`/`surface`+`AppRadius.card`. `TrendChart`'s
   points are now hollow (background-filled circle, coloured ring) instead
   of solid, and `WeeklyBarChart` tints only the most recent (current-week)
   bar, with the rest in `chartInactive` — both are shared, multi-consumer
   widgets, so this reads app-wide, not only on this screen.
   `chartSeries[0]` now equals `tint`, so any single-series chart picks up
   the same accent by default.
8. Session Summary (`session_summary_screen.dart`, `pr_badge.dart`): the
   `celebration_outlined` icon is gone — "Nice work." at 40/700 carries the
   moment instead, with a new workout-name/date subtitle (read from the
   already-watched `workoutByIdProvider`, not a new one). Stats render as a
   2×2 grid of `surface` tiles; PRs render as `prSurface`/`prBorder` cards
   with no trophy icon. `PrBadge` and the summary's PR icon now read
   `context.appColors.pr` instead of the seeded `colorScheme.tertiary`,
   resolving the handoff's "PR colour vs. the seeded tertiary role" conflict.
9. The app icon, adaptive icon, launch background and store graphics
   (`F-THM-006`) regenerated from the new seed via `tools/gen-icons.sh`, so
   branding matches the new tint rather than the retired indigo.

## Conflicts resolved (from the design handoff)

- **Material 3 vs. Apple styling** — kept M3/`ColorScheme.fromSeed` as the
  base (re-seeded to the new tint) for cascade and dynamic-colour support;
  layered the handoff's exact tokens on top for the four redesigned screens
  and the shared chrome. See point 3 above.
- **PR colour vs. seeded `tertiary`** — `pr` wins; see point 8.
- **"Chrome recedes" vs. tinted cards** — the tinted-card treatment is a
  deliberate, accepted departure from `docs/24-DESIGN-SYSTEM.md`'s "cards are
  the exception" rule, matching the handoff's own call-out. The recent-
  workouts and exercises/settings rows stay flush, per the handoff.
- **`ghost` role** — left at its existing tuned value rather than moved to
  `labelSecondary`, per the handoff's own tie-breaker ("`ghost` wins").

## Deliberately out of scope

Two structures in the handoff's mockup don't correspond to anything the real
data layer or existing widgets expose, and adding them would have meant new
providers or a changed interaction model — which the handoff itself commits
not to require ("no new providers, no data-model changes"):

- Home's "This week" 3-tile Sessions/Volume/PRs grid — the existing
  `WeeklyInsightsSection` (a list of insight cards under the same header) was
  restyled to the new tokens instead of replaced.
- Insights' "Top set / e1RM / Volume" segmented metric switcher — the real
  screen already plots e1RM trend and weekly volume simultaneously via
  `DateRangeSelector` and two independent charts, a different (and already
  shipped) interaction model; both charts were restyled, not replaced.
- The reps row's 5 preset buttons (6–10) and the single-field "Log a Set"
  page in the mockup — the real keypad supports arbitrary typed values across
  four field types (weight/reps/duration/distance); restyled in place rather
  than narrowed to the mockup's simplified demo interaction.

Parked as an idea rather than built, per the "don't silently expand scope"
rule — flagged here for a future decision, not a gap in this feature.

## Acceptance

- [x] `AppColors`/`AppTheme` carry the full Apple token set, gated on
      dynamic colour being off; `tools/verify.sh` (format, analyze, test,
      layers, network, strings, docs) passes clean.
- [x] The five-tab shell, Home, Log a Set surfaces, Insights, and Session
      Summary are restyled in both light and dark, matching the handoff's
      colours, radii, spacing, and typography for the elements that map to
      real data/widgets.
- [x] `pr` drives every celebratory colour in the app (`PrBadge`, the
      summary's PR cards) instead of the seeded `tertiary` role.
- [x] Existing test suite passes with only the expected, documented
      behavioural updates (Settings' entry point, the Start tab's label,
      section-header casing).
- [x] App icon, adaptive icon, launch background, and store graphics
      regenerated from the new seed.

## Edge cases

- Dynamic colour ON: every fixed-hex override in `AppTheme._build` falls back
  to the wallpaper-derived `ColorScheme`, so toggling it produces the same
  before/after behaviour it always did — the Apple palette is additive, not a
  replacement for that feature.
- A workout finished by a since-deleted routine day still resolves a name and
  date on Session Summary — `workoutByIdProvider` reads the `workouts` row
  directly, not the routine.

## Open questions

- Whether to build the two deliberately-out-of-scope mockup structures above
  as real features (a "this week" summary provider, a metric-switching
  Insights chart) is the project owner's call — nothing here blocks on it.

---

## Why

Strong / Hevy / JEFIT all lean on a recognisable, premium visual language;
this app's Material 3 default read as generic next to them. A design handoff
grounded in the real repository (real screens, real data, real component
names) let this land as a genuine reskin rather than a mockup nobody could
build against.
