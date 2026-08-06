/// Rendering set values and ghosts (`F-LOG-003`, `F-LOG-004` §3).
///
/// One place, because the ghost and the entered value must read as the same
/// quantity in the same unit — a ghost that rounds differently from the field
/// below it looks like a different number.
library;

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/units/distance.dart';
import '../../../core/units/mass.dart';
import '../../../core/units/unit_preferences.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/set_repository.dart';
import '../../../domain/logging/duration_entry.dart';
import '../../../domain/logging/set_fields.dart';

/// Column header text. Weight and distance carry the unit here so the values
/// themselves do not: screen space in the set row is the scarcest resource in
/// the app (docs/22-UNITS.md §display-rules).
String fieldHeader(SetField field, UnitPreferences prefs) =>
    switch (field) {
      SetField.weight => prefs.load.symbol,
      SetField.reps => 'Reps',
      SetField.distance => prefs.distance.symbol,
      SetField.duration => 'Time',
    };

/// The stored value of [field], or null when the set has none yet.
String? formatSetField(
  WorkoutSet set,
  SetField field,
  QuantityFormatter formatter,
  UnitPreferences prefs,
) => switch (field) {
  SetField.weight => set.weightGrams == null
      ? null
      : formatter.setWeight(Mass.grams(set.weightGrams!)),
  SetField.reps => set.reps?.toString(),
  SetField.distance => set.distanceMetres == null
      ? null
      : formatter.distance(Distance.metres(set.distanceMetres!),
          showUnit: false),
  SetField.duration => set.durationSeconds == null
      ? null
      : formatDurationSeconds(set.durationSeconds!),
};

/// The same, for a ghost.
String? formatGhostField(
  GhostSet ghost,
  SetField field,
  QuantityFormatter formatter,
  UnitPreferences prefs,
) => switch (field) {
  SetField.weight => ghost.weightGrams == null
      ? null
      : formatter.setWeight(Mass.grams(ghost.weightGrams!)),
  SetField.reps => ghost.reps?.toString(),
  SetField.distance => ghost.distanceMetres == null
      ? null
      : formatter.distance(Distance.metres(ghost.distanceMetres!),
          showUnit: false),
  SetField.duration => ghost.durationSeconds == null
      ? null
      : formatDurationSeconds(ghost.durationSeconds!),
};

/// Last time, as one line: `100 kg × 8` (`F-LOG-004` §3).
///
/// The unit *is* shown here, unlike in the input columns, because the ghost has
/// no column header of its own to carry it.
String? formatGhostSummary(
  GhostSet ghost,
  List<SetField> fields,
  QuantityFormatter formatter,
  UnitPreferences prefs,
) {
  final parts = <String>[];
  for (final field in fields) {
    final text = formatGhostField(ghost, field, formatter, prefs);
    if (text == null) continue;
    parts.add(switch (field) {
      SetField.weight => '$text ${prefs.load.symbol}',
      SetField.distance => '$text ${prefs.distance.symbol}',
      _ => text,
    });
  }
  return parts.isEmpty ? null : parts.join(' × ');
}
