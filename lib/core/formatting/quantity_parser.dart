import 'package:intl/intl.dart';

import '../units/distance.dart';
import '../units/length.dart';
import '../units/mass.dart';

/// Turns typed text into canonical quantities (F-I18N-002).
///
/// The counterpart to `QuantityFormatter`, and the only other place that knows
/// what a pound is.
///
/// **Editing writes what the user typed.** Parsed once, from their display
/// unit, straight to canonical — never via a formatted intermediate, which
/// would drift (docs/22-UNITS.md).
///
/// Decimal separators follow the locale, but leniently: a US user who types
/// `102,5` means 102.5, and refusing that is a bug, not correctness. This is an
/// input-correctness concern, not localisation polish, which is why it lands in
/// Phase 0 rather than with the rest of i18n.
///
/// Pure Dart.
class QuantityParser {
  const QuantityParser({this.locale});

  final String? locale;

  /// Parses a number, returning null if the input is not a valid one.
  ///
  /// Handles both `,` and `.` as the decimal separator, disambiguating against
  /// the locale's own conventions:
  ///
  /// | Input     | en_US   | de_DE   | Why |
  /// |-----------|---------|---------|-----|
  /// | `102.5`   | 102.5   | 102.5   | `.` is decimal in en_US; lenient in de_DE |
  /// | `102,5`   | 102.5   | 102.5   | lenient in en_US; decimal in de_DE |
  /// | `1,234`   | 1234    | 1.234   | group separator followed by exactly 3 digits |
  /// | `1.234`   | 1.234   | 1234    | mirror image of the above |
  /// | `1,234.5` | 1234.5  | 1234.5  | last separator wins as decimal |
  double? parseNumber(String input) {
    var text = input.trim().replaceAll(RegExp(r'\s'), '');
    if (text.isEmpty) return null;

    var negative = false;
    if (text.startsWith('-')) {
      negative = true;
      text = text.substring(1);
    } else if (text.startsWith('+')) {
      text = text.substring(1);
    }
    if (text.isEmpty) return null;

    // Anything that is not a digit or a separator is a rejection, not something
    // to strip. Silently discarding characters is how "10O" becomes 10.
    if (!RegExp(r'^[0-9.,]+$').hasMatch(text)) return null;

    final symbols = NumberFormat.decimalPattern(locale).symbols;
    final decimalSep = symbols.DECIMAL_SEP;
    final groupSep = symbols.GROUP_SEP;

    final separatorPositions = <int>[
      for (var i = 0; i < text.length; i++)
        if (text[i] == ',' || text[i] == '.') i,
    ];

    String normalised;
    if (separatorPositions.isEmpty) {
      normalised = text;
    } else {
      final lastIndex = separatorPositions.last;
      final lastChar = text[lastIndex];
      final digitsAfter = text.length - lastIndex - 1;

      // Is the final separator a decimal point, or grouping?
      final bool lastIsDecimal;
      if (separatorPositions.length > 1 && lastChar != decimalSep) {
        // Repeated identical separators can only be grouping: "1.234.567".
        lastIsDecimal = false;
      } else if (lastChar == decimalSep) {
        lastIsDecimal = true;
      } else if (lastChar == groupSep) {
        // The locale's group separator reads as grouping only in its canonical
        // shape — exactly three trailing digits. "1,234" is 1234; "102,5" is
        // someone typing a decimal with the wrong key, and means 102.5.
        lastIsDecimal = digitsAfter != 3;
      } else {
        lastIsDecimal = true;
      }

      if (digitsAfter == 0) return null; // trailing separator: "102."

      if (lastIsDecimal) {
        final wholePart = text.substring(0, lastIndex);
        final fractionPart = text.substring(lastIndex + 1);
        // Anything left in the whole part must be valid grouping. Without this
        // check "1.2.3" would parse as 12.3 rather than being rejected.
        final ungrouped = _stripGrouping(wholePart, groupSep);
        if (ungrouped == null) return null;
        normalised = '$ungrouped.$fractionPart';
      } else {
        final ungrouped = _stripGrouping(text, groupSep);
        if (ungrouped == null) return null;
        normalised = ungrouped;
      }
    }

    if (normalised.isEmpty || normalised == '.') return null;
    final value = double.tryParse(normalised);
    if (value == null) return null;
    return negative ? -value : value;
  }

  /// Removes grouping separators, returning null if [text] is not validly
  /// grouped.
  ///
  /// Valid grouping means: only the locale's group separator appears, the first
  /// group is 1-3 digits, and every later group is exactly 3. So `1,234,567`
  /// passes and `1.2.3`, `1,23,456` and `1,2345` do not.
  static String? _stripGrouping(String text, String groupSep) {
    if (text.isEmpty) return text;
    final other = groupSep == ',' ? '.' : ',';
    if (text.contains(other)) return null;
    if (!text.contains(groupSep)) return text;

    final groups = text.split(groupSep);
    if (groups.first.isEmpty || groups.first.length > 3) return null;
    for (final group in groups.skip(1)) {
      if (group.length != 3) return null;
    }
    return groups.join();
  }

  /// Parses text typed in [unit] into canonical grams.
  Mass? parseMass(String input, MassUnit unit) {
    final value = parseNumber(input);
    return value == null ? null : Mass.inUnit(value, unit);
  }

  Length? parseLength(String input, LengthUnit unit) {
    final value = parseNumber(input);
    return value == null ? null : Length.inUnit(value, unit);
  }

  Distance? parseDistance(String input, DistanceUnit unit) {
    final value = parseNumber(input);
    return value == null ? null : Distance.inUnit(value, unit);
  }
}
