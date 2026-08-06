/// Formatting a routine target's rep range (`F-ROU-003`).
///
/// A range is the point — 8-12, not a single number — so a single value is
/// only ever the result of `min == max`, never a modelling shortcut.
///
/// Pure Dart.
library;

/// Renders `min`/`max` as `"8–12"`, or `"8"` when they coincide or only one
/// side is set. Empty when neither is set — targets are optional throughout
/// (`F-ROU-003` §3).
String formatRepRange(int? min, int? max) {
  if (min == null && max == null) return '';
  if (min == null) return '$max';
  if (max == null) return '$min';
  if (min == max) return '$min';
  return '$min–$max';
}
