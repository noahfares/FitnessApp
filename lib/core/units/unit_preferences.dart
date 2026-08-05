import 'distance.dart';
import 'length.dart';
import 'mass.dart';

/// The user's display-unit choices (F-SET-001).
///
/// **Display-only.** Changing any of these never migrates or rewrites stored
/// data and is instantly reversible — that is the whole payoff of canonical
/// storage (ADR-0003).
///
/// Four settings rather than one "metric/imperial" switch, because real users
/// mix them: lifting in kilograms while weighing in pounds is common in the UK,
/// and the reverse happens in the US among lifters training to international
/// standards.
///
/// Pure Dart — no Flutter, no persistence. Loading and saving lives in
/// `lib/features/settings/application/`.
class UnitPreferences {
  const UnitPreferences({
    this.load = MassUnit.kg,
    this.body = MassUnit.kg,
    this.length = LengthUnit.cm,
    this.distance = DistanceUnit.km,
  });

  /// Metric everywhere. The default when the locale tells us nothing useful.
  static const UnitPreferences metric = UnitPreferences();

  static const UnitPreferences imperial = UnitPreferences(
    load: MassUnit.lb,
    body: MassUnit.lb,
    length: LengthUnit.inches,
    distance: DistanceUnit.miles,
  );

  /// Country codes that use imperial units by default.
  ///
  /// The US, Liberia and Myanmar. The UK is deliberately absent: it is metric
  /// for barbell loading — plates are sold in kilograms — even though
  /// bodyweight is often spoken in stone. Stone is not offered at all; it is a
  /// display unit nobody enters weights in.
  static const Set<String> _imperialCountries = {'US', 'LR', 'MM'};

  /// Weights on sets, targets, plates and bars.
  final MassUnit load;

  /// Bodyweight and mass measurements.
  final MassUnit body;

  /// Circumference measurements.
  final LengthUnit length;

  /// Cardio distance.
  final DistanceUnit distance;

  /// First-run defaults inferred from the device locale, then never touched
  /// again — a later locale change must not silently alter someone's settings.
  ///
  /// [countryCode] is the region subtag of the device locale, e.g. `US` in
  /// `en_US`. Null or unrecognised means metric.
  factory UnitPreferences.forCountry(String? countryCode) {
    if (countryCode == null) return metric;
    return _imperialCountries.contains(countryCode.toUpperCase())
        ? imperial
        : metric;
  }

  UnitPreferences copyWith({
    MassUnit? load,
    MassUnit? body,
    LengthUnit? length,
    DistanceUnit? distance,
  }) => UnitPreferences(
    load: load ?? this.load,
    body: body ?? this.body,
    length: length ?? this.length,
    distance: distance ?? this.distance,
  );

  @override
  bool operator ==(Object other) =>
      other is UnitPreferences &&
      other.load == load &&
      other.body == body &&
      other.length == length &&
      other.distance == distance;

  @override
  int get hashCode => Object.hash(load, body, length, distance);

  @override
  String toString() =>
      'UnitPreferences(load: ${load.symbol}, body: ${body.symbol}, '
      'length: ${length.symbol}, distance: ${distance.symbol})';
}
