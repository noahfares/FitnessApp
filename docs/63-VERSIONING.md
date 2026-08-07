# Versioning

**Every commit bumps the version and gets a matching tag.** This is not a
guideline. A commit without a version bump and a tag is incomplete work.

The operational summary lives in [`../CLAUDE.md`](../CLAUDE.md) so it is loaded
into every session. This document is the full scheme.

## Why this strictly

The project has no server, no crash reporting, and no telemetry
([ADR-0002](70-decisions/ADR-0002-local-first.md)). When something breaks, the
only diagnostic context available is "which version is this?" — reported by a
user reading the About screen (`F-SET-009`).

Tags also become the release trigger: `release.yml` fires on `v*` and builds the
signed APK ([`61-CI-CD.md`](61-CI-CD.md)). No tag, no build, no release.

## Source of truth

`VERSION` at the repository root. One line, no `v` prefix:

```
0.2.0
```

Everything else derives from it:

- The git tag is `v` + the file contents — `v0.2.0`. Exactly, always.
- `pubspec.yaml`'s `version:` field, once Flutter exists.
- The build number in `F-REL-005`.
- The version shown in About (`F-SET-009`).

CI fails if `VERSION`, the tag, and `pubspec.yaml` disagree.

## Scheme

`MAJOR.MINOR.PATCH`, semantic versioning, with a pre-1.0 convention.

### Pre-1.0 (now)

`MAJOR` stays `0` while the database schema is still moving. During this period:

| Change | Bump | Example |
|---|---|---|
| New feature, phase work, schema change, new planning document | **MINOR** | `0.3.0 → 0.4.0` |
| Fix, clarification, refactor, doc edit, test-only change | **PATCH** | `0.3.0 → 0.3.1` |

A breaking schema change does **not** force a major bump pre-1.0 — that's the
point of `0.x`. It does require a tested migration regardless
([`21-DATA-MODEL.md`](21-DATA-MODEL.md)).

### 1.0 and after

`1.0.0` is declared when the schema is stable enough to guarantee a migration
path from every subsequent version. That is a deliberate commitment, not a
milestone celebration. Expected around the end of Phase 5, once export/import
proves the data can survive anything.

After 1.0, standard semver:

| Change | Bump |
|---|---|
| Breaking schema change, or a change requiring user action | **MAJOR** |
| New feature, backward-compatible | **MINOR** |
| Fix, no behaviour change | **PATCH** |

## Procedure

Run on every commit, without asking:

```bash
# 1. Decide the bump, write it
echo "0.4.0" > VERSION

# 2. Stage everything including VERSION
git add -A
git commit -m "feat(log): F-LOG-004 last-time ghost values in set rows"

# 3. Push to main — CI creates the tag (F-REL-012)
git push origin main
```

**Do not create tags locally.** `.github/workflows/tag.yml` reads `VERSION` on
every push and creates `v$VERSION` annotated at that commit. It is the single
authority on tagging, which is what makes "every commit is tagged" a guarantee
rather than something anyone has to remember.

### Rules

1. **CI creates the tag, not you.** Annotated, message derived from the commit
   subject. If the tag is missing after a push, the workflow failed — check it
   rather than tagging by hand.
2. **One commit, one version, one tag.** Never batch commits under a version.
3. **Tags are immutable once pushed.** Never delete, never move. A mistake is
   fixed by a new version, not by rewriting a tag.
4. **Tag messages** are one line summarising user-visible change. For a release,
   a short body listing the feature IDs included.
5. **If the tag doesn't appear after a push, say so.** Don't silently continue
   as though it succeeded, and don't work around it by tagging locally — fix the
   workflow.
6. **Version numbers are never reused or rolled back.** Play rejects a reused
   build number, and a reused tag makes history unreadable.

## Version history

| Version | Contents |
|---|---|
| `0.1.0` | Planning system established — 160 features, 7-phase roadmap, 7 ADRs, analytics spec |
| `0.2.0` | Schema requirements integrated from external handoff; versioning protocol; roadmap made binding |
| `0.3.0` | Docs restructured: one file per feature, `Reads:` lines, batches, tooling, plain-English guide, `F-REL-012` auto-tagging |
| `0.3.1` | Workflow moved to trunk-based: direct commits to `main`, no pull requests |
| `0.18.0` | **Phase 1 complete** — catalogue, session logging, rest timer, history, dashboard, bodyweight capture, JSON dump, signed-APK release automation. Verified on-device from the release APK; "two weeks of real training" exit criterion waived by the project owner. |

Maintained on every minor bump. Patch releases are not listed individually.

## Relationship to phases

Phases ([`50-ROADMAP.md`](50-ROADMAP.md)) and versions are independent axes.
A phase spans many versions. There is no rule that Phase 3 means `0.3.x` — the
version tracks commits, the phase tracks scope.

The one alignment: **completing a phase gets its own minor bump and a tag whose
message lists the exit criteria met.** That's the checkpoint worth being able to
find later.

## A note on how this used to fail

Claude Code sessions in this environment can push branches but not `refs/tags`
(403, with no proxy denial logged — the refusal is in the credential's scope,
not egress policy). That is why tagging moved into CI (`F-REL-012`), which is a
better design regardless: the tag is created by the same system that will build
and sign the release from it.

Verified working as of `v0.3.0`.
