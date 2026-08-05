/// Body-measurement length, stored canonically as whole millimetres.
///
/// Used for circumference measurements (F-BOD-002). Distances travelled use
/// [Distance] instead — different magnitude, different display rules.
///
/// Pure Dart. See docs/22-UNITS.md.
class Length implements Comparable<Length> {
  const Length.millimetres(this.millimetres);

  /// Exact international definition.
  static const double millimetresPerInch = 25.4;

  static const Length zero = Length.millimetres(0);

  final int millimetres;

  factory Length.cm(num cm) => Length.millimetres((cm * 10).round());

  factory Length.inches(num inches) =>
      Length.millimetres((inches * millimetresPerInch).round());

  factory Length.inUnit(num value, LengthUnit unit) => switch (unit) {
    LengthUnit.cm => Length.cm(value),
    LengthUnit.inches => Length.inches(value),
  };

  double get inCm => millimetres / 10;

  double get inInches => millimetres / millimetresPerInch;

  double toUnit(LengthUnit unit) => switch (unit) {
    LengthUnit.cm => inCm,
    LengthUnit.inches => inInches,
  };

  Length operator +(Length other) =>
      Length.millimetres(millimetres + other.millimetres);

  Length operator -(Length other) =>
      Length.millimetres(millimetres - other.millimetres);

  bool operator <(Length other) => millimetres < other.millimetres;

  bool operator >(Length other) => millimetres > other.millimetres;

  @override
  int compareTo(Length other) => millimetres.compareTo(other.millimetres);

  @override
  bool operator ==(Object other) =>
      other is Length && other.millimetres == millimetres;

  @override
  int get hashCode => millimetres.hashCode;

  @override
  String toString() => 'Length(${millimetres}mm)';
}

enum LengthUnit {
  cm('cm'),
  inches('in');

  const LengthUnit(this.symbol);

  final String symbol;
}
