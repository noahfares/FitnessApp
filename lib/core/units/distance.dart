/// Travelled distance, stored canonically as whole metres.
///
/// Cardio entries only (F-CAT-002 `distanceTime`). Pure Dart.
/// See docs/22-UNITS.md.
class Distance implements Comparable<Distance> {
  const Distance.metres(this.metres);

  /// Exact international definition of the statute mile.
  static const double metresPerMile = 1609.344;

  static const Distance zero = Distance.metres(0);

  final int metres;

  factory Distance.km(num km) => Distance.metres((km * 1000).round());

  factory Distance.miles(num miles) =>
      Distance.metres((miles * metresPerMile).round());

  factory Distance.inUnit(num value, DistanceUnit unit) => switch (unit) {
    DistanceUnit.km => Distance.km(value),
    DistanceUnit.miles => Distance.miles(value),
  };

  double get inKm => metres / 1000;

  double get inMiles => metres / metresPerMile;

  double toUnit(DistanceUnit unit) => switch (unit) {
    DistanceUnit.km => inKm,
    DistanceUnit.miles => inMiles,
  };

  Distance operator +(Distance other) => Distance.metres(metres + other.metres);

  Distance operator -(Distance other) => Distance.metres(metres - other.metres);

  bool operator <(Distance other) => metres < other.metres;

  bool operator >(Distance other) => metres > other.metres;

  @override
  int compareTo(Distance other) => metres.compareTo(other.metres);

  @override
  bool operator ==(Object other) => other is Distance && other.metres == metres;

  @override
  int get hashCode => metres.hashCode;

  @override
  String toString() => 'Distance(${metres}m)';
}

enum DistanceUnit {
  km('km'),
  miles('mi');

  const DistanceUnit(this.symbol);

  final String symbol;
}
