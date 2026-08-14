# FitnessApp

An offline-first strength-training tracker for Android (iOS later), built to give
away for free the features that commercial fitness apps put behind a
subscription: unlimited routines and custom exercises, genuine analytics,
automated progression, and complete data export.

No account. No server. No telemetry. Your data stays on your device and you can
take it with you at any time.

## Status

**Phases 0–5 complete.** In **Phase 6** — publish readiness: accessibility,
localisation, onboarding, and store release. The design is documented in full
under [`docs/`](docs/) and is built out phase by phase, in order.

| | |
|---|---|
| Version | `0.67.0` — canonical in [`VERSION`](VERSION); scheme in [versioning](docs/63-VERSIONING.md) |
| Stack | Flutter + Dart ([ADR-0001](docs/70-decisions/ADR-0001-flutter.md)) |
| Platforms | Android first, distributed as an APK via GitHub Releases; iOS and app-store releases planned |
| Data | Local SQLite (Drift), no backend ([ADR-0002](docs/70-decisions/ADR-0002-local-first.md)) |
| Progress | 163 features planned, 115 done — see [`docs/features.tsv`](docs/features.tsv) |
| Next step | Phase 6 — publish |
| Privacy | No account, no telemetry, no network calls — see [`PRIVACY.md`](PRIVACY.md) |
| Licence | TBD |

## Documentation

Start at **[`docs/00-INDEX.md`](docs/00-INDEX.md)** — it maps every document and
tells you which to read for a given task.

Quick links:

- [Vision, scope and non-goals](docs/10-VISION.md)
- [Architecture](docs/20-ARCHITECTURE.md) · [Data model](docs/21-DATA-MODEL.md) · [Units](docs/22-UNITS.md)
- [Feature catalogue](docs/30-features/) — every planned feature, with a stable ID
- [Analytics specification](docs/40-ANALYTICS-SPEC.md)
- [Roadmap](docs/50-ROADMAP.md) — binding, followed in order · [Backlog](docs/51-BACKLOG.md)
- [Engineering conventions](docs/60-ENGINEERING.md) · [Release process](docs/62-RELEASE.md) · [Versioning](docs/63-VERSIONING.md)
- [External inputs](docs/11-EXTERNAL-INPUTS.md) — prior art brought in from outside

## Building

Requires the Flutter SDK (pinned to the version in
[`.github/workflows/ci.yml`](.github/workflows/ci.yml)).

```bash
flutter pub get
flutter test
flutter run
```

Checks that CI runs, and that you can run locally:

```bash
tools/check-docs.sh     # docs integrity: IDs, Reads: targets, version agreement
tools/check-layers.sh   # lib/domain/ imports no Flutter and no data layer
flutter analyze --fatal-infos
dart format --set-exit-if-changed lib test
```

Debug APKs are attached to every CI run as a build artefact, so any commit is
installable without a local toolchain.

## Contributing

This is a personal project, but the planning docs are public and issues are
welcome. If you want to propose a feature, the format is in
[`docs/30-features/README.md`](docs/30-features/README.md).
