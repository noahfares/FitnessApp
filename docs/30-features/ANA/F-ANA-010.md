# F-ANA-010 — Acute-to-chronic workload ratio

Status: done | Priority: P2 | Phase: 4
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets

## Spec

Ratio of 7-day rolling volume to 28-day rolling volume, as a fatigue and
ramp-rate signal. Well established in sports science for injury risk, though the
evidence base is contested — present it as information, never as a warning, and
say plainly what it is.

## Status note (batch 4.5)

`domain/analytics/acwr.dart`'s `computeAcwr` matches §8's `acwr` fixture,
built on a new `dailyVolume` helper in `weekly_volume.dart` (day
granularity, unlike the weekly charts already there). Shown on the
Insights tab as a plain information tile — no colour coding, no "warning"
language — labelled with the 0.8–1.3 typical range and an explicit "this
is information, not a warning" line (§8 rule 4). Feeds `F-PRG-011`'s
deload suggestion as its second signal.
