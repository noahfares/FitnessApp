# Analytics & charts — `ANA`

The features here are the *presentation* of the metrics. The metrics themselves —
formulas, edge cases, worked fixtures — are specified in
[`../40-ANALYTICS-SPEC.md`](../40-ANALYTICS-SPEC.md) and implemented as pure
functions in `lib/domain/analytics/`.

Principle 3 in [`../10-VISION.md`](../10-VISION.md): insight over record-keeping.
A chart nobody can act on is decoration. Every feature here should answer a
question a lifter actually asks.

Chart conventions — axis rules, colour, empty states — are in
[`../24-DESIGN-SYSTEM.md`](../24-DESIGN-SYSTEM.md).

---

### F-ANA-001 — Analytics engine
Status: planned | Priority: P0 | Phase: 3
Blocks: F-ANA-002 … F-ANA-014

**Intent** — All metrics computed by pure Dart functions over entity lists, with
no Flutter or database dependency. This is the load-bearing decision that makes
the numbers trustworthy: every function is testable against a hand-worked
fixture, and a wrong figure is a failing test rather than a chart nobody
double-checks.

**Behaviour**
1. Functions live in `lib/domain/analytics/`, take plain entity lists, return
   plain results.
2. Every function has a unit test using the fixture from
   [`../40-ANALYTICS-SPEC.md`](../40-ANALYTICS-SPEC.md).
3. Warm-up and incomplete sets are filtered at the boundary, once, so no
   individual metric can forget to.
4. Results are memoised in `.family` providers keyed by inputs and date range.

**Acceptance criteria**
- [ ] `domain/` has zero Flutter imports, enforced by a lint rule in CI.
- [ ] Every metric in the spec has a passing fixture test.
- [ ] Computing a year of history stays under 100 ms on a mid-range device.

---

### F-ANA-002 — Per-exercise history
Status: planned | Priority: P0 | Phase: 3
Screens: Exercise Detail

Reverse-chronological list of every session containing an exercise, each showing
all sets, the best set, session volume, and estimated 1RM. The most-visited
analytics screen — it's what you check before you load the bar.

---

### F-ANA-003 — Estimated 1RM trend
Status: planned | Priority: P1 | Phase: 3
Depends on: F-ANA-001
Screens: Exercise Detail, Per-Exercise Analytics

**Intent** — The single best answer to "am I getting stronger?" Raw top-set
weight is confounded by rep changes; e1RM normalises across rep ranges so a
5×5 block and an 8–12 block are comparable.

**Behaviour**
1. One point per session: the best working set's e1RM.
2. Line chart over a selectable range, with an optional linear-regression overlay.
3. Sets above 12 reps are marked unreliable and optionally excluded.
4. Formula selectable in settings (`F-SET-006`); the chart states which is in use.
5. Y axis does not start at zero (`../24-DESIGN-SYSTEM.md`).

**Acceptance criteria**
- [ ] Matches hand-computed fixtures exactly.
- [ ] Fewer than three points renders "not enough data yet", not a misleading line.

---

### F-ANA-004 — Volume charts
Status: planned | Priority: P1 | Phase: 3
Depends on: F-ANA-001

Weekly volume load (Σ weight × reps over working sets) as a bar chart, per
exercise, per muscle group, and overall. Zero-based Y axis, since bar length
encodes magnitude. Week boundaries follow the user's first-day-of-week setting
(`F-SET-005`).

---

### F-ANA-005 — Sets per muscle group per week
Status: planned | Priority: P1 | Phase: 3
Depends on: F-CAT-013
Blocks: F-ROU-011

**Intent** — The metric that actually drives hypertrophy programming, and the one
most consumer apps omit entirely. Training literature talks in hard sets per
muscle per week; nothing else in the app answers "am I doing enough for rear
delts?"

**Behaviour**
1. Count working sets per muscle per week. Primary muscle counts 1.0, each
   secondary counts 0.5.
2. Bar chart per muscle with optional reference bands for common volume targets.
3. Drill into a muscle to see which exercises contributed.

**Open questions** — Should reference bands ship at all? They imply a
prescriptive stance the app otherwise avoids, and the research ranges are wide.
Probably yes, clearly labelled as a rough guide, off by default.

---

### F-ANA-006 — Consistency
Status: planned | Priority: P1 | Phase: 3
Screens: Consistency

Calendar heatmap of training days, current and longest streak, rolling
sessions-per-week average, and adherence against schedule once `F-ROU-012`
exists. Streaks are motivating but must not shame — no loss animations, no
guilt copy.

---

### F-ANA-007 — PR timeline
Status: planned | Priority: P1 | Phase: 3
Depends on: F-LOG-013
Screens: PR Timeline

Chronological list of every personal record, filterable by exercise and kind,
with the set that achieved it. The app's highlight reel.

---

### F-ANA-008 — Muscle balance
Status: planned | Priority: P2 | Phase: 3
Depends on: F-CAT-013

Push-to-pull and quad-to-hamstring ratios plus a radar chart of relative volume
by muscle group. Catches the classic imbalances that cause injuries and stalls,
which are invisible in per-exercise views.

---

### F-ANA-009 — Stall detection
Status: planned | Priority: P2 | Phase: 4
Depends on: F-ANA-003

**Intent** — Charts require you to go looking. Stalling is exactly the thing you
don't notice from inside it, and the thing most worth being told.

**Behaviour**
1. Linear regression on e1RM over the trailing N sessions of an exercise.
2. Flag when the slope is flat or negative across a meaningful window with
   enough data points to be significant.
3. Surface as plain English — "Bench press hasn't moved in 6 weeks" — not as a
   chart annotation.
4. Suggest concrete actions: deload (`F-PRG-011`), volume change, or exercise
   variation.

**Open questions** — Thresholds. Too sensitive and it cries wolf every deload
week; too lax and it's useless. Needs tuning against real history, so ship it
after there is real history to tune against.

---

### F-ANA-010 — Acute-to-chronic workload ratio
Status: planned | Priority: P2 | Phase: 4

Ratio of 7-day rolling volume to 28-day rolling volume, as a fatigue and
ramp-rate signal. Well established in sports science for injury risk, though the
evidence base is contested — present it as information, never as a warning, and
say plainly what it is.

---

### F-ANA-011 — Rep range and intensity distribution
Status: planned | Priority: P2 | Phase: 4
Depends on: F-LOG-014

Histograms of sets by rep range and by intensity zone (% of e1RM, or RPE where
recorded). Reveals that a program claiming to be "strength focused" is actually
running everything at 8–12 — a genuinely common blind spot.

---

### F-ANA-012 — Duration and rest compliance
Status: planned | Priority: P3 | Phase: 4
Depends on: F-TIM-007

Session duration trend and actual-versus-prescribed rest. Drifting rest times
explain a lot of apparent plateaus.

---

### F-ANA-013 — Weekly insight cards
Status: planned | Priority: P2 | Phase: 4
Depends on: F-ANA-003, F-ANA-004, F-ANA-005, F-ANA-009

**Intent** — The payoff for the whole analytics layer. Most users will never open
a chart; they will read a sentence. This turns the metrics into the thing the app
is actually for.

**Behaviour**
1. A small set of generated cards on the dashboard, e.g. "Chest volume is down
   31% versus your 4-week average", "Squat e1RM up 7.5 kg this month",
   "Rear delts: 4 sets last week".
2. Ranked by significance; only genuinely notable changes shown.
3. Each card links to the chart behind it.
4. Never fabricates significance — with insufficient data, it says nothing
   rather than inventing an observation.

**Acceptance criteria**
- [ ] A new user with two sessions sees no spurious insights.
- [ ] Every card's claim is verifiable from the underlying chart.

---

### F-ANA-014 — Body map heat overlay
Status: planned | Priority: P3 | Phase: 4
Depends on: F-CAT-013

Anatomical silhouette shaded by recent training volume per muscle. Instantly
legible, and it's what people actually want from `F-ANA-005`. Needs a licence-
clean SVG — same sourcing discipline as `F-CAT-001`.

---

### F-ANA-015 — Date range and filter controls
Status: planned | Priority: P1 | Phase: 3

Shared range selector across every chart — 4 weeks, 3 months, 6 months, 1 year,
all time, custom. Selection persists across screens within a session so
comparing charts doesn't mean re-selecting the range each time.

---

### F-ANA-016 — Chart interaction
Status: planned | Priority: P2 | Phase: 3

Tap for a tooltip with exact values and the source session, pinch to zoom the
time axis, tap through to the workout that produced a point. Charts that are
read-only pictures waste the data behind them.

---

### F-ANA-017 — Year in review
Status: idea | Priority: P3 | Phase: —

An annual recap — total volume, sessions, PRs, biggest gains — as a shareable
image. Purely for delight, and the only outward-facing artefact the app would
produce.

---

### F-ANA-018 — Exercise comparison
Status: idea | Priority: P3 | Phase: —

Overlay two exercises' e1RM trends on one chart to compare, say, low-bar versus
high-bar squat progression, or track how an accessory tracks its main lift.
