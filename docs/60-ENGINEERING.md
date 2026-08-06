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

**Canonical list: [`../CLAUDE.md`](../CLAUDE.md#invariants).** It is auto-loaded
every session, so it is the one place that cannot go unread. Not restated here —
a rule written in four places drifts in three of them.

Violating one is a bug, not a style choice.

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
6. **Widget tests build on `test/support/harness.dart`** — `pumpScreen` for a
   single screen, `pumpApp` when navigation is the subject. It pins the two
   defaults that otherwise cost a debugging round trip every time: the test
   locale is `en_US`, which makes units imperial on first run, and
   `clockTickProvider` ticks once a second, which means `pumpAndSettle` never
   settles. A test that is *about* either overrides it back explicitly.
7. Run it with **`tools/test.sh`** — failures only, one line when green.

## Git conventions

**Every commit bumps `VERSION`.** No exceptions, no asking. Tagging is then
automatic — `.github/workflows/tag.yml` creates `v$VERSION` on push
(`F-REL-012`), so don't create tags by hand. Full protocol:
[`63-VERSIONING.md`](63-VERSIONING.md).

**Branches: none.** Work goes straight onto `main`. This is a solo project with
no reviewer, so a branch exists only to be merged by the person who wrote it.

Reconsider once `F-REL-001` gives CI a real test suite: a pull request would then
run tests *before* the code lands, keeping `main` always-green, which is a
genuine benefit rather than ceremony. Until there are tests to run, a PR gates
nothing.

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

**Pull requests: not used.** The reasoning behind a change belongs in an ADR
([`70-decisions/`](70-decisions/)) and its commit message — both versioned, both
in the repo, both read by future sessions. A PR description is a third copy that
goes stale.

With no PR, **the commit message is the whole record.** Write it accordingly:
what changed, why, and what was deliberately not done.

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

- New feature → `tools/new-feature.sh <DOMAIN> "<title>"`, which allocates the
  ID and regenerates the index. `features.tsv` and `30-features/INDEX.md` are
  generated — never hand-edit them.
- Built a feature and needed a document its `Reads:` line didn't list? Add it.
  That line is what keeps future sessions cheap.
- Decision that constrains future work → an ADR in
  [`70-decisions/`](70-decisions/).
- Discovering a feature's spec was wrong → fix the spec, don't just fix the code.

### Cross-reference integrity

```bash
tools/check-docs.sh
```

Verifies feature files are well formed, no ID is referenced without being
defined, every `Reads:` target resolves, `features.tsv` and `INDEX.md` are
current, every roadmap ID exists, counts reconcile, and `VERSION` agrees with
`pubspec.yaml`.

Run it after any planning session and before any commit that touches `docs/`.
