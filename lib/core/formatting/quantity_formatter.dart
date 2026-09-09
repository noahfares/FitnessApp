import 'package:intl/intl.dart';

import '../units/distance.dart';
import '../units/length.dart';
import '../units/mass.dart';
import '../units/unit_preferences.dart';

/// Turns canonical quantities into display text (F-I18N-002).
///
/// One of only two places in the app that knows what a pound is — the other is
/// `QuantityParser`. Everything between them works in canonical integers.
///
/// **Display rounding never writes back.** These strings are for reading only;
/// the stored gram value stays authoritative. Formatting `100 kg` as `220.5 lb`
/// and storing the round-trip of that would drift the value on every edit.
/// See docs/22-UNITS.md.
///
/// Pure Dart — `intl` has no Flutter dependency.
class QuantityFormatter {
  const QuantityFormatter({required this.prefs, this.locale});

  final UnitPreferences prefs;

  /// Locale name, e.g. `en_US`. Null uses `intl`'s current default.
  final String? locale;

  /// Set-row weight: one decimal, trailing `.0` stripped, ungrouped.
  ///
  /// Ungrouped because the set row is the most contested space in the app and
  /// `1000` is narrower than `1,000`. The unit is normally carried by the
  /// column header, hence [showUnit] defaulting to false.
  String setWeight(Mass mass, {bool showUnit = false}) => _mass(
    mass,
    prefs.load,
    maxDecimals: 1,
    grouped: false,
    showUnit: showUnit,
  );

  /// Bodyweight: one decimal, in the independently configured body unit.
  String bodyweight(Mass mass, {bool showUnit = true}) => _mass(
    mass,
    prefs.body,
    maxDecimals: 1,
    grouped: true,
    showUnit: showUnit,
  );

  /// Volume load total: no decimals, thousands separated — `12,480 kg`.
  /// Decimals on a five-figure total are noise.
  String volume(Mass mass, {bool showUnit = true}) => _mass(
    mass,
    prefs.load,
    maxDecimals: 0,
    grouped: true,
    showUnit: showUnit,
  );

  /// A single set's volume load, rounded to the nearest whole unit — the
  /// numeric twin of [volume]'s `maxDecimals: 0`, but an `int` rather than a
  /// grouped string so a live display (`F-LOG-024`) can animate digit by
  /// digit instead of diffing text.
  int volumeWholeUnits(Mass mass) => mass.toUnit(prefs.load).round();

  /// Estimated 1RM: one decimal.
  String e1rm(Mass mass, {bool showUnit = true}) => _mass(
    mass,
    prefs.load,
    maxDecimals: 1,
    grouped: true,
    showUnit: showUnit,
  );

  /// Circumference: one decimal in centimetres, two in inches.
  ///
  /// Inches take the extra digit because an inch is 2.54 centimetres, so one
  /// decimal there would be coarser than the metric equivalent.
  String circumference(Length length, {bool showUnit = true}) {
    final decimals = prefs.length == LengthUnit.cm ? 1 : 2;
    final text = _number(
      length.toUnit(prefs.length),
      maxDecimals: decimals,
      grouped: false,
    );
    return showUnit ? '$text ${prefs.length.symbol}' : text;
  }

  /// A percentage stored as basis points (`docs/22-UNITS.md`) — one decimal,
  /// e.g. body-fat `1850` basis points formats as `18.5%`.
  String percent(int basisPoints, {bool showUnit = true}) {
    final text = _number(basisPoints / 100, maxDecimals: 1, grouped: false);
    return showUnit ? '$text%' : text;
  }

  /// Travelled distance: two decimals.
  String distance(Distance distance, {bool showUnit = true}) {
    final text = _number(
      distance.toUnit(prefs.distance),
      maxDecimals: 2,
      grouped: true,
    );
    return showUnit ? '$text ${prefs.distance.symbol}' : text;
  }

  /// Bare number in an explicit unit, ungrouped, no suffix.
  ///
  /// For editable text fields: the output must round-trip back through
  /// `QuantityParser` unchanged, so grouping separators are omitted.
  String massValueOnly(Mass mass, MassUnit unit, {int maxDecimals = 1}) =>
      _number(mass.toUnit(unit), maxDecimals: maxDecimals, grouped: false);

  String _mass(
    Mass mass,
    MassUnit unit, {
    required int maxDecimals,
    required bool grouped,
    required bool showUnit,
  }) {
    final text = _number(
      mass.toUnit(unit),
      maxDecimals: maxDecimals,
      grouped: grouped,
    );
    return showUnit ? '$text ${unit.symbol}' : text;
  }

  String _number(
    double value, {
    required int maxDecimals,
    required bool grouped,
  }) {
    final format = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = maxDecimals;
    if (!grouped) format.turnOffGrouping();
    return format.format(value);
  }
}
