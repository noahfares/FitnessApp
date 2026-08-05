# F-CAT-001 — Seeded exercise catalogue

Status: planned | Priority: P0 | Phase: 1
Blocks: F-CAT-002, F-LOG-002
Reads: 21-DATA-MODEL#exercises, 21-DATA-MODEL#seed-data, 10-VISION#risks
Data: `exercises`

## Spec
1. Catalogue ships as `assets/seed/exercises.json`, versioned, each record with
   a stable UUID, the source dataset's `external_id`, name, primary muscle,
   secondary muscles, equipment, and tracking type.
2. Seeded into `exercises` on first launch.
3. On app upgrade, re-seeding matches on `external_id` — adding new records and
   updating unmodified seeded ones. It never overwrites user-edited or custom
   rows. Matching on `external_id` rather than name is what makes upstream
   corrections possible without duplicating rows or breaking references from
   existing sets.
4. `assets/seed/SOURCES.md` records provenance and licence for every record.

## Acceptance
- [ ] First launch yields a populated, searchable catalogue with no network access.
- [ ] Every record has a primary muscle and a tracking type — no nulls.
- [ ] Editing a seeded exercise, then upgrading, preserves the user's edit.
- [ ] An upstream rename applied via `external_id` updates the row without
      creating a duplicate or orphaning historical sets.
- [ ] `SOURCES.md` accounts for every record with a verified licence.

## Edge cases

Seeding interrupted mid-write (wrap in a transaction). A seeded
exercise removed in a later version but referenced by existing sets — archive,
never delete.

## Open questions
- Source: a permissively licensed public dataset, or hand-authored? Requires
  reading actual licence text, not a README summary. **Blocking before any
  public release.**
  - **Lead:** Free Exercise DB is the concrete candidate carried over from the
    external schema handoff ([`../11-EXTERNAL-INPUTS.md`](../../11-EXTERNAL-INPUTS.md)).
    Licence still to be verified against the repository's actual licence file,
    not its README. Note that its images, if any, may carry different terms from
    its data — check both separately.
- How is "user-modified" tracked — a boolean flag or comparing `updated_at`
  against the seed timestamp?

---

## Why

The app is unusable on first launch without a decent set of
exercises. 200–400 covers essentially all barbell, dumbbell, machine, cable and
bodyweight work an ordinary lifter does. This is also the single largest legal
risk in the project: scraping a competitor's database is a non-starter and would
be fatal to a store release.
