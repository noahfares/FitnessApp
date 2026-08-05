# Body metrics — `BOD`

Bodyweight and measurements. Small surface area, but it feeds
`F-LOG-019` (bodyweight-loaded exercises), and body composition context is what
makes volume and strength trends interpretable.

---

### F-BOD-001 — Bodyweight log
Status: planned | Priority: P1 | Phase: 4
Blocks: F-LOG-019, F-BOD-003
Screens: Body Metrics
Data: `body_measurements`

**Behaviour**
1. Log bodyweight with a date and optional note; multiple entries per day
   allowed, though one is typical.
2. Displayed in the body unit (`F-SET-001`), which is independently configurable
   from the load unit — many people lift in kilograms and weigh in pounds.
3. The most recent value before a workout's date supplies its
   `workouts.bodyweight_grams`.
4. Quick entry from the dashboard, not just from a settings screen.

**Acceptance criteria**
- [ ] Stored canonically in grams; changing the display unit rewrites nothing.
- [ ] Backfilling an older entry updates the affected workouts' bodyweight
      association.

---

### F-BOD-002 — Circumference measurements
Status: planned | Priority: P2 | Phase: 4
Data: `body_measurements`

Waist, chest, hips, neck, arms, thighs, calves, shoulders, plus body-fat
percentage. Left and right tracked separately for limbs, since asymmetry is
worth seeing. Stored in millimetres, displayed in centimetres or inches
(`F-SET-001`). Users choose which measurements to track — showing all thirteen
by default is clutter.

---

### F-BOD-003 — Trend charts with smoothing
Status: planned | Priority: P1 | Phase: 4
Depends on: F-BOD-001, F-ANA-001

**Intent** — Daily bodyweight is dominated by water, food, and time of day; the
raw series swings by kilograms and reading it as progress is actively
misleading. The smoothed line is the only part that carries information.

**Behaviour**
1. Chart raw points plus an exponential moving average.
2. The EMA is visually dominant; raw points are secondary.
3. Rate of change shown per week, computed on the smoothed series.
4. Optional goal line (`F-BOD-005`).

**Acceptance criteria**
- [ ] EMA matches the fixture in [`../40-ANALYTICS-SPEC.md`](../40-ANALYTICS-SPEC.md).
- [ ] Gaps in logging don't corrupt the smoothing.

---

### F-BOD-004 — Progress photos
Status: planned | Priority: P2 | Phase: 5

**Intent** — The most useful body-composition record there is, and the most
sensitive data the app would ever hold.

**Behaviour**
1. Photos stored in app-private storage. **Never uploaded, never leave the
   device**, and excluded from any future cloud sync unless explicitly opted in.
2. Date-tagged, side-by-side comparison view.
3. Included in local backups (`F-DAT-003`) only with explicit consent, since it
   changes the backup's sensitivity profile entirely.
4. Optional biometric lock (`F-SET-010`).

**Open questions** — Backup handling is genuinely tricky: silently including
photos in a backup file the user then emails to themselves would be a serious
privacy failure. Default to excluding them, with a clear opt-in.

---

### F-BOD-005 — Goals
Status: idea | Priority: P3 | Phase: —

Target bodyweight or measurement with a goal line on charts and progress
tracking. Deliberately unopinionated — no calorie advice, no prescriptive
timelines, since that's a different app and a different duty of care.

---

### F-BOD-006 — Measurement reminders
Status: idea | Priority: P3 | Phase: —

Optional recurring reminder to log bodyweight or measurements. Must be genuinely
optional and easy to switch off; nagging is a fast route to uninstallation.
