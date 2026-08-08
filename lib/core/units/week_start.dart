/// The first day of the week (`F-SET-005`).
///
/// Pure Dart — no Flutter, no persistence. Loading and saving lives in
/// `lib/features/settings/application/`, same split as [UnitPreferences].
class WeekStart {
  const WeekStart(this.weekday);

  /// ISO weekday: Monday = 1 … Sunday = 7, matching `DateTime.weekday`.
  final int weekday;

  static const WeekStart monday = WeekStart(DateTime.monday);
  static const WeekStart saturday = WeekStart(DateTime.saturday);
  static const WeekStart sunday = WeekStart(DateTime.sunday);

  /// Country codes whose calendars conventionally start the week on Saturday.
  static const Set<String> _saturdayCountries = {'EG', 'SA', 'AE', 'QA'};

  /// Countries that start on Sunday. Most of the rest of the world starts on
  /// Monday (ISO 8601), which is the fallback.
  static const Set<String> _sundayCountries = {
    'US',
    'CA',
    'MX',
    'BR',
    'JP',
    'KR',
    'PH',
    'ZA',
  };

  /// First-run default inferred from the device locale, then never touched
  /// again — same reasoning as `UnitPreferences.forCountry`.
  factory WeekStart.forCountry(String? countryCode) {
    if (countryCode == null) return monday;
    final code = countryCode.toUpperCase();
    if (_saturdayCountries.contains(code)) return saturday;
    if (_sundayCountries.contains(code)) return sunday;
    return monday;
  }

  /// The start of [date]'s week — the most recent date on or before it whose
  /// weekday matches [weekday]. Time-of-day is discarded.
  DateTime weekStartFor(DateTime date) {
    final midnight = DateTime(date.year, date.month, date.day);
    final diff = (midnight.weekday - weekday) % 7;
    return midnight.subtract(Duration(days: diff));
  }

  @override
  bool operator ==(Object other) =>
      other is WeekStart && other.weekday == weekday;

  @override
  int get hashCode => weekday.hashCode;
}
