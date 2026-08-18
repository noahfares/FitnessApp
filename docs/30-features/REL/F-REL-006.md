# F-REL-006 — Store listing assets

Status: in-progress | Priority: P2 | Phase: 6
Depends on: F-THM-006
Reads: 62-RELEASE, 61-CI-CD

## Spec

Screenshots, feature graphic, short and full descriptions, category, content
rating. Required for both stores. The screenshots need real-looking training
data, which means a seeded demo database — worth building as a test fixture
anyway.

## Status

Copy and graphics done; **screenshots are not**, and cannot be from this
environment.

- `store/LISTING.md` holds the title, short and full descriptions, category,
  content-rating answers and a release-notes template — checked in so the
  listing is reviewable and versioned rather than typed into a web form.
- `store/play-icon-512.png` and `store/play-feature-graphic.png` are generated
  by `tools/gen-icons.sh` (`F-THM-006`).
- Screenshots need a device or emulator. A golden render from `flutter test`
  uses the test font, so every label would come out as placeholder boxes —
  worse than no screenshot. `store/LISTING.md` carries the shot list, in
  listing order, and the demo-data step (`F-DAT`-adjacent dev tooling:
  Settings › Data › Load sample data) that fills the screens with something
  worth photographing.
- The spec's own note that screenshots "need real-looking training data, which
  means a seeded demo database" was already satisfied ahead of time by the
  `DemoDataSeeder` built as dev tooling in v0.44.0.
