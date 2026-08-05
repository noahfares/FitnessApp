# External inputs

Prior-art and handoff documents brought into the project from outside, what was
adopted from each, and what was deliberately not.

Recording this matters because a future session will otherwise re-litigate
decisions that were already made, or silently follow advice that has since been
superseded.

---

## `liftingappschemarequirements.md` — schema & data capture handoff

**Received:** 2026-08, v0.2.0. Written for an earlier plan of the same app.

A short document on schema decisions that are "cheap to make now and expensive
or impossible to retrofit after real training data exists". Its core argument —
that unrecoverable data capture beats feature completeness in v1 — is correct
and now shapes Phase 0 and Phase 1.

### Superseded by decisions already taken

The document assumes **React Native (Expo) + `expo-sqlite` + Drizzle ORM**. That
stack was subsequently evaluated and not chosen; see
[ADR-0001](70-decisions/ADR-0001-flutter.md). The project is Flutter + Drift.

The stack difference changes almost nothing about the document's substance —
its schema arguments are ORM-agnostic. Read every mention of Drizzle as Drift,
and `expo-sqlite` as `drift`/SQLite.

### Adopted in full

Documented in [ADR-0008](70-decisions/ADR-0008-sync-ready-foundations.md) and
[`21-DATA-MODEL.md`](21-DATA-MODEL.md).

| Recommendation | Where it landed |
|---|---|
| UUID primary keys, not autoincrement | Schema v1 — replaced the integer PKs originally planned |
| `created_at` / `updated_at` UTC on every row | Schema v1, all tables |
| `deleted_at` soft deletes, never hard-delete | Schema v1 — **overrode** the mixed hard/soft deletion policy originally written |
| `user_id` on every table, constant `'local-user'` | Schema v1, all tables |
| Local timezone offset stored beside each UTC timestamp | Schema v1 — **this was missing entirely** and is genuinely unrecoverable |
| `set_type` value `backoff` | Added to the enum, which had five values and now has six |
| `external_id` on exercises for seed re-sync | Added — distinct from, and complementary to, the row UUID (`F-CAT-001`) |
| Free-text notes on **sets**, not only workouts | New feature `F-LOG-023` — workout and per-exercise notes existed, per-set did not |
| Bodyweight log is unrecoverable, so capture early | `F-BOD-001` moved from Phase 4 to **Phase 1** |
| JSON dump as insurance against schema mistakes | New feature `F-DAT-011`, **Phase 1** — a minimal debug dump, distinct from the full export (`F-DAT-001`, Phase 5) |
| Free Exercise DB as a candidate seed source | Recorded as a concrete lead in `F-CAT-001`'s open question, with its licence still to be verified |

### Already covered, no change needed

Nullable `weight`/`reps`/`duration`/`distance` driven by a per-exercise logging
type (`F-CAT-002`, called `tracking_type` here, with five values rather than
four); explicit `position` ordering (`order_index`); nullable superset
`group_id` (`superset_group`); sets referencing exercises by stable ID; row per
set rather than a JSON blob; RPE/RIR nullable per set (`F-LOG-014`);
`completed_at` per set (`F-TIM-007` derives rest from it); migrations configured
from the first commit.

### Adopted with a deliberate difference

**Canonical units.** The document says store weight in kilograms in a single
column. This project goes further and stores **integer grams**
([ADR-0003](70-decisions/ADR-0003-canonical-units.md)). Same principle, stricter
execution: a kilogram double drifts under repeated `+2.5` increments, which is
exactly the operation this app performs hundreds of times per training block.

### Not adopted, with reasons

The document's §5 "explicitly out of scope for v1" list is mostly followed —
no auth, no server, no sync layer, no abstraction over SQLite. Two exceptions:

| Their position | Ours | Why |
|---|---|---|
| Skip localization | Keep `F-I18N-002` in Phase 0 | Not localization — decimal-separator *parsing*. A user typing `102,5` must work. That's an input-correctness bug, not polish. Actual translations (`F-I18N-003`) are indeed unscheduled |
| Skip UI unit tests | Partially agree | Widget tests are limited to `SetRow` and the active-workout screen — the critical path. Everything else defers. Domain-layer tests remain mandatory and are not "UI tests" |

Their §6 v1 slice — seeded catalogue, start workout, log sets, rest timer,
previous-performance display, history list — maps almost exactly onto Phase 1
in [`50-ROADMAP.md`](50-ROADMAP.md), which is a useful independent confirmation
that the phase boundary is drawn in the right place.

Their defer list (charts, PR tracking, templates, plate calculator, body
measurements beyond bodyweight) matches Phases 2–4 here, with one deliberate
exception: bodyweight itself moved *earlier*, on their own unrecoverability
argument.

---

## Adding to this document

When a planning input arrives from outside — a handoff doc, a competitor
teardown, an article that changes an approach — record it here with: what it
said, what was adopted, what was rejected and why, and which decisions it
supersedes or is superseded by. Then update the affected documents in the same
commit.
