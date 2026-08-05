# FitnessApp

An offline-first strength-training tracker for Android (iOS later), built to give
away for free the features that commercial fitness apps put behind a
subscription: unlimited routines and custom exercises, genuine analytics,
automated progression, and complete data export.

No account. No server. No telemetry. Your data stays on your device and you can
take it with you at any time.

## Status

**Planning — v0.2.0.** No application code yet. The design is documented in full
under [`docs/`](docs/) and is being built out incrementally, phase by phase.

| | |
|---|---|
| Version | `0.2.0` — see [`VERSION`](VERSION) and [versioning](docs/63-VERSIONING.md) |
| Stack | Flutter + Dart ([ADR-0001](docs/70-decisions/ADR-0001-flutter.md)) |
| Platforms | Android first, distributed as an APK via GitHub Releases; iOS and app-store releases planned |
| Data | Local SQLite (Drift), no backend ([ADR-0002](docs/70-decisions/ADR-0002-local-first.md)) |
| Next step | Phase 0 in the [roadmap](docs/50-ROADMAP.md) |
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

Nothing to build yet. Once Phase 0 lands:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

## Contributing

This is a personal project, but the planning docs are public and issues are
welcome. If you want to propose a feature, the format is in
[`docs/30-features/README.md`](docs/30-features/README.md).
