/// Mass, stored canonically as whole grams.
///
/// Integers, not doubles, because the app adds 2.5 kg to a number hundreds of
/// times across a training block. Floating point would accumulate into values
/// like 102.49999999 and surface in a chart. See docs/22-UNITS.md and
/// docs/70-decisions/ADR-0003-canonical-units.md.
///
/// Pure Dart. Never holds a display unit — kilograms versus pounds is resolved
/// at the presentation edge from a single user preference.
class Mass implements Comparable<Mass> {
  const Mass.grams(this.grams);

  /// Exact international definition. Never approximate it: round-tripping a
  /// value through an approximation loses data.
  static const double gramsPerPound = 453.59237;

  static const Mass zero = Mass.grams(0);

  final int grams;

  factory Mass.kg(num kg) => Mass.grams((kg * 1000).round());

  factory Mass.lb(num lb) => Mass.grams((lb * gramsPerPound).round());

  /// Converts from whichever unit [unit] names. The single entry point used by
  /// the input parser, so there is one place where a display unit becomes
  /// canonical.
  factory Mass.inUnit(num value, MassUnit unit) => switch (unit) {
    MassUnit.kg => Mass.kg(value),
    MassUnit.lb => Mass.lb(value),
  };

  double get inKg => grams / 1000;

  double get inLb => grams / gramsPerPound;

  double toUnit(MassUnit unit) => switch (unit) {
    MassUnit.kg => inKg,
    MassUnit.lb => inLb,
  };

  bool get isZero => grams == 0;

  Mass operator +(Mass other) => Mass.grams(grams + other.grams);

  Mass operator -(Mass other) => Mass.grams(grams - other.grams);

  Mass operator *(num factor) => Mass.grams((grams * factor).round());

  Mass operator -() => Mass.grams(-grams);

  bool operator <(Mass other) => grams < other.grams;

  bool operator <=(Mass other) => grams <= other.grams;

  bool operator >(Mass other) => grams > other.grams;

  bool operator >=(Mass other) => grams >= other.grams;

  @override
  int compareTo(Mass other) => grams.compareTo(other.grams);

  @override
  bool operator ==(Object other) => other is Mass && other.grams == grams;

  @override
  int get hashCode => grams.hashCode;

  /// Debug only. User-facing text comes from the formatter, which is
  /// locale-aware and honours the unit preference.
  @override
  String toString() => 'Mass(${grams}g)';
}

/// Applies to both `loadUnit` (weights on sets, plates, bars) and `bodyUnit`
/// (bodyweight), which are configured independently — lifting in kilograms
/// while weighing in pounds is entirely normal.
enum MassUnit {
  kg('kg'),
  lb('lb');

  const MassUnit(this.symbol);

  final String symbol;
}
