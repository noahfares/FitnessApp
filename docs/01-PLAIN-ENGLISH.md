# Plain English

The rest of these documents use a lot of jargon. This one explains it. Read it
once end to end — it's written to be read that way — then come back to it
whenever a term stops making sense.

For weightlifting terms (e1RM, hard set, RPE), see
[`80-GLOSSARY.md`](80-GLOSSARY.md) instead. This file is about the *software*
vocabulary.

If a term you hit isn't here, that's a gap worth fixing — say so and it gets
added.

---

## 1. How this project is organised

**Planning-first.** Most side projects start by writing code and figure out the
design as they go. This one writes the design down first, in `docs/`, and treats
the code as a consequence of it. The reason is specific: a lifting app's value
is years of accumulated training data, and design mistakes that reach real data
are extremely expensive to undo. Thinking is cheap right now; migrating a year
of your own training history is not.

**The numbered files.** `docs/` filenames start with numbers to fix their order
and grouping — `10-VISION`, `20-ARCHITECTURE`, `21-DATA-MODEL`. The tens digit
is the category (10s = why, 20s = how it's built, 30s = what to build, 40s =
the maths, 50s = when, 60s = process). Nothing clever; it just means the list
sorts into a sensible reading order instead of alphabetically.

**Feature ID.** Every planned feature has a permanent code like `F-LOG-004` —
`F` for feature, `LOG` for the logging area, `004` for the fourth one. It never
changes and is never reused, even if the feature is dropped.

Why bother: it gives everything one unambiguous name. Instead of "the thing that
shows last session's numbers" — which I might interpret three different ways
across three conversations — you say `F-LOG-004`. The roadmap schedules IDs,
commits reference IDs, and one file holds the full spec for each. You can say
*"build F-LOG-004"* and there is exactly one correct interpretation.

**Phase.** A numbered chunk of work with a defined finish line. Phase 1 is "an
app you can actually log a workout in". Phases are done strictly in order,
because later ones genuinely depend on earlier ones — you can't build analytics
before there's data to analyse.

**Exit criteria.** The checklist that has to be true before a phase counts as
finished. This exists to stop the very common failure of a project being "nearly
done" with five phases simultaneously 80% complete and nothing usable.

**Binding roadmap.** [`50-ROADMAP.md`](50-ROADMAP.md) is followed in order and
not quietly rearranged. I can add small things inside the current phase, but
moving work between phases or declaring a phase finished early needs your
say-so. It's there so the project can't drift without you noticing.

---

## 2. Git and version control

**Git** tracks every change to every file over time, so nothing is ever really
lost and you can always see what changed and when.

**Repository (repo).** The project folder plus its entire history.

**Commit.** One saved snapshot, with a message describing what changed. Think of
it as a save point. History is a chain of commits.

**Branch.** A parallel line of work. Ours is
`claude/fitness-app-planning-a9bb61`. You work on a branch so the main line
stays stable; when the work is good, it gets merged in.

**`main`.** By convention, the primary branch — the "official" state.

**Merge.** Combining one branch's changes into another.

**Remote / `origin`.** The copy on GitHub. `origin` is its standard nickname.
Your computer has one copy, GitHub has another, and they sync deliberately.

**Push / fetch / pull.** Push sends your commits to GitHub. Fetch downloads
what's on GitHub without changing your files. Pull is fetch plus merge.

**Diff.** The line-by-line difference between two versions. When I say "readable
diffs" I mean it's easy to see exactly what changed — which is why splitting one
476-line file into small ones matters.

**Tag.** A permanent label on a specific commit, usually a version number like
`v0.3.0`. Unlike a branch, a tag never moves. It's a bookmark meaning "this
exact state was version 0.3.0".

**Semantic versioning** — the `MAJOR.MINOR.PATCH` scheme, e.g. `0.3.0`:

- **PATCH** (`0.3.0 → 0.3.1`) — a fix, nothing new.
- **MINOR** (`0.3.0 → 0.4.0`) — something new added, old things still work.
- **MAJOR** (`0.3.0 → 1.0.0`) — something changed in a way that breaks
  compatibility.

While `MAJOR` is `0`, the project is openly unstable and allowed to change
shape. Reaching `1.0.0` is a promise that from then on, upgrading won't destroy
anyone's data. Full scheme: [`63-VERSIONING.md`](63-VERSIONING.md).

**CI (Continuous Integration).** A robot that runs checks automatically on every
push — tests, formatting, build. It catches mistakes without anyone remembering
to look. Ours will live in `.github/workflows/`.

**Workflow.** One CI job definition. `tag.yml` creates the version tag on every
push, so tagging can't be forgotten.

---

## 3. Planning vocabulary

**Spec (specification).** A precise description of what something should do,
written before building it. Ours are the feature files. A good spec is testable:
you can look at the finished thing and say definitively whether it matches.

**Acceptance criteria.** The checklist inside a spec that decides "is this
done?" Written as things you can actually verify, not vibes. "Ghost values
appear correctly on the second session of an exercise" — you can check that.
"Feels fast" — you can't.

**ADR (Architecture Decision Record).** A short document recording a significant
decision: what we were choosing between, what we picked, why, and what it would
cost to change our mind. Ours are in [`70-decisions/`](70-decisions/).

Why they're worth writing: in four months, neither of us will remember why the
app stores weights in grams. Without a record, we'd re-argue it, or worse,
"helpfully" change it and break everything downstream. An ADR turns "why is it
like this?" from an hour of archaeology into a two-minute read.

**Reversal cost.** How expensive it would be to undo a decision. Some are free
to change (which chart library). Some are catastrophic after real data exists
(how weights are stored). We decide the expensive ones first, deliberately.

**Invariant.** A rule that must *always* hold. Breaking one is a bug, not a
style preference. Example: "warm-up sets never count toward volume". They're
listed in `CLAUDE.md` because they're the things most easily broken by accident.

**Scope creep.** A project quietly growing beyond its plan — building the thing
next to the thing you meant to build, repeatedly, until nothing is finished.
The roadmap and the ID system exist largely to make it visible when it starts.

**Backlog.** Ideas that are written down and given IDs but not scheduled. Not
rejected — parked. [`51-BACKLOG.md`](51-BACKLOG.md).

**MVP (Minimum Viable Product).** The smallest version that's genuinely useful.
Ours is Phase 1: log a workout on your phone, nothing more.

**P0 / P1 / P2 / P3.** Priority. P0 = the app is pointless without it. P1 =
expected of a serious tracker. P2 = valuable, not urgent. P3 = speculative.

**Non-goal.** Something we've explicitly decided *not* to do, with the reason
recorded. Nutrition tracking is a non-goal. Writing them down stops the same
"should we also…" conversation recurring forever.

**Dogfooding.** Using your own product for real. Hence the instruction to stop
after Phase 1 and actually train with it for two weeks — real use will tell us
which of the 162 planned features actually matter.

---

## 4. Data vocabulary

**Database.** Structured storage on the phone. Ours is SQLite, a small database
that lives in a single file with no server.

**Table / row / column.** A table is like a spreadsheet tab — `sets` is a table.
Each row is one record (one set you performed). Each column is one field
(weight, reps, when you finished it).

**Schema.** The full definition of tables and columns — the shape of the data.
[`21-DATA-MODEL.md`](21-DATA-MODEL.md) is the schema.

**Primary key.** The column uniquely identifying each row. No two rows share one.

**UUID.** A long random identifier like `f47ac10b-58cc-...`, unique without any
coordination. We use UUIDs as primary keys instead of counting 1, 2, 3 — which
means an ID can be generated instantly on the phone before anything is saved, so
the screen can update the moment you tap rather than waiting on the database.

**Foreign key.** A column pointing at a row in another table. A set points at
the workout exercise it belongs to. That's how rows relate.

**Index.** A lookup structure that makes certain queries fast, like the index at
the back of a book. Without one, finding "the last time I benched" means reading
every set ever recorded.

**Query.** A request for data. "All sets for this exercise, most recent first."

**Migration.** A script that upgrades an existing database from one schema
version to the next without losing data. Once the app is on your phone with real
history, you can't just change the schema — you have to move the existing data
across carefully. This is why so much attention goes into the schema *now*.

**Nullable.** A column allowed to be empty. Reps is nullable because a plank has
a duration and no reps.

**Soft delete / tombstone.** Instead of removing a row, we mark it deleted with
a timestamp and filter it out of queries. The data is still there. This makes
undo trivial and means a mis-tap mid-workout can never destroy anything.

**Canonical units.** Storing every measurement one fixed way — weights always in
grams, distances always in metres — and converting only when displaying. So
kg-vs-lb is purely a display setting: switching it changes nothing in storage
and is instantly reversible. Without this, you eventually get some rows in
pounds and some in kilograms, every total is wrong, and there's no way to tell
which is which. See [`22-UNITS.md`](22-UNITS.md).

**Snapshot.** Copying data at a moment in time rather than linking to something
that can change later. When you start a workout from a routine, it *copies* the
exercise list. Otherwise, editing your routine next month would silently rewrite
what last month's workout claims you did.

**Write-through.** Saving to the database immediately on every change, rather
than holding it in memory and saving at the end. Means the app can be killed
mid-workout and lose nothing.

**Seed data.** Starting content shipped with the app — the initial exercise
catalogue, so it isn't empty on first launch.

**Export / import.** Getting your data out to a file, and back in. Ours is a
core feature rather than an afterthought: it's what makes "your data is yours"
true rather than a slogan.

---

## 5. How the code is organised

**Layer.** A tier of the codebase with one job, only talking to specific other
tiers. Ours: `domain` (the maths), `data` (storage), `features` (screens).

**Domain layer.** Where all the calculations live — estimated 1RM, volume,
progression targets. Deliberately isolated from anything to do with screens or
databases, which makes every calculation testable in isolation. This is the most
important structural rule in the project: a wrong number in a chart is worse
than a missing chart, because you'd act on it.

**Pure function.** Code that takes inputs, returns an output, and does nothing
else — no saving, no screen changes, no reading the clock. Same inputs always
give the same result, so it's completely testable. All our maths is pure.

**Repository.** The code layer between screens and the database. Screens ask the
repository for data and never touch the database directly, so storage can change
without rewriting every screen.

**State management.** How the app tracks what's currently happening — which
workout is in progress, what's typed in a field — and keeps the screen in sync.
Ours is Riverpod.

**Reactive / stream.** Data that pushes updates automatically. The screen
subscribes to "the current workout" and redraws itself whenever that changes,
instead of anyone remembering to refresh it.

**Dependency / package / library.** Code written by someone else that we use
rather than rebuild — the charting library, the database library. Each one is a
long-term commitment, which is why adding one is a considered decision.

**Lint.** An automated style and correctness checker. We use it to *enforce*
the domain-layer rule mechanically, rather than trusting anyone to remember it.

**Refactor.** Restructuring code without changing what it does. What we just did
to the docs was a refactor.

---

## 6. Testing vocabulary

**Unit test.** Automated check of one small piece in isolation. "Given 100 kg
for 8 reps, does the e1RM function return 126.667?"

**Widget test.** A test of one piece of interface.

**Integration test.** A test of a whole flow end to end — start a workout, log
sets, finish, confirm it appears in history.

**Fixture.** A worked example with known-correct inputs and outputs, used as a
test case. [`40-ANALYTICS-SPEC.md`](40-ANALYTICS-SPEC.md) has one for every
formula: the numbers are worked out by hand in the document first, then the test
asserts the code produces the same. That way the spec and the test can't drift
apart, and a wrong formula is a failing test rather than a chart nobody checks.

**Coverage.** What percentage of the code is exercised by tests. A useful signal,
a terrible target — chasing a number produces tests written to satisfy the
number.

**Regression.** Something that used to work and now doesn't. Tests exist mainly
to make regressions loud instead of silent.

---

## 7. Shipping vocabulary

**APK.** The Android app file. You can install one directly, which is how you'll
get the app before it's on any store.

**Sideloading.** Installing an APK directly rather than through an app store.

**AAB (Android App Bundle).** The format Google Play requires instead of an APK.

**Signing key / keystore.** A cryptographic key that proves an app update came
from the same author as the original. **Android will refuse to update an app
if the new version is signed with a different key** — the only fix is
uninstalling, which deletes all the app's data.

This is why [ADR-0007](70-decisions/ADR-0007-signing.md) exists and why it's
flagged as the one genuinely irreversible decision. Get it wrong and everyone
who installed the APK from GitHub is stranded on that version forever, losing
their training history if they move to the Play Store version.

**Play App Signing.** Google's system where they hold the final signing key and
you hold an "upload key". The detail that matters: at enrolment you can either
let Google generate a new key or adopt yours. Only the second keeps sideloaded
installs upgradeable.

**Staged rollout.** Releasing to a small percentage of users first, so a bad
release can be halted before it reaches everyone.

**Release notes.** The summary of what changed in a version.

**Telemetry / analytics (the software kind).** Data an app sends back to its
developer about usage. We collect **none** — no account, no tracking, no network
calls at all. It's an ethical position and also makes the app-store privacy
declarations honest by default. Confusingly, "analytics" in this project almost
always means *your training charts*, not this.

---

## 8. Terms specific to this project

**Ghost values** (`F-LOG-004`) — last session's numbers shown greyed out in each
set row, so you can see what to beat without looking anything up.

**Sticky note** (`F-CAT-007`) — a note attached to an exercise that persists
across every session. Seat height, pin position.

**Progression rule** (`F-PRG-001`) — a rule attached to an exercise that decides
next session's target weight and reps automatically.

**Tracking type** (`F-CAT-002`) — what an exercise measures. Bench press is
weight × reps; a plank is time; running is distance and time. Determines which
input boxes appear.

**Reads:** — a line at the top of every feature file listing exactly which
documents are needed to build it. It exists so a build session opens three
files instead of twelve, which directly reduces cost.

**Batch** — a group of features that share context and get built in one session,
so the background reading is done once instead of five times.

**`features.tsv`** — a single generated file listing all 163 features with their
status and phase. The fastest way to see the whole project state.

**Phase 0** — the setup phase. A running app with no features: project
structure, theming, database, and CI. Boring, and everything else stands on it.
