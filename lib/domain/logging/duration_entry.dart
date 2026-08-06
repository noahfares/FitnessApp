/// Typing and displaying a duration (`F-LOG-006`).
///
/// Pure Dart.
library;

/// Reads keypad digits as a stopwatch does: the last two are seconds, whatever
/// precedes them is minutes. `130` is 1:30, `45` is 0:45, `10000` is 1:00:00.
///
/// The alternative — typing a raw number of seconds — asks people to divide by
/// sixty mid-set. Every gym timer in existence works this way, so the input
/// pattern is already learned.
///
/// Returns null for empty or non-numeric input. Seconds above 59 are accepted
/// as typed (`175` is 1:75, i.e. 135 s) rather than rejected mid-entry: the
/// digits are still being typed and refusing a prefix makes the keypad feel
/// broken.
int? secondsFromDigits(String digits) {
  if (digits.isEmpty) return null;
  if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return null;

  final trimmed = digits.length > 6 ? digits.substring(0, 6) : digits;
  if (trimmed.length <= 2) return int.parse(trimmed);

  final seconds = int.parse(trimmed.substring(trimmed.length - 2));
  final minutes = int.parse(trimmed.substring(0, trimmed.length - 2));
  return minutes * 60 + seconds;
}

/// The digits that would produce [seconds], for seeding the keypad from a
/// stored value.
String digitsFromSeconds(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  if (minutes == 0) return '$remainder';
  return '$minutes${remainder.toString().padLeft(2, '0')}';
}

/// `mm:ss` below an hour, `h:mm:ss` above it.
String formatDurationSeconds(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final hours = safe ~/ 3600;
  final minutes = (safe ~/ 60).remainder(60).toString().padLeft(2, '0');
  final secs = safe.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
}
