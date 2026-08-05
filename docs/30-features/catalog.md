# Exercise catalogue — `CAT`

The list of things you can do in a workout. Every logged set points at a row
here. Entry format: [`README.md`](README.md).

---

### F-CAT-001 — Seeded exercise catalogue
Status: planned | Priority: P0 | Phase: 1
Blocks: F-CAT-002, F-LOG-002
Data: `exercises`

**Intent** — The app is unusable on first launch without a decent set of
exercises. 200–400 covers essentially all barbell, dumbbell, machine, cable and
bodyweight work an ordinary lifter does. This is also the single largest legal
risk in the project: scraping a competitor's database is a non-starter and would
be fatal to a store release.

**Behaviour**
1. Catalogue ships as `assets/seed/exercises.json`, versioned, each record with
   a stable UUID, name, primary muscle, secondary muscles, equipment, and
   tracking type.
2. Seeded into `exercises` on first launch.
3. On app upgrade, re-seeding adds new records and updates unmodified seeded
   ones. It never overwrites user-edited or custom rows.
4. `assets/seed/SOURCES.md` records provenance and licence for every record.

**Acceptance criteria**
- [ ] First launch yields a populated, searchable catalogue with no network access.
- [ ] Every record has a primary muscle and a tracking type — no nulls.
- [ ] Editing a seeded exercise, then upgrading, preserves the user's edit.
- [ ] `SOURCES.md` accounts for every record with a verified licence.

**Edge cases** — Seeding interrupted mid-write (wrap in a transaction). A seeded
exercise removed in a later version but referenced by existing sets — archive,
never delete.

**Open questions**
- Source: a permissively licensed public dataset, or hand-authored? Requires
  reading actual licence text, not a README summary. **Blocking before any
  public release.**
- How is "user-modified" tracked — a boolean flag or `updated_at` comparison?

---

### F-CAT-002 — Exercise model & tracking types
Status: planned | Priority: P0 | Phase: 1
Depends on: F-CAT-001
Blocks: F-LOG-003
Data: `exercises`

**Intent** — Not everything is weight × reps. Planks are time, running is
distance + time, pull-ups are reps (optionally weighted). The tracking type
decides which input fields the logger renders, so it has to exist before the
set row is built rather than being bolted on.

**Behaviour**
1. `tracking_type` ∈ `weightReps`, `reps`, `time`, `distanceTime`, `weightTime`.
2. The logger renders only the relevant inputs for the type.
3. Analytics respect the type — volume load is meaningless for `time`, and those
   exercises are excluded from volume rather than counted as zero.
4. Type is editable on custom exercises, and on seeded ones with a warning that
   existing history may become inconsistent.

**Acceptance criteria**
- [ ] Each of the five types renders correct inputs.
- [ ] Analytics exclude, rather than zero out, inapplicable metrics.

**Edge cases** — Changing type on an exercise with history. Weighted pull-ups
(`weightReps` with bodyweight added — see `F-LOG-019`).

---

### F-CAT-003 — Custom exercises
Status: planned | Priority: P0 | Phase: 1
Depends on: F-CAT-002
Screens: Custom Exercise Editor
Data: `exercises`

**Intent** — The single most commonly paywalled feature in competitors, and the
one that makes the app viable for anyone with an unusual machine or a coach's
bespoke movement. Unlimited, free.

**Behaviour**
1. Create with name, primary muscle, optional secondary muscles, equipment,
   tracking type.
2. Edit and archive freely. Delete only when no sets reference it; otherwise
   archive.
3. Custom exercises are indistinguishable from seeded ones in use, marked only
   in the editor.
4. Duplicate-name warning, not a block — "Bench Press (Smith)" is legitimate.

**Acceptance criteria**
- [ ] Created exercise is immediately usable in the picker.
- [ ] Deleting one with history is prevented, with archive offered.
- [ ] Survives export/import round-trip with its UUID intact.

---

### F-CAT-004 — Search
Status: planned | Priority: P0 | Phase: 1
Depends on: F-CAT-001
Screens: Exercise Catalogue, Exercise Picker

**Intent** — With 400 exercises, search *is* the picker. It's used mid-session
with a rest clock running, so it must be instant and forgiving.

**Behaviour**
1. Case- and diacritic-insensitive substring match on name and aliases.
2. Results update per keystroke; no explicit search action.
3. Ordering: exact prefix match, then favourites, then recency, then alphabetical.
4. Tolerates a leading/trailing space and matches across word boundaries
   ("inc bench" → "Incline Bench Press").

**Acceptance criteria**
- [ ] Sub-100 ms on a 400-row catalogue on a low-end device.
- [ ] "rdl" finds Romanian Deadlift via alias (`F-CAT-008`).

**Open questions** — Fuzzy matching for typos? Adds complexity; defer until it
proves annoying in real use.

---

### F-CAT-005 — Filter by muscle and equipment
Status: planned | Priority: P1 | Phase: 1
Depends on: F-CAT-001
Screens: Exercise Catalogue, Exercise Picker

**Behaviour**
1. Filter chips for primary muscle group and equipment type.
2. Filters combine with search and with each other (AND across categories, OR
   within one).
3. Active filters are visible and clearable in one tap.
4. Filter state persists within a session, resets on app restart.

**Acceptance criteria**
- [ ] Filters compose correctly with search text.
- [ ] Result count is shown when filters are active.

---

### F-CAT-006 — Favourites and recency ordering
Status: planned | Priority: P1 | Phase: 2
Depends on: F-CAT-004
Data: `exercises.is_favorite`, derived from `sets`

**Intent** — Almost every session reuses the same 15–25 movements. Making the
picker default to what you actually do turns a search into a single tap.

**Behaviour**
1. Star to favourite; favourites pin to the top.
2. Below favourites, order by most recently performed.
3. Empty search shows favourites and recents rather than an alphabetical wall.

**Acceptance criteria**
- [ ] Opening the picker with no query surfaces the last-used exercises first.

---

### F-CAT-007 — Per-exercise sticky notes
Status: planned | Priority: P1 | Phase: 2
Screens: Exercise Detail, Active Workout
Data: `exercises.notes`

**Intent** — Seat height 4, pin position 7, grip at the second ring. This
information is forgotten between sessions, is a genuine source of inconsistent
training, and no competitor handles it well. It is nearly free to build and
disproportionately useful.

**Behaviour**
1. A free-text note attached to the exercise, distinct from per-session notes
   (`F-LOG-008`).
2. Shown inline in the active workout, collapsed to one line, expandable.
3. Editable from the session without leaving it.
4. Persists across all sessions and routines.

**Acceptance criteria**
- [ ] Note is visible on the active-workout screen without navigation.
- [ ] Editing mid-session doesn't disturb logged sets or the rest timer.

---

### F-CAT-008 — Aliases and synonyms
Status: planned | Priority: P2 | Phase: 2
Depends on: F-CAT-004
Data: `exercises.aliases`

**Behaviour**
1. Seeded exercises carry common aliases and abbreviations (RDL, OHP, BSS).
2. Aliases are searchable but not displayed as the primary name.
3. Users can add aliases to any exercise.

---

### F-CAT-009 — Archive and hide
Status: planned | Priority: P1 | Phase: 2
Data: `exercises.archived_at`

**Intent** — 400 exercises is a lot of noise when you use 20. Archiving prunes
the picker without destroying history.

**Behaviour**
1. Archive hides an exercise from pickers and search by default.
2. History remains fully intact and viewable.
3. An "archived" filter reveals and restores them.
4. Bulk-archive by equipment type, for people without access to a cable machine.

---

### F-CAT-010 — Merge duplicate exercises
Status: idea | Priority: P2 | Phase: —

**Intent** — After an import (`F-DAT-005`) or careless custom creation, the same
movement can exist twice with split history. Merging reassigns all sets from one
to the other and archives the loser.

**Open questions** — Irreversible without a backup; requires a confirmation and
probably an automatic pre-merge backup.

---

### F-CAT-011 — Exercise media
Status: idea | Priority: P3 | Phase: —

Illustrations or short animations per exercise. Deferred on three grounds: app
size, licensing (same problem as `F-CAT-001` but harder for images), and the
fact that experienced users don't need them. If built, ship as an optional
downloadable pack rather than bundled.

---

### F-CAT-012 — Substitution suggestions
Status: idea | Priority: P2 | Phase: —
Depends on: F-CAT-013

Machine occupied, so offer alternatives with the same primary muscle and
available equipment, swappable in one tap mid-session. Needs the muscle taxonomy
and an equipment-availability preference to be useful rather than noisy.

---

### F-CAT-013 — Muscle taxonomy and body map data
Status: planned | Priority: P1 | Phase: 3
Blocks: F-ANA-005, F-ANA-008, F-ANA-014

**Intent** — Sets-per-muscle-per-week and muscle-balance analytics are only as
good as the taxonomy underneath. A fixed enum with defined granularity, decided
once, because changing it later invalidates historical aggregates.

**Behaviour**
1. Fixed enum, as listed in [`../21-DATA-MODEL.md`](../21-DATA-MODEL.md).
2. Each muscle maps to a region on the body-map SVG (`F-ANA-014`).
3. Each maps to a push/pull/legs/core category for balance ratios (`F-ANA-008`).
4. Secondary-muscle involvement counts as 0.5 of a set (`F-ANA-005`).

**Open questions**
- Granularity: is splitting front/side/rear delts right while lumping all quad
  heads together? Defensible, but decide explicitly.
- Is a fixed 0.5 weighting for secondary muscles good enough, or should it vary
  per exercise? Fixed for v1; revisit with real data.

---

### F-CAT-014 — Exercise variants and modifiers
Status: idea | Priority: P3 | Phase: —

Grip width, stance, tempo, bar type as structured modifiers rather than separate
exercises — so "Bench Press (close grip)" shares a progression history with its
parent while remaining distinguishable. Powerful and genuinely complicated;
needs its own design pass before it's more than an idea.
