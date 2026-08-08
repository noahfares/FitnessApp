# Analytics specification

Every metric the app computes: definition, formula, edge cases, and a worked
numeric fixture. Implemented as pure functions in `lib/domain/analytics/`
(`F-ANA-001`); presented by the features in
[`30-features/ANA/`](30-features/ANA/).

**The fixtures in this document are the unit tests.** They are also available
machine-readable in [`fixtures/analytics.json`](fixtures/analytics.json) —
tests load that file rather than transcribing these tables into Dart, so the two
cannot drift apart. This document stays the source of truth: if they ever
disagree, the JSON is wrong.

A metric without a passing fixture test is not done.

## Universal preconditions

Applied once at the boundary of the analytics engine, so no individual metric
can forget them:

1. **Tombstoned rows are excluded.** `deleted_at IS NOT NULL` → dropped, at
   every level: set, workout exercise, workout, exercise. Nothing is ever hard
   deleted ([ADR-0008](70-decisions/ADR-0008-sync-ready-foundations.md)), so a
   query that forgets this silently counts data the user deleted.
2. **Warm-up sets are excluded.** Always, from every metric.
   (`set_type == warmup` → dropped.)
3. **Incomplete sets are excluded.** `is_completed == false` → dropped.
4. **Sets with null weight or reps are excluded** from metrics requiring them.
5. **All computation is on canonical integers** — grams, seconds, metres.
   Conversion to display units happens after the metric, never before.
6. **Week boundaries follow the user's first-day-of-week setting** (`F-SET-005`),
   and a session belongs to the **local** calendar date derived from its
   `started_at` plus `started_at_tz_offset_minutes` — never from UTC directly.
   A 22:00 session in UTC+10 is not the next day.

Set types `working`, `drop`, `failure`, `amrap`, and `backoff` all count.

---

## 1. Estimated one-rep max (e1RM)

Used by: `F-ANA-003`, `F-ANA-009`, `F-LOG-013`, `F-PRG-010`.

Normalises performances across rep ranges so a heavy triple and a set of ten are
comparable. This is the app's primary answer to "am I getting stronger?"

### Formulas

Selectable in settings (`F-SET-006`); Epley is the default.

| Name | Formula |
|---|---|
| **Epley** | `1RM = w × (1 + r / 30)` |
| **Brzycki** | `1RM = w × 36 / (37 − r)` |
| **Lombardi** | `1RM = w × r^0.10` |

Where `w` = weight, `r` = reps.

### Rules

1. **`r == 1` returns `w` exactly**, for every formula. Epley otherwise returns
   `w × 1.033` for a genuine single, which is plainly wrong. Special-case it.
2. **`r > 12` is flagged unreliable.** All three formulas diverge badly at high
   reps. Compute it, mark it, and let charts optionally exclude it.
3. **Brzycki is undefined at `r ≥ 37`** (division by zero or negative). Clamp:
   return unreliable and fall back to Epley.
4. **Session e1RM = the maximum e1RM across that session's counted sets** — not
   the heaviest set, and not the last set. A set of 8 can out-score a heavy
   triple, and that's the point of the metric.
5. Zero-weight sets yield no e1RM (excluded, not zero).

### Fixture — `e1rm`

| Weight | Reps | Epley | Brzycki | Lombardi |
|---|---|---|---|---|
| 100 kg | 1 | 100.000 | 100.000 | 100.000 |
| 100 kg | 5 | 116.667 | 112.500 | 117.462 |
| 100 kg | 8 | 126.667 | 124.138 | 123.114 |
| 100 kg | 10 | 133.333 | 133.333 | 125.893 |
| 60 kg | 12 | 84.000 | 86.400 | 76.925 |

Worked: Epley at 100×8 = `100 × (1 + 8/30)` = `100 × 1.26667` = **126.667**.
Brzycki = `100 × 36/29` = **124.138**. Lombardi = `100 × 8^0.1` = **123.114**.
(Lombardi at 60×12 = `60 × 12^0.1` = `60 × 1.28209` = **76.925** — corrected in
batch 3.2; the table previously read 76.049, arithmetically inconsistent with
the formula the other four rows all match exactly.)

Note the three agree closely at 5–10 reps and diverge outside it — which is why
the choice is exposed to the user rather than hidden.

### Fixture — session e1RM

Session sets: `warmup 60×10`, `100×5`, `105×3`, `95×8`.
Epley: warm-up dropped; 116.667, 115.500, 120.333 → **session e1RM = 120.333**
from the 95×8 set, not from the heaviest set. Correct behaviour.

---

## 2. Volume load

Used by: `F-ANA-004`, `F-ANA-010`, `F-ANA-013`, `F-LOG-018`.

```
volumeLoad = Σ (weight × reps)   over counted sets
```

### Rules

1. Only meaningful for `weightReps` and `weightTime` tracking types. Other types
   are **excluded**, never counted as zero — a zero would drag averages down and
   imply the work didn't happen.
2. Bodyweight exercises contribute only if effective load is known
   (`F-LOG-019`); otherwise excluded.
3. Per-side entry has already been converted to total load at write time
   (`F-LOG-017`), so no adjustment happens here.
4. Aggregated per exercise, per muscle group, and overall, by day or by week.

### Fixture — `volumeLoad`

Sets: `warmup 60×10`, `100×5`, `100×5`, `95×8`.

```
warm-up excluded
100 × 5 = 500
100 × 5 = 500
 95 × 8 = 760
total   = 1760 kg
```

Including the warm-up would give 2360 — a 34% overstatement, and the reason
`F-LOG-005` is a P0 feature rather than a nicety.

---

## 3. Hard sets per muscle group per week

Used by: `F-ANA-005`, `F-ROU-011`, `F-ANA-014`.

The metric that actually drives hypertrophy programming, and the one most
consumer apps omit.

```
setsFor(muscle, week) = Σ over counted sets:
    1.0  if muscle == exercise.primary_muscle
    0.5  if muscle ∈ exercise.secondary_muscles
    0    otherwise
```

### Rules

1. Every counted set contributes 1.0 to exactly one primary muscle.
2. Each secondary muscle receives 0.5. An exercise with three secondaries
   contributes 1.0 + 1.5 = 2.5 total muscle-sets, which is intended: totals
   across muscles are not meant to equal the session's set count.
3. The 0.5 weighting is fixed for v1. Per-exercise weightings are an open
   question in `F-CAT-013`.
4. `fullBody` as a primary muscle contributes to no specific muscle count.

### Fixture — `setsPerMuscle`

One week: Bench Press (primary `chest`, secondary `triceps`, `frontDelts`) for
4 sets; Overhead Press (primary `frontDelts`, secondary `triceps`) for 3 sets.

```
chest       = 4 × 1.0                 = 4.0
frontDelts  = 4 × 0.5  +  3 × 1.0     = 5.0
triceps     = 4 × 0.5  +  3 × 0.5     = 3.5
```

---

## 4. Personal records

Used by: `F-LOG-013`, `F-ANA-007`. Cached in `personal_records`, always
rebuildable from `sets`.

| Kind | Definition |
|---|---|
| `maxWeight` | Highest weight for any counted set of the exercise, regardless of reps |
| `maxRepsAtWeight` | Highest rep count at a given weight (qualifier = that weight) |
| `bestE1rm` | Highest e1RM of any counted set |
| `maxSessionVolume` | Highest single-session volume load for the exercise |

### Rules

1. **Strictly greater than.** Ties are not records.
2. Warm-up sets can never set a record.
3. The first-ever set of an exercise is technically a record on every kind.
   Record it silently; suppress the celebration (`F-LOG-013`).
4. Deleting or editing a set invalidates the cache for that exercise, which is
   recomputed from raw sets — never patched incrementally, since a patch can
   only ever demote incorrectly.
5. When one set triggers several kinds at once, display only the most
   significant, ordered `bestE1rm` > `maxWeight` > `maxRepsAtWeight` >
   `maxSessionVolume`.

### Fixture — `prDetection`

History: `100×5` (e1RM 116.667), `105×3` (e1RM 115.500).
New set `102.5×5` → e1RM 119.583.

```
maxWeight        105 → not beaten (102.5 < 105)          no PR
maxRepsAtWeight  no prior set at 102.5 kg                 PR
bestE1rm         116.667 → 119.583                        PR
displayed                                                 bestE1rm
```

A heavier bar isn't the only kind of progress, and this fixture is precisely the
case a naive "is it the heaviest?" check gets wrong.

---

## 5. Consistency

Used by: `F-ANA-006`.

| Metric | Definition |
|---|---|
| Training day | A local calendar date with ≥1 workout containing ≥1 counted set |
| Current streak | Consecutive **weeks** meeting the weekly session target, up to the current week |
| Longest streak | The maximum of the above over all history |
| Sessions/week | Rolling count over the trailing 4 weeks ÷ 4 |

### Rules

1. **Streaks are weekly, not daily.** Nobody trains every day, and a daily streak
   would punish correct programming — the metric would actively encourage bad
   training.
2. The weekly target defaults to 3 and is user-configurable.
3. The current week is provisional and never breaks a streak until it ends.
4. Streaks are presented without shame: no loss animation, no guilt copy
   (`F-ANA-006`).

### Fixture — `streak`

Weekly session counts, oldest → newest, target 3:
`[3, 4, 3, 2, 3, 3, 3, 1(current, in progress)]`

```
current streak  = 3   (the three complete weeks meeting target;
                       the in-progress week does not break it)
longest streak  = 3   (weeks 1–3, tied with weeks 5–7)
sessions/week   = (3 + 3 + 3 + 1) / 4 = 2.5
```

---

## 6. Bodyweight trend (EMA)

Used by: `F-BOD-003`.

Raw daily bodyweight swings by kilograms from water, food, and time of day.
Reading the raw series as progress is actively misleading; the smoothed line is
the only part that carries information.

```
α = 2 / (N + 1)                         N = 7 by default
EMA₀ = x₀
EMAₜ = α·xₜ + (1 − α)·EMAₜ₋₁
```

### Rules

1. `N = 7` gives `α = 0.25`.
2. The EMA is rendered visually dominant; raw points are secondary.
3. **Gaps do not corrupt the series** — the EMA advances per *observation*, not
   per calendar day. A two-week gap does not decay the average toward zero.
4. Weekly rate of change is computed on the smoothed series, never the raw one.

### Fixture — `ema`

Input (kg): `80.0, 80.6, 80.2, 81.0, 80.4, 80.8, 80.5`, `α = 0.25`.

| t | x | EMA |
|---|---|---|
| 0 | 80.0 | 80.000 |
| 1 | 80.6 | 80.150 |
| 2 | 80.2 | 80.163 |
| 3 | 81.0 | 80.372 |
| 4 | 80.4 | 80.379 |
| 5 | 80.8 | 80.484 |
| 6 | 80.5 | 80.488 |

Raw range is 1.0 kg; the smoothed range is 0.49 kg and monotonically rising —
the actual signal, invisible in the raw series.

---

## 7. Stall detection

Used by: `F-ANA-009`, `F-PRG-011`.

Least-squares slope of session e1RM against session index:

```
slope = Σ(xᵢ − x̄)(yᵢ − ȳ) / Σ(xᵢ − x̄)²
```

Where `x` is the session index and `y` is that session's e1RM.

### Rules

1. Requires **at least 5 sessions** within the window. Fewer, and no verdict is
   given — silence, not a guess.
2. Window defaults to the trailing 8 sessions of that exercise.
3. Stalled when `slope ≤ 0.1 kg per session` **and** the window spans at least
   3 weeks. The time condition prevents flagging a lift done twice in one week.
4. Deload weeks are excluded from the window once `F-ROU-013` exists.
5. Reported in plain English, not as a chart annotation (`F-ANA-009`).

### Fixture — `slope`

Session e1RMs: `126.7, 127.5, 127.0, 127.2, 126.9` at indices `0…4`.

```
x̄ = 2.0,  ȳ = 127.06
Σ(x−x̄)(y−ȳ) = 0.72 − 0.44 + 0 + 0.14 − 0.32 = 0.10
Σ(x−x̄)²     = 4 + 1 + 0 + 1 + 4            = 10
slope = 0.10 / 10 = 0.01 kg per session      → STALLED
```

Over five sessions that is 0.05 kg of total progress. The chart would look
noisy and ambiguous; the slope is unambiguous.

**Open question:** thresholds are guesses until tested against real history.
This is why `F-ANA-009` is scheduled for Phase 4 — after there is history to
tune against.

---

## 8. Acute-to-chronic workload ratio

Used by: `F-ANA-010`, `F-PRG-011`.

```
acute   = Σ volume load over the last 7 days
chronic = (Σ volume load over the last 28 days) / 4
ACWR    = acute / chronic
```

### Rules

1. Requires ≥28 days of history. Below that, not shown.
2. `chronic == 0` yields no value, never a division by zero.
3. Conventionally, 0.8–1.3 is described as a typical range and above ~1.5 as a
   sharp ramp.
4. **Presented as information, never as a warning.** The injury-risk literature
   behind ACWR is genuinely contested, and an app that tells someone they are
   about to get hurt on the basis of contested statistics is overreaching. State
   what it measures and let the user judge.

### Fixture — `acwr`

Weekly volumes, oldest → newest: `[10000, 11000, 10500, 15000]` kg.

```
acute   = 15000
chronic = (10000 + 11000 + 10500 + 15000) / 4 = 46500 / 4 = 11625
ACWR    = 15000 / 11625 = 1.290
```

---

## 9. Muscle balance ratios

Used by: `F-ANA-008`.

Computed over a trailing window (default 4 weeks) using the muscle-set counts
from §3.

| Ratio | Numerator | Denominator |
|---|---|---|
| Push : pull | `chest + frontDelts + triceps` | `lats + upperBack + biceps` |
| Quad : hamstring | `quads` | `hamstrings + glutes` |

### Rules

1. Presented as a ratio, e.g. `1.4 : 1`, alongside a commonly cited target of
   roughly 1:1, clearly labelled as a rough guide rather than a prescription.
2. A zero denominator is reported as "no pulling volume recorded", not as
   infinity.
3. The push/pull category mapping is fixed by `F-CAT-013`.

### Fixture — `pushPullRatio`

`chest 12`, `frontDelts 6`, `triceps 9`, `lats 10`, `upperBack 6`, `biceps 6`.

```
push = 12 + 6 + 9 = 27
pull = 10 + 6 + 6 = 22
ratio = 27 / 22 = 1.23 : 1
```

---

## 10. Intensity and rep distribution

Used by: `F-ANA-011`.

### Rep-range buckets

`1–3` strength · `4–6` strength/hypertrophy · `7–12` hypertrophy ·
`13–20` hypertrophy/endurance · `21+` endurance. Counted by number of sets.

### Intensity zones

Percentage of the exercise's current e1RM at the time of the set:

`<60%` · `60–70%` · `70–80%` · `80–90%` · `90%+`

### Rules

1. Intensity requires a known e1RM for the exercise **at that point in time** —
   using today's e1RM to classify a set from a year ago would be wrong. Use the
   most recent e1RM at or before the set's date.
2. Sets with no computable e1RM baseline are excluded, not bucketed as zero.
3. Where RPE exists (`F-LOG-014`), an RPE-based distribution is shown alongside;
   it's a more honest measure of intensity than a percentage of an estimate.

---

## 11. Estimated session duration

Used by: `F-ROU-011`.

```
estimate = Σ over exercises: sets × (avgSetSeconds + restSeconds)
```

With `avgSetSeconds` defaulting to 45 and rest resolved per `F-ROU-006`.

Crude by design — it exists so a routine editor can warn that a plan implies a
two-hour session, not to predict anything precisely. Label it as approximate.

---

## Implementation notes

1. Every function above is pure: plain inputs, plain outputs, no clock, no
   randomness, no I/O. The current date arrives as a parameter — otherwise the
   tests are unstable at midnight.
2. Intermediate arithmetic is on canonical integers. Rounding happens once, at
   display.
3. Every function gets the fixture above as a test, plus an empty-input test
   (must return a defined empty result, never throw) and a single-element test.
4. Performance target: a full recomputation over ~5 years of history in under
   100 ms on a mid-range device. Memoise in providers keyed by inputs
   (`F-ANA-001`).
5. When a metric cannot be computed, return an explicit "insufficient data"
   result rather than zero. **Zero and unknown are different things**, and
   conflating them is how a chart ends up telling a confident lie.
