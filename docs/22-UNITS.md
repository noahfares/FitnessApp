# Units

Rationale: [ADR-0003](70-decisions/ADR-0003-canonical-units.md). Schema
consequences: [`21-DATA-MODEL.md`](21-DATA-MODEL.md).

Mixed-unit data corruption is invisible until it is catastrophic — a single row
stored in pounds among thousands in kilograms produces a chart that looks
plausible and is wrong. The defence is structural, not procedural.

## Rules

1. **Storage is canonical and integer.** Mass in grams, length in millimetres,
   distance in metres, duration in seconds, percentages in basis points.
2. **There is no unit column.** Anywhere. A quantity in the database has exactly
   one interpretation.
3. **Conversion happens at the edges only** — the formatter on the way out, the
   parser on the way in. Nothing in between knows what a pound is.
4. **The domain layer never sees a display unit.** All computation is on
   canonical integers.
5. **Value objects, not bare ints, in domain signatures.** `Mass`, not `int`.
   The type system then makes a unit mix-up a compile error rather than a silent
   bug.

## Value objects

Live in `lib/core/units/`. Immutable, `const`-constructible, `Comparable`, with
value equality. Pure Dart — usable from `domain/`.

```dart
class Mass implements Comparable<Mass> {
  final int grams;
  const Mass.grams(this.grams);

  factory Mass.kg(num kg)  => Mass.grams((kg * 1000).round());
  factory Mass.lb(num lb)  => Mass.grams((lb * _gramsPerPound).round());

  double get inKg => grams / 1000;
  double get inLb => grams / _gramsPerPound;

  static const _gramsPerPound = 453.59237;   // exact, by definition

  Mass operator +(Mass o) => Mass.grams(grams + o.grams);
  Mass operator -(Mass o) => Mass.grams(grams - o.grams);
  Mass operator *(num f)  => Mass.grams((grams * f).round());
}
```

Equivalents: `Length` (millimetres), `Distance` (metres), and Dart's built-in
`Duration` for time — no custom type needed there.

`453.59237 g` per pound is the exact international definition. Never approximate
it; round-tripping a value through an approximation loses data.

## The user preference

Three **independent** settings (`F-SET-001`), because real users mix them —
lifting in kilograms while weighing themselves in pounds is common in the UK, and
in the US the reverse happens among lifters who train to international standards.

| Setting | Options | Applies to |
|---|---|---|
| `loadUnit` | `kg` \| `lb` | Weights on sets, targets, plates, bars |
| `bodyUnit` | `kg` \| `lb` | Bodyweight and mass measurements |
| `lengthUnit` | `cm` \| `in` | Circumference measurements |
| `distanceUnit` | `km` \| `mi` | Cardio distance |

Changing any of these is **display-only**. It never triggers a data migration,
never rewrites a row, and is instantly reversible. This is the payoff for
canonical storage.

## Display rules

| Context | kg | lb |
|---|---|---|
| Set weight | 1 decimal, trailing `.0` stripped → `100`, `102.5` | 1 decimal, stripped → `225`, `227.5` |
| Bodyweight | 1 decimal | 1 decimal |
| Volume totals | 0 decimals, thousands separated → `12,480 kg` | 0 decimals |
| Estimated 1RM | 1 decimal | 1 decimal |
| Circumference | 1 decimal cm | 2 decimals in (`14.25"`) |
| Distance | 2 decimals km | 2 decimals mi |

Unit suffixes are shown on totals, summaries, and charts, and *omitted* inside
set-row inputs where the column header already carries the unit. Screen space in
the set row is the scarcest resource in the app.

Formatting is locale-aware via `intl` (`F-I18N-002`) — decimal separators and
thousands separators follow the device locale, not a hardcoded assumption.

## Rounding and the lying-display trap

Converted values are inherently imprecise: 100 kg is 220.462 lb. Displaying
`220.5 lb` is right; storing the round-trip of that display is wrong, because
`220.5 lb → 100.02 kg` and the value drifts every time it's edited.

Therefore:

1. **Display rounding never writes back.** The stored gram value is authoritative
   and untouched by rendering.
2. **Editing writes what the user typed**, parsed once from their display unit.
   If they type `225` in pound mode, that stores `102058 g` exactly.
3. **Increments respect the display unit.** Stepping up in kilogram mode adds
   2.5 kg; in pound mode it adds 5 lb. The step is defined in the display unit,
   converted once, and applied to the canonical value (`F-SET-007`).
4. **Plate solving happens in canonical grams** against the real plate inventory
   (`F-PLT-001`), so a "225 lb" target on a kilogram-plate gym correctly resolves
   to the nearest achievable load rather than an impossible number.

## Import and export

- **Export** (`F-DAT-001`) writes canonical integers, plus an explicit
  `"units": "canonical-v1"` marker naming grams/metres/seconds. Never export in
  the user's display unit; a JSON file that means different things depending on
  a setting is a data-loss bug waiting to happen.
- **CSV export** (`F-DAT-002`) is for humans and spreadsheets, so it *does* use
  the display unit — with the unit in the column header (`weight_kg`) and a note
  that CSV is lossy and not the backup format.
- **Import** (`F-DAT-005`, `F-DAT-006`) must determine the source unit
  explicitly. Strong and Hevy exports include a unit column or a header hint;
  if it cannot be determined with certainty, **ask the user** rather than guess.
  A silently mis-imported history is worse than a failed import.

## Testing requirements

Non-negotiable, in `test/core/units/`:

- Round-trip: `Mass.lb(x).inLb == x` within display precision for the full
  plausible range (0–1000 lb).
- Exactness: `Mass.kg(100).grams == 100000`, `Mass.lb(45).grams == 20412`.
  (45 × 453.59237 = 20411.657, which rounds to 20412. An earlier draft of this
  document said 20411 — that was the *truncated* value, and truncation would
  bias every imperial conversion downward. Conversions round to the nearest
  gram.)
- No drift: applying `+2.5 kg` 200 times gives exactly `500 kg` more.
- Formatter output for every row of the display table above, in both units and
  in at least two locales (`en_US`, `de_DE` — comma decimal separator).
- Parser rejects malformed input and accepts both `,` and `.` decimal separators
  per locale.
