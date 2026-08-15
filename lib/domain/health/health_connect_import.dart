/// Deciding which Health Connect bodyweight readings to import (`F-HLT-002`).
///
/// A manual entry always wins: if the user has already logged their own
/// bodyweight for a local calendar day, an incoming Health Connect reading
/// for that same day is skipped rather than added alongside it or replacing
/// it — a background sync should never appear to second-guess something the
/// user typed in themselves.
library;

/// True if [candidateLocalDate] has no manually-entered measurement yet.
///
/// [manuallyMeasuredLocalDates] is every local calendar date that already
/// has a measurement whose `health_connect_record_id` is null, i.e. one the
/// user entered by hand — never a date that only has a previously-imported
/// Health Connect reading. Both sides are normalised to midnight internally,
/// so callers may pass either a bare date or a full timestamp.
///
/// Deliberately does not consider dates that only have earlier Health
/// Connect imports: re-importing the exact same reading twice is prevented
/// separately, by its own UUID dedup — a different check for a different
/// failure mode.
bool shouldImportHealthConnectReading({
  required DateTime candidateLocalDate,
  required Set<DateTime> manuallyMeasuredLocalDates,
}) {
  final normalized = _atMidnight(candidateLocalDate);
  final manualDates = manuallyMeasuredLocalDates.map(_atMidnight).toSet();
  return !manualDates.contains(normalized);
}

DateTime _atMidnight(DateTime date) =>
    DateTime(date.year, date.month, date.day);
