# ADR-0001 — Flutter + Dart

**Status:** Accepted · 2026-08

## Context

A strength-training app that must run on Android now, distributed as an APK from
GitHub, and reach both Google Play and the App Store eventually. Chart-heavy,
data-heavy, offline-only, built and maintained by one person. iOS is a confirmed
goal with no timeline, which rules out anything that makes the port a rewrite.

## Options

**Flutter + Dart.** One codebase for both platforms. `fl_chart` is the strongest
charting option across the candidates. Material 3 gives light/dark and dynamic
colour essentially for free. Drift provides typed SQLite with real migrations.
APK builds run in GitHub Actions with no third-party service. Cost: learning
Dart if unfamiliar; UI is drawn rather than native, which purists dislike.

**React Native + Expo.** Strongest if the author already writes
TypeScript/React. Huge ecosystem, OTA updates, Expo handles builds. Cost:
charting is materially weaker (Victory Native, react-native-svg); the SQLite
story is more fragmented; and cloud builds add a dependency on Expo's service
for the thing that most needs to be self-contained.

**Kotlin + Compose Multiplatform.** Best native Android feel, most direct APK
path, Room and SQLDelight are excellent. Cost: iOS support is the least mature of
the three, and realistically some UI gets written twice — which is most of what
cross-platform was supposed to avoid.

**Native Android only (Kotlin).** Fastest route to an excellent Android app, zero
compromise. Cost: iOS becomes a full rewrite, which in practice means it never
happens.

## Decision

**Flutter + Dart.**

The deciding factors, in order:

1. **Charting.** Analytics are a headline feature, not a garnish. `fl_chart`
   renders in-widget, so it themes correctly in light and dark without bespoke
   work — which matters given how many charts are planned.
2. **One codebase, genuinely.** The iOS goal is real. Flutter is the only option
   here where "port later" doesn't quietly mean "rewrite later".
3. **Persistence.** Drift's typed queries, generated migrations, and streaming
   results directly enable the reactive data flow in
   [`../20-ARCHITECTURE.md`](../20-ARCHITECTURE.md).
4. **Self-contained builds.** GitHub Actions builds an APK with no external build
   service in the loop.
5. **Solo maintainability.** One language, one toolchain, one test runner.

## Consequences

- Dart must be learned if unfamiliar. It's a small, conventional language; this
  is days, not months.
- UI is Material on both platforms. Matching Cupertino idioms on iOS is
  explicitly not a goal — consistency and maintainability win.
- Any platform-specific capability (notifications, Health Connect, widgets) needs
  a plugin or a platform channel, and must sit behind an interface in
  `data/platform/`.
- Build-runner code generation is part of the workflow.
- APK size is larger than a native equivalent. Irrelevant here.

## Reversal cost

Low through Phase 0. **High after Phase 2** — by then the data layer, state
management, and the entire UI are Flutter-specific. The pure `domain/` layer
would survive a port in spirit but not in code.

Say something now if this is wrong.
