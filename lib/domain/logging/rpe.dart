/// RPE and RIR (`F-LOG-014`).
///
/// Pure Dart. Canonical storage is always RPE (`sets.rpe`) — RIR is a display
/// transform of it, never a second stored value, so the two can never disagree
/// about what actually happened on the set.
library;

/// Which scale a set's difficulty is shown in. Stored as a preference, never
/// per set — a session does not switch scales mid-way (`F-LOG-014` §2).
enum RpeDisplayMode { rpe, rir }

/// The only valid values, 6.0–10.0 in 0.5 steps (`F-LOG-014` §1). Below 6 is
/// rare enough to not be worth logging, and RPE tops out at 10 by definition.
const List<double> rpeSteps = [6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0];

/// RIR = 10 − RPE (`F-LOG-014` §2). Its own inverse: converting twice returns
/// the original value exactly, since both scales share the same 0.5 step.
double rpeToRir(double rpe) => 10 - rpe;

/// The value to show for a stored [rpe] in [mode], or null when nothing has
/// been logged.
double? displayRpe(double? rpe, RpeDisplayMode mode) {
  if (rpe == null) return null;
  return mode == RpeDisplayMode.rpe ? rpe : rpeToRir(rpe);
}

/// `8.5` → `"8.5"`, `9.0` → `"9"` — trailing `.0` stripped the same way set
/// weights are (docs/22-UNITS.md §display-rules): a whole RPE showing `9.0`
/// reads as more precise than a value picked from nine fixed steps actually is.
String formatRpeValue(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

/// Whether the app is currently interested in RPE at all (`F-LOG-014` §3).
/// The stored value itself is untouched by this — turning the setting off
/// hides the column, it never clears logged data.
class RpeSettings {
  const RpeSettings({
    this.enabled = false,
    this.displayMode = RpeDisplayMode.rpe,
  });

  /// Off by default: most users don't want it, and the set row has no room to
  /// spare for a column nobody asked for (`F-LOG-014` §3).
  final bool enabled;
  final RpeDisplayMode displayMode;

  RpeSettings copyWith({bool? enabled, RpeDisplayMode? displayMode}) =>
      RpeSettings(
        enabled: enabled ?? this.enabled,
        displayMode: displayMode ?? this.displayMode,
      );

  @override
  bool operator ==(Object other) =>
      other is RpeSettings &&
      other.enabled == enabled &&
      other.displayMode == displayMode;

  @override
  int get hashCode => Object.hash(enabled, displayMode);
}
