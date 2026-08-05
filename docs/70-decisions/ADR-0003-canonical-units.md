# ADR-0003 — Canonical integer-gram storage

**Status:** Accepted · 2026-08

## Context

The app must support metric and imperial units. Mixed-unit data corruption is
insidious: a handful of rows stored in pounds among thousands in kilograms
produces charts that look plausible and are wrong, and the error is usually
discovered years later when the history is irreplaceable.

There is also an arithmetic problem. The app adds 2.5 kg to a number hundreds of
times across a training block. In floating point that accumulates into values
like `102.49999999`, which then round inconsistently and break equality checks.

## Options

**Store the user's unit with a unit column per row.** Straightforward to write.
Cost: every query must convert, every comparison must normalise, and one place
that forgets is a silent corruption. Aggregates across mixed rows are wrong by
default.

**Store canonical kilograms as a double.** One interpretation, simple
conversion. Cost: floating-point drift under repeated increments, and equality
comparisons that need epsilons everywhere.

**Store canonical grams as an integer.** One interpretation, exact arithmetic,
no drift, trivial equality. Cost: conversion at every display boundary, and
value objects needed to keep call sites honest.

## Decision

**Weight in integer grams. Distance in integer metres. Duration in integer
seconds. Length in integer millimetres. Percentages in basis points.**

No unit column anywhere in the schema. Unit preference is display-only
(`F-SET-001`). Domain signatures take value objects (`Mass`, `Length`,
`Distance`), never bare integers, so a unit mix-up is a compile error.

Grams represent every plate increment in use anywhere exactly, including 0.25 kg
micro-plates and 1.25 lb fractional plates. The pound conversion uses the exact
international definition, `453.59237 g`.

## Consequences

- **Changing a unit setting is instant and free.** No migration, no rewrite,
  fully reversible. This is the main payoff.
- Every display path formats; every input path parses. Both are centralised in
  `core/units/` and `core/formatting/`.
- Display rounding must never be written back. `100 kg` shows as `220.5 lb`, and
  storing the round-trip of that display would drift the value on every edit.
- Export uses canonical units with an explicit marker (`F-DAT-001`); CSV uses
  display units with the unit in the column header (`F-DAT-002`).
- Import must establish the source unit with certainty, and **ask rather than
  guess** when it can't (`F-DAT-005`).
- The unit tests in [`../22-UNITS.md`](../22-UNITS.md) — round-trip, exactness,
  no-drift — are mandatory, not optional.

## Reversal cost

**Very high once real training history exists.** Changing the storage
representation means migrating every set, measurement, and target, with no way
to verify correctness against a ground truth that no longer exists.

This is why it's decided in Phase 0, before any data exists.
