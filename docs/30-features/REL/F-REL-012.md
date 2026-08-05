# F-REL-012 — Auto-tag from VERSION

Status: done | Priority: P0 | Phase: 0
Blocks: F-REL-003
Reads: 63-VERSIONING, 61-CI-CD

## Spec

1. On every push to any branch, read `VERSION` at the repository root.
2. If no tag `v$VERSION` exists, create an annotated tag at that commit whose
   message is the commit's subject line.
3. If the tag already exists and points at the same commit, do nothing.
4. If the tag exists and points at a **different** commit, **fail the run
   loudly**. Never move or delete a published tag
   ([`../../63-VERSIONING.md`](../../63-VERSIONING.md)) — a version that
   silently changed meaning is worse than a missing one.
5. Uses the Actions `GITHUB_TOKEN`; requires `contents: write` permission.
6. Once code exists, tag creation triggers `release.yml` (`F-REL-002`,
   `F-REL-003`).

## Acceptance

- [x] Pushing a commit with a bumped `VERSION` creates the matching tag without
      any manual step. **Verified: `v0.3.0` created by CI on push of `f18c2ae`.**
- [x] Pushing a commit with an unchanged `VERSION` is a no-op, not an error.
- [ ] Reusing a version number for a different commit fails the run. *Not yet
      exercised — no version has been reused.*
- [x] Works from any environment, including sessions whose credentials cannot
      push tags directly. **This was the motivating case.**

## Edge cases

Force-push rewriting history under an existing tag (the mismatch check catches
it). Two commits pushed together where only the later bumps `VERSION` — the tag
lands on the pushed head, which is correct. A malformed `VERSION` file (fail,
don't guess).

## Open questions

Should it also create a GitHub Release, or leave that to `release.yml` once
there is an artefact to attach? Currently: tag only. A release with nothing in
it is noise.

---

## Why

The versioning protocol says every commit gets a tag
([`../../63-VERSIONING.md`](../../63-VERSIONING.md)), but that only holds if
tagging actually happens every time. Relying on whoever is committing to
remember — human or agent — makes it a discipline rather than a guarantee.

There is also a concrete failure this fixes. Claude Code sessions in this
environment can push branches but **not** tags: `refs/tags/*` returns 403 while
branch pushes to the same URL succeed, and the agent proxy logs no denial, so
the refusal is in the credential's scope rather than egress policy. Moving tag
creation into CI makes the limitation irrelevant instead of requiring a manual
`git push --tags` after every session.

Doing it in CI is also simply more correct: the tag is created by the same
system that will build and sign the release from it, using the commit that was
actually pushed.
