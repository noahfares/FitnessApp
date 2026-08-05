# Engineering conventions

How work gets done. Companion documents: [`61-CI-CD.md`](61-CI-CD.md) for
automation, [`62-RELEASE.md`](62-RELEASE.md) for shipping.

## Definition of done

A feature is done when **all** of these hold. Not most.

- [ ] Behaviour matches its entry in [`30-features/`](30-features/), including
      the edge cases listed there.
- [ ] Every acceptance criterion in the entry is verified, not assumed.
- [ ] `Status:` updated to `done` **in the same commit as the code**.
- [ ] Unit tests for any pure logic; widget tests for any non-trivial UI.
- [ ] Checked in **both** light and dark themes.
- [ ] Touch targets ≥ 48 dp; usable at 200% text scale.
- [ ] All user-facing strings externalised (`F-I18N-001`).
- [ ] No new lint warnings; `flutter analyze` clean.
- [ ] Open questions in the entry either resolved (with the entry updated) or
      still listed as open — never silently decided in code.

If an acceptance criterion turns out to be wrong, change the criterion in the
entry and say so. Don't quietly ignore it.

## Invariants

Restated from [`../CLAUDE.md`](../CLAUDE.md) because they are the things most
likely to be violated by accident. Violating one is a bug, not a style choice.

1. **Canonical units only** — grams, metres, seconds. No per-row unit flags.
   ([`22-UNITS.md`](22-UNITS.md))
2. **`lib/domain/` imports nothing from Flutter and nothing from `lib/data/`.**
   Enforced by lint in CI.
3. **Warm-up sets are excluded from every analytic.** Filtered once at the
   engine boundary.
4. **Workouts snapshot their template.** Editing a routine never alters history.
5. **Write-through persistence.** Session state lives in the database, not in
   memory.
6. **No network calls in the core app.**
7. **Nothing is ever hard-deleted.** Every delete sets `deleted_at`; every read
   filters `deleted_at IS NULL`; every write sets `updated_at`.
   ([ADR-0008](70-decisions/ADR-0008-sync-ready-foundations.md))
8. **Every user-meaningful timestamp stores its local UTC offset** beside the
   UTC value. Local calendar dates are derived from the pair, never from UTC.

## Code style

- `dart format` defaults, enforced in CI. No debates.
- `flutter_lints` plus the layer rule. Warnings are errors in CI.
- Files `snake_case`, types `UpperCamelCase`, members `lowerCamelCase`.
- One public type per file, named after the file.
- Prefer explicit types on public APIs; `var` freely inside function bodies.
- Immutable data everywhere: `freezed` for entities, `const` constructors on
  widgets wherever possible.

### Comments

Match the density of the surrounding code. Explain **why**, never **what** —
the code says what. Comments that earn their place here:

- Why a formula is the way it is, with a pointer to
  [`40-ANALYTICS-SPEC.md`](40-ANALYTICS-SPEC.md).
- Why an apparently redundant guard exists (usually a real edge case).
- Platform-specific workarounds, with a link to the issue.

Never leave commented-out code. That is what git is for.

## Testing strategy

| Layer | Type | Bar |
|---|---|---|
| `domain/` | Pure unit | **Near-total coverage, mandatory.** Every analytics function uses its fixture from `40-ANALYTICS-SPEC.md` |
| `core/units/` | Pure unit | Round-trip, exactness, and no-drift tests are non-negotiable |
| `data/db/` | Integration, in-memory Drift | Every migration path; repository mapping both ways |
| `features/application/` | Provider tests with overridden repositories | All core flows |
| `features/presentation/` | Widget tests | `SetRow` and the active-workout screen at minimum — the critical path |
| End to end | `integration_test` | One smoke test: start → log sets → finish → history |

Additional rules:

1. **Every analytics function gets three tests minimum**: the documented fixture,
   an empty input (must return a defined empty result, never throw), and a
   single-element input.
2. **Pure functions take the current date as a parameter.** A function that reads
   the clock produces tests that fail at midnight.
3. **Every migration gets a test** that opens a database at version *n*,
   migrates, and asserts on the *data* — not merely that nothing threw.
4. **Bug fixes start with a failing test.** Always.
5. Coverage is not a target in itself, but a `domain/` function without a test
   does not merit review.

## Git conventions

**Every commit bumps `VERSION` and gets a matching annotated tag.** No
exceptions, no asking. The full protocol is in
[`63-VERSIONING.md`](63-VERSIONING.md); the short version is: decide the bump,
write `VERSION`, commit, `git tag -a vX.Y.Z`, push the branch and the tag.

**Branches:** `claude/<domain>-<short-description>`, e.g.
`claude/log-ghost-values`.

**Commits:** `<type>(<domain>): <F-ID> <summary>`

```
feat(log): F-LOG-004 last-time ghost values in set rows
fix(analytics): F-ANA-003 exclude warm-up sets from session e1RM
docs(features): F-PRG-005 expand RPE autoregulation spec
test(units): F-SET-001 no-drift test for repeated increments
refactor(data): extract set queries into SetDao
chore(ci): cache pub dependencies
```

Types: `feat` `fix` `docs` `test` `refactor` `perf` `chore`.

Commits that implement a feature **must** cite its ID and update its `Status:`.
Commits without an ID are for infrastructure, refactoring, and documentation
only.

**Pull requests:** not required for solo work, but any change touching the
schema, an ADR, or an invariant gets one — as a record of the reasoning, even if
self-merged.

## Reviewing changes

The checklist, in priority order:

1. **Are the numbers right?** Any change touching a metric gets checked against
   its fixture by hand. This is the highest-consequence category of bug in the
   project.
2. **Does it violate an invariant?** Especially units, the domain-layer rule,
   and the `deleted_at` filter — a query that forgets the last one silently
   resurrects deleted data, which looks like a data-integrity bug rather than a
   missing `WHERE` clause.
3. **Does it break the snapshot guarantee?** Anything touching routines or
   workouts.
4. **Does the set row get slower?** Latency there outweighs almost any feature.
5. **Both themes checked?**
6. **Does the feature entry still describe reality?**

## Performance budgets

| Operation | Budget |
|---|---|
| Ghost-value lookup (`F-LOG-004`) | < 50 ms, several years of history — the hottest path in the app |
| Exercise search over 400 rows | < 100 ms on a low-end device |
| Full analytics recomputation, 5 years | < 100 ms |
| Set-row scroll, 12-exercise session | No dropped frames |
| Cold start to usable | < 2 s |

Measured on a genuinely low-end device, not a flagship or an emulator. Gym
phones are old and cold.

## Schema changes

1. Update [`21-DATA-MODEL.md`](21-DATA-MODEL.md) **first**, in the same commit.
2. Add a numbered migration. Never edit a shipped one — fix forward.
3. Commit the Drift schema snapshot so migration tests can build historical
   schemas.
4. Write the migration test.
5. Bump the export schema version (`F-DAT-001`) if the change is user-visible,
   and keep an import path from the previous version.

## Documentation upkeep

The docs are the source of truth, so drift between them and the code is a defect
in the docs.

- New feature → new entry with a new ID, and update the **Allocated** column in
  [`00-INDEX.md`](00-INDEX.md).
- Decision that constrains future work → an ADR in
  [`70-decisions/`](70-decisions/).
- Discovering a feature's spec was wrong → fix the spec, don't just fix the code.

### Cross-reference integrity

Every `Depends on:` and `Blocks:` reference must resolve to a real entry, and
every ID in [`50-ROADMAP.md`](50-ROADMAP.md) must exist in a feature file. To
check:

```bash
# every ID defined by a heading
grep -rhoE '^### (F-[A-Z0-9]+-[0-9]{3})' docs/30-features/ | sed 's/^### //' | sort -u > /tmp/defined
# every ID referenced anywhere
grep -rhoE 'F-[A-Z0-9]+-[0-9]{3}' docs/ | sort -u > /tmp/referenced
# anything referenced but never defined
comm -13 /tmp/defined /tmp/referenced
```

The last command should print nothing. Run it after any planning session.
