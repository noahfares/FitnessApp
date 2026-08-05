# Design system

Material 3. Features `F-THM-001`–`F-THM-006` and `F-A11Y-001`–`F-A11Y-005` in
[`30-features/THM/`](30-features/THM/) and [`A11Y/`](30-features/A11Y/).

## Design brief

The requirement is "clean and organised". Concretely, for this app:

- **Dense where it counts, generous elsewhere.** A set row must fit five columns
  legibly on a small phone; a settings screen has no such pressure.
- **Numbers are the interface.** Weights, reps, and volumes get tabular figures
  and consistent alignment so columns scan vertically. Proportional digits in a
  set list look sloppy and read slowly.
- **Chrome recedes.** Cards, dividers, and borders are the exception. Grouping
  comes from spacing and typographic hierarchy first.
- **One accent.** A single seed colour drives the scheme. Colour carries meaning
  — PRs, completion, warnings — and is not decoration.
- **No decorative imagery.** No stock gym photography, no gradients-for-vibes.

## Colour (`F-THM-001`, `F-THM-002`)

Generated with `ColorScheme.fromSeed` from one seed colour, producing both light
and dark schemes. Dynamic colour from the Android 12+ wallpaper is supported and
user-toggleable (`F-THM-003`), defaulting **off** so the app has a consistent
identity out of the box.

Light and dark are equal citizens, not one derived from the other by inversion.
Both are checked in every review. Dark mode gets:

- True surface elevation via M3 surface tints, not opacity hacks.
- No pure black background — `surface` from the scheme, so OLED smearing during
  scroll doesn't hurt readability. A separate pure-black AMOLED option is
  backlogged (`F-THM-002` open question).
- Chart lines and fills that hold contrast on dark surfaces (`F-THM-004`); chart
  colours are theme tokens, never hardcoded.

### Semantic colour roles

Defined once as theme extensions, never as literals in widgets:

| Role | Meaning |
|---|---|
| `success` | Completed set, achieved target |
| `pr` | Personal record — the only celebratory colour in the app |
| `warning` | Missed target, stalled lift, deload suggestion |
| `danger` | Destructive action |
| `ghost` | "Last time" prefill text (`F-LOG-004`) — must read as clearly non-authoritative but remain legible |
| `chartSeries[]` | Ordered categorical chart palette, colour-blind safe (`F-A11Y-003`) |

`ghost` is the subtlest and most important: too faint and it's invisible in gym
lighting, too strong and users mistake it for entered data. Requires physical
testing under bright light, not just a simulator.

## Typography (`F-THM-005`)

Material 3 type scale with one override: **all numeric displays use tabular
(monospaced) figures**. Set weights, reps, volume totals, timers, and chart
axis labels.

| Use | Style |
|---|---|
| Screen titles | `headlineSmall` |
| Section headers | `titleMedium` |
| Set-row values | `bodyLarge`, tabular |
| Rest timer | `displaySmall`, tabular — readable at arm's length on a bench |
| Metadata, ghost values | `bodySmall` |

All text scales with the system font-size setting (`F-A11Y-002`). Set rows must
remain usable at 200% scale; this constrains how many columns can fit and is
a design constraint from the start, not a later fix.

## Spacing & layout

4 dp base unit; spacing tokens `4, 8, 12, 16, 24, 32`. Screen padding 16 dp.
Minimum touch target 48 dp — set-row checkboxes and steppers get 56 dp, because
they're hit mid-set with imprecise aim (`F-A11Y-004`).

Layout targets phones in portrait. Landscape and tablet are supported by not
breaking — no bespoke layouts until someone actually wants them.

## Component inventory

Built once in `features/shell/widgets/` or `core/`, reused everywhere. Each
becomes a widget test.

| Component | Notes | Feature |
|---|---|---|
| `SetRow` | The most important widget in the app. Columns: set number/type, ghost previous, weight, reps, complete. Swipe for type change and delete. | `F-LOG-003` |
| `NumericKeypad` | Bottom-sheet keypad with plate-aware increments. Big targets. Never the system keyboard for weight entry. | `F-LOG-006` |
| `IncrementStepper` | +/− stepping by the exercise's increment, long-press to repeat. | `F-LOG-006` |
| `ExercisePickerSheet` | Search, filter, recents-first ordering. | `F-CAT-004` |
| `RestTimerBar` | Persistent while running; tappable to adjust. | `F-TIM-001` |
| `ActiveWorkoutBanner` | Above bottom nav, all screens. | `F-NAV-003` |
| `MetricTile` | One number, label, delta vs previous period. | `F-ANA-013` |
| `TrendChart` | Line chart with optional regression overlay. | `F-ANA-003` |
| `BarChart` | Weekly volume and set counts. | `F-ANA-004` |
| `CalendarHeatmap` | Consistency grid. | `F-ANA-006` |
| `MuscleBodyMap` | SVG silhouette with per-muscle intensity shading. | `F-ANA-014` |
| `EmptyState` | Icon, one line, one action. Every list needs one. | `F-NAV-005` |
| `ConfirmSheet` | Destructive confirmation naming what is lost. | `F-NAV-006` |
| `PrBadge` | Inline PR marker. | `F-LOG-013` |

## Charts (`F-THM-004`, `F-ANA-016`)

Consistent across every chart in the app:

- Colours come from `chartSeries[]` theme tokens; readable in both schemes and
  distinguishable without colour alone — series are also differentiated by
  marker shape or dash pattern (`F-A11Y-003`).
- Y axes on weight charts do **not** start at zero — training changes are small
  relative to absolute load and a zero-based axis flattens every meaningful
  trend into a straight line. Volume bar charts *do* start at zero, because bar
  length encodes magnitude.
- Every chart states its date range and units in a subtitle.
- Fewer than three data points renders a "not enough data yet" state rather than
  a misleading two-point line.
- Interaction is tap-for-tooltip and pinch-to-zoom on the time axis; no
  animations longer than 200 ms, and none at all under reduce-motion
  (`F-A11Y-005`).

## Motion

Sparing. Transitions 150–250 ms. Exactly two celebratory moments: PR achieved
(`F-LOG-013`) and workout finished (`F-LOG-018`). Nothing else animates for
delight — mid-set, animation is latency.

## Accessibility baseline (`F-A11Y-001`–`005`)

Not a Phase 6 retrofit. Every feature ships with:

- Semantic labels on all interactive elements; set rows announce meaningfully
  ("set 3, working, 100 kilograms, 8 reps, completed") rather than reading raw
  cell contents.
- 4.5:1 contrast minimum for text, 3:1 for interactive boundaries, in both
  schemes.
- Full functionality at 200% text scale.
- No information conveyed by colour alone.
- Reduce-motion honoured.
